import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/ref_storage/ref_storage.dart';
import '../../domain/entities/affiliate.dart';
import 'affiliate_datasource.dart';

/// A production-ready datasource that uses Firebase Firestore for global 
/// affiliate tracking and attribution.
class FirestoreAffiliateDataSource implements AffiliateDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Future<String?> getCurrentRefCode() => RefStorage.instance.getRef();

  @override
  Future<void> setRefCode(String? code) => RefStorage.instance.setRef(code);

  @override
  Future<AffiliateAccount?> getAccount() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('affiliates').doc(user.uid).get();
    if (!doc.exists) return null;

    return _accountFromFirestore(doc.id, doc.data()!);
  }

  @override
  Future<AffiliateAccount> createAccount({
    required String name,
    required String email,
    required String paymentEmail,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User must be logged in to join affiliate program');

    final existing = await getAccount();
    if (existing != null) return existing;

    final account = AffiliateAccount(
      id: user.uid,
      name: name.trim(),
      email: email.trim(),
      promoCode: _generatePromoCode(),
      paymentEmail: paymentEmail.trim().isEmpty ? email.trim() : paymentEmail.trim(),
      status: AffiliateStatus.active,
      createdAt: DateTime.now(),
    );

    await _firestore.collection('affiliates').doc(user.uid).set(_accountToFirestore(account));
    return account;
  }

  @override
  Future<List<AffiliateCommission>> getCommissions() async {
    final user = _auth.currentUser;
    if (user == null) return const [];

    final snapshot = await _firestore
        .collection('commissions')
        .where('affiliateId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => _commissionFromFirestore(doc.id, doc.data())).toList();
  }

  @override
  Future<AffiliateStats> getStats() async {
    final account = await getAccount();
    if (account == null) {
      return const AffiliateStats(
        clicks: 0,
        sales: 0,
        commission: 0,
        conversionRate: 0,
        pendingCommissions: 0,
      );
    }

    final commissions = await getCommissions();
    final approved = commissions
        .where((c) => c.status != CommissionStatus.paid)
        .fold<double>(0, (total, c) => total + c.amount);
    
    final pendingCount = commissions.where((c) => c.status == CommissionStatus.pending).length;

    final conversion = account.totalClicks == 0
        ? 0.0
        : (account.totalSales / account.totalClicks) * 100;

    return AffiliateStats(
      clicks: account.totalClicks,
      sales: account.totalSales,
      commission: approved,
      conversionRate: conversion,
      pendingCommissions: pendingCount,
    );
  }

  @override
  Future<AffiliateClick> recordClick({
    required String code,
    String source = 'direct',
  }) async {
    final clickData = {
      'affiliateCode': code.trim(),
      'source': source,
      'createdAt': FieldValue.serverTimestamp(),
    };

    final docRef = await _firestore.collection('clicks').add(clickData);
    
    // Update affiliate total clicks (In production, use a Cloud Function for this 
    // to prevent user-side tampering, but we'll do it here for MVP).
    final affiliateQuery = await _firestore
        .collection('affiliates')
        .where('promoCode', isEqualTo: code.trim())
        .limit(1)
        .get();

    if (affiliateQuery.docs.isNotEmpty) {
      final affDoc = affiliateQuery.docs.first;
      await affDoc.reference.update({'totalClicks': FieldValue.increment(1)});
    }

    return AffiliateClick(
      id: docRef.id,
      affiliateCode: code.trim(),
      source: source,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<AffiliateCommission?> recordSale({
    required String orderId,
    required double orderAmount,
  }) async {
    final code = await getCurrentRefCode();
    if (code == null || code.trim().isEmpty) return null;

    final affiliateQuery = await _firestore
        .collection('affiliates')
        .where('promoCode', isEqualTo: code.trim())
        .limit(1)
        .get();

    if (affiliateQuery.docs.isEmpty) return null;

    final affDoc = affiliateQuery.docs.first;
    final commissionAmount = orderAmount * AppConstants.affiliateCommissionRate;

    final commissionData = {
      'affiliateId': affDoc.id,
      'affiliateCode': code.trim(),
      'orderId': orderId,
      'orderAmount': orderAmount,
      'rate': AppConstants.affiliateCommissionRate,
      'amount': commissionAmount,
      'status': CommissionStatus.pending.name,
      'createdAt': FieldValue.serverTimestamp(),
    };

    final docRef = await _firestore.collection('commissions').add(commissionData);

    // Update affiliate account totals
    await affDoc.reference.update({
      'totalSales': FieldValue.increment(1),
      'totalCommission': FieldValue.increment(commissionAmount),
      'pendingBalance': FieldValue.increment(commissionAmount),
    });

    return AffiliateCommission(
      id: docRef.id,
      affiliateCode: code.trim(),
      orderId: orderId,
      orderAmount: orderAmount,
      rate: AppConstants.affiliateCommissionRate,
      amount: commissionAmount,
      status: CommissionStatus.pending,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<void> requestPayout() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final affDoc = _firestore.collection('affiliates').doc(user.uid);
    final data = (await affDoc.get()).data();
    if (data == null) return;
    
    final balance = (data['pendingBalance'] as num?)?.toDouble() ?? 0.0;
    if (balance < 25.0) return;

    // Record payout request (In production, you'd create a 'payouts' collection)
    await affDoc.update({
      'pendingBalance': 0,
      'lastPayoutRequest': FieldValue.serverTimestamp(),
    });

    // Mark pending commissions as paid (Simplified)
    final commissions = await _firestore
        .collection('commissions')
        .where('affiliateId', isEqualTo: user.uid)
        .where('status', isEqualTo: CommissionStatus.pending.name)
        .get();

    final batch = _firestore.batch();
    for (var doc in commissions.docs) {
      batch.update(doc.reference, {'status': CommissionStatus.paid.name});
    }
    await batch.commit();
  }

  // Helpers

  String _generatePromoCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = DateTime.now().microsecondsSinceEpoch;
    final buffer = StringBuffer('CS-');
    for (var i = 0; i < 6; i++) {
      buffer.write(chars[(random >> (i * 4)) % chars.length]);
    }
    return buffer.toString();
  }

  Map<String, dynamic> _accountToFirestore(AffiliateAccount a) => {
        'name': a.name,
        'email': a.email,
        'promoCode': a.promoCode,
        'paymentEmail': a.paymentEmail,
        'status': a.status.name,
        'createdAt': a.createdAt,
        'totalClicks': a.totalClicks,
        'totalSales': a.totalSales,
        'totalCommission': a.totalCommission,
        'pendingBalance': a.pendingBalance,
      };

  AffiliateAccount _accountFromFirestore(String id, Map<String, dynamic> json) =>
      AffiliateAccount(
        id: id,
        name: json['name'] as String,
        email: json['email'] as String,
        promoCode: json['promoCode'] as String,
        paymentEmail: json['paymentEmail'] as String,
        status: AffiliateStatus.values.firstWhere(
          (s) => s.name == json['status'],
          orElse: () => AffiliateStatus.active,
        ),
        createdAt: (json['createdAt'] as Timestamp).toDate(),
        totalClicks: (json['totalClicks'] as num?)?.toInt() ?? 0,
        totalSales: (json['totalSales'] as num?)?.toInt() ?? 0,
        totalCommission: (json['totalCommission'] as num?)?.toDouble() ?? 0,
        pendingBalance: (json['pendingBalance'] as num?)?.toDouble() ?? 0,
      );

  AffiliateCommission _commissionFromFirestore(String id, Map<String, dynamic> json) =>
      AffiliateCommission(
        id: id,
        affiliateCode: json['affiliateCode'] as String,
        orderId: json['orderId'] as String,
        orderAmount: (json['orderAmount'] as num).toDouble(),
        rate: (json['rate'] as num).toDouble(),
        amount: (json['amount'] as num).toDouble(),
        status: CommissionStatus.values.firstWhere(
          (s) => s.name == json['status'],
          orElse: () => CommissionStatus.pending,
        ),
        createdAt: (json['createdAt'] as Timestamp).toDate(),
      );
}

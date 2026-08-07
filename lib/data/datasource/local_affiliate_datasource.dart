import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/affiliate.dart';
import 'affiliate_datasource.dart';

class HiveAffiliateDataSource implements AffiliateDataSource {
  static const String _accountBox = 'affiliate_account_box';
  static const String _commissionBox = 'affiliate_commission_box';
  static const String _clickBox = 'affiliate_click_box';
  static const String _refBox = 'affiliate_ref_box';

  static const double _payoutThreshold = 25.0;

  @override
  Future<AffiliateAccount?> getAccount() async {
    final box = await Hive.openBox<String>(_accountBox);
    final raw = box.get('account');
    if (raw == null) {
      return null;
    }
    return _accountFromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<AffiliateAccount> createAccount({
    required String name,
    required String email,
    required String paymentEmail,
  }) async {
    final existing = await getAccount();
    if (existing != null) return existing;

    final account = AffiliateAccount(
      id: 'aff_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      email: email.trim(),
      promoCode: _generatePromoCode(),
      paymentEmail: paymentEmail.trim().isEmpty ? email.trim() : paymentEmail.trim(),
      status: AffiliateStatus.active,
      createdAt: DateTime.now(),
    );

    final box = await Hive.openBox<String>(_accountBox);
    await box.put('account', jsonEncode(_accountToJson(account)));
    return account;
  }

  @override
  Future<List<AffiliateCommission>> getCommissions() async {
    final box = await Hive.openBox<String>(_commissionBox);
    final raw = box.get('commissions');
    if (raw == null) {
      return const [];
    }
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => _commissionFromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
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
        .fold<double>(0, (sum, c) => sum + c.amount);
    final pendingCount =
        commissions.where((c) => c.status == CommissionStatus.pending).length;

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
  Future<String?> getCurrentRefCode() async {
    final box = await Hive.openBox<String>(_refBox);
    return box.get('ref');
  }

  @override
  Future<void> setRefCode(String? code) async {
    final box = await Hive.openBox<String>(_refBox);
    if (code == null) {
      await box.delete('ref');
    } else {
      await box.put('ref', code.trim());
    }
  }

  @override
  Future<AffiliateClick> recordClick({
    required String code,
    String source = 'direct',
  }) async {
    final click = AffiliateClick(
      id: 'clk_${DateTime.now().millisecondsSinceEpoch}',
      affiliateCode: code.trim(),
      source: source,
      createdAt: DateTime.now(),
    );

    final clickBox = await Hive.openBox<String>(_clickBox);
    final clicks = <Map<String, dynamic>>[];
    final raw = clickBox.get('clicks');
    if (raw != null) {
      clicks.addAll(
          (jsonDecode(raw) as List<dynamic>).cast<Map<String, dynamic>>());
    }
    clicks.add(_clickToJson(click));
    await clickBox.put('clicks', jsonEncode(clicks));

    final account = await _findAccountByCode(code.trim());
    if (account != null) {
      final box = await Hive.openBox<String>(_accountBox);
      await box.put(
        'account',
        jsonEncode(_accountToJson(
          account.copyWith(totalClicks: account.totalClicks + 1),
        )),
      );
    }

    return click;
  }

  @override
  Future<AffiliateCommission?> recordSale({
    required String orderId,
    required double orderAmount,
  }) async {
    final code = await getCurrentRefCode();
    if (code == null || code.trim().isEmpty) return null;

    final account = await _findAccountByCode(code.trim());
    if (account == null) return null;

    final commission = AffiliateCommission(
      id: 'com_${DateTime.now().millisecondsSinceEpoch}',
      affiliateCode: code.trim(),
      orderId: orderId,
      orderAmount: orderAmount,
      rate: AppConstants.affiliateCommissionRate,
      amount: orderAmount * AppConstants.affiliateCommissionRate,
      status: CommissionStatus.pending,
      createdAt: DateTime.now(),
    );

    final commissionBox = await Hive.openBox<String>(_commissionBox);
    final commissions = <Map<String, dynamic>>[];
    final raw = commissionBox.get('commissions');
    if (raw != null) {
      commissions.addAll(
          (jsonDecode(raw) as List<dynamic>).cast<Map<String, dynamic>>());
    }
    commissions.add(_commissionToJson(commission));
    await commissionBox.put('commissions', jsonEncode(commissions));

    final box = await Hive.openBox<String>(_accountBox);
    await box.put(
      'account',
      jsonEncode(_accountToJson(
        account.copyWith(
          totalSales: account.totalSales + 1,
          totalCommission: account.totalCommission + commission.amount,
          pendingBalance: account.pendingBalance + commission.amount,
        ),
      )),
    );

    return commission;
  }

  @override
  Future<void> requestPayout() async {
    final account = await getAccount();
    if (account == null || account.pendingBalance < _payoutThreshold) return;

    final box = await Hive.openBox<String>(_accountBox);
    await box.put(
      'account',
      jsonEncode(_accountToJson(
        account.copyWith(
          pendingBalance: 0,
          totalCommission: account.totalCommission,
        ),
      )),
    );

    final commissionBox = await Hive.openBox<String>(_commissionBox);
    final commissions = await getCommissions();
    final updated = commissions.map((c) {
      if (c.status == CommissionStatus.paid) return c;
      return AffiliateCommission(
        id: c.id,
        affiliateCode: c.affiliateCode,
        orderId: c.orderId,
        orderAmount: c.orderAmount,
        rate: c.rate,
        amount: c.amount,
        status: CommissionStatus.paid,
        createdAt: c.createdAt,
      );
    }).toList();
    await commissionBox.put(
      'commissions',
      jsonEncode(updated.map(_commissionToJson).toList()),
    );
  }

  Future<AffiliateAccount?> _findAccountByCode(String code) async {
    final account = await getAccount();
    if (account != null && account.promoCode == code) return account;
    return null;
  }

  String _generatePromoCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = DateTime.now().microsecondsSinceEpoch;
    final buffer = StringBuffer('CS-');
    for (var i = 0; i < 6; i++) {
      buffer.write(chars[(random >> (i * 4)) % chars.length]);
    }
    return buffer.toString();
  }

  Map<String, dynamic> _accountToJson(AffiliateAccount a) => {
        'id': a.id,
        'name': a.name,
        'email': a.email,
        'promoCode': a.promoCode,
        'paymentEmail': a.paymentEmail,
        'status': a.status.name,
        'createdAt': a.createdAt.toIso8601String(),
        'totalClicks': a.totalClicks,
        'totalSales': a.totalSales,
        'totalCommission': a.totalCommission,
        'pendingBalance': a.pendingBalance,
      };

  AffiliateAccount _accountFromJson(Map<String, dynamic> json) => AffiliateAccount(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        promoCode: json['promoCode'] as String,
        paymentEmail: json['paymentEmail'] as String,
        status: AffiliateStatus.values.firstWhere(
          (s) => s.name == json['status'],
          orElse: () => AffiliateStatus.active,
        ),
        createdAt: DateTime.parse(json['createdAt'] as String),
        totalClicks: (json['totalClicks'] as num?)?.toInt() ?? 0,
        totalSales: (json['totalSales'] as num?)?.toInt() ?? 0,
        totalCommission: (json['totalCommission'] as num?)?.toDouble() ?? 0,
        pendingBalance: (json['pendingBalance'] as num?)?.toDouble() ?? 0,
      );

  Map<String, dynamic> _commissionToJson(AffiliateCommission c) => {
        'id': c.id,
        'affiliateCode': c.affiliateCode,
        'orderId': c.orderId,
        'orderAmount': c.orderAmount,
        'rate': c.rate,
        'amount': c.amount,
        'status': c.status.name,
        'createdAt': c.createdAt.toIso8601String(),
      };

  AffiliateCommission _commissionFromJson(Map<String, dynamic> json) =>
      AffiliateCommission(
        id: json['id'] as String,
        affiliateCode: json['affiliateCode'] as String,
        orderId: json['orderId'] as String,
        orderAmount: (json['orderAmount'] as num).toDouble(),
        rate: (json['rate'] as num).toDouble(),
        amount: (json['amount'] as num).toDouble(),
        status: CommissionStatus.values.firstWhere(
          (s) => s.name == json['status'],
          orElse: () => CommissionStatus.pending,
        ),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  Map<String, dynamic> _clickToJson(AffiliateClick c) => {
        'id': c.id,
        'affiliateCode': c.affiliateCode,
        'source': c.source,
        'createdAt': c.createdAt.toIso8601String(),
      };
}

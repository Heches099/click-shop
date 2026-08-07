import 'dart:async';
import '../entities/affiliate.dart';
import '../repositories/affiliate_repository.dart';

class AffiliateUseCase {
  final AffiliateRepository repository;

  AffiliateUseCase(this.repository);

  Future<AffiliateAccount?> getAccount() async {
    final result = await repository.getAccount();
    return result.fold((failure) => null, (account) => account);
  }

  Future<AffiliateAccount?> createAccount({
    required String name,
    required String email,
    required String paymentEmail,
  }) async {
    final result = await repository.createAccount(
      name: name,
      email: email,
      paymentEmail: paymentEmail,
    );
    return result.fold((failure) => null, (account) => account);
  }

  Future<List<AffiliateCommission>> getCommissions() async {
    final result = await repository.getCommissions();
    return result.fold((failure) => <AffiliateCommission>[], (list) => list);
  }

  Future<AffiliateStats> getStats() async {
    final result = await repository.getStats();
    return result.fold(
      (failure) => const AffiliateStats(
        clicks: 0,
        sales: 0,
        commission: 0,
        conversionRate: 0,
        pendingCommissions: 0,
      ),
      (stats) => stats,
    );
  }

  Future<String?> getCurrentRefCode() async {
    final result = await repository.getCurrentRefCode();
    return result.fold((failure) => null, (code) => code);
  }

  Future<void> setRefCode(String? code) async {
    await repository.setRefCode(code);
  }

  Future<void> trackIncomingRef(String code) async {
    final result = await repository.setRefCode(code);
    result.fold((failure) {}, (_) {});
    if (code.trim().isEmpty) return;
    await repository.recordClick(code: code.trim(), source: 'direct');
  }

  Future<AffiliateCommission?> recordSale({
    required String orderId,
    required double orderAmount,
  }) async {
    final result = await repository.recordSale(
      orderId: orderId,
      orderAmount: orderAmount,
    );
    return result.fold((failure) => null, (commission) => commission);
  }

  Future<void> requestPayout() async {
    await repository.requestPayout();
  }

  Future<String> buildReferralLink(String code) async {
    final result = await repository.buildReferralLink(code);
    return result.fold((failure) => '', (link) => link);
  }
}

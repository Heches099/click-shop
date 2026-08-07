import '../../domain/entities/affiliate.dart';

abstract class AffiliateDataSource {
  Future<AffiliateAccount?> getAccount();

  Future<AffiliateAccount> createAccount({
    required String name,
    required String email,
    required String paymentEmail,
  });

  Future<List<AffiliateCommission>> getCommissions();

  Future<AffiliateStats> getStats();

  Future<String?> getCurrentRefCode();

  Future<void> setRefCode(String? code);

  Future<AffiliateClick> recordClick({
    required String code,
    String source,
  });

  Future<AffiliateCommission?> recordSale({
    required String orderId,
    required double orderAmount,
  });

  Future<void> requestPayout();
}

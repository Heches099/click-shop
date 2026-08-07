import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/affiliate.dart';

abstract class AffiliateRepository {
  Future<Either<Failure, AffiliateAccount?>> getAccount();

  Future<Either<Failure, AffiliateAccount>> createAccount({
    required String name,
    required String email,
    required String paymentEmail,
  });

  Future<Either<Failure, List<AffiliateCommission>>> getCommissions();

  Future<Either<Failure, AffiliateStats>> getStats();

  Future<Either<Failure, String?>> getCurrentRefCode();

  Future<Either<Failure, void>> setRefCode(String? code);

  Future<Either<Failure, AffiliateClick>> recordClick({
    required String code,
    String source,
  });

  Future<Either<Failure, AffiliateCommission?>> recordSale({
    required String orderId,
    required double orderAmount,
  });

  Future<Either<Failure, void>> requestPayout();

  Future<Either<Failure, String>> buildReferralLink(String code);
}

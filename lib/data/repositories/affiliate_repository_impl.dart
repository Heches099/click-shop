import 'package:dartz/dartz.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/affiliate.dart';
import '../../domain/repositories/affiliate_repository.dart';
import '../datasource/affiliate_datasource.dart';

class AffiliateRepositoryImpl implements AffiliateRepository {
  final AffiliateDataSource dataSource;

  AffiliateRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, AffiliateAccount?>> getAccount() async {
    try {
      return Right(await dataSource.getAccount());
    } catch (e) {
      return const Left(Failure.cacheError());
    }
  }

  @override
  Future<Either<Failure, AffiliateAccount>> createAccount({
    required String name,
    required String email,
    required String paymentEmail,
  }) async {
    try {
      if (name.trim().isEmpty || email.trim().isEmpty) {
        return const Left(Failure.validationError('Name and email are required'));
      }
      final account = await dataSource.createAccount(
        name: name,
        email: email,
        paymentEmail: paymentEmail,
      );
      return Right(account);
    } catch (e) {
      return const Left(Failure.cacheError());
    }
  }

  @override
  Future<Either<Failure, List<AffiliateCommission>>> getCommissions() async {
    try {
      return Right(await dataSource.getCommissions());
    } catch (e) {
      return const Left(Failure.cacheError());
    }
  }

  @override
  Future<Either<Failure, AffiliateStats>> getStats() async {
    try {
      return Right(await dataSource.getStats());
    } catch (e) {
      return const Left(Failure.cacheError());
    }
  }

  @override
  Future<Either<Failure, String?>> getCurrentRefCode() async {
    try {
      return Right(await dataSource.getCurrentRefCode());
    } catch (e) {
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, void>> setRefCode(String? code) async {
    try {
      await dataSource.setRefCode(code);
      return const Right(null);
    } catch (e) {
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, AffiliateClick>> recordClick({
    required String code,
    String source = 'direct',
  }) async {
    try {
      final click = await dataSource.recordClick(code: code, source: source);
      return Right(click);
    } catch (e) {
      return const Left(Failure.cacheError());
    }
  }

  @override
  Future<Either<Failure, AffiliateCommission?>> recordSale({
    required String orderId,
    required double orderAmount,
  }) async {
    try {
      final commission =
          await dataSource.recordSale(orderId: orderId, orderAmount: orderAmount);
      return Right(commission);
    } catch (e) {
      return const Left(Failure.cacheError());
    }
  }

  @override
  Future<Either<Failure, void>> requestPayout() async {
    try {
      await dataSource.requestPayout();
      return const Right(null);
    } catch (e) {
      return const Left(Failure.cacheError());
    }
  }

  @override
  Future<Either<Failure, String>> buildReferralLink(String code) async {
    return Right('${AppConstants.storeBaseUrl}?ref=$code');
  }
}

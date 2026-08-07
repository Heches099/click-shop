import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/service_locator.dart';
import '../../../domain/entities/affiliate.dart';
import '../../../domain/usecases/affiliate_usecase.dart';

final affiliateUseCaseProvider = Provider<AffiliateUseCase>((ref) {
  return sl<AffiliateUseCase>();
});

/// The signed-up affiliate account, or null if the user has not joined yet.
final affiliateAccountProvider =
    FutureProvider<AffiliateAccount?>((ref) async {
  return ref.watch(affiliateUseCaseProvider).getAccount();
});

final affiliateCommissionsProvider =
    FutureProvider<List<AffiliateCommission>>((ref) async {
  return ref.watch(affiliateUseCaseProvider).getCommissions();
});

final affiliateStatsProvider = FutureProvider<AffiliateStats>((ref) async {
  return ref.watch(affiliateUseCaseProvider).getStats();
});

/// Referral code captured from the current visitor's link (?ref=CODE).
final currentRefCodeProvider = FutureProvider<String?>((ref) async {
  return ref.watch(affiliateUseCaseProvider).getCurrentRefCode();
});

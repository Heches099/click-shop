import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../data/datasource/affiliate_datasource.dart';
import '../../data/datasource/auth_remote_datasource.dart';
import '../../data/datasource/local_affiliate_datasource.dart';
import '../../data/datasource/remote_affiliate_datasource.dart';
import '../../data/datasource/mock_auth_datasource.dart';
import '../../data/datasource/product_remote_datasource.dart';
import '../../data/repositories/affiliate_repository_impl.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/repositories/affiliate_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/usecases/affiliate_usecase.dart';
import '../../domain/usecases/auth_usecase.dart';
import '../../domain/usecases/product_usecase.dart';
import '../constants/app_constants.dart';
import '../network/dio_client.dart';
import '../network/network_info.dart';
import 'payments/payment_service.dart';
import 'analytics/analytics_service.dart';

final sl = GetIt.instance;

Future<void> initServiceLocator() async {
  // Core
  await Hive.initFlutter();
  
  sl.registerLazySingleton<Connectivity>(() => Connectivity());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  sl.registerLazySingleton<DioClient>(() => DioClient());
  sl.registerLazySingleton<Dio>(() => sl<DioClient>().dio);

  // Analytics
  sl.registerLazySingleton<AnalyticsService>(() => AnalyticsService());

  // Payments
  sl.registerLazySingleton<PaymentService>(
    () => AppConstants.useRemoteDataSource 
        ? StripePaymentService() 
        : MockPaymentService(),
  );

  // Auth (mock – no Firebase for now)
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => MockAuthRemoteDataSource(),
  );
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(sl()),
  );

  // Affiliate program
  sl.registerLazySingleton<AffiliateDataSource>(
    () => AppConstants.useRemoteDataSource 
        ? FirestoreAffiliateDataSource() 
        : HiveAffiliateDataSource(),
  );
  sl.registerLazySingleton<AffiliateRepository>(
    () => AffiliateRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => AffiliateUseCase(sl()));

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => ProductUseCase(sl()));
}

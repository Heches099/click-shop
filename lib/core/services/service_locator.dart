import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../data/datasource/affiliate_datasource.dart';
import '../../data/datasource/amazon_remote_datasource.dart';
import '../../data/datasource/auth_remote_datasource.dart';
import '../../data/datasource/local_cart_datasource.dart';
import '../../data/datasource/order_remote_datasource.dart';
import '../../data/datasource/product_remote_datasource.dart';
import '../../data/datasource/remote_affiliate_datasource.dart';
import '../../data/repositories/affiliate_repository_impl.dart';
import '../../data/repositories/amazon_repository_impl.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/cart_repository_impl.dart';
import '../../data/repositories/order_repository_impl.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/repositories/affiliate_repository.dart';
import '../../domain/repositories/amazon_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/usecases/affiliate_usecase.dart';
import '../../domain/usecases/amazon_usecase.dart';
import '../../domain/usecases/auth_usecase.dart';
import '../../domain/usecases/product_usecase.dart';
import '../../presentation/saved/data/saved_store.dart';
import '../constants/app_constants.dart';
import '../network/dio_client.dart';
import '../network/network_info.dart';
import '../network/token_storage.dart';
import 'payments/payment_service.dart';
import 'analytics/analytics_service.dart';

final sl = GetIt.instance;

Future<void> initServiceLocator() async {
  // Core
  await Hive.initFlutter();
  final tokenStorage = TokenStorage();
  await tokenStorage.open();
  final cartBox = await Hive.openBox<String>(AppConstants.cartBox);

  sl.registerLazySingleton<TokenStorage>(() => tokenStorage);
  sl.registerLazySingleton<Connectivity>(() => Connectivity());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  sl.registerLazySingleton<DioClient>(
    () => DioClient(tokenStorage: tokenStorage),
  );
  sl.registerLazySingleton<Dio>(() => sl<DioClient>().dio);

  // Analytics
  sl.registerLazySingleton<AnalyticsService>(() => AnalyticsService());

  // Payments
  sl.registerLazySingleton<PaymentService>(() => StripePaymentService());

  // Auth (Firebase)
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      FirebaseAuth.instance,
      GoogleSignIn.instance,
      sl<DioClient>(),
      sl<TokenStorage>(),
    ),
  );
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(sl()),
  );

  // Amazon Associates
  sl.registerLazySingleton<AmazonRemoteDataSource>(
    () => AmazonRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<AmazonRepository>(
    () => AmazonRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => AmazonUseCase(sl()));
  sl.registerLazySingleton(() => SavedStore());

  // Affiliate program
  sl.registerLazySingleton<AffiliateDataSource>(
    () => FirestoreAffiliateDataSource(),
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

  // Cart (persisted to Hive so page refreshes keep the bag).
  sl.registerLazySingleton<LocalCartDataSource>(
    () => HiveCartDataSource(cartBox),
  );
  sl.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(sl<LocalCartDataSource>()),
  );

  // Orders (backend), used by the checkout + payment flow.
  sl.registerLazySingleton<OrderRemoteDataSource>(
    () => OrderRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => GoogleSignInUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => ProductUseCase(sl()));
}

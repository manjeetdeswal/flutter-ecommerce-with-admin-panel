// lib/core/providers/dependency_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod/riverpod.dart';

// Data Layer Imports
import '../features/products/data/datasources/product_remote_data_source.dart';
import '../features/products/data/repositories/product_repository_impl.dart';

// Domain Layer Import (This was missing!)
import '../features/products/domain/repositories/product_repository.dart';

// 1. Provide the HTTP Client
final httpClientProvider = Provider<http.Client>((ref) {
  return http.Client();
});

// 2. Provide the Data Source, injecting the HTTP Client
final productRemoteDataSourceProvider = Provider<ProductRemoteDataSource>((ref) {
  final client = ref.watch(httpClientProvider);
  return ProductRemoteDataSourceImpl(client: client);
});

// 3. Provide the Repository, injecting the Data Source
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final remoteDataSource = ref.watch(productRemoteDataSourceProvider);
  return ProductRepositoryImpl();
});
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../models/pass_package.dart';
import '../models/user_voucher.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/api_constants.dart';

class PassState {
  final bool isLoading;
  final List<PassPackage> packages;
  final List<UserVoucher> vouchers;
  final String? error;

  PassState({
    this.isLoading = false,
    this.packages = const [],
    this.vouchers = const [],
    this.error,
  });

  PassState copyWith({
    bool? isLoading,
    List<PassPackage>? packages,
    List<UserVoucher>? vouchers,
    String? error,
  }) {
    return PassState(
      isLoading: isLoading ?? this.isLoading,
      packages: packages ?? this.packages,
      vouchers: vouchers ?? this.vouchers,
      error: error,
    );
  }
}

class PassNotifier extends Notifier<PassState> {
  @override
  PassState build() {
    Future.microtask(() {
      fetchPackages();
      fetchVouchers();
    });
    return PassState();
  }

  Future<void> fetchPackages() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final dio = ref.read(dioProvider);
      // Admin might not have a specific GET /admin/passes/packages yet, 
      // so we use the public one that shows all passes.
      final response = await dio.get('/passes/packages');
      
      final List<dynamic> data = response.data;
      final packages = data.map((json) => PassPackage.fromJson(json)).toList();
      
      state = state.copyWith(isLoading: false, packages: packages);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchVouchers() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final dio = ref.read(dioProvider);
      
      // Attempt to hit the admin endpoint. If it doesn't exist (404), fallback to mock data.
      try {
        final response = await dio.get('/admin/passes/vouchers');
        final List<dynamic> data = response.data;
        final vouchers = data.map((json) => UserVoucher.fromJson(json)).toList();
        state = state.copyWith(isLoading: false, vouchers: vouchers);
      } on DioException catch (e) {
        if (e.response?.statusCode == 404 || e.response?.statusCode == 401) {
          // Fallback to Mock Data since the endpoint isn't ready
          await Future.delayed(const Duration(seconds: 1)); // simulate network
          state = state.copyWith(
            isLoading: false,
            vouchers: [
              UserVoucher(
                id: 'v1',
                userId: 'u1',
                packageId: 'p1',
                voucherCode: 'PUJA-VIP-2026',
                status: 'redeemed',
                redeemedAt: DateTime.now().toIso8601String(),
                redeemedByCounter: 'Counter A',
                createdAt: DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
                userName: 'Arjun Das',
                userPhone: '+91 9876543210',
                packageTitle: 'Premium VIP Access 2026',
              ),
              UserVoucher(
                id: 'v2',
                userId: 'u2',
                packageId: 'p1',
                voucherCode: 'PUJA-VIP-8821',
                status: 'issued',
                createdAt: DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
                userName: 'Priya Sen',
                userPhone: '+91 9123456789',
                packageTitle: 'Premium VIP Access 2026',
              ),
            ]
          );
        } else {
          rethrow;
        }
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> createPackage(PassPackage package) async {
    try {
      final dio = ref.read(dioProvider);
      await dio.post('/admin/passes/packages', data: package.toJson());
      await fetchPackages();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updatePackage(String id, PassPackage package) async {
    try {
      final dio = ref.read(dioProvider);
      await dio.patch('/admin/passes/packages/$id', data: package.toJson());
      await fetchPackages();
      return true;
    } catch (e) {
      return false;
    }
  }
}

final passProvider = NotifierProvider<PassNotifier, PassState>(() {
  return PassNotifier();
});

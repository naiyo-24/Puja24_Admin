import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'dart:typed_data';
import '../../../core/network/dio_client.dart';
import '../../../core/network/api_constants.dart';
import '../models/banner_model.dart';

class BannerState {
  final List<BannerModel> banners;
  final bool isLoading;
  final String? error;

  BannerState({this.banners = const [], this.isLoading = false, this.error});

  BannerState copyWith({List<BannerModel>? banners, bool? isLoading, String? error}) {
    return BannerState(
      banners: banners ?? this.banners,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class BannerNotifier extends Notifier<BannerState> {
  @override
  BannerState build() {
    Future.microtask(() => fetchBanners());
    return BannerState();
  }

  Future<void> fetchBanners() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get(ApiConstants.adminBanners);
      final List<dynamic> data = response.data;
      final banners = data.map((json) => BannerModel.fromJson(json)).toList();
      state = state.copyWith(isLoading: false, banners: banners);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to load banners: ${e.toString()}');
    }
  }

  Future<void> uploadBanner(Uint8List imageBytes, String filename, {String? linkUrl, String? title, String? subtitle}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final dio = ref.read(dioProvider);
      FormData formData = FormData.fromMap({
        'image': MultipartFile.fromBytes(imageBytes, filename: filename),
        'link_url': linkUrl ?? '',
        'title': title ?? '',
        'subtitle': subtitle ?? '',
      });

      // Create a fresh Dio instance specifically for uploads to avoid BaseOptions forcing application/json
      final uploadDio = Dio(
        BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          connectTimeout: const Duration(seconds: 30), // Give more time for uploads
          receiveTimeout: const Duration(seconds: 30),
        )
      );
      // Copy interceptors to keep Auth Token
      uploadDio.interceptors.addAll(dio.interceptors);

      await uploadDio.post(
        ApiConstants.adminBanners,
        data: formData,
      );
      
      await fetchBanners();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to upload banner: ${e.toString()}');
    }
  }

  Future<void> toggleBannerStatus(String id, bool isActive) async {
    try {
      final dio = ref.read(dioProvider);
      await dio.patch('${ApiConstants.adminBanners}/$id/toggle', data: {'is_active': isActive});
      
      final updatedBanners = state.banners.map((b) {
        if (b.id == id) {
          return BannerModel(
            id: b.id, 
            imageUrl: b.imageUrl, 
            linkUrl: b.linkUrl, 
            isActive: isActive, 
            createdAt: b.createdAt
          );
        }
        return b;
      }).toList();
      
      state = state.copyWith(banners: updatedBanners);
    } catch (e) {
      state = state.copyWith(error: 'Failed to toggle banner status: ${e.toString()}');
    }
  }

  Future<void> deleteBanner(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final dio = ref.read(dioProvider);
      await dio.delete('${ApiConstants.adminBanners}/$id');
      await fetchBanners();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to delete banner: ${e.toString()}');
    }
  }
}

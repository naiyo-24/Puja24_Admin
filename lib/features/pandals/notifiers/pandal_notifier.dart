import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../models/place.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/api_constants.dart';

class PandalState {
  final bool isLoading;
  final List<Place> pandals;
  final String? error;

  PandalState({
    this.isLoading = false,
    this.pandals = const [],
    this.error,
  });

  PandalState copyWith({
    bool? isLoading,
    List<Place>? pandals,
    String? error,
  }) {
    return PandalState(
      isLoading: isLoading ?? this.isLoading,
      pandals: pandals ?? this.pandals,
      error: error,
    );
  }
}

class PandalNotifier extends Notifier<PandalState> {
  @override
  PandalState build() {
    Future.microtask(() => fetchPandals());
    return PandalState();
  }

  Future<void> fetchPandals() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get(ApiConstants.adminPlaces, queryParameters: {'limit': 10000});
      
      final List<dynamic> data = response.data;
      final pandals = data.map((json) => Place.fromJson(json)).toList();
      
      state = state.copyWith(isLoading: false, pandals: pandals);
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false, 
        error: e.response?.data['detail'] ?? 'Failed to fetch pandals',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> createPandal(Place place) async {
    try {
      final dio = ref.read(dioProvider);
      await dio.post(ApiConstants.adminPlaces, data: place.toJson());
      await fetchPandals(); // refresh list
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updatePandal(String id, Place place) async {
    try {
      final dio = ref.read(dioProvider);
      await dio.patch('${ApiConstants.adminPlaces}/$id', data: place.toJson());
      await fetchPandals();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deletePandal(String id) async {
    try {
      final dio = ref.read(dioProvider);
      await dio.delete('${ApiConstants.adminPlaces}/$id');
      await fetchPandals();
      return true;
    } catch (e) {
      return false;
    }
  }
}

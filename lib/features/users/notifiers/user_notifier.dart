import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../models/user.dart';
import '../../../core/network/dio_client.dart';

class UserState {
  final bool isLoading;
  final List<AppUser> users;
  final String? error;

  UserState({
    this.isLoading = false,
    this.users = const [],
    this.error,
  });

  UserState copyWith({
    bool? isLoading,
    List<AppUser>? users,
    String? error,
  }) {
    return UserState(
      isLoading: isLoading ?? this.isLoading,
      users: users ?? this.users,
      error: error,
    );
  }
}

class UserNotifier extends Notifier<UserState> {
  @override
  UserState build() {
    Future.microtask(() => fetchUsers());
    return UserState();
  }

  Future<void> fetchUsers() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final dio = ref.read(dioProvider);
      // Assuming a GET endpoint exists for admins
      final response = await dio.get('/admin/users'); 
      
      final List<dynamic> data = response.data;
      final usersList = data.map((json) => AppUser.fromJson(json)).toList();
      
      state = state.copyWith(isLoading: false, users: usersList);
    } catch (e) {
        state = state.copyWith(
          isLoading: false, 
          error: 'Error: ${e.toString()}',
        );
    }
  }

  Future<bool> toggleUserStatus(String id, bool currentStatus) async {
    try {
      final dio = ref.read(dioProvider);
      await dio.patch('/admin/users/$id', data: {'is_active': !currentStatus});
      await fetchUsers(); // refresh list
      return true;
    } catch (e) {
      return false;
    }
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../notifiers/user_notifier.dart';

final userProvider = NotifierProvider<UserNotifier, UserState>(() {
  return UserNotifier();
});

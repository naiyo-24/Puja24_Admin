import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../notifiers/auth_notifier.dart';

final authStateProvider = NotifierProvider<AuthNotifier, bool>(() {
  return AuthNotifier();
});

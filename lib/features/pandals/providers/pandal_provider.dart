import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../notifiers/pandal_notifier.dart';

final pandalProvider = NotifierProvider<PandalNotifier, PandalState>(() {
  return PandalNotifier();
});

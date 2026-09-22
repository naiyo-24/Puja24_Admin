import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../notifiers/banner_notifier.dart';

final bannerProvider = NotifierProvider<BannerNotifier, BannerState>(() {
  return BannerNotifier();
});

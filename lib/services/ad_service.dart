import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static Future<void> initialize() async {
    try {
      await MobileAds.instance.initialize();
    } catch (error, stackTrace) {
      debugPrint('Ads initialization skipped: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}

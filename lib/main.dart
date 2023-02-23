import 'dart:io';
import 'package:device_preview/device_preview.dart';
import 'package:device_preview_screenshot/device_preview_screenshot.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:logging/logging.dart';
import 'package:rigassat/services/gtfs_fetch.dart';
import 'package:rigassat/theme/config/theme.dart';
import 'IAP/ad_removal_state.gen.dart';
import 'IAP/in_app_purchase.dart';
import 'ads/ads_controller.dart';
import 'components/bottom_nav.dart';
import 'crashlytics/crashlytics.dart';
import 'data/route.dart';
import 'firebase_options.dart';
import 'models/locale/locale_providers.dart';
import 'theme/theme_mode_state.dart';

Future<void> main() async {
  FirebaseCrashlytics? crashlytics;
  if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      crashlytics = FirebaseCrashlytics.instance;
    } catch (e) {
      debugPrint("Firebase couldn't be initialized: $e");
    }
  }
  await guardWithCrashlytics(
    guardedMain,
    crashlytics: crashlytics,
  );
}

void guardedMain() async {
  if (kReleaseMode) {
    // Don't log anything below warnings in production.
    Logger.root.level = Level.WARNING;
  }
  Logger.root.onRecord.listen((record) {
    debugPrint('${record.level.name}: ${record.time}: '
        '${record.loggerName}: '
        '${record.message}');
  });

  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Hive.initFlutter();
  Hive.registerAdapter(RouteTypeAdapter());
  await Hive.openBox<RouteType>('favorites');
  await Hive.openBox('prefs');
  fetchData();

  runApp(
    const ProviderScope(child: MyApp()),
  );
}

final Box<RouteType> favoritesBox = Hive.box<RouteType>('favorites');

Logger _log = Logger('main.dart');

final adsControllerProvider =
    (!kIsWeb && (Platform.isIOS || Platform.isAndroid))
        ? Provider<AdsController>(
            (ref) => AdsController(MobileAds.instance)..initialize())
        : null;

final inAppPurchaseControllerProvider = (!kIsWeb &&
        (Platform.isIOS || Platform.isAndroid))
    ? StateNotifierProvider<InAppPurchaseController, AdRemovalPurchaseState>(
        (ref) => InAppPurchaseController(InAppPurchase.instance)
          ..subscribe()
          ..restorePurchases(),
      )
    : null;

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<Locale> _supportedLocales = ref.read(supportedLocalesProvider);

    // Watch the current locale and rebuild on change
    Locale _locale = ref.watch(localeProvider);
    _log.info("Rebuilding with watched locale: " + _locale.toString());

    FlutterNativeSplash.remove();
    final ThemeModeState currentTheme = ref.watch(themeProvider);
    return MaterialApp(
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.unknown
        },
      ),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: _supportedLocales,
      themeMode: currentTheme.themeMode,
      theme: lightTheme,
      darkTheme: darkTheme,
      locale: _locale,
      home: const ConvexBottomBar(),
    );
  }
}

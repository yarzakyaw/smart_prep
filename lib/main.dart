import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smart_prep/core/models/submission_model.dart';
import 'package:smart_prep/core/models/test_model.dart';
import 'package:smart_prep/core/theme/app_theme.dart';
import 'package:smart_prep/features/auth/model/user_info_model.dart';
import 'package:smart_prep/features/auth/view/pages/sign_in_page.dart';
import 'package:smart_prep/features/auth/view/pages/sign_up_page.dart';
import 'package:smart_prep/features/auth/viewmodel/auth_view_model.dart';
import 'package:smart_prep/features/classes/view/pages/classes_page.dart';
import 'package:smart_prep/features/classes/view/pages/submissions_page.dart';
import 'package:smart_prep/features/classes/view/pages/submit_test_page.dart';
import 'package:smart_prep/features/classes/view/widget/class_details_widget.dart';
import 'package:smart_prep/features/dashboard/view/pages/dashboard.dart';
import 'package:smart_prep/features/home/view/pages/home_page.dart';
import 'package:smart_prep/features/localization/app_localizations.dart';
import 'package:smart_prep/features/market/view/pages/market_page.dart';
import 'package:smart_prep/features/onboarding/view/pages/onboarding_page.dart';
import 'package:smart_prep/features/practice/view/pages/practice_page.dart';
import 'package:smart_prep/features/practice/view/widgets/practice_page_widget.dart';
import 'package:smart_prep/features/practice/view/widgets/review_page_widget.dart';
import 'package:smart_prep/features/profile/view/pages/profile_page.dart';
import 'package:smart_prep/features/splash/view/pages/splash_screen.dart';
import 'package:smart_prep/firebase_options.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Configure Crashlytics
  // Enable Crashlytics collection (disabled in debug mode by default)
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
    !kDebugMode,
  );

  // Capture Flutter errors
  FlutterError.onError = (FlutterErrorDetails details) {
    if (kDebugMode) {
      // In debug mode, print errors to console
      FlutterError.dumpErrorToConsole(details);
    } else {
      // In release mode, report to Crashlytics
      FirebaseCrashlytics.instance.recordFlutterError(details);
    }
  };

  // Capture uncaught asynchronous errors
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true; // Indicate that the error is handled
  };

  // await Hive.initFlutter();
  final appDocumentDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);
  Hive.registerAdapter(UserInfoModelAdapter());
  Hive.registerAdapter(SubmissionModelAdapter());
  Hive.registerAdapter(TestModelAdapter());

  await Hive.openBox<UserInfoModel>('user_info');
  await Hive.openBox<SubmissionModelAdapter>('submissions');
  await Hive.openBox<TestModelAdapter>('tests');
  await Hive.openBox('settings');

  runApp(ProviderScope(child: SmartPrepApp()));
}

class SmartPrepApp extends ConsumerStatefulWidget {
  const SmartPrepApp({super.key});

  // This widget is the root of your application.
  @override
  ConsumerState<SmartPrepApp> createState() => _SmartPrepAppState();
}

class _SmartPrepAppState extends ConsumerState<SmartPrepApp> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(authViewModelProvider.notifier).setInitialScreen();
    });
  }

  @override
  Widget build(BuildContext context) {
    final savedUserInfo = ref
        .watch(authViewModelProvider.notifier)
        .getUserInfo();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return GetMaterialApp(
      locale: Locale(savedUserInfo?.languagePreference ?? 'en'),
      debugShowCheckedModeBanner: false,
      title: 'Smart Prep',
      theme: AppTheme.lightThemeMode,
      darkTheme: AppTheme.darkThemeMode,
      themeMode: ThemeMode.system,
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const SplashScreen()),
        GetPage(name: '/onboarding', page: () => const OnboardingPage()),
        GetPage(name: '/dashboard', page: () => const Dashboard()),
        GetPage(name: '/dashboard/home', page: () => const HomePage()),
        GetPage(name: '/dashboard/practice', page: () => PracticePage()),
        GetPage(
          name: '/dashboard/practice/main',
          page: () {
            final args = Get.arguments as Map<String, dynamic>?;
            return PracticePageWidget(
              mode: args?['mode'] ?? 'mcq',
              subject: args?['subject'],
            );
          },
        ),
        GetPage(
          name: '/dashboard/practice/review',
          page: () {
            final args = Get.arguments as Map<String, dynamic>?;
            return ReviewPageWidget(questions: args?['questions'] ?? []);
          },
        ),
        GetPage(name: '/classes', page: () => const ClassesPage()),
        GetPage(
          name: '/classes/class_details',
          page: () {
            final args = Get.arguments as Map<String, dynamic>?;
            return ClassDetailsWidget(classModel: args?['class']);
          },
        ),
        GetPage(name: '/profile', page: () => const ProfilePage()),
        GetPage(name: '/signin', page: () => const SignInPage()),
        GetPage(
          name: '/signup',
          page: () {
            final args = Get.arguments as Map<String, dynamic>?;
            return SignUpPage(
              isAnonymousConversion: args?['isAnonymousConversion'] ?? false,
            );
          },
        ),
        GetPage(name: '/marketplace', page: () => const MarketPage()),
        GetPage(
          name: '/submit_test',
          page: () {
            final args = Get.arguments as Map<String, dynamic>?;
            return SubmitTestPage(test: args?['test']);
          },
        ),
        GetPage(name: '/submissions', page: () => const SubmissionsPage()),
      ],
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [Locale('en', 'US'), Locale('my', '')],
    );
  }

  @override
  void dispose() {
    Hive.close();
    super.dispose();
  }
}

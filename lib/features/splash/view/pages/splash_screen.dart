import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:smart_prep/core/constants/image_strings.dart';
import 'package:smart_prep/core/providers/current_user_notifier.dart';
import 'package:smart_prep/services/sample_data.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    redirect();
  }

  Future<void> redirect() async {
    final box = await Hive.openBox('settings');
    final onboardingCompleted = box.get(
      'onboarding_completed',
      defaultValue: false,
    );

    Future.microtask(() async {
      await SampleData.populateSampleQuestions(); // Initialize with versioning
    });
    await Future.delayed(const Duration(seconds: 2));
    final currentUser = ref.watch(currentUserNotifierProvider);
    currentUser == null || onboardingCompleted == false
        ? Get.offAllNamed('onboarding')
        : Get.offAllNamed('dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SvgPicture.asset(
          iLogo,
          width: MediaQuery.of(context).size.width * 0.5,
          height: MediaQuery.of(context).size.height * 0.2,
        ),
      ),
    );
  }
}

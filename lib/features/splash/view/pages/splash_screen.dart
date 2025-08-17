import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:smart_prep/core/constants/image_strings.dart';
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
    Future.microtask(() async {
      await SampleData.populateSampleQuestions(); // Initialize with versioning
    });
    /* Future.microtask(() async {
      final dbService = DatabaseService();
      // Optional: Clear old data before populating
      await dbService.clearAllQuestions();
      await SampleData.populateSampleQuestions();
      // Debug: Fetch and print raw database content

      final questions = await dbService.getQuestions();
      debugPrint('Raw database questions: $questions');
    }); */
    /* SnackbarGetxController.successSnackBar(
      title: 'Success',
      message: 'Sample questions populated',
    ); */
    await Future.delayed(const Duration(seconds: 2));
    // Get.offAll(
    //   () => const Dashboard(),
    //   transition: Transition.fadeIn,
    //   duration: const Duration(milliseconds: 500),
    // );
    Get.offAllNamed('dashboard');
    // final currentUser = ref.watch(currentUserNotifierProvider);
    // currentUser == null
    //     ? Navigator.pushReplacementNamed(context, 'GetStarted')
    //     : Navigator.pushReplacementNamed(context, 'Dashboard');
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

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:smart_prep/core/theme/app_pallete.dart';

class SnackbarGetxController extends GetxController {
  /* -- ============= SNACK-BARS ================ -- */

  static void successSnackBar({
    required String title,
    required String message,
  }) {
    /* final isDark =
        WidgetsBinding.instance.platformDispatcher.platformBrightness ==
        Brightness.dark; */
    Get.snackbar(
      title,
      message,
      isDismissible: true,
      shouldIconPulse: true,
      colorText: AppPallete.whiteColor,
      backgroundColor: AppPallete.amberColor,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 6),
      margin: const EdgeInsets.all(10),
      icon: const Icon(
        LineAwesomeIcons.check_circle,
        color: AppPallete.whiteColor,
      ),
    );
  }

  // static warningSnackBar({
  //   required title,
  //   message,
  // }) {
  //   Get.snackbar(
  //     title,
  //     message,
  //     isDismissible: true,
  //     shouldIconPulse: true,
  //     colorText: mingalarWhiteColor,
  //     backgroundColor: mingalarOnBoardingPage3Color,
  //     snackPosition: SnackPosition.BOTTOM,
  //     duration: const Duration(seconds: 6),
  //     margin: const EdgeInsets.all(10),
  //     icon: const Icon(
  //       LineAwesomeIcons.exclamation_circle_solid,
  //       color: mingalarWhiteColor,
  //     ),
  //   );
  // }

  static void errorSnackBar({required String title, required String message}) {
    Get.snackbar(
      title,
      message,
      isDismissible: true,
      shouldIconPulse: true,
      colorText: AppPallete.whiteColor,
      backgroundColor: AppPallete.gradient3,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 6),
      margin: const EdgeInsets.all(10),
      icon: const Icon(
        LineAwesomeIcons.times_circle,
        color: AppPallete.whiteColor,
      ),
    );
  }

  // static modernSnackBar({required title, message}) {
  //   Get.snackbar(
  //     title,
  //     message,
  //     isDismissible: true,
  //     colorText: tWhiteColor,
  //     backgroundColor: Colors.blueGrey,
  //     snackPosition: SnackPosition.BOTTOM,
  //     duration: const Duration(seconds: 5),
  //     margin: const EdgeInsets.all(tDefaultSpace - 10),
  //   );
  // }
}

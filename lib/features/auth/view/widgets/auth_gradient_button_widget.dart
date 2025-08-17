import 'package:flutter/material.dart';
import 'package:smart_prep/core/theme/app_pallete.dart';

class AuthGradientButtonWidget extends StatelessWidget {
  final String buttonText;
  final VoidCallback onTap;

  const AuthGradientButtonWidget({
    super.key,
    required this.buttonText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [AppPallete.gradient1, AppPallete.gradient2]
              : [AppPallete.gradient4, AppPallete.gradient5],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          fixedSize: Size(width, 55),
          backgroundColor: AppPallete.transparentColor,
          shadowColor: AppPallete.transparentColor,
        ),
        child: Text(
          buttonText,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:smart_prep/core/theme/app_pallete.dart';

class ClickableRichtextWidget extends StatelessWidget {
  final String text1, text2;
  final VoidCallback onPressed;

  const ClickableRichtextWidget({
    super.key,
    required this.text1,
    required this.text2,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$text1? ',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            TextSpan(
              text: text2,
              style: Theme.of(context).textTheme.bodyLarge!.apply(
                color: AppPallete.facebookForegroundColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

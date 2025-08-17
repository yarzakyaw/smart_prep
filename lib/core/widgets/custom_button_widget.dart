import 'package:flutter/material.dart';
import 'package:smart_prep/core/theme/app_pallete.dart';
import 'package:smart_prep/core/widgets/custom_loader.dart';

class CustomButtonWidget extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final bool isEditing;
  final double width;

  const CustomButtonWidget({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.isEditing = false,
    this.width = 100,
  });

  @override
  Widget build(BuildContext context) {
    // var isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return SizedBox(
      width: isFullWidth ? double.infinity : width,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isEditing
              ? AppPallete.greyColor
              : AppPallete.amberColor,
        ),
        onPressed: onPressed,
        child: isLoading
            ? const CustomLoader()
            : Text(
                //text.toUpperCase(),
                text,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge!.apply(color: AppPallete.whiteColor),
              ),
      ),
    );
  }
}

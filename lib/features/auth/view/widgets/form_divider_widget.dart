import 'package:flutter/material.dart';
import 'package:smart_prep/core/theme/app_pallete.dart';
import 'package:smart_prep/core/utils.dart';

class FormDividerWidget extends StatelessWidget {
  const FormDividerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    final lineColor = isDark ? AppPallete.gradient2 : AppPallete.gradient4;
    return Row(
      children: [
        Flexible(
          child: Divider(
            thickness: 1,
            indent: 50,
            color: lineColor,
            endIndent: 10,
          ),
        ),
        Text(
          translate(context, 'or'),
          style: Theme.of(context).textTheme.bodyLarge!.apply(
            color: isDark ? AppPallete.whiteColor : AppPallete.backgroundColor,
          ),
        ),
        Flexible(
          child: Divider(
            thickness: 1,
            indent: 10,
            color: lineColor,
            endIndent: 50,
          ),
        ),
      ],
    );
  }
}

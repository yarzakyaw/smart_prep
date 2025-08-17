import 'package:flutter/material.dart';

class FormHeaderWidget extends StatelessWidget {
  final Color? imageColor;
  final double? imageHeight;
  final double? heightBetween;
  final String? image;
  final String title;
  final String? subTitle;
  final CrossAxisAlignment crossAxisAlignment;
  final TextAlign? textAlign;

  const FormHeaderWidget({
    super.key,
    this.imageColor,
    this.imageHeight,
    this.heightBetween = 5,
    this.image,
    required this.title,
    this.subTitle,
    required this.crossAxisAlignment,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8),
      child: Column(
        children: [
          if (image != null)
            Image(
              image: AssetImage(image!),
              color: imageColor,
              height: size.height * imageHeight!,
            ),
          SizedBox(height: heightBetween),
          Text(title, style: Theme.of(context).textTheme.displaySmall),
          SizedBox(height: heightBetween),
          if (subTitle != null)
            Text(
              subTitle!,
              textAlign: textAlign,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
        ],
      ),
    );
  }
}

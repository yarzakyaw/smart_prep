import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_prep/features/auth/view/widgets/clickable_richtext_widget.dart';

class SocialFooterWidget extends ConsumerWidget {
  final String text1, text2;
  final VoidCallback onPressed;

  const SocialFooterWidget({
    super.key,
    required this.text1,
    required this.text2,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        ClickableRichtextWidget(
          text1: text1,
          text2: text2,
          onPressed: onPressed,
        ),
      ],
    );
  }
}

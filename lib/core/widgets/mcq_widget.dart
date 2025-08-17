import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_prep/core/constants/text_strings.dart';
import 'package:smart_prep/core/models/question.dart';
import 'package:smart_prep/core/providers/quiz_provider.dart';

class MCQWidget extends ConsumerWidget {
  final Question question;
  final Function(String) onAnswerSelected;

  const MCQWidget({
    super.key,
    required this.question,
    required this.onAnswerSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAnswers = ref.watch(userAnswersProvider);
    final selectedAnswer = userAnswers[question.id];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        question.subject == 'Mathematics'
            ? Math.tex(question.text, textStyle: const TextStyle(fontSize: 18))
            : Text(
                question.text,
                style: const TextStyle(fontSize: 18, fontFamily: tFont),
              ),
        /* Text(
          question.text,
          style: const TextStyle(fontSize: 18, fontFamily: tFont),
        ), */
        const SizedBox(height: 16),
        ...question.options!.map(
          (option) => RadioListTile<String>(
            title: question.subject == 'Mathematics'
                ? Math.tex(option, textStyle: const TextStyle(fontSize: 16))
                : Text(option, style: const TextStyle(fontFamily: tFont)),
            // title: Text(option, style: const TextStyle(fontFamily: tFont)),
            value: option,
            groupValue: selectedAnswer,
            onChanged: (value) {
              if (value != null) {
                onAnswerSelected(value);
              }
            },
          ),
        ),
      ],
    );
  }
}

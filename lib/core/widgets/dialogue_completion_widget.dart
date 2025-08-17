import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_prep/core/constants/text_strings.dart';
import 'package:smart_prep/core/models/question.dart';
import 'package:smart_prep/core/snackbar_getx_controller.dart';
import 'package:smart_prep/core/utils.dart';

class DialogueCompletionWidget extends ConsumerStatefulWidget {
  final Question question;
  final Function(String) onAnswerSubmitted;

  const DialogueCompletionWidget({
    super.key,
    required this.question,
    required this.onAnswerSubmitted,
  });

  @override
  ConsumerState<DialogueCompletionWidget> createState() =>
      _DialogueCompletionWidgetState();
}

class _DialogueCompletionWidgetState
    extends ConsumerState<DialogueCompletionWidget> {
  String? selectedOption;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.question.text,
          style: const TextStyle(fontSize: 18, fontFamily: tFont),
        ),
        const SizedBox(height: 16),
        ...widget.question.options!.map(
          (option) => RadioListTile<String>(
            title: Text(option, style: const TextStyle(fontFamily: tFont)),
            value: option,
            groupValue: selectedOption,
            onChanged: (value) {
              setState(() {
                selectedOption = value;
              });
            },
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            if (selectedOption != null) {
              widget.onAnswerSubmitted(selectedOption!);
              setState(() {
                selectedOption = null;
              });
            } else {
              SnackbarGetxController.errorSnackBar(
                title: translate(context, 'error'),
                message: translate(context, 'select_option'),
              );
            }
          },
          child: Text(translate(context, 'submit_ans')),
        ),
      ],
    );
  }
}

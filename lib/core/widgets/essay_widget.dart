import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_prep/core/constants/text_strings.dart';
import 'package:smart_prep/core/models/question.dart';
import 'package:smart_prep/core/snackbar_getx_controller.dart';
import 'package:smart_prep/core/utils.dart';

class EssayWidget extends ConsumerStatefulWidget {
  final Question question;
  final Function(String) onAnswerSubmitted;

  const EssayWidget({
    super.key,
    required this.question,
    required this.onAnswerSubmitted,
  });

  @override
  ConsumerState<EssayWidget> createState() => _EssayWidgetState();
}

class _EssayWidgetState extends ConsumerState<EssayWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.question.text,
          style: const TextStyle(fontSize: 18, fontFamily: tFont),
        ),
        if (widget.question.prompt != null) ...[
          const SizedBox(height: 8),
          Text(
            'Prompt: ${widget.question.prompt}',
            style: const TextStyle(
              fontSize: 16,
              fontFamily: tFont,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
        const SizedBox(height: 16),
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: translate(context, 'essay_instruction'),
            hintStyle: const TextStyle(fontFamily: tFont),
          ),
          style: const TextStyle(fontFamily: tFont),
          maxLines: 10,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            if (_controller.text.isNotEmpty) {
              widget.onAnswerSubmitted(_controller.text);
              _controller.clear();
            } else {
              SnackbarGetxController.errorSnackBar(
                title: translate(context, 'error'),
                message: translate(context, 'write_essay'),
              );
            }
          },
          child: Text(translate(context, 'submit_ans')),
        ),
      ],
    );
  }
}

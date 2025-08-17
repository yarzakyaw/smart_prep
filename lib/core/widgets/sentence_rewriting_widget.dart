import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_prep/core/constants/text_strings.dart';
import 'package:smart_prep/core/models/question.dart';
import 'package:smart_prep/core/snackbar_getx_controller.dart';
import 'package:smart_prep/core/utils.dart';

class SentenceRewritingWidget extends ConsumerStatefulWidget {
  final Question question;
  final Function(String) onAnswerSubmitted;

  const SentenceRewritingWidget({
    super.key,
    required this.question,
    required this.onAnswerSubmitted,
  });

  @override
  ConsumerState<SentenceRewritingWidget> createState() =>
      _SentenceRewritingWidgetState();
}

class _SentenceRewritingWidgetState
    extends ConsumerState<SentenceRewritingWidget> {
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
        const SizedBox(height: 8),
        Text(
          'Original Sentence: ${widget.question.originalSentence}',
          style: const TextStyle(
            fontSize: 16,
            fontFamily: tFont,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: translate(context, 'rewrite_sentence'),
            hintStyle: const TextStyle(fontFamily: tFont),
          ),
          style: const TextStyle(fontFamily: tFont),
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
                message: translate(context, 'rewrite_sentence'),
              );
            }
          },
          child: Text(translate(context, 'submit_ans')),
        ),
      ],
    );
  }
}

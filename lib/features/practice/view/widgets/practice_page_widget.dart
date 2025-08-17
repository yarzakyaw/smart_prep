import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_prep/core/providers/quiz_provider.dart';
import 'package:smart_prep/features/practice/view/widgets/practice_quiz_widget.dart';

class PracticePageWidget extends ConsumerWidget {
  final String mode;
  final String? subject;

  const PracticePageWidget({super.key, required this.mode, this.subject});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionsAsync = ref.watch(questionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Practice: ${mode == 'mixed' ? 'Mixed' : mode.replaceAll('_', ' ').toUpperCase()} (${subject ?? 'All Subjects'})',
        ),
      ),
      body: questionsAsync.when(
        data: (questions) {
          final filteredQuestions = mode == 'mixed'
              ? questions
                    .where(
                      (q) =>
                          subject == null ||
                          subject == 'all' ||
                          q.subject == subject,
                    )
                    .toList()
              : questions
                    .where(
                      (q) =>
                          q.type.toString().split('.').last == mode &&
                          (subject == null ||
                              subject == 'all' ||
                              q.subject == subject),
                    )
                    .toList();
          return PracticeQuizWidget(
            questions: filteredQuestions,
            mode: mode,
            subject: subject,
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

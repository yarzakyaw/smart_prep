import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:smart_prep/core/constants/text_strings.dart';
import 'package:smart_prep/core/models/question.dart';
import 'package:smart_prep/core/providers/progress_provider.dart';
import 'package:smart_prep/core/providers/quiz_provider.dart';
import 'package:smart_prep/core/widgets/dialogue_completion_widget.dart';
import 'package:smart_prep/core/widgets/essay_widget.dart';
import 'package:smart_prep/core/widgets/fill_in_the_blank_widget.dart';
import 'package:smart_prep/core/widgets/mcq_widget.dart';
import 'package:smart_prep/core/widgets/sentence_rewriting_widget.dart';
import 'package:smart_prep/core/widgets/short_answer_widget.dart';

class PracticeQuizWidget extends ConsumerWidget {
  final String mode;
  final List<Question> questions;
  final String? subject;

  const PracticeQuizWidget({
    super.key,
    required this.questions,
    required this.mode,
    this.subject,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (questions.isEmpty) {
      return const Center(child: Text('No questions available for this mode'));
    }

    final currentIndex = ref.watch(currentQuestionIndexProvider);
    final score = ref.watch(scoreProvider);
    final userAnswers = ref.watch(userAnswersProvider);

    if (currentIndex >= questions.length) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Practice Completed! Score: $score/${questions.length}',
              style: const TextStyle(fontSize: 20, fontFamily: tFont),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Save progress
                ref
                    .read(progressProvider.notifier)
                    .addProgress(
                      mode,
                      score,
                      questions.length,
                      userAnswers,
                      questions,
                      subject: subject,
                    );
                Get.toNamed(
                  '/dashboard/practice/review',
                  arguments: {'questions': questions},
                );
              },
              child: const Text('Review Answers'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(quizProvider.notifier).resetQuiz();
                Navigator.pop(context); // Return to HomeScreen
              },
              child: const Text('Return to Home'),
            ),
          ],
        ),
      );
    }

    final question = questions[currentIndex];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Question ${currentIndex + 1} of ${questions.length}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Container(
                key: ValueKey(question.id),
                child: _buildQuestionWidget(context, ref, question),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Score: $score', style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildQuestionWidget(
    BuildContext context,
    WidgetRef ref,
    Question question,
  ) {
    switch (question.type) {
      case QuestionType.mcq:
        return MCQWidget(
          question: question,
          onAnswerSelected: (answer) {
            ref.read(quizProvider.notifier).submitAnswer(question, answer);
          },
        );
      case QuestionType.fillInTheBlank:
        return FillInTheBlankWidget(
          question: question,
          onAnswerSubmitted: (answer) {
            ref.read(quizProvider.notifier).submitAnswer(question, answer);
          },
        );
      case QuestionType.shortAnswer:
        return ShortAnswerWidget(
          question: question,
          onAnswerSubmitted: (answer) {
            ref.read(quizProvider.notifier).submitAnswer(question, answer);
          },
        );
      case QuestionType.dialogueCompletion:
        return DialogueCompletionWidget(
          question: question,
          onAnswerSubmitted: (answer) {
            ref.read(quizProvider.notifier).submitAnswer(question, answer);
          },
        );
      case QuestionType.essay:
        return EssayWidget(
          question: question,
          onAnswerSubmitted: (answer) {
            ref.read(quizProvider.notifier).submitAnswer(question, answer);
          },
        );
      case QuestionType.sentenceRewriting:
        return SentenceRewritingWidget(
          question: question,
          onAnswerSubmitted: (answer) {
            ref.read(quizProvider.notifier).submitAnswer(question, answer);
          },
        );
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_prep/core/constants/text_strings.dart';
import 'package:smart_prep/core/models/question.dart';
import 'package:smart_prep/core/providers/quiz_provider.dart';

class ReviewPageWidget extends ConsumerWidget {
  final List<Question> questions;

  const ReviewPageWidget({super.key, required this.questions});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAnswers = ref.watch(userAnswersProvider);
    final score = ref.watch(scoreProvider);

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          ref.read(quizProvider.notifier).resetQuiz();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Review Answers')),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Score: $score/${questions.length}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: tFont,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  final question = questions[index];
                  final userAnswer = userAnswers[question.id] ?? 'No answer';
                  final isCorrect =
                      userAnswer.trim().toLowerCase() ==
                      question.correctAnswer.trim().toLowerCase();

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Question ${index + 1}: ${question.text}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: tFont,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your Answer: $userAnswer',
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: tFont,
                              color: isCorrect ? Colors.green : Colors.red,
                            ),
                          ),
                          Text(
                            'Correct Answer: ${question.correctAnswer}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontFamily: tFont,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Explanation: ${question.explanation}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontFamily: tFont,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  ref.read(quizProvider.notifier).resetQuiz();
                  Navigator.pop(context); // Return to PracticeScreen
                },
                child: const Text('Back to Practice'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

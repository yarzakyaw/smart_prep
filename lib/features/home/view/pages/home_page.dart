import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:smart_prep/core/constants/text_strings.dart';
import 'package:smart_prep/core/models/question.dart';
import 'package:smart_prep/core/providers/progress_provider.dart';
import 'package:smart_prep/core/providers/quiz_provider.dart';
import 'package:smart_prep/core/snackbar_getx_controller.dart';
import 'package:smart_prep/core/utils.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);
    final questionsAsync = ref.watch(questionsProvider);
    // final currentUser = ref.watch(currentUserNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Tracking'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text(
                    'Clear Progress',
                    style: TextStyle(fontFamily: tFont),
                  ),
                  content: const Text(
                    'Are you sure you want to clear all progress?',
                    style: TextStyle(fontFamily: tFont),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontFamily: tFont),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        'Clear',
                        style: TextStyle(fontFamily: tFont),
                      ),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await ref.read(progressProvider.notifier).clearProgress();
                SnackbarGetxController.successSnackBar(
                  title: translate(context, 'success'),
                  message: translate(context, 'progress_cleared'),
                );
              }
            },
            tooltip: 'Clear Progress',
          ),
          /* currentUser == null
              ? const SizedBox.shrink()
              : IconButton(
                  icon: const Icon(Icons.person),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SignUpPage(
                          isAnonymousConversion:
                              currentUser.userDetails?.isAnonymous ?? false,
                        ),
                      ),
                    );
                  },
                  tooltip: currentUser.userDetails?.isAnonymous ?? false
                      ? 'Upgrade Account'
                      : 'Profile',
                ), */
        ],
      ),
      body: questionsAsync.when(
        data: (questions) => progress.isEmpty
            ? const Center(
                child: Text(
                  'No progress data available',
                  style: TextStyle(fontFamily: tFont),
                ),
              )
            : ListView.builder(
                itemCount: progress.length,
                itemBuilder: (context, index) {
                  final entry = progress[index];
                  final formattedDate = DateFormat(
                    'yyyy-MM-dd HH:mm',
                  ).format(entry.timestamp);
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
                            'Practice Mode: ${entry.mode.replaceAll('_', ' ').toUpperCase()}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: tFont,
                            ),
                          ),
                          Text(
                            'Subject: ${entry.subject ?? 'All Subjects'}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontFamily: tFont,
                            ),
                          ),
                          Text(
                            'Date: $formattedDate',
                            style: const TextStyle(
                              fontSize: 14,
                              fontFamily: tFont,
                            ),
                          ),
                          Text(
                            'Score: ${entry.score}/${entry.totalQuestions}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontFamily: tFont,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (entry.incorrectAnswers.isNotEmpty) ...[
                            const Text(
                              'Incorrect Answers:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                fontFamily: tFont,
                              ),
                            ),
                            ...entry.incorrectAnswers.entries.map((e) {
                              final question = questions.firstWhere(
                                (q) => q.id == e.key,
                                orElse: () => Question(
                                  id: e.key,
                                  type: QuestionType.mcq,
                                  text: 'Unknown question',
                                  correctAnswer: 'Unknown',
                                  explanation: 'No explanation available',
                                  category: 'Unknown',
                                  year: 0,
                                  place: 'No place available',
                                ),
                              );
                              return Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  'Q: ${question.text}\nYour Answer: ${e.value}\nCorrect Answer: ${question.correctAnswer}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontFamily: tFont,
                                  ),
                                ),
                              );
                            }),
                          ] else
                            const Text(
                              'All answers correct!',
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: tFont,
                                color: Colors.green,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

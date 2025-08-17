import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_prep/core/models/submission_model.dart';
import 'package:smart_prep/core/models/test_model.dart';
import 'package:smart_prep/core/providers/current_user_notifier.dart';
import 'package:smart_prep/features/home/repositories/home_remote_repository.dart';

class SubmissionsPage extends ConsumerWidget {
  const SubmissionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserNotifierProvider);
    final submissionsStream = ref
        .watch(homeRemoteRepositoryProvider)
        .getUserSubmissions(user!.userDetails!.uid);

    return Scaffold(
      appBar: AppBar(title: const Text('My Submissions')),
      body: StreamBuilder<List<SubmissionModel>>(
        stream: submissionsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            debugPrint('Firestore Error: ${snapshot.error}');
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final submissions = snapshot.data ?? [];
          if (submissions.isEmpty) {
            return const Center(
              child: Text(
                'No submissions found.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return FutureBuilder<List<TestModel>>(
            future: Future.wait(
              submissions.map((submission) async {
                final testDoc = await FirebaseFirestore.instance
                    .collection('tests')
                    .doc(submission.testId)
                    .get();
                return TestModel.fromMap(testDoc.data()!);
              }),
            ),
            builder: (context, testSnapshot) {
              if (testSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (testSnapshot.hasError) {
                debugPrint('Firestore Error: ${snapshot.error}');
                return Center(child: Text('Error: ${testSnapshot.error}'));
              }
              final tests = testSnapshot.data ?? [];

              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: submissions.length,
                itemBuilder: (context, index) {
                  final submission = submissions[index];
                  final test = tests[index];
                  return Card(
                    elevation: 4,
                    child: ListTile(
                      title: Text(
                        test.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Submitted: ${submission.submittedAt.toString().split('.')[0]}',
                          ),
                          if (submission.score != null)
                            Text('Score: ${submission.score}'),
                          if (submission.feedback != null)
                            Text('Feedback: ${submission.feedback}'),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

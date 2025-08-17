import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:smart_prep/core/models/test_model.dart';
import 'package:smart_prep/core/providers/current_user_notifier.dart';
import 'package:smart_prep/core/utils.dart';
import 'package:smart_prep/features/auth/viewmodel/auth_view_model.dart';
import 'package:smart_prep/features/classes/models/class_model.dart';
import 'package:smart_prep/features/classes/view/pages/submissions_page.dart';
import 'package:smart_prep/features/classes/view/pages/submit_test_page.dart';
import 'package:smart_prep/features/home/repositories/home_remote_repository.dart';

class ClassDetailsWidget extends ConsumerWidget {
  final ClassModel classModel;

  const ClassDetailsWidget({super.key, required this.classModel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserNotifierProvider);
    final savedUserInfo = ref
        .watch(authViewModelProvider.notifier)
        .getUserInfo();
    final testsStream = ref
        .watch(homeRemoteRepositoryProvider)
        .getTests(classModel.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(classModel.title),
        actions: [
          if (user != null && savedUserInfo!.accountType == 'student')
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                try {
                  await ref
                      .read(homeRemoteRepositoryProvider)
                      .submitClassJoinRequest(
                        classId: classModel.id,
                        userName: savedUserInfo.name,
                        userEmail: savedUserInfo.email,
                      );
                  Get.snackbar(
                    'Success',
                    'Join request sent',
                    snackPosition: SnackPosition.BOTTOM,
                    titleText: const Text('Success'),
                    messageText: const Text('Join request sent'),
                  );
                } catch (e) {
                  Get.snackbar(
                    'Error',
                    'Failed to send join request: $e',
                    snackPosition: SnackPosition.BOTTOM,
                    titleText: const Text('Error'),
                    messageText: const Text('Failed to send join request'),
                  );
                }
              },
            ),
          IconButton(
            icon: const Icon(Icons.list_alt),
            onPressed: () {
              Get.to(() => const SubmissionsPage());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Text(
            '${translate(context, 'title')}: ${classModel.title}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            '${translate(context, 'subject')}: ${classModel.subject}',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            '${translate(context, 'teacher')}: ${classModel.teacherName}',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            '${translate(context, 'created')}: ${classModel.createdAt.toString().split('.')[0]}',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          Text(
            '${translate(context, 'description')}:',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(classModel.description, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 16),
          StreamBuilder<List<TestModel>>(
            stream: testsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                debugPrint('Firestore Error: ${snapshot.error}');
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              final tests = snapshot.data ?? [];
              if (tests.isEmpty) {
                return const Center(
                  child: Text(
                    'No tests available.',
                    style: TextStyle(fontSize: 16),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: tests.length,
                itemBuilder: (context, index) {
                  final test = tests[index];
                  return Card(
                    elevation: 4,
                    child: ListTile(
                      title: Text(
                        test.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Type: ${test.type}\nDue: ${test.dueDate?.toString().split('.')[0] ?? 'No due date'}',
                      ),
                      trailing: ElevatedButton(
                        onPressed: () {
                          Get.to(() => SubmitTestPage(test: test));
                        },
                        child: const Text('Submit'),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:smart_prep/core/models/test_model.dart';
import 'package:smart_prep/core/providers/current_user_notifier.dart';
import 'package:smart_prep/features/home/repositories/home_remote_repository.dart';

class SubmitTestPage extends ConsumerStatefulWidget {
  final TestModel test;

  const SubmitTestPage({super.key, required this.test});

  @override
  ConsumerState<SubmitTestPage> createState() => _SubmitTestPageState();
}

class _SubmitTestPageState extends ConsumerState<SubmitTestPage> {
  final _formKey = GlobalKey<FormState>();
  File? _pdfFile;
  final List<Map<String, dynamic>> _answers = [];
  String? _errorMessage;

  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null) {
      setState(() {
        _pdfFile = File(result.files.single.path!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserNotifierProvider);
    final isDeadlinePassed =
        widget.test.dueDate != null &&
        DateTime.now().isAfter(widget.test.dueDate!);

    return Scaffold(
      appBar: AppBar(title: Text('Submit ${widget.test.title}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (isDeadlinePassed)
                const Text(
                  'Submission deadline has passed.',
                  style: TextStyle(color: Colors.red),
                ),
              if (widget.test.isOnline && widget.test.type != 'essay') ...[
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.test.questions?.length ?? 0,
                  itemBuilder: (context, index) {
                    final question = widget.test.questions![index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(question['question']),
                        if (widget.test.type == 'mcq')
                          ...question['options'].asMap().entries.map<Widget>((
                            entry,
                          ) {
                            final optionIndex = entry.key;
                            final option = entry.value;
                            return RadioListTile<int>(
                              title: Text(option),
                              value: optionIndex,
                              groupValue: _answers[index]['answer'],
                              onChanged: (value) {
                                setState(() {
                                  _answers[index] = {
                                    'questionId': question['id'],
                                    'answer': value,
                                  };
                                });
                              },
                            );
                          }).toList(),
                        if (widget.test.type == 'fill-in-the-blank')
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Answer',
                            ),
                            onChanged: (value) {
                              setState(() {
                                _answers[index] = {
                                  'questionId': question['id'],
                                  'answer': value,
                                };
                              });
                            },
                          ),
                      ],
                    );
                  },
                ),
              ],
              if (widget.test.type == 'essay')
                ElevatedButton(
                  onPressed: isDeadlinePassed ? null : _pickPdf,
                  child: Text(_pdfFile == null ? 'Upload PDF' : 'PDF Selected'),
                ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: isDeadlinePassed
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          try {
                            String? pdfUrl;
                            if (_pdfFile != null) {
                              pdfUrl = await ref
                                  .read(homeRemoteRepositoryProvider)
                                  .uploadSubmissionPdf(
                                    widget.test.id,
                                    _pdfFile!,
                                    user!.userDetails!.uid,
                                  );
                            }
                            await ref
                                .read(homeRemoteRepositoryProvider)
                                .submitTest(
                                  testId: widget.test.id,
                                  studentId: user!.userDetails!.uid,
                                  classId: widget.test.classId,
                                  studentName: user.username,
                                  questionType: widget.test.type,
                                  pdfPath: pdfUrl,
                                  answers:
                                      widget.test.isOnline &&
                                          widget.test.type != 'essay'
                                      ? _answers
                                      : null,
                                );
                            Get.back();
                            Get.snackbar(
                              'Success',
                              'Test submitted',
                              snackPosition: SnackPosition.BOTTOM,
                              titleText: const Text('Success'),
                              messageText: const Text(''),
                            );
                          } catch (e) {
                            setState(() {
                              _errorMessage = e.toString();
                            });
                          }
                        }
                      },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

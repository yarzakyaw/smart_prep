import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:smart_prep/core/constants/text_strings.dart';

class PracticePage extends ConsumerStatefulWidget {
  const PracticePage({super.key});

  @override
  ConsumerState<PracticePage> createState() => _PracticePageState();
}

class _PracticePageState extends ConsumerState<PracticePage> {
  String? selectedSubject;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Myanmar Grade 12 Exam Practice')),
      /* body: questionsAsync.when(
        data: (questions) => QuizWidget(questions: questions),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ), */
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome to Exam Practice!\nမြန်မာစာ',
                style: TextStyle(fontSize: 20, fontFamily: tFont),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              DropdownButton<String>(
                hint: const Text(
                  'Select Subject',
                  style: TextStyle(fontFamily: tFont),
                ),
                value: selectedSubject,
                items:
                    [
                      'English',
                      'Mathematics',
                      'Myanmar Language',
                      'All Subjects',
                    ].map((subject) {
                      return DropdownMenuItem<String>(
                        value: subject == 'All Subjects' ? 'all' : subject,
                        child: Text(
                          subject,
                          style: const TextStyle(fontFamily: tFont),
                        ),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedSubject = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: selectedSubject != null
                    ? () {
                        /* Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PracticePageWidget(
                              mode: 'mcq',
                              subject: selectedSubject,
                            ),
                          ),
                        ); */
                        Get.toNamed(
                          '/dashboard/practice/main',
                          arguments: {
                            'mode': 'mcq',
                            'subject': selectedSubject,
                          },
                        );
                      }
                    : null,
                child: const Text('Practice MCQs'),
              ),
              /* ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const PracticePageWidget(mode: 'mcq'),
                    ),
                  );
                },
                child: const Text('Practice MCQs'),
              ), */
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: selectedSubject != null
                    ? () {
                        /* Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PracticePageWidget(
                              mode: 'fillInTheBlank',
                              subject: selectedSubject,
                            ),
                          ),
                        ); */
                        Get.toNamed(
                          '/dashboard/practice/main',
                          arguments: {
                            'mode': 'fillInTheBlank',
                            'subject': selectedSubject,
                          },
                        );
                      }
                    : null,
                child: const Text('Practice Fill-in-the-blank'),
              ),
              /* ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const PracticePageWidget(mode: 'fillInTheBlank'),
                    ),
                  );
                },
                child: const Text('Practice Fill-in-the-blank'),
              ), */
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: selectedSubject != null
                    ? () {
                        /* Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PracticePageWidget(
                              mode: 'shortAnswer',
                              subject: selectedSubject,
                            ),
                          ),
                        ); */
                        Get.toNamed(
                          '/dashboard/practice/main',
                          arguments: {
                            'mode': 'shortAnswer',
                            'subject': selectedSubject,
                          },
                        );
                      }
                    : null,
                child: const Text('Practice Short Answer'),
              ),
              /* ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const PracticePageWidget(mode: 'shortAnswer'),
                    ),
                  );
                },
                child: const Text('Practice Short Answer'),
              ), */
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: selectedSubject != null
                    ? () {
                        /* Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PracticePageWidget(
                              mode: 'sentenceRewriting',
                              subject: selectedSubject,
                            ),
                          ),
                        ); */
                        Get.toNamed(
                          '/dashboard/practice/main',
                          arguments: {
                            'mode': 'sentenceRewriting',
                            'subject': selectedSubject,
                          },
                        );
                      }
                    : null,
                child: const Text('Practice Sentence Rewriting'),
              ),
              /* ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const PracticePageWidget(mode: 'sentenceRewriting'),
                    ),
                  );
                },
                child: const Text('Practice Sentence Rewriting'),
              ), */
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: selectedSubject != null
                    ? () {
                        /* Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PracticePageWidget(
                              mode: 'dialogueCompletion',
                              subject: selectedSubject,
                            ),
                          ),
                        ); */
                        Get.toNamed(
                          '/dashboard/practice/main',
                          arguments: {
                            'mode': 'dialogueCompletion',
                            'subject': selectedSubject,
                          },
                        );
                      }
                    : null,
                child: const Text('Practice Dialogue Completion'),
              ),
              /* ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const PracticePageWidget(mode: 'dialogueCompletion'),
                    ),
                  );
                },
                child: const Text('Practice Dialogue Completion'),
              ), */
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: selectedSubject != null
                    ? () {
                        /* Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PracticePageWidget(
                              mode: 'essay',
                              subject: selectedSubject,
                            ),
                          ),
                        ); */
                        Get.toNamed(
                          '/dashboard/practice/main',
                          arguments: {
                            'mode': 'essay',
                            'subject': selectedSubject,
                          },
                        );
                      }
                    : null,
                child: const Text('Practice Essay Writing'),
              ),
              /* ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const PracticePageWidget(mode: 'essay'),
                    ),
                  );
                },
                child: const Text('Practice Essay'),
              ), */
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: selectedSubject != null
                    ? () {
                        /* Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PracticePageWidget(
                              mode: 'mixed',
                              subject: selectedSubject,
                            ),
                          ),
                        ); */
                        Get.toNamed(
                          '/dashboard/practice/main',
                          arguments: {
                            'mode': 'mixed',
                            'subject': selectedSubject,
                          },
                        );
                      }
                    : null,
                child: const Text('Practice Mixed Questions'),
              ),
              /* ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const PracticePageWidget(mode: 'mixed'),
                    ),
                  );
                },
                child: const Text('Practice Mixed Questions'),
              ), */
            ],
          ),
        ),
      ),
    );
  }
}

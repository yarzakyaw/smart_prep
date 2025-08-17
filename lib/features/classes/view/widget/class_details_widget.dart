import 'package:flutter/material.dart';
import 'package:smart_prep/core/utils.dart';
import 'package:smart_prep/features/classes/models/class_model.dart';

class ClassDetailsWidget extends StatelessWidget {
  final ClassModel classModel;

  const ClassDetailsWidget({super.key, required this.classModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(classModel.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Class participation features coming soon!'),
                  ),
                );
              },
              child: Text(translate(context, 'view_class')),
            ),
          ],
        ),
      ),
    );
  }
}

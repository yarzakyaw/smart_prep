import 'dart:convert';

enum QuestionType {
  mcq,
  fillInTheBlank,
  shortAnswer,
  dialogueCompletion,
  essay,
  sentenceRewriting,
}

class Question {
  final int id;
  final QuestionType type;
  final String text;
  final List<String>? options; // For MCQs and dialogue completion
  final String correctAnswer;
  final String explanation;
  final String category;
  final String? prompt; // For essay writing
  final String? originalSentence; // For sentence rewriting
  final String? subject; // Added subject
  final int year;
  final String place;

  Question({
    required this.id,
    required this.type,
    required this.text,
    this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.category,
    this.prompt,
    this.originalSentence,
    this.subject,
    required this.year,
    required this.place,
  });

  // Factory to create Question from SQLite data
  factory Question.fromMap(Map<String, dynamic> map) {
    String typeString = (map['type'] ?? '').toString().toLowerCase().trim();
    QuestionType questionType;

    switch (typeString) {
      case 'mcq':
        questionType = QuestionType.mcq;
        break;
      case 'fillintheblank':
        questionType = QuestionType.fillInTheBlank;
        break;
      case 'shortanswer':
        questionType = QuestionType.shortAnswer;
        break;
      case 'dialoguecompletion':
        questionType = QuestionType.dialogueCompletion;
        break;
      case 'essay':
        questionType = QuestionType.essay;
        break;
      case 'sentencerewriting':
        questionType = QuestionType.sentenceRewriting;
        break;
      default:
        throw Exception('Invalid question type: $typeString');
    }

    return Question(
      id: map['id'] ?? 0,
      type: questionType,
      text: map['text'] ?? '',
      options: map['options'] != null
          ? List<String>.from(jsonDecode(map['options']))
          : null,
      correctAnswer: map['correct_answer'] ?? '',
      explanation: map['explanation'] ?? '',
      category: map['category'] ?? '',
      prompt: map['prompt'] ?? '',
      originalSentence: map['original_sentence'] ?? '',
      subject: map['subject'] ?? '',
      year: map['year'] ?? 0,
      place: map['place'] ?? '',
    );
  }

  // Convert Question to map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'text': text,
      'options': options != null ? jsonEncode(options) : null,
      'correct_answer': correctAnswer,
      'explanation': explanation,
      'category': category,
      'prompt': prompt,
      'original_sentence': originalSentence,
      'subject': subject,
      'year': year,
      'place': place,
    };
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_prep/services/database_service.dart';

class SampleData {
  static Future<void> populateSampleQuestions() async {
    final dbService = DatabaseService();
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('questions_initialized') == true) {
      debugPrint('Questions already initialized');
      return;
    }
    // Check if database is already populated
    /* final existingQuestions = await dbService.getQuestions();
    if (existingQuestions.isNotEmpty) {
      debugPrint(
        'Database already populated with ${existingQuestions.length} questions.',
      );
      return;
    } */

    final questions = [
      // MCQs
      {
        'type': 'mcq',
        'text': 'Wild animals are ______ when they get angry.',
        'options': jsonEncode(['terrifying', 'terrified', 'fiercely']),
        'correct_answer': 'terrifying',
        'explanation':
            'The correct word is "terrifying," meaning causing fear, which fits the context.',
        'category': 'Vocabulary',
        'year': 2023,
        'place': 'Mandalay',
        "subject": "English",
      },
      {
        'type': 'mcq',
        'text': 'Thet Htar Thuza looked ______ and confident before the match.',
        'options': jsonEncode(['relaxed', 'relaxing', 'relaxation']),
        'correct_answer': 'relaxed',
        'explanation':
            '"Relaxed" describes a state of being calm and confident.',
        'category': 'Vocabulary',
        'year': 2023,
        'place': 'Mandalay',
        "subject": "English",
      },
      {
        'type': 'mcq',
        'text':
            'The early life struggles of famous writers are really ______ to me.',
        'options': jsonEncode(['fascinated', 'fascinating', 'fascination']),
        'correct_answer': 'fascinating',
        'explanation':
            '"Fascinating" describes something that captures interest.',
        'category': 'Vocabulary',
        'year': 2023,
        'place': 'Mandalay',
        "subject": "English",
      },
      {
        'type': 'mcq',
        'text':
            'The latest rise on unemployment has proved extremely ______ to the government.',
        'options': jsonEncode(['embarrassed', 'embarrassing', 'embarrassment']),
        'correct_answer': 'embarrassing',
        'explanation':
            '"Embarrassing" describes a situation that causes shame or discomfort.',
        'category': 'Vocabulary',
        'year': 2023,
        'place': 'Mandalay',
        "subject": "English",
      },
      // Fill-in-the-blank
      {
        'type': 'fillInTheBlank',
        'text': 'She has a profound h__________ of fascism.',
        'correct_answer': 'hatred',
        'explanation':
            'The word "hatred" fits the context and starts with "h".',
        'category': 'Vocabulary',
        'year': 2023,
        'place': 'Mandalay',
        "subject": "English",
      },
      {
        'type': 'fillInTheBlank',
        'text':
            'Watching the sun rise over the mountain was an almost m__________ experience.',
        'correct_answer': 'magical',
        'explanation':
            'The word "magical" fits the context and starts with "m".',
        'category': 'Vocabulary',
        'year': 2023,
        'place': 'Mandalay',
        "subject": "English",
      },
      {
        'type': 'fillInTheBlank',
        'text': 'The crime appears to have been m__________ by hatred.',
        'correct_answer': 'motivated',
        'explanation':
            'The word "motivated" fits the context and starts with "m".',
        'category': 'Comprehension',
        'year': 2023,
        'place': 'Mandalay',
        "subject": "English",
      },
      {
        'type': 'fillInTheBlank',
        'text': 'Positive and negative are two ______ of emotions.',
        'correct_answer': 'types',
        'explanation':
            'The word "types" fits the context of classifying emotions.',
        'category': 'Comprehension',
        'year': 2023,
        'place': 'Mandalay',
      },
      // Short Answer
      {
        'type': 'shortAnswer',
        'text': 'What are the two main types of emotions?',
        'correct_answer': 'Positive and negative',
        'explanation':
            'The passage states that emotions are classified into positive and negative.',
        'category': 'Comprehension',
        'year': 2023,
        'place': 'Mandalay',
        "subject": "English",
      },
      {
        'type': 'shortAnswer',
        'text': 'What does emotion mean?',
        'correct_answer':
            'Emotion refers to a feeling or state of mind, such as joy, anger, or love.',
        'explanation':
            'Emotions are described as feelings like joy, anger, or love in the passage.',
        'category': 'Comprehension',
        'year': 2023,
        'place': 'Mandalay',
        "subject": "English",
      },
      {
        'type': 'shortAnswer',
        'text': 'What are four positive emotions?',
        'correct_answer': 'Delight, joy, sympathy, and love',
        'explanation':
            'The passage lists delight, joy, sympathy, and love as examples of positive emotions.',
        'category': 'Comprehension',
        'year': 2023,
        'place': 'Mandalay',
        "subject": "English",
      },
      {
        "type": "dialogueCompletion",
        "text": "Complete the dialogue: A: How was your weekend? B: __________",
        "options": jsonEncode([
          "It was great, thanks!",
          "I was very busy.",
          "Not sure.",
        ]),
        "correct_answer": "It was great, thanks!",
        "explanation":
            "The response should be positive and conversational, matching the friendly tone of A's question.",
        "category": "Comprehension",
        'year': 2023,
        'place': 'Mandalay',
        "subject": "English",
      },
      {
        "type": "essay",
        "text": "Write an essay on the importance of education in Myanmar.",
        "prompt":
            "Discuss how education impacts personal and societal development (150-200 words).",
        "correct_answer":
            "A well-structured essay discussing personal growth, career opportunities, and societal benefits like economic development.",
        "explanation":
            "The essay should cover key points like personal empowerment and societal progress.",
        "category": "Writing",
        'year': 2023,
        'place': 'Mandalay',
        "subject": "English",
      },
      {
        "type": "sentenceRewriting",
        "text": "Rewrite the sentence using the word 'confident'.",
        "original_sentence": "She was sure of her abilities before the exam.",
        "correct_answer": "She was confident of her abilities before the exam.",
        "explanation":
            "The word 'confident' is a synonym for 'sure' in this context, maintaining the sentence's meaning.",
        "category": "Grammar",
        'year': 2023,
        'place': 'Mandalay',
        "subject": "English",
      },
      //
      {
        "type": "mcq",
        "text": "x^2 + 5x + 6 = 0",
        "options": jsonEncode(["x = -2, -3", "x = 2, 3", "x = -1, -6"]),
        "correct_answer": "x = -2, -3",
        "explanation":
            "Solve the quadratic equation using factorization: (x + 2)(x + 3) = 0, so x = -2, -3.",
        "category": "Algebra",
        'year': 2023,
        'place': 'Mandalay',
        "subject": "Mathematics",
      },
      {
        "type": "shortAnswer",
        "text": "What is the derivative of f(x) = 3x^2 + 2x + 1?",
        "correct_answer": "6x + 2",
        "explanation": "Using the power rule, the derivative is 6x + 2.",
        "category": "Calculus",
        'year': 2023,
        'place': 'Mandalay',
        "subject": "Mathematics",
      },
      {
        "type": "mcq",
        "text": "မြန်မာစာတွင် စာလုံးပေါင်းများကို မည်သို့ခွဲခြားသနည်း။",
        "options": jsonEncode([
          "အသံထွက်ဖြင့်",
          "စာလုံးဖွဲ့စည်းမှုဖြင့်",
          "အနက်ဖြင့်",
        ]),
        "correct_answer": "စာလုံးဖွဲ့စည်းမှုဖြင့်",
        "explanation":
            "မြန်မာစာတွင် စာလုံးပေါင်းများကို စာလုံးဖွဲ့စည်းမှုဖြင့် ခွဲခြားသည်။",
        "category": "Grammar",
        'year': 2023,
        'place': 'Mandalay',
        "subject": "Myanmar Language",
      },
      {
        "type": "shortAnswer",
        "text": "မြန်မာစာပိုဒ်တစ်ပိုဒ်တွင် အဓိကအချက်ကို မည်သို့ဖော်ပြသနည်း။",
        "correct_answer":
            "အဓိကအချက်ကို ရှင်းလင်းစွာ ဖော်ပြပြီး ဥပမာများဖြင့် ထောက်ခံသည်။",
        "explanation":
            "စာပိုဒ်တွင် အဓိကအချက်ကို ရှင်းလင်းစွာ ဖော်ပြပြီး ဥပမာများဖြင့် ထောက်ခံရမည်။",
        "category": "Comprehension",
        'year': 2023,
        'place': 'Mandalay',
        "subject": "Myanmar Language",
      },
    ];

    for (var question in questions) {
      await dbService.insertQuestion(question);
    }
    await prefs.setBool('questions_initialized', true);
    debugPrint('Inserted ${questions.length} sample questions.');
  }

  // Development-only method to force re-population
  static Future<void> forcePopulateSampleQuestions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('questions_initialized', false); // Reset flag
    await DatabaseService().clearAllQuestions(); // Clear existing questions
    await populateSampleQuestions();
  }
}

// Provider for DatabaseService
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_prep/core/models/question.dart';
import 'package:smart_prep/services/database_service.dart';

final databaseServiceProvider = Provider<DatabaseService>(
  (ref) => DatabaseService(),
);

// Provider for list of questions
final questionsProvider = FutureProvider<List<Question>>((ref) async {
  final dbService = ref.watch(databaseServiceProvider);
  final questionMaps = await dbService.getQuestions();
  return questionMaps.map((map) => Question.fromMap(map)).toList();
});

// StateProvider for current question index
final currentQuestionIndexProvider = StateProvider<int>((ref) => 0);

// StateProvider for user answers (map of question ID to answer)
final userAnswersProvider = StateProvider<Map<int, String>>((ref) => {});

// StateProvider for score
final scoreProvider = StateProvider<int>((ref) => 0);

// Notifier for quiz state management
class QuizNotifier extends StateNotifier<QuizState> {
  QuizNotifier(this.ref) : super(QuizState());

  final Ref ref;

  // Submit answer and update score
  void submitAnswer(Question question, String userAnswer) {
    final isCorrect = _isAnswerCorrect(question, userAnswer);
    state = state.copyWith(
      userAnswers: {...state.userAnswers, question.id: userAnswer},
      score: isCorrect ? state.score + 1 : state.score,
    );

    ref.read(userAnswersProvider.notifier).state = state.userAnswers;
    ref.read(scoreProvider.notifier).state = state.score;
    ref.read(currentQuestionIndexProvider.notifier).state++;
  }

  bool _isAnswerCorrect(Question question, String userAnswer) {
    if (question.type == QuestionType.essay ||
        question.type == QuestionType.sentenceRewriting) {
      // Basic comparison (to be improved with AI in Phase 3)
      return userAnswer.trim().toLowerCase().contains(
        question.correctAnswer.trim().toLowerCase(),
      );
    }
    return userAnswer.trim().toLowerCase() ==
        question.correctAnswer.trim().toLowerCase();
  }

  /* void submitAnswer(Question question, String userAnswer) {
    final isCorrect =
        userAnswer.trim().toLowerCase() ==
        question.correctAnswer.trim().toLowerCase();
    state = state.copyWith(
      userAnswers: {...state.userAnswers, question.id: userAnswer},
      score: isCorrect ? state.score + 1 : state.score,
    );

    // Update providers
    ref.read(userAnswersProvider.notifier).state = state.userAnswers;
    ref.read(scoreProvider.notifier).state = state.score;

    // Move to next question
    ref.read(currentQuestionIndexProvider.notifier).state++;
  } */

  // Reset quiz
  void resetQuiz() {
    state = QuizState();
    ref.read(currentQuestionIndexProvider.notifier).state = 0;
    ref.read(userAnswersProvider.notifier).state = {};
    ref.read(scoreProvider.notifier).state = 0;
  }
}

class QuizState {
  final Map<int, String> userAnswers;
  final int score;

  QuizState({this.userAnswers = const {}, this.score = 0});

  QuizState copyWith({Map<int, String>? userAnswers, int? score}) {
    return QuizState(
      userAnswers: userAnswers ?? this.userAnswers,
      score: score ?? this.score,
    );
  }
}

// Provider for QuizNotifier
final quizProvider = StateNotifierProvider<QuizNotifier, QuizState>(
  (ref) => QuizNotifier(ref),
);

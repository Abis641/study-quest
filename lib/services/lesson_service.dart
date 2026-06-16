// lib/services/lesson_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/lesson_model.dart';
import '../models/quiz_model.dart';
import '../config/firebase_config.dart';

final lessonServiceProvider =
    Provider<LessonService>((ref) => LessonService());

class LessonService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _lessons =>
      _db.collection(FirebaseConfig.lessonsCollection);
  CollectionReference get _quizzes =>
      _db.collection(FirebaseConfig.quizzesCollection);

  Future<List<LessonModel>> getLessonsForSubject(String subjectId) async {
    final snap = await _lessons
        .where('subjectId', isEqualTo: subjectId)
        .orderBy('order')
        .get();
    return snap.docs
        .map((d) => LessonModel.fromMap(d.data() as Map<String, dynamic>))
        .toList();
  }

  Future<LessonModel?> getLesson(String lessonId) async {
    final doc = await _lessons.doc(lessonId).get();
    if (!doc.exists) return null;
    return LessonModel.fromMap(doc.data() as Map<String, dynamic>);
  }

  Future<QuizModel?> getQuiz(String quizId) async {
    final doc = await _quizzes.doc(quizId).get();
    if (!doc.exists) return null;
    return QuizModel.fromMap(doc.data() as Map<String, dynamic>);
  }

  Future<List<QuizModel>> getQuizzesForSubject(String subjectId) async {
    final snap = await _quizzes
        .where('subjectId', isEqualTo: subjectId)
        .get();
    return snap.docs
        .map((d) => QuizModel.fromMap(d.data() as Map<String, dynamic>))
        .toList();
  }

  /// Seeds the database with sample content if not already present.
  Future<void> seedSampleData() async {
    final existing = await _lessons.limit(1).get();
    if (existing.docs.isNotEmpty) return; // Already seeded

    final batch = _db.batch();

    // ── MATH LESSONS ───────────────────────────────────────────────────────
    final mathLesson1 = LessonModel(
      id: 'math_multiplication',
      title: 'Multiplication Magic',
      subjectId: 'math',
      description: 'Learn how to multiply numbers like a wizard!',
      emoji: '✖️',
      order: 1,
      content: [
        const LessonContent(
          type: 'text',
          content:
              'Multiplication is like adding the same number many times. 3 × 4 means adding 3 four times: 3+3+3+3 = 12!',
        ),
        const LessonContent(
          type: 'fact',
          content:
              '⭐ Fun Fact: The × symbol for multiplication was invented in 1631 by William Oughtred!',
        ),
        const LessonContent(
          type: 'text',
          content:
              'Multiplication Table Tips:\n• Any number × 1 = that number\n• Any number × 0 = 0\n• Any number × 10 = just add a zero!',
        ),
        const LessonContent(
          type: 'fact',
          content: '🎯 Challenge: What is 7 × 8? Think about it... it\'s 56!',
        ),
      ],
      quizId: 'quiz_math_multiplication',
      createdAt: DateTime.now(),
    );

    final mathLesson2 = LessonModel(
      id: 'math_division',
      title: 'Division Quest',
      subjectId: 'math',
      description: 'Split numbers into equal groups!',
      emoji: '➗',
      order: 2,
      content: [
        const LessonContent(
          type: 'text',
          content:
              'Division is sharing equally. If you have 12 cookies and 4 friends, each friend gets 12 ÷ 4 = 3 cookies!',
        ),
        const LessonContent(
          type: 'fact',
          content: '⭐ Division and multiplication are opposite operations!',
        ),
        const LessonContent(
          type: 'text',
          content:
              'Key Division Rules:\n• Any number ÷ 1 = that number\n• Any number ÷ itself = 1\n• Zero ÷ any number = 0',
        ),
      ],
      quizId: 'quiz_math_division',
      createdAt: DateTime.now(),
    );

    // ── SCIENCE LESSONS ────────────────────────────────────────────────────
    final scienceLesson1 = LessonModel(
      id: 'science_solar_system',
      title: 'The Solar System',
      subjectId: 'science',
      description: 'Explore our cosmic neighborhood!',
      emoji: '🪐',
      order: 1,
      content: [
        const LessonContent(
          type: 'text',
          content:
              'Our solar system has 8 planets orbiting the Sun. In order: Mercury, Venus, Earth, Mars, Jupiter, Saturn, Uranus, and Neptune.',
        ),
        const LessonContent(
          type: 'fact',
          content:
              '⭐ Fun Fact: Jupiter is so big that all other planets could fit inside it!',
        ),
        const LessonContent(
          type: 'text',
          content:
              'The Sun is a star at the center of our solar system. It is 109 times wider than Earth and about 4.6 billion years old!',
        ),
        const LessonContent(
          type: 'fact',
          content:
              '🚀 Saturn\'s rings are made of ice and rock pieces. The rings are about 30 meters thick but stretch 282,000 km wide!',
        ),
      ],
      quizId: 'quiz_science_solar_system',
      createdAt: DateTime.now(),
    );

    // ── ENGLISH LESSONS ────────────────────────────────────────────────────
    final englishLesson1 = LessonModel(
      id: 'english_vocabulary',
      title: 'Power Vocabulary',
      subjectId: 'english',
      description: 'Supercharge your word power!',
      emoji: '📝',
      order: 1,
      content: [
        const LessonContent(
          type: 'text',
          content:
              'Vocabulary is the collection of words you know! The more words you learn, the better you can express yourself.',
        ),
        const LessonContent(
          type: 'fact',
          content:
              '⭐ The English language has over 170,000 words currently in use!',
        ),
        const LessonContent(
          type: 'text',
          content:
              'Today\'s Power Words:\n• Enormous - very large\n• Vibrant - full of energy and life\n• Curious - eager to learn or know things\n• Magnificent - impressively beautiful\n• Persevere - continue despite difficulties',
        ),
      ],
      quizId: 'quiz_english_vocabulary',
      createdAt: DateTime.now(),
    );

    // ── GEOGRAPHY LESSONS ──────────────────────────────────────────────────
    final geoLesson1 = LessonModel(
      id: 'geography_continents',
      title: 'The 7 Continents',
      subjectId: 'geography',
      description: 'Travel the world without leaving home!',
      emoji: '🗺️',
      order: 1,
      content: [
        const LessonContent(
          type: 'text',
          content:
              'Earth has 7 continents: Africa, Antarctica, Asia, Australia (Oceania), Europe, North America, and South America.',
        ),
        const LessonContent(
          type: 'fact',
          content:
              '⭐ Asia is the largest continent — it covers about 30% of Earth\'s land area!',
        ),
        const LessonContent(
          type: 'text',
          content:
              'Fun Continent Facts:\n🌍 Africa has the most countries (54)\n🌏 Australia is both a continent AND a country\n❄️ Antarctica has no permanent human residents\n🌎 South America has the Amazon rainforest',
        ),
        const LessonContent(
          type: 'fact',
          content:
              '🗺️ All 7 continents end with the same letter they start with: AsiA, EuropE, AntarcticA, AfricA, AmericA, AustraliA, OceaniA!',
        ),
      ],
      quizId: 'quiz_geography_continents',
      createdAt: DateTime.now(),
    );

    // Add lessons to batch
    for (final lesson in [
      mathLesson1,
      mathLesson2,
      scienceLesson1,
      englishLesson1,
      geoLesson1,
    ]) {
      batch.set(_lessons.doc(lesson.id), lesson.toMap());
    }

    // ── QUIZZES ────────────────────────────────────────────────────────────
    final quizzes = _buildSampleQuizzes();
    for (final quiz in quizzes) {
      batch.set(_quizzes.doc(quiz.id), quiz.toMap());
    }

    await batch.commit();
  }

  List<QuizModel> _buildSampleQuizzes() {
    return [
      // Math Multiplication Quiz
      QuizModel(
        id: 'quiz_math_multiplication',
        title: 'Multiplication Challenge',
        subjectId: 'math',
        lessonId: 'math_multiplication',
        createdAt: DateTime.now(),
        questions: [
          const QuizQuestion(
            id: 'q1',
            question: 'What is 7 × 8?',
            type: QuestionType.multipleChoice,
            options: ['48', '54', '56', '64'],
            correctAnswer: '56',
            explanation: '7 × 8 = 56. Think of it as 7 groups of 8!',
            xpReward: 10,
            coinReward: 5,
          ),
          const QuizQuestion(
            id: 'q2',
            question: 'Any number multiplied by 0 equals 0.',
            type: QuestionType.trueFalse,
            options: ['True', 'False'],
            correctAnswer: 'True',
            explanation:
                'Yes! Zero times anything is always zero. You have 0 groups of anything = nothing!',
            xpReward: 10,
            coinReward: 5,
          ),
          const QuizQuestion(
            id: 'q3',
            question: 'What is 9 × 9?',
            type: QuestionType.multipleChoice,
            options: ['72', '81', '90', '99'],
            correctAnswer: '81',
            explanation:
                '9 × 9 = 81. A cool trick: 9×9, the digits of the answer (8+1) always add up to 9!',
            xpReward: 10,
            coinReward: 5,
          ),
          const QuizQuestion(
            id: 'q4',
            question: 'What is 12 × 10?',
            type: QuestionType.multipleChoice,
            options: ['100', '110', '120', '130'],
            correctAnswer: '120',
            explanation:
                'To multiply by 10, just add a zero! 12 → 120.',
            xpReward: 10,
            coinReward: 5,
          ),
          const QuizQuestion(
            id: 'q5',
            question: '6 × 7 = ___',
            type: QuestionType.fillBlank,
            options: ['42'],
            correctAnswer: '42',
            explanation:
                '6 × 7 = 42. This is one of the trickiest facts to remember!',
            xpReward: 15,
            coinReward: 8,
          ),
        ],
      ),

      // Math Division Quiz
      QuizModel(
        id: 'quiz_math_division',
        title: 'Division Master',
        subjectId: 'math',
        lessonId: 'math_division',
        createdAt: DateTime.now(),
        questions: [
          const QuizQuestion(
            id: 'dq1',
            question: 'What is 24 ÷ 6?',
            type: QuestionType.multipleChoice,
            options: ['3', '4', '5', '6'],
            correctAnswer: '4',
            explanation:
                '24 ÷ 6 = 4. Think: how many groups of 6 fit in 24? Four groups!',
            xpReward: 10,
            coinReward: 5,
          ),
          const QuizQuestion(
            id: 'dq2',
            question: 'Division is the opposite of multiplication.',
            type: QuestionType.trueFalse,
            options: ['True', 'False'],
            correctAnswer: 'True',
            explanation:
                'Correct! 3×4=12 and 12÷4=3. They are inverse operations!',
            xpReward: 10,
            coinReward: 5,
          ),
          const QuizQuestion(
            id: 'dq3',
            question: 'What is 56 ÷ 8?',
            type: QuestionType.multipleChoice,
            options: ['6', '7', '8', '9'],
            correctAnswer: '7',
            explanation:
                '56 ÷ 8 = 7. Recall: 7 × 8 = 56, so 56 ÷ 8 = 7!',
            xpReward: 10,
            coinReward: 5,
          ),
        ],
      ),

      // Science Solar System Quiz
      QuizModel(
        id: 'quiz_science_solar_system',
        title: 'Solar System Explorer',
        subjectId: 'science',
        lessonId: 'science_solar_system',
        createdAt: DateTime.now(),
        questions: [
          const QuizQuestion(
            id: 'sq1',
            question: 'How many planets are in our solar system?',
            type: QuestionType.multipleChoice,
            options: ['7', '8', '9', '10'],
            correctAnswer: '8',
            explanation:
                'There are 8 planets: Mercury, Venus, Earth, Mars, Jupiter, Saturn, Uranus, Neptune.',
            xpReward: 10,
            coinReward: 5,
          ),
          const QuizQuestion(
            id: 'sq2',
            question: 'Which planet is the largest in our solar system?',
            type: QuestionType.multipleChoice,
            options: ['Saturn', 'Earth', 'Jupiter', 'Neptune'],
            correctAnswer: 'Jupiter',
            explanation:
                'Jupiter is the largest planet — all other planets could fit inside it!',
            xpReward: 10,
            coinReward: 5,
          ),
          const QuizQuestion(
            id: 'sq3',
            question: 'The Sun is a planet.',
            type: QuestionType.trueFalse,
            options: ['True', 'False'],
            correctAnswer: 'False',
            explanation:
                'The Sun is a star, not a planet! It is at the center of our solar system.',
            xpReward: 10,
            coinReward: 5,
          ),
          const QuizQuestion(
            id: 'sq4',
            question: 'Which planet has famous rings?',
            type: QuestionType.multipleChoice,
            options: ['Mars', 'Saturn', 'Venus', 'Mercury'],
            correctAnswer: 'Saturn',
            explanation:
                'Saturn has the most visible rings, made of ice and rock pieces!',
            xpReward: 10,
            coinReward: 5,
          ),
        ],
      ),

      // English Vocabulary Quiz
      QuizModel(
        id: 'quiz_english_vocabulary',
        title: 'Word Power Quiz',
        subjectId: 'english',
        lessonId: 'english_vocabulary',
        createdAt: DateTime.now(),
        questions: [
          const QuizQuestion(
            id: 'eq1',
            question: 'What does "enormous" mean?',
            type: QuestionType.multipleChoice,
            options: ['Very small', 'Very fast', 'Very large', 'Very quiet'],
            correctAnswer: 'Very large',
            explanation:
                '"Enormous" means extremely large. An elephant is enormous!',
            xpReward: 10,
            coinReward: 5,
          ),
          const QuizQuestion(
            id: 'eq2',
            question: '"Curious" means eager to learn or know things.',
            type: QuestionType.trueFalse,
            options: ['True', 'False'],
            correctAnswer: 'True',
            explanation:
                'Yes! A curious person always wants to find out more about the world.',
            xpReward: 10,
            coinReward: 5,
          ),
          const QuizQuestion(
            id: 'eq3',
            question: 'Which word means "to continue despite difficulties"?',
            type: QuestionType.multipleChoice,
            options: ['Vibrant', 'Persevere', 'Magnificent', 'Curious'],
            correctAnswer: 'Persevere',
            explanation:
                '"Persevere" means to keep going even when things are tough. Never give up!',
            xpReward: 10,
            coinReward: 5,
          ),
        ],
      ),

      // Geography Continents Quiz
      QuizModel(
        id: 'quiz_geography_continents',
        title: 'Continents Challenge',
        subjectId: 'geography',
        lessonId: 'geography_continents',
        createdAt: DateTime.now(),
        questions: [
          const QuizQuestion(
            id: 'gq1',
            question: 'How many continents are there on Earth?',
            type: QuestionType.multipleChoice,
            options: ['5', '6', '7', '8'],
            correctAnswer: '7',
            explanation:
                'There are 7 continents: Africa, Antarctica, Asia, Australia, Europe, North America, and South America.',
            xpReward: 10,
            coinReward: 5,
          ),
          const QuizQuestion(
            id: 'gq2',
            question: 'Which continent is the largest?',
            type: QuestionType.multipleChoice,
            options: ['Africa', 'North America', 'Asia', 'Europe'],
            correctAnswer: 'Asia',
            explanation:
                'Asia is the largest continent, covering about 30% of Earth\'s land area!',
            xpReward: 10,
            coinReward: 5,
          ),
          const QuizQuestion(
            id: 'gq3',
            question: 'Australia is both a continent and a country.',
            type: QuestionType.trueFalse,
            options: ['True', 'False'],
            correctAnswer: 'True',
            explanation:
                'That\'s right! Australia is unique because it\'s the only country that is also an entire continent.',
            xpReward: 10,
            coinReward: 5,
          ),
          const QuizQuestion(
            id: 'gq4',
            question: 'Which continent has the most countries?',
            type: QuestionType.multipleChoice,
            options: ['Europe', 'Asia', 'Africa', 'South America'],
            correctAnswer: 'Africa',
            explanation: 'Africa has 54 countries — more than any other continent!',
            xpReward: 10,
            coinReward: 5,
          ),
        ],
      ),
    ];
  }
}

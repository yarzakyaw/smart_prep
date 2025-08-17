import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static Database? _database;
  static const String _dbName = 'smart_prep_main.db';
  static const String _tableQuestions = 'questions';
  static const String _tableProgress = 'progress';
  static const int _dbVersion = 1; // Database version

  // Initialize database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getApplicationDocumentsDirectory();
    final path = join(dbPath.path, _dbName);

    final prefs = await SharedPreferences.getInstance();
    final currentVersion = prefs.getInt('db_version') ?? 0;
    debugPrint('Current DB version: $currentVersion');

    if (currentVersion < _dbVersion) {
      // Delete old database if version is outdated
      await databaseFactory.deleteDatabase(path);
      await prefs.setInt('db_version', _dbVersion);
      await prefs.setBool(
        'questions_initialized',
        false,
      ); // Reset for new questions
    }

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableQuestions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            type TEXT,
            text TEXT,
            options TEXT,
            correct_answer TEXT,
            explanation TEXT,
            category TEXT,
            prompt TEXT,
            original_sentence TEXT,
            subject TEXT,
            year INTEGER,
            place TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE $_tableProgress (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            mode TEXT,
            subject TEXT,
            score INTEGER,
            total_questions INTEGER,
            incorrect_answers TEXT,
            timestamp INTEGER
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < newVersion) {
          await db.execute('DROP TABLE IF EXISTS $_tableQuestions');
          await db.execute('DROP TABLE IF EXISTS $_tableProgress');
          await db.execute('''
            CREATE TABLE $_tableQuestions (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              type TEXT,
              text TEXT,
              options TEXT,
              correct_answer TEXT,
              explanation TEXT,
              category TEXT,
              prompt TEXT,
              original_sentence TEXT,
              subject TEXT,
              year INTEGER,
              place TEXT
            )
          ''');
          await db.execute('''
            CREATE TABLE $_tableProgress (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              mode TEXT,
              subject TEXT,
              score INTEGER,
              total_questions INTEGER,
              incorrect_answers TEXT,
              timestamp INTEGER
            )
          ''');
        }
      },
    );
  }

  // Insert a question
  Future<void> insertQuestion(Map<String, dynamic> question) async {
    final db = await database;
    await db.insert(
      _tableQuestions,
      question,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Retrieve all questions
  Future<List<Map<String, dynamic>>> getQuestions() async {
    final db = await database;
    return await db.query(_tableQuestions);
  }

  // Retrieve questions by type
  Future<List<Map<String, dynamic>>> getQuestionsByType(
    String type,
    String? subject,
  ) async {
    final db = await database;
    if (type == 'mixed') {
      if (subject == null || subject == 'all') {
        return await db.query(_tableQuestions);
      }
      return await db.query(
        _tableQuestions,
        where: 'subject = ?',
        whereArgs: [subject],
      );
    }
    if (subject == null || subject == 'all') {
      return await db.query(
        _tableQuestions,
        where: 'type = ?',
        whereArgs: [type],
      );
    }
    return await db.query(
      _tableQuestions,
      where: 'type = ? AND subject = ?',
      whereArgs: [type, subject],
    );
  }
  /* Future<List<Map<String, dynamic>>> getQuestionsByType(String type) async {
    final db = await database;
    if (type == 'mixed') {
      return await db.query(_tableQuestions);
    }
    return await db.query(
      _tableQuestions,
      where: 'type = ?',
      whereArgs: [type],
    );
  } */

  // Retrieve questions by category
  Future<List<Map<String, dynamic>>> getQuestionsByCategory(
    String category,
    String? subject,
  ) async {
    final db = await database;
    if (subject == null || subject == 'all') {
      return await db.query(
        _tableQuestions,
        where: 'category = ?',
        whereArgs: [category],
      );
    }
    return await db.query(
      _tableQuestions,
      where: 'category = ? AND subject = ?',
      whereArgs: [category, subject],
    );
  }
  /*   Future<List<Map<String, dynamic>>> getQuestionsByCategory(
    String category,
  ) async {
    final db = await database;
    return await db.query(
      _tableQuestions,
      where: 'category = ?',
      whereArgs: [category],
    );
  } */

  Future<void> insertProgress(Map<String, dynamic> progress) async {
    final db = await database;
    await db.insert(
      _tableProgress,
      progress,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getProgress() async {
    final db = await database;
    return await db.query(_tableProgress, orderBy: 'timestamp DESC');
  }

  Future<void> clearProgress() async {
    final db = await database;
    await db.delete(_tableProgress);
  }

  // Delete all questions from the table
  Future<void> clearAllQuestions() async {
    final db = await database;
    await db.delete(_tableQuestions);
  }
}

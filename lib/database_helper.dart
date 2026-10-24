// database_helper.dart — Model (Diary) + จัดการ SQLite (CRUD ครบ)
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// ---------------- Model ----------------
class Diary {
  final int? id;
  final String title;
  final String content;
  final String date;
  final String mood;
  final String? qoute;

  Diary({
    this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.mood,
    this.qoute,
  });

  // object -> Map (เขียนลง DB)
  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'content': content,
    'date': date,
    'mood': mood,
    'qoute': qoute,
  };

  // Map (จาก DB) -> object   (?? กันข้อมูลเก่าที่ยังไม่มี mood)
  factory Diary.fromMap(Map<String, dynamic> map) => Diary(
    id: map['id'],
    title: map['title'],
    content: map['content'],
    date: map['date'],
    mood: map['mood'] ?? 'เฉยๆ',
    qoute: map['qoute'],
  );
}

// ---------------- SQLite ----------------
class DatabaseHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'diary.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        // ตารางสร้างครั้งเดียว -> แก้โครงสร้างแล้วต้องถอนแอปรันใหม่
        return db.execute(
          'CREATE TABLE diaries('
          'id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'title TEXT NOT NULL, '
          'content TEXT NOT NULL, '
          'date TEXT NOT NULL, '
          'qoute TEXT, '
          'mood TEXT NOT NULL)',
        );
      },
    );
  }

  // CREATE
  static Future<void> insert(Diary diary) async {
    final db = await database;
    await db.insert('diaries', diary.toMap());
  }

  // READ (ใหม่สุดขึ้นก่อน)
  static Future<List<Diary>> getAll() async {
    final db = await database;
    final maps = await db.query('diaries', orderBy: 'id DESC');
    return maps.map((m) => Diary.fromMap(m)).toList();
  }

  // UPDATE
  static Future<void> update(Diary diary) async {
    final db = await database;
    await db.update(
      'diaries',
      diary.toMap(),
      where: 'id = ?',
      whereArgs: [diary.id],
    );
  }

  // DELETE
  static Future<void> delete(int id) async {
    final db = await database;
    await db.delete('diaries', where: 'id = ?', whereArgs: [id]);
  }
}

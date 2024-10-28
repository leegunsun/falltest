import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDB extends GetxController {
  // 싱글톤 패턴 구현
  LocalDB._privateConstructor();
  static final LocalDB _instance = LocalDB._privateConstructor();
  factory LocalDB() => _instance;

  static late Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  // 데이터베이스 초기화 메서드
  static Future<Database> initDatabase() async {
    // 데이터베이스 경로 설정
    String dbPath = await getDatabasesPath();
    String path = join(dbPath, 'example.db');

    // 데이터베이스 열기, 없으면 생성
    _database = await openDatabase(
        path,
        version: 1,
        onConfigure: _onConfigure, // 추가 설정
        onCreate: _onCreate,       // 테이블 생성
        onUpgrade: _onUpgrade,     // 스키마 업데이트
        onDowngrade: _onDowngrade, // 스키마 다운그레이드
        onOpen: _onOpen            // 데이터베이스 열릴 때 호출
    );

    return _database!;
  }

  // onConfigure 콜백 (예: 외래 키 활성화)
  static Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  // 테이블 생성 onCreate 콜백
  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY,
        name TEXT,
        age INTEGER
      )
    ''');
  }

  // 스키마 변경 onUpgrade 콜백
  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      // 예제: 테이블에 새로운 컬럼 추가
      await db.execute('ALTER TABLE users ADD COLUMN email TEXT');
    }
  }

  // 다운그레이드 콜백
  static Future<void> _onDowngrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion > newVersion) {
      // 특정 상황에 맞는 다운그레이드 로직 작성
    }
  }

  // 데이터베이스가 열릴 때 호출되는 onOpen 콜백
  static Future<void> _onOpen(Database db) async {
    // 데이터베이스가 열렸을 때 실행할 로직
  }

  Future<int> insertUser(Map<String, dynamic> user) async {

    int? _result =  await _database?.insert('users', user);

    return _result ?? -1;
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {

    List<Map<String, Object?>>? _result =  await _database?.query('users');

    return _result ?? [{}];
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const String _databaseName = 'upi_analyzer.db';
  static const int _databaseVersion = 1;

  static final DatabaseHelper _instance = DatabaseHelper._internal();

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = path.join(await getDatabasesPath(), _databaseName);
    return openDatabase(
      dbPath,
      version: _databaseVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE raw_messages (
        id TEXT PRIMARY KEY,
        raw_body TEXT NOT NULL,
        sanitized_body TEXT,
        timestamp INTEGER NOT NULL,
        status TEXT NOT NULL DEFAULT 'pending'
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        transaction_id TEXT PRIMARY KEY,
        raw_message_id TEXT,
        amount REAL NOT NULL,
        currency TEXT NOT NULL DEFAULT 'INR',
        transaction_type TEXT NOT NULL,
        provider TEXT,
        merchant TEXT,
        category TEXT,
        confidence REAL NOT NULL,
        timestamp INTEGER NOT NULL,
        FOREIGN KEY (raw_message_id) REFERENCES raw_messages (id)
      )
    ''');
  }

  Future<int> insertRawMessage(Map<String, dynamic> rawMessage) async {
    final db = await database;
    return db.insert(
      'raw_messages',
      rawMessage,
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<int> updateRawMessage(Map<String, dynamic> rawMessage) async {
    final db = await database;
    final id = rawMessage['id'];
    final payload = Map<String, dynamic>.from(rawMessage)..remove('id');
    return db.update('raw_messages', payload, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getRawMessagesByStatus(
    String status,
  ) async {
    final db = await database;
    return db.query(
      'raw_messages',
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'timestamp ASC',
    );
  }

  Future<int> insertTransaction(Map<String, dynamic> transaction) async {
    final db = await database;
    return db.insert(
      'transactions',
      transaction,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateTransaction(Map<String, dynamic> transaction) async {
    final db = await database;
    final id = transaction['transaction_id'];
    final payload = Map<String, dynamic>.from(transaction)
      ..remove('transaction_id');
    return db.update(
      'transactions',
      payload,
      where: 'transaction_id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getTransactions() async {
    final db = await database;
    return db.query('transactions', orderBy: 'timestamp DESC');
  }

  Future<int> getTransactionCount() async {
    final db = await database;
    final rows = await db.rawQuery(
      'SELECT COUNT(*) AS count FROM transactions',
    );
    return (rows.first['count'] as int?) ?? 0;
  }

  Future<int> getRawMessageCount() async {
    final db = await database;
    final rows = await db.rawQuery(
      'SELECT COUNT(*) AS count FROM raw_messages',
    );
    return (rows.first['count'] as int?) ?? 0;
  }

  Future<List<Map<String, dynamic>>> getTransactionsByTimeRange(
    int startTimestamp,
    int endTimestamp,
  ) async {
    final db = await database;
    return db.query(
      'transactions',
      where: 'timestamp BETWEEN ? AND ?',
      whereArgs: [startTimestamp, endTimestamp],
      orderBy: 'timestamp DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getMonthlyExpenses() async {
    final db = await database;
    final range = _currentMonthRange();
    return db.rawQuery(
      '''
      SELECT
        strftime('%d', timestamp / 1000, 'unixepoch', 'localtime') AS day,
        SUM(amount) AS total
      FROM transactions
      WHERE (transaction_type = 'expense' OR transaction_type = 'DEBIT')
        AND timestamp BETWEEN ? AND ?
      GROUP BY day
      ORDER BY day ASC
    ''',
      [range.start, range.end],
    );
  }

  Future<List<Map<String, dynamic>>> getCategoryDistribution() async {
    final db = await database;
    final range = _currentMonthRange();
    return db.rawQuery(
      '''
      SELECT
        COALESCE(NULLIF(category, ''), 'Other') AS category,
        SUM(amount) AS total
      FROM transactions
      WHERE (transaction_type = 'expense' OR transaction_type = 'DEBIT')
        AND timestamp BETWEEN ? AND ?
      GROUP BY COALESCE(NULLIF(category, ''), 'Other')
      ORDER BY total DESC
    ''',
      [range.start, range.end],
    );
  }

  Future<List<Map<String, dynamic>>> getTopMerchants() async {
    final db = await database;
    final range = _currentMonthRange();
    return db.rawQuery(
      '''
      SELECT
        COALESCE(NULLIF(merchant, ''), 'Unknown') AS merchant,
        SUM(amount) AS total
      FROM transactions
      WHERE (transaction_type = 'expense' OR transaction_type = 'DEBIT')
        AND timestamp BETWEEN ? AND ?
      GROUP BY COALESCE(NULLIF(merchant, ''), 'Unknown')
      ORDER BY total DESC
      LIMIT 5
    ''',
      [range.start, range.end],
    );
  }

  Future<void> clearDemoData() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(
        'transactions',
        where: 'transaction_id LIKE ? OR transaction_id LIKE ?',
        whereArgs: ['demo_%', 'mock_%'],
      );
      await txn.delete(
        'raw_messages',
        where: 'id LIKE ? OR id LIKE ?',
        whereArgs: ['demo_%', 'mock_%'],
      );
    });
    print("Database cleared safely for demo reset.");
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  ({int start, int end}) _currentMonthRange() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final nextMonth = DateTime(now.year, now.month + 1, 1);
    return (
      start: start.millisecondsSinceEpoch,
      end: nextMonth.millisecondsSinceEpoch - 1,
    );
  }
}
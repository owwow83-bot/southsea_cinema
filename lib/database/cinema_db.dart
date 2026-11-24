import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:southsea_cinema/models/booking.dart';

class CinemaDatabase {
  CinemaDatabase._internal();

  static final CinemaDatabase instance = CinemaDatabase._internal();

  static Database? _database;

  // Allows tests to supply an in-memory database.
  void setDatabase(Database? db) {
    _database = db;
  }

  Future<Database> get database async {
    final Database? cachedDatabase = _database;

    if (cachedDatabase != null) {
      return cachedDatabase;
    }

    final Database db = await _initDB('cinema_data.db');

    _database = db;
    return db;
  }

  Future<Database> _initDB(String fileName) async {
    final String folder = await getDatabasesPath();
    final String filePath = join(folder, fileName);

    return openDatabase(
      filePath,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> createTables(
    Database db,
    int version,
  ) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS bookings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        booking_number INTEGER NOT NULL,
        summary TEXT NOT NULL,
        total REAL NOT NULL,
        date TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createDB(
    Database db,
    int version,
  ) async {
    await createTables(db, version);

    // Sample bookings appear only on first creation.
    await db.insert('bookings', {
      'booking_number': 1003,
      'summary': '2 x Interstellar',
      'total': 21.00,
      'date': '18/11/2026 18:30',
    });

    await db.insert('bookings', {
      'booking_number': 1002,
      'summary': '1 x Inception',
      'total': 9.50,
      'date': '15/11/2026 19:00',
    });

    await db.insert('bookings', {
      'booking_number': 1001,
      'summary': '1 x Interstellar',
      'total': 10.50,
      'date': '12/11/2026 17:00',
    });
  }

  Future<int> insertBooking(Booking booking) async {
    final Database db = await database;

    return db.insert(
      'bookings',
      booking.toMap(),
    );
  }

  Future<List<Booking>> getAllBookings() async {
    final Database db = await database;

    final List<Map<String, Object?>> records = await db.query(
      'bookings',
      orderBy: 'booking_number DESC',
    );

    return records.map((row) => Booking.fromMap(row)).toList();
  }

  Future<int> getNextBookingNumber() async {
    final Database db = await database;

    final List<Map<String, Object?>> records = await db.rawQuery(
      'SELECT MAX(booking_number) AS max_num '
      'FROM bookings',
    );

    if (records.isEmpty) {
      return 1001;
    }

    final Object? maxValue = records.first['max_num'];

    if (maxValue == null) {
      return 1001;
    }

    return (maxValue as int) + 1;
  }

  Future<void> close() async {
    final Database? cachedDatabase = _database;

    if (cachedDatabase != null) {
      await cachedDatabase.close();
      _database = null;
    }
  }
}

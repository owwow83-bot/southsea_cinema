import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:southsea_cinema/models/booking.dart';
import 'package:southsea_cinema/models/booking_item.dart';

/// Local cinema booking database. Version 2 adds the booking_items table.
class CinemaDatabase {
  CinemaDatabase._internal();

  static final CinemaDatabase instance = CinemaDatabase._internal();
  static const int schemaVersion = 2;
  static Database? _database;

  /// Use a temporary in-memory database in tests instead of Android storage.
  void setDatabase(Database? db) {
    _database = db;
  }

  Future<Database> get database async {
    final Database? cached = _database;
    if (cached != null) return cached;

    final String directory = await getDatabasesPath();
    final String path = join(directory, 'cinema_data.db');
    final Database opened = await openDatabaseAtPath(path);
    _database = opened;
    return opened;
  }

  /// A separate path/factory makes a real version-1 to version-2 upgrade
  /// test possible on Windows, without an Android phone or emulator.
  Future<Database> openDatabaseAtPath(
    String path, {
    DatabaseFactory? factory,
  }) async {
    final DatabaseFactory chosenFactory = factory ?? databaseFactory;
    return chosenFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: schemaVersion,
        onConfigure: configureDatabase,
        onCreate: _createDB,
        onUpgrade: upgradeDatabase,
      ),
    );
  }

  Future<void> configureDatabase(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// Used by production onCreate and by tests (without sample records).
  /// Passing version 1 deliberately creates only the Worksheet 7 table.
  Future<void> createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS bookings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        booking_number INTEGER NOT NULL,
        summary TEXT NOT NULL,
        total REAL NOT NULL,
        date TEXT NOT NULL
      )
    ''');

    if (version >= 2) {
      await _createBookingItemsTable(db);
    }
  }

  Future<void> _createBookingItemsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS booking_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        booking_id INTEGER NOT NULL REFERENCES bookings(id),
        movie_id TEXT NOT NULL,
        movie_title TEXT NOT NULL,
        unit_price REAL NOT NULL CHECK (unit_price >= 0),
        quantity INTEGER NOT NULL CHECK (quantity > 0)
      )
    ''');
  }

  Future<void> _createDB(Database db, int version) async {
    await createTables(db, version);

    // Preserve the three Worksheet 7 sample bookings on new installs.
    // These old-format entries intentionally have no booking_items rows.
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

  Future<void> upgradeDatabase(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2 && newVersion >= 2) {
      // Do not drop or modify the customer's existing bookings.
      await _createBookingItemsTable(db);
    }
  }

  /// Keep the Worksheet 7 method for existing model/database tests.
  Future<int> insertBooking(Booking booking) async {
    final Database db = await database;
    return db.insert('bookings', booking.toMap());
  }

  /// Save the parent and every purchased movie as one atomic operation.
  Future<int> saveBookingWithItems(
    Booking booking,
    List<BookingItem> items,
  ) async {
    if (items.isEmpty) {
      throw ArgumentError('A booking must contain at least one movie.');
    }

    final Database db = await database;
    return db.transaction((Transaction transaction) async {
      final int bookingId = await transaction.insert(
        'bookings',
        booking.toMap(),
      );

      for (final BookingItem item in items) {
        await transaction.insert(
          'booking_items',
          item.toMapForBooking(bookingId),
        );
      }
      return bookingId;
    });
  }

  Future<List<Booking>> getAllBookings() async {
    final Database db = await database;
    final List<Map<String, Object?>> records = await db.query(
      'bookings',
      orderBy: 'booking_number DESC',
    );
    return records.map(Booking.fromMap).toList();
  }

  Future<List<BookingItem>> getItemsForBooking(int bookingId) async {
    final Database db = await database;
    final List<Map<String, Object?>> records = await db.query(
      'booking_items',
      where: 'booking_id = ?',
      whereArgs: [bookingId],
      orderBy: 'id ASC',
    );
    return records.map(BookingItem.fromMap).toList();
  }

  Future<int> getNextBookingNumber() async {
    final Database db = await database;
    final List<Map<String, Object?>> rows = await db.rawQuery(
      'SELECT MAX(booking_number) AS max_num FROM bookings',
    );
    final Object? maxValue = rows.first['max_num'];
    return maxValue == null ? 1001 : (maxValue as int) + 1;
  }

  Future<void> close() async {
    final Database? current = _database;
    if (current != null) {
      await current.close();
      _database = null;
    }
  }
}

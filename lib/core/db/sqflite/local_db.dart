import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LocalDb {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'customer_app.db');

    return await openDatabase(
      path,
      version: 5,

      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE cartitems (
            id INTEGER PRIMARY KEY AUTOINCREMENT,

            menu_id INTEGER,
            name TEXT,

            price REAL,
            takeaway_price REAL,
            delivery_price REAL,

            quantity INTEGER,

            menu_variation TEXT,
            choices TEXT,

            deal_details TEXT
          )
        ''');
      },

      onUpgrade: (db, oldVersion, newVersion) async {

        // VERSION 3
        if (oldVersion < 3) {
          await db.execute('''
            ALTER TABLE cartitems
            ADD COLUMN price REAL
          ''');

          await db.execute('''
            ALTER TABLE cartitems
            ADD COLUMN takeaway_price REAL
          ''');

          await db.execute('''
            ALTER TABLE cartitems
            ADD COLUMN delivery_price REAL
          ''');

          await db.execute('''
            ALTER TABLE cartitems
            ADD COLUMN menu_variation TEXT
          ''');
        }

        // VERSION 4
        if (oldVersion < 4) {
          await db.execute('''
            ALTER TABLE cartitems
            ADD COLUMN choices TEXT
          ''');
        }

        // VERSION 5
        if (oldVersion < 5) {
          await db.execute('''
            ALTER TABLE cartitems
            ADD COLUMN deal_details TEXT
          ''');
        }
      },
    );
  }
}
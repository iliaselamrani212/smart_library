import 'package:smart_library/models/books_model.dart';
import 'package:smart_library/models/user_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper{
  final databaseName = "books.db";

  String user = '''
   CREATE TABLE users (
   usrId INTEGER PRIMARY KEY AUTOINCREMENT,
   fullName TEXT,
   email TEXT UNIQUE, 
   usrPassword TEXT,
   profilePicture TEXT
   )
   ''';

  String mybooks = '''
   CREATE TABLE mybooks (
    id TEXT,
    usrId INTEGER,
    title TEXT,
    authors TEXT,
    thumbnail TEXT,
    description TEXT,
    category TEXT,
    status TEXT,
    pages INTEGER,
    totalPages INTEGER,
    addedDate TEXT,
    PRIMARY KEY (id, usrId),
    FOREIGN KEY (usrId) REFERENCES users(usrId)
   )
   ''';

  String favorites = '''
    CREATE TABLE favorites (
      id TEXT,
      usrId INTEGER,
      title TEXT,
      authors TEXT,
      thumbnail TEXT,
      description TEXT,
      category TEXT,
      status TEXT,
      pages INTEGER,
      totalPages INTEGER,
      addedDate TEXT,
      PRIMARY KEY (id, usrId),
      FOREIGN KEY (usrId) REFERENCES users(usrId)
    )
  ''';

  String reading_history = '''
   CREATE TABLE reading_history (
   id	INTEGER	PRIMARY	KEY AUTOINCREMENT,
   bookId	TEXT,
   usrId INTEGER,
   startDate	TEXT,
   endDate	TEXT,
   status	TEXT,
   FOREIGN KEY (usrId) REFERENCES users(usrId)
   )
   ''';
   
  String notes = '''
    CREATE TABLE notes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      usrId INTEGER,
      bookId TEXT,
      pageNumber INTEGER, 
      noteText TEXT, 
      date TEXT, 
      content TEXT,
      createdAt TEXT,
      FOREIGN KEY (usrId) REFERENCES users(usrId)
    )
   ''';

  String daily_reading_log = '''
    CREATE TABLE daily_reading_log (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      usrId INTEGER,
      bookId TEXT,
      pagesRead INTEGER,
      logDate TEXT,
      FOREIGN KEY (usrId) REFERENCES users(usrId)
    )
   ''';

  Future<Database> initDB ()async{
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, databaseName);

    return openDatabase(path, version: 12, 
    onCreate: (db,version)async{
      await db.execute(user);
      await db.execute(mybooks);
      await db.execute(favorites);
      await db.execute(reading_history);
      await db.execute(notes);
      await db.execute(daily_reading_log);
    },
    onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 5) {
           try {
             await db.execute("ALTER TABLE mybooks ADD COLUMN totalPages INTEGER DEFAULT 0");
             await db.execute("ALTER TABLE favorites ADD COLUMN totalPages INTEGER DEFAULT 0");
           } catch (e) {
             print("Migration error v5 (ignored if columns exist): $e");
           }
        }
        if (oldVersion < 6) {
          try {
             await db.execute("ALTER TABLE mybooks ADD COLUMN addedDate TEXT");
          } catch (e) {
             print("Migration error v6: $e");
          }
        }
        if (oldVersion < 7) {
          try {
             await db.execute("ALTER TABLE favorites ADD COLUMN addedDate TEXT");
          } catch (e) {
             print("Migration error v7: $e");
          }
        }
        if (oldVersion < 8) {
           try {
             await db.execute("ALTER TABLE notes ADD COLUMN pageNumber INTEGER DEFAULT 0");
           } catch (e) {
             print("Migration error v8 (ignored if column exists): $e");
           }
        }
        if (oldVersion < 9) {
           try {
             await db.execute("ALTER TABLE notes ADD COLUMN noteText TEXT DEFAULT ''");
           } catch (e) {
             print("Migration error v9 (ignored if column exists): $e");
           }
        }
        if (oldVersion < 10) {
           try {
             await db.execute("ALTER TABLE notes ADD COLUMN date TEXT DEFAULT ''");
           } catch (e) {
             print("Migration error v10 (ignored if column exists): $e");
           }
        }
        if (oldVersion < 11) {
           try {
             await db.execute(daily_reading_log);
           } catch (e) {
             print("Migration error v11 (ignored if table exists): $e");
           }
        }
        if (oldVersion < 12) {
           try {
             await db.execute("ALTER TABLE users ADD COLUMN profilePicture TEXT");
           } catch (e) {
             print("Migration error v12 (ignored if column exists): $e");
           }
        }
      },
    );
  }

  Future<bool> authenticate(Users usr)async{
    final Database db = await initDB();
    var result = await db.rawQuery("select * from users where email = '${usr.email}' AND usrPassword = '${usr.password}' ");
    if(result.isNotEmpty){
      return true;
    }else{
      return false;
    }
  }

  Future<int> createUser(Users usr)async{
    final Database db = await initDB();
    return db.insert("users", usr.toMap());
  }

  Future<Users?> getUser(String email)async{
    final Database db = await initDB();
    var res = await db.query("users",where: "email = ?", whereArgs: [email]);
    return res.isNotEmpty? Users.fromMap(res.first):null;
  }

  Future<int> updateUser(Users usr) async {
    final Database db = await initDB();
    return await db.update(
      "users",
      {
        "fullName": usr.fullName,
        "email": usr.email,
        "usrPassword": usr.password,
        "profilePicture": usr.profilePicture,
      },
      where: "usrId = ?",
      whereArgs: [usr.usrId],
    );
  }

  Future<int> insertFavorite(Book book, int usrId) async {
    final Database db = await initDB();
    final Map<String, dynamic> bookMap = book.toMap();
    bookMap['usrId'] = usrId;
    bookMap['addedDate'] ??= DateTime.now().toIso8601String();
    return db.insert("favorites", bookMap,
    conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> removeFavorite(String id, int usrId) async {
    final Database db = await initDB();
    return db.delete("favorites", where: "id = ? AND usrId = ?", whereArgs: [id, usrId],
    );
  }

  Future<List<Book>> getFavorites(int usrId) async {
    final Database db = await initDB();
    final List<Map<String, dynamic>> maps = await db.query(
      "favorites",
      where: "usrId = ?",
      whereArgs: [usrId],
    );

    return List.generate(maps.length, (i) {
      return Book.fromMap(maps[i]);
    });
  }


  Future<List<Book>> getUserBooks(int usrId) async {
    final Database db = await initDB();
    final List<Map<String, dynamic>> maps = await db.query(
      "mybooks",
      where: "usrId = ?",
      whereArgs: [usrId],
    );

    return List.generate(maps.length, (i) {
      return Book.fromMap(maps[i]);
    });
  }

  Future<int> insertUserBook(Book book, int usrId) async {
    final Database db = await initDB();
    final Map<String, dynamic> bookMap = book.toMap();
    bookMap['usrId'] = usrId;
    bookMap['addedDate'] ??= DateTime.now().toIso8601String();
    
    return db.insert(
      "mybooks",
      bookMap,
      conflictAlgorithm: ConflictAlgorithm.replace, 
    );
  }


  Future<int> updateUserBook(Book book, int usrId) async {
    final Database db = await initDB();
    final Map<String, dynamic> bookMap = book.toMap();

    return await db.update(
      "mybooks",
      bookMap,
      where: "id = ? AND usrId = ?",
      whereArgs: [book.id, usrId],
    );
  }

  Future<int> removeUserBook(String id, int usrId) async {
    final Database db = await initDB();
    return db.delete(
      "mybooks",
      where: "id = ? AND usrId = ?",
      whereArgs: [id, usrId],
    );
  }

  Future<List<Map<String, dynamic>>> getReadingHistory(int usrId) async {
    final Database db = await initDB();
    return await db.rawQuery('''
      SELECT 
        rh.id,
        rh.bookId,
        rh.usrId,
        rh.startDate,
        rh.endDate,
        rh.status,
        mb.title,
        mb.thumbnail
      FROM reading_history rh
      LEFT JOIN mybooks mb ON rh.bookId = mb.id AND rh.usrId = mb.usrId
      WHERE rh.usrId = ?
      ORDER BY rh.startDate DESC
    ''', [usrId]);
  }

  Future<void> updateReadingHistory(String bookId, int usrId, String status) async {
     final Database db = await initDB();
     await db.insert("reading_history", {
       "bookId": bookId,
       "usrId": usrId,
       "startDate": DateTime.now().toIso8601String(),
       "status": status,
     });
  }

  Future<void> updatePageProgress(String bookId, int usrId, int newPage) async {
     final Database db = await initDB();
     
     var res = await db.query("mybooks", columns: ['pages'], where: "id = ? AND usrId = ?", whereArgs: [bookId, usrId]);
     int currentPages = 0;
     if (res.isNotEmpty && res.first['pages'] != null) {
       currentPages = res.first['pages'] as int;
     }

     int delta = newPage - currentPages;

     if (delta > 0) {
       await db.insert("daily_reading_log", {
         "usrId": usrId,
         "bookId": bookId,
         "pagesRead": delta,
         "logDate": DateTime.now().toIso8601String(),
       });
     }

     await db.update("mybooks", {"pages": newPage}, where: "id = ? AND usrId = ?", whereArgs: [bookId, usrId]);
  }
  
  Future<int> getPagesReadThisMonth(int usrId) async {
    final Database db = await initDB();
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1).toIso8601String();
    
    final result = await db.rawQuery('''
      SELECT SUM(pagesRead) as total 
      FROM daily_reading_log 
      WHERE usrId = ? AND logDate >= ?
    ''', [usrId, startOfMonth]);
    
    if (result.isNotEmpty && result.first['total'] != null) {
      return result.first['total'] as int;
    }
    return 0;
  }

  Future<void> updateBookState(String bookId, int usrId, String status) async {
    final Database db = await initDB();
    await db.update("mybooks", {"status": status}, where: "id = ? AND usrId = ?", whereArgs: [bookId, usrId]);
  }

  Future<List<Map<String, dynamic>>> getNotes(int usrId) async {
     final Database db = await initDB();
     return await db.query("notes", where: "usrId = ?", whereArgs: [usrId]);
  }

  Future<List<Map<String, dynamic>>> getBookNotes(int usrId, String bookId) async {
     final Database db = await initDB();
     return await db.query("notes", where: "usrId = ? AND bookId = ?", whereArgs: [usrId, bookId]);
  }

  Future<int> insertNote(Map<String, dynamic> note) async {
     final Database db = await initDB();
     return await db.insert("notes", note);
  }

  Future<int> deleteNote(int id) async {
     final Database db = await initDB();
     return await db.delete("notes", where: "id = ?", whereArgs: [id]);
  }

  Future<int> updateNote(Map<String, dynamic> note) async {
    final Database db = await initDB();
    return await db.update(
      "notes",
      note,
      where: "id = ?",
      whereArgs: [note['id']],
    );
  }

  Future<Map<String, int>> getMonthlyReadingStats(int usrId) async {
    final Database db = await initDB();
    try {
      final result = await db.rawQuery('''
        SELECT substr(logDate, 1, 7) as month, SUM(pagesRead) as total
        FROM daily_reading_log
        WHERE usrId = ?
        GROUP BY month
      ''', [usrId]);

      Map<String, int> stats = {};
      for (var row in result) {
        if (row['month'] != null && row['total'] != null) {
          stats[row['month'] as String] = row['total'] as int;
        }
      }
      return stats;
    } catch (e) {
      print("Error fetching monthly stats: $e");
      return {};
    }
  }


Future<void> deleteTable(String tableName) async {
  try {
    final Database db = await initDB();
    await db.execute("DROP TABLE IF EXISTS $tableName");
    print("Table $tableName deleted successfully.");
  } catch (e) {
    print("Error deleting table $tableName: $e");
  }
}
}
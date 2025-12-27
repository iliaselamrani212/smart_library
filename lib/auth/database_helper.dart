import 'package:smart_library/models/books_model.dart';
import 'package:smart_library/models/user_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper{
  final databaseName = "books.db";

  //Tables

// Update this string in your Tables section
  String user = '''
    CREATE TABLE users (
    usrId INTEGER PRIMARY KEY AUTOINCREMENT,
    fullName TEXT,
    email TEXT UNIQUE,
    usrPassword TEXT
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
      PRIMARY KEY (id, usrId),
      FOREIGN KEY (usrId) REFERENCES users(usrId)
    )
  ''';

 String reading_history = '''
   CREATE TABLE reading_history (
   id	INTEGER	PRIMARY	KEY,
   bookId	INTEGER,
   startDate	TEXT,
   endDate	TEXT,
   status	TEXT,
   )
   ''';

String notesTable = '''
  CREATE TABLE notes (
    noteId INTEGER PRIMARY KEY AUTOINCREMENT,
    usrId INTEGER,
    bookTitle TEXT,
    pageNumber TEXT,
    noteText TEXT,
    date TEXT,
    FOREIGN KEY (usrId) REFERENCES users(usrId)
  )
''';


// 3. Add these functions to handle Notes
Future<int> insertNote(Map<String, dynamic> note) async {
  final Database db = await initDB();
  return await db.insert("notes", note);
}

Future<List<Map<String, dynamic>>> getNotes(int usrId) async {
  final Database db = await initDB();
  return await db.query("notes", where: "usrId = ?", whereArgs: [usrId]);
}

Future<int> deleteNote(int noteId) async {
  final Database db = await initDB();
  return await db.delete("notes", where: "noteId = ?", whereArgs: [noteId]);
}

  //Create a connection to the database
Future<Database> initDB ()async{
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, databaseName);

    return openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute(user);
      await db.execute(favorites);
      await db.execute(mybooks);
      await db.execute(notesTable); // <--- YOU MUST ADD THIS LINE
    });
  }

  //Function

  //Authentication
 // Authentication using Email instead of Username
Future<bool> authenticate(Users usr) async {
  final Database db = await initDB();
  // Changed usrName to email
  var result = await db.rawQuery(
      "SELECT * FROM users WHERE email = ? AND usrPassword = ?",
      [usr.email, usr.password] // Using parameterized queries for security
  );
  return result.isNotEmpty;
}

// Get User details by Email
Future<Users?> getUser(String email) async {
  final Database db = await initDB();
  var res = await db.query("users", where: "email = ?", whereArgs: [email]);
  return res.isNotEmpty ? Users.fromMap(res.first) : null;
}

  //Sign up
  Future<int> createUser(Users usr)async{
    final Database db = await initDB();
    return db.insert("users", usr.toMap());
  }


 

  // Insert a book into favorites
  Future<int> insertFavorite(Book book, int usrId) async {
    final Database db = await initDB();
    return db.insert("favorites", {
      ...book.toMap(),
      "usrId": usrId,
    },
    conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Remove a book from favorites by its id
  Future<int> removeFavorite(String id, int usrId) async {
    final Database db = await initDB();
    return db.delete("favorites", where: "id = ? AND usrId = ?", whereArgs: [id, usrId],
    );
  }

  // Retrieve all favorite books
  //had lfunction hia bach kan affichiw list dial favorit
  Future<List<Book>> getFavorites(int usrId) async {
    final Database db = await initDB();
    final List<Map<String, dynamic>> maps = await db.query(
      "favorites",
      where: "usrId = ?",
      whereArgs: [usrId],
    );

    return List.generate(maps.length, (i) {
      return Book(
        id: maps[i]['id'],
        title: maps[i]['title'],
        authors: maps[i]['authors'].toString().split(', '),
        thumbnail: maps[i]['thumbnail'],
        description: maps[i]['description'],
      );
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
    return Book(
      id: maps[i]['id'],
      title: maps[i]['title'],
      authors: maps[i]['authors'].toString().split(', '),
      thumbnail: maps[i]['thumbnail'],
      description: maps[i]['description'],
    );
  });
}

Future<int> insertUserBook(Book book, int usrId) async {
  final Database db = await initDB();
  return db.insert(
    "mybooks",
    {
      ...book.toMap(), // assuming Book has a toMap() function
      "usrId": usrId,
    },
    conflictAlgorithm: ConflictAlgorithm.replace, // avoid duplicates
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
import 'package:flutter/material.dart';
import 'package:smart_library/auth/database_helper.dart';
import 'package:smart_library/models/books_model.dart';

class MyBooksProvider with ChangeNotifier {
  List<Book> _myBooks = [];
  bool _isLoading = false;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<Book> get myBooks => _myBooks;
  bool get isLoading => _isLoading;

  Future<void> fetchUserBooks(int userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _myBooks = await _dbHelper.getUserBooks(userId);
    } catch (e) {
      debugPrint("Error fetching books: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addBook(Book book, int userId) async {
    try {
      await _dbHelper.insertUserBook(book, userId);
      // We reload to ensure consistency or just add to list
      _myBooks.add(book); 
      notifyListeners();
    } catch (e) {
      debugPrint("Error adding book: $e");
      rethrow;
    }
  }

  Future<void> removeBook(String bookId, int userId) async {
    try {
      await _dbHelper.removeUserBook(bookId, userId);
      _myBooks.removeWhere((b) => b.id == bookId);
      notifyListeners();
    } catch (e) {
      debugPrint("Error removing book: $e");
    }
  }
}

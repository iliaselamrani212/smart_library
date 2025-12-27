import 'package:flutter/material.dart';
import 'package:smart_library/auth/database_helper.dart';
import 'package:smart_library/models/books_model.dart';

class MyBooksProvider with ChangeNotifier {
  List<Book> _myBooks = [];
  // 1. Parallel list to hold the state strings
  List<String> _bookStates = []; 
  
  bool _isLoading = false;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<Book> get myBooks => _myBooks;
  List<String> get bookStates => _bookStates;
  bool get isLoading => _isLoading;

  Future<void> fetchUserBooks(int userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _myBooks = await _dbHelper.getUserBooks(userId);
      
      // 2. Load states in order. If a status is missing/null, DEFAULT to 'Not Read'
      _bookStates = _myBooks.map((book) => (book.status == null || book.status.isEmpty) ? 'Not Read' : book.status).toList();
      
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
      
      _myBooks.add(book);
      // 3. YOUR REQUIREMENT: When adding a book, default state is 'Not Read'
      _bookStates.add('Not Read'); 
      
      notifyListeners();
    } catch (e) {
      debugPrint("Error adding book: $e");
      rethrow;
    }
  }

  Future<void> updateState(int index, String bookId, int userId, String newStatus) async {
    // Safety check to prevent crashes
    if (index < 0 || index >= _bookStates.length) return;

    // Update local list
    _bookStates[index] = newStatus;
    notifyListeners();

    // Update Database in background
    await _dbHelper.updateBookState(bookId, userId, newStatus);
    await _dbHelper.updateReadingHistory(bookId, userId, newStatus);
  }

  Future<void> removeBook(String bookId, int userId) async {
    try {
      await _dbHelper.removeUserBook(bookId, userId);
      int index = _myBooks.indexWhere((b) => b.id == bookId);
      if (index != -1) {
        _myBooks.removeAt(index);
        _bookStates.removeAt(index); // Keep lists equal length
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Error removing book: $e");
    }
  }
}
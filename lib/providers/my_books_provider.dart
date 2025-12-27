import 'package:flutter/material.dart';
import 'package:smart_library/auth/database_helper.dart';
import 'package:smart_library/models/books_model.dart';

class MyBooksProvider with ChangeNotifier {
  List<Book> _myBooks = [];
  List<String> _bookStates = []; // Parallel list for status
  
  bool _isLoading = false;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<Book> get myBooks => _myBooks;
  List<String> get bookStates => _bookStates;
  bool get isLoading => _isLoading;

  // --- PAGE COUNTER LOGIC ---
  int _pagesCount = 0;
  int get pagesCount => _pagesCount;

  // 1. MEMORY ONLY: Use this when entering the screen
  void loadPagesCounter(int count) {
    _pagesCount = count;
    notifyListeners();
  }

  // 2. DATABASE & MEMORY: Use this when clicking "Save"
  // FIXED: Added userId as a parameter. Do not use 'context' here.
// 2. DATABASE & MEMORY: Use this when clicking "Save"
  Future<void> savePageToDatabase(String bookId, int userId, int page) async {
    // A. Update the Single Value (for the slider)
    _pagesCount = page;

    // B. Update the List in Memory (CRITICAL STEP)
    // We find the book and swap it with a new one containing the updated page count
    final index = _myBooks.indexWhere((b) => b.id == bookId);
    if (index != -1) {
      final oldBook = _myBooks[index];
      // Create a copy of the book with the new page number
      // NOTE: This assumes your Book model has a copyWith method or you reconstruct it.
      // If you don't have copyWith, we recreate it manually:
      final newBook = Book(
        id: oldBook.id,
        title: oldBook.title,
        authors: oldBook.authors,
        description: oldBook.description,
        category: oldBook.category,
        thumbnail: oldBook.thumbnail,
        status: oldBook.status,
        // UPDATE THE PAGE HERE
        pages: page, 
      );
      
      _myBooks[index] = newBook;
    }
    
    notifyListeners(); // Update the UI

    // C. Update Database permanently
    try {
      await _dbHelper.updatePageProgress(bookId, userId, page);
    } catch (e) {
      debugPrint("Error saving page: $e");
    }
  }

  // --- BOOK LIST LOGIC ---

  Future<void> fetchUserBooks(int userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _myBooks = await _dbHelper.getUserBooks(userId);
      // Load states in order. Default to 'Not Read'
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
      _bookStates.add('Not Read'); 
      notifyListeners();
    } catch (e) {
      debugPrint("Error adding book: $e");
      rethrow;
    }
  }

  Future<void> updateState(int index, String bookId, int userId, String newStatus) async {
    if (index < 0 || index >= _bookStates.length) return;

    _bookStates[index] = newStatus;
    notifyListeners();

    await _dbHelper.updateBookState(bookId, userId, newStatus);
    await _dbHelper.updateReadingHistory(bookId, userId, newStatus);
  }

  Future<void> removeBook(String bookId, int userId) async {
    try {
      await _dbHelper.removeUserBook(bookId, userId);
      int index = _myBooks.indexWhere((b) => b.id == bookId);
      if (index != -1) {
        _myBooks.removeAt(index);
        _bookStates.removeAt(index);
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Error removing book: $e");
    }
  }
}
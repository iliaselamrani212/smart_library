import 'package:flutter/material.dart';
import 'package:smart_library/auth/database_helper.dart';
import 'package:smart_library/models/books_model.dart';

class MyBooksProvider with ChangeNotifier {
  List<Book> _myBooks = [];
  List<String> _bookStates = [];
  bool _isLoading = false;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<Book> get myBooks => _myBooks;
  List<String> get bookStates => _bookStates;
  bool get isLoading => _isLoading;

  int _pagesCount = 0;
  int get pagesCount => _pagesCount;

  void loadPagesCounter(int count) {
    _pagesCount = count;
    notifyListeners();
  }

  Future<void> savePageToDatabase(String bookId, int userId, int page) async {
    _pagesCount = page;

    final index = _myBooks.indexWhere((b) => b.id == bookId);
    if (index != -1) {
      final oldBook = _myBooks[index];
      final newBook = oldBook.copyWith(pages: page);
      _myBooks[index] = newBook;
    }
    
    notifyListeners(); 

    try {
      await _dbHelper.updatePageProgress(bookId, userId, page);
    } catch (e) {
      debugPrint("Error saving page: $e");
    }
  }

  Future<void> fetchUserBooks(int userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _myBooks = await _dbHelper.getUserBooks(userId);
      _bookStates = _myBooks.map((book) => (book.status.isEmpty) ? 'Not Read' : book.status).toList();
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

  Future<void> updateBook(Book updatedBook, int userId) async {
    try {
      await _dbHelper.updateUserBook(updatedBook, userId);
      final index = _myBooks.indexWhere((b) => b.id == updatedBook.id);
      if (index != -1) {
        _myBooks[index] = updatedBook;
        _bookStates[index] = updatedBook.status;
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Error updating book: $e");
    }
  }

  Future<void> updateState(int index, String bookId, int userId, String newStatus) async {
    if (index < 0 || index >= _bookStates.length) return;

    _bookStates[index] = newStatus;
    
    if (newStatus == 'Finished') {
      final bookIndex = _myBooks.indexWhere((b) => b.id == bookId);
      if (bookIndex != -1) {
        final book = _myBooks[bookIndex];
        if (book.totalPages > 0 && book.pages < book.totalPages) {
          debugPrint("Auto-completing book: updating pages from ${book.pages} to ${book.totalPages}");
          _myBooks[bookIndex] = book.copyWith(pages: book.totalPages);
          await _dbHelper.updatePageProgress(bookId, userId, book.totalPages);
        }
      }
    }

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
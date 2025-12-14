import 'package:smart_library/auth/database_helper.dart';
import 'package:smart_library/models/books_model.dart';
import 'package:flutter/foundation.dart';

class FavoriteBooksProvider with ChangeNotifier {
  int? _currentUserId;
  List<Book> _favorites = [];
  bool _isLoading = true;

  List<Book> get favorites => _favorites;
  bool get isLoading => _isLoading;

  FavoriteBooksProvider() {
    loadFavorites();
  }

  void setCurrentUserId(int userId) {
    _currentUserId = userId;
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    _favorites = await DatabaseHelper().getFavorites(_currentUserId!);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addFavorite(Book book) async {
    try {
      await DatabaseHelper().insertFavorite(book, _currentUserId!);
      if (! _favorites.any((b) => b.id == book.id)) {
        _favorites.add(book);
      }
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<void> removeFavorite(String bookId) async {
    try {
      await DatabaseHelper().removeFavorite(bookId, _currentUserId!);
      _favorites.removeWhere((book) => book.id == bookId);
      notifyListeners();
    } catch (e) {
      // Handle error
    }
  }
}
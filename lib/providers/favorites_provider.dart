import 'package:smart_library/auth/database_helper.dart';
import 'package:smart_library/models/books_model.dart';
import 'package:flutter/foundation.dart';

class FavoriteBooksProvider with ChangeNotifier {
  int? _currentUserId;
  List<Book> _favorites = [];
  bool _isLoading = false; // Start as false to avoid infinite spinners if no user

  // Match the getter name used in MyBooksScreen
  List<Book> get favoriteBooks => _favorites;
  bool get isLoading => _isLoading;

  // Function to set user and immediately load their data
  void setCurrentUserId(int userId) {
    _currentUserId = userId;
    fetchFavorites(userId);
  }

  // Renamed to fetchFavorites to match the call in MyBooksScreen
  Future<void> fetchFavorites(int userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUserId = userId;
      _favorites = await DatabaseHelper().getFavorites(userId);
    } catch (e) {
      debugPrint("Error fetching favorites: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addFavorite(Book book) async {
    if (_currentUserId == null) return;
    
    try {
      await DatabaseHelper().insertFavorite(book, _currentUserId!);
      // Check if already in list to avoid duplicates in UI
      if (!_favorites.any((b) => b.id == book.id)) {
        _favorites.add(book);
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Error adding favorite: $e");
    }
  }

  Future<void> removeFavorite(String bookId) async {
    if (_currentUserId == null) return;

    try {
      await DatabaseHelper().removeFavorite(bookId, _currentUserId!);
      _favorites.removeWhere((book) => book.id == bookId);
      notifyListeners();
    } catch (e) {
      debugPrint("Error removing favorite: $e");
    }
  }

  // Check if a specific book is favorited (useful for the Heart icon color)
  bool isFavorite(String bookId) {
    return _favorites.any((book) => book.id == bookId);
  }
}
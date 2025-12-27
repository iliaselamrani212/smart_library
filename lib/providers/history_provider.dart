import 'package:flutter/material.dart';
import 'package:smart_library/auth/database_helper.dart';

class HistoryProvider with ChangeNotifier {
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = false;//to make sure the data base is free

  List<Map<String, dynamic>> get history => _history;
  bool get isLoading => _isLoading;

  Future<void> fetchHistory(int userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Using the join query we discussed earlier to get book titles/images
      _history = await DatabaseHelper().getReadingHistory(userId);
    } catch (e) {
      debugPrint("History Fetch Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
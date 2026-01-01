import 'package:flutter/material.dart';
import 'package:smart_library/auth/database_helper.dart';

class HistoryProvider with ChangeNotifier {
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get history => _history;
  bool get isLoading => _isLoading;

  Future<void> fetchHistory(int userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _history = await DatabaseHelper().getReadingHistory(userId);
      debugPrint("History fetched: ${_history.length} items");
      for (var item in _history) {
        debugPrint("History item: title=${item['title']}, thumbnail=${item['thumbnail']}, status=${item['status']}");
      }
    } catch (e) {
      debugPrint("History Fetch Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
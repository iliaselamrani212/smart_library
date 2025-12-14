import 'dart:convert';
import 'package:smart_library/models/books_model.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://www.googleapis.com/books/v1/volumes';

  // Fetch books from the API using a search query.
  Future<List<Book>> fetchBooks(String query) async {
    final response = await http.get(Uri.parse('$baseUrl?q=$query&maxResults=40'));  //  api fetches 40 results.
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> items = data['items'] ?? [];
      return items.map((item) => Book.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load books');
    }
  }
}
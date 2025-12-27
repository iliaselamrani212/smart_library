class Book {
  final String id;
  final String title;
  final List<dynamic> authors;
  final String thumbnail;
  final String description;
  final String categories; // Added for your database

  Book({
    required this.id,
    required this.title,
    required this.authors,
    required this.thumbnail,
    required this.description,
    required this.categories, // Required in constructor
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    // Google Books API typically returns categories as a List<String>
    final categoryList = json['volumeInfo']['categories'] as List<dynamic>?;
    
    return Book(
      id: json['id'] as String,
      title: json['volumeInfo']['title'] ?? "No Title",
      authors: json['volumeInfo']['authors'] ?? ["Unknown Author"],
      thumbnail: json['volumeInfo']['imageLinks'] != null
          ? json['volumeInfo']['imageLinks']['thumbnail']
          : '',
      description: json['volumeInfo']['description'] ?? '',
      // Join the list into a single string for simple SQLite storage
      categories: categoryList != null ? categoryList.join(', ') : 'General',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      // Convert list to comma-separated string for SQLite
      'authors': authors.map((author) => author.toString()).join(', '), 
      'thumbnail': thumbnail,
      'description': description,
      'categories': categories, // Match your DB column name
    };
  }
}
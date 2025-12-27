class Book {
  final String id;
  final String title;
  final List<dynamic> authors;
  final String thumbnail;
  final String description;
  final String category;
  final String status;
  final int pages; // 1. New Field

  Book({
    required this.id,
    required this.title,
    required this.authors,
    required this.thumbnail,
    required this.description,
    required this.category,
    this.status = 'Not Read',
    this.pages = 0, // 2. Default value is 0
  });

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id']?.toString() ?? '', 
      title: map['title']?.toString() ?? 'No Title', 
      authors: map['authors'] is String 
          ? (map['authors'] as String).split(', ') 
          : (map['authors'] as List<dynamic>?) ?? ["Unknown Author"],
      thumbnail: map['thumbnail']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      category: map['category']?.toString() ?? 'General', 
      status: map['status']?.toString() ?? 'Not Read',
      // 3. Database: If column is null, use 0
      pages: (map['pages'] as int?) ?? 0, 
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'authors': authors.join(', '), 
      'thumbnail': thumbnail,
      'description': description,
      'category': category,
      'status': status,
      'pages': pages, // 4. Save integer to DB
    };
  }

  factory Book.fromJson(Map<String, dynamic> json) {
    final volumeInfo = json['volumeInfo'];
    final categoryList = volumeInfo['categories'] as List<dynamic>?;
    
    return Book(
      id: json['id'] as String,
      title: volumeInfo['title'] ?? "No Title",
      authors: volumeInfo['authors'] ?? ["Unknown Author"],
      thumbnail: volumeInfo['imageLinks'] != null
          ? volumeInfo['imageLinks']['thumbnail']
          : '',
      description: volumeInfo['description'] ?? '',
      category: categoryList != null ? categoryList.join(', ') : 'General',
      status: 'Not Read',
      // 5. API: If 'pageCount' is missing, use 0
      pages: (volumeInfo['pageCount'] as int?) ?? 0, 
    );
  }

  // 6. CopyWith for updates
  Book copyWith({String? status, int? pages}) {
    return Book(
      id: id,
      title: title,
      authors: authors,
      thumbnail: thumbnail,
      description: description,
      category: category,
      status: status ?? this.status,
      pages: pages ?? this.pages, // Allows updating pages
    );
  }
}
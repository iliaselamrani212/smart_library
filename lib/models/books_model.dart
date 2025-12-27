class Book {
  final String id;
  final String title;
  final List<dynamic> authors;
  final String thumbnail;
  final String description;
  final String category;
  final String status;

  Book({
    required this.id,
    required this.title,
    required this.authors,
    required this.thumbnail,
    required this.description,
    required this.category,
    this.status = 'Not Read',
  });

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      // The ?? ensures that if the value is NULL, it becomes an empty String instead of crashing
      id: map['id']?.toString() ?? '', 
      title: map['title']?.toString() ?? 'No Title', 
      authors: map['authors'] is String 
          ? (map['authors'] as String).split(', ') 
          : (map['authors'] as List<dynamic>?) ?? ["Unknown Author"],
      thumbnail: map['thumbnail']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      category: map['category']?.toString() ?? 'General', 
      status: map['status']?.toString() ?? 'Not Read', 
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
    };
  }

  factory Book.fromJson(Map<String, dynamic> json) {
    final categoryList = json['volumeInfo']['categories'] as List<dynamic>?;
    
    return Book(
      id: json['id'] as String,
      title: json['volumeInfo']['title'] ?? "No Title",
      authors: json['volumeInfo']['authors'] ?? ["Unknown Author"],
      thumbnail: json['volumeInfo']['imageLinks'] != null
          ? json['volumeInfo']['imageLinks']['thumbnail']
          : '',
      description: json['volumeInfo']['description'] ?? '',
      category: categoryList != null ? categoryList.join(', ') : 'General',
      status: 'Not Read', // 3. API books start as 'Not Read'
    );
  }

  // 6. Added copyWith to easily update only the status
  Book copyWith({String? status}) {
    return Book(
      id: id,
      title: title,
      authors: authors,
      thumbnail: thumbnail,
      description: description,
      category: category,
      status: status ?? this.status,
    );
  }
}
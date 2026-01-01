class Book {
  final String id;
  final String title;
  final List<dynamic> authors;
  final String thumbnail;
  final String description;
  final String category;
  final String status;
  final int pages;
  final int totalPages;
  final String? addedDate;

  Book({
    required this.id,
    required this.title,
    required this.authors,
    required this.thumbnail,
    required this.description,
    required this.category,
    this.status = 'Not Read',
    this.pages = 0, 
    this.totalPages = 200,
    this.addedDate,
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
      pages: (map['pages'] as int?) ?? 0,
      totalPages: (map['totalPages'] as int?) ?? 200, 
      addedDate: map['addedDate'] as String?,
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
      'pages': pages, 
      'totalPages': totalPages,
      'addedDate': addedDate,
    };
  }

  factory Book.fromJson(Map<String, dynamic> json) {
    final volumeInfo = json['volumeInfo'];
    final categoryList = volumeInfo['categories'] as List<dynamic>?;
    
    int pCount = (volumeInfo['pageCount'] as int?) ?? 0;

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
      pages: 0,
      totalPages: pCount,
      addedDate: DateTime.now().toIso8601String(),
    );
  }

  Book copyWith({String? status, int? pages, int? totalPages, String? addedDate}) {
    return Book(
      id: id,
      title: title,
      authors: authors,
      thumbnail: thumbnail,
      description: description,
      category: category,
      status: status ?? this.status,
      pages: pages ?? this.pages,
      totalPages: totalPages ?? this.totalPages,
      addedDate: addedDate ?? this.addedDate,
    );
  }
}
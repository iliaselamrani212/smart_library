class Book {
  final String id;
  final String title;
  final List<dynamic> authors;
  final String thumbnail;
  final String description;

  Book({
    required this.id,
    required this.title,
    required this.authors,
    required this.thumbnail,
    required this.description,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] as String,
      title: json['volumeInfo']['title'] ?? "No Title",
      authors: json['volumeInfo']['authors'] ?? ["Unknown Author"],
      thumbnail: json['volumeInfo']['imageLinks'] != null
          ? json['volumeInfo']['imageLinks']['thumbnail']
          : '',
      description: json['volumeInfo']['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'authors': authors.map((author) => author.toString()).join(', '),
      'thumbnail': thumbnail,
      'description': description,
    };
  }

}
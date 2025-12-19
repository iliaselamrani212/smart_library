import 'package:flutter/material.dart';

class MyBooksScreen extends StatelessWidget {
  const MyBooksScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ================= FEATURED BOOKS (HAUT) =================
          // Ici le cœur reste SUR la photo
          const Text(
            'Featured Books',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: featuredBooks.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    // Image
                    Container(
                      width: 130,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: DecorationImage(
                          image: AssetImage('assets/images/test.jpg'),
                          fit: BoxFit.cover,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade300,
                            blurRadius: 8,
                            offset: const Offset(2, 4),
                          ),
                        ],
                      ),
                    ),
                    // Bouton Favori (Sur l'image)
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.favorite,
                          color: Colors.red,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 32),

          // ================= CATEGORIES =================
          const Text(
            'Categories',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return _categoryChip(categories[index]);
              },
            ),
          ),

          const SizedBox(height: 32),

          // ================= RECENTLY ADDED (BAS) =================
          // Ici le cœur est À DROITE de la carte
          const Text(
            'Recently Added',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentBooks.length,
            itemBuilder: (context, index) {
              final book = recentBooks[index];

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. IMAGE (Sans Stack, simple image)
                    Container(
                      height: 120,
                      width: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: AssetImage(book['image']!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // 2. TEXTE (Au milieu)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            book['title']!,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            book['author']!,
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            book['description']!,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),

                    // 3. BOUTON FAVORI (Tout à droite)
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.favorite, // Cœur plein rouge
                        color: Colors.red,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ================= CATEGORY CHIP =================
  static Widget _categoryChip(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ================= DATA =================

final List<String> featuredBooks = [
  'assets/images/test.jpg',
  'assets/images/test.png',
  'assets/images/test.png',
];

final List<String> categories = [
  'Short Stories',
  'Science Fiction',
  'Action',
  'Romance',
  'Fantasy',
];

final List<Map<String, String>> recentBooks = [
  {
    'title': 'The Double',
    'author': 'Fyodor Dostoyevsky',
    'description': 'The Double centers on a government clerk who goes mad...',
    'image': 'assets/images/2.jpg',
  },
  {
    'title': 'The Blazing World',
    'author': 'Margaret Cavendish',
    'description': 'The description of a new world...',
    'image': 'assets/images/2.jpg',
  },
  {
    'title': 'The Double',
    'author': 'Fyodor Dostoyevsky',
    'description': 'The Double centers on a government clerk who goes mad...',
    'image': 'assets/images/2.jpg',
  },
];
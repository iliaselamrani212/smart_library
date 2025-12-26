import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_library/providers/my_books_provider.dart';
import 'package:smart_library/providers/user_provider.dart';
import 'package:smart_library/models/books_model.dart';
import 'book_datails_screen.dart'; // Assurez-vous que ce fichier existe

class MyBooksScreen extends StatefulWidget {
  const MyBooksScreen({Key? key}) : super(key: key);

  @override
  State<MyBooksScreen> createState() => _MyBooksScreenState();
}

class _MyBooksScreenState extends State<MyBooksScreen> {
  // Variables pour stocker les choix de filtres
  String _selectedStatus = 'All';
  String _selectedSort = 'Newest';
  String _selectedAuthor = 'All'; 
  
  @override
  void initState() {
    super.initState();
    // Charger les livres au démarrage de l'écran
    WidgetsBinding.instance.addPostFrameCallback((_) {
       final userProvider = Provider.of<UserProvider>(context, listen: false);
       final userId = userProvider.currentUser?.usrId ?? 1; // Fallback ID for testing
       Provider.of<MyBooksProvider>(context, listen: false).fetchUserBooks(userId);
    });
  }

  // Fonction pour extraire les auteurs uniques de la liste de livres
  List<String> getUniqueAuthors(List<Book> books) {
    final authors = books.expand((book) => book.authors).map((a) => a.toString()).toSet().toList();
    return ['All', ...authors];
  }

  @override
  Widget build(BuildContext context) {
    // Consommer le provider
    final myBooksProvider = Provider.of<MyBooksProvider>(context);
    // On inverse la liste pour afficher les derniers ajouts en premier (si l'ID est chronologique)
    // Ou mieux, on s'assure que l'ajout se fait en fin de liste et on affiche la liste inversée
    final allBooks = myBooksProvider.myBooks.reversed.toList();
    final isLoading = myBooksProvider.isLoading;

    // TODO: Implémenter le filtrage réel ici si besoin avec _selectedStatus, etc.
    // Pour l'instant on affiche tout ou on filtre basiquement
    List<Book> filteredBooks = allBooks;
    if (_selectedAuthor != 'All') {
      filteredBooks = filteredBooks.where((book) => book.authors.contains(_selectedAuthor)).toList();
    }
    // Ajoutez d'autres logiques de tri/filtrage ici...

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ================= FEATURED BOOKS =================
                const Text(
                  'Featured Books',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
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
                          GestureDetector(
                            child: Container(
                              width: 130,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                image: DecorationImage(
                                  image: AssetImage('assets/images/test.jpg'),
                                  fit: BoxFit.cover,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => BookDetailsScreen()));
                            },
                          ),
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
                                color: Color(0xFFFF4757),
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
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
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

                // ================= RECENTLY ADDED + FILTER BUTTON =================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recently Added',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),

                    // --- BOUTON FILTRE ---
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.tune_rounded),
                        color: const Color(0xFF1F2937),
                        onPressed: () {
                          _showFilterModal(context, allBooks);
                        },
                      ),
                    ),
                  ],
                ),

                // Feedback visuel des filtres actifs
                if (_selectedStatus != 'All' || _selectedSort != 'Newest' || _selectedAuthor != 'All')
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Filtering by: $_selectedStatus • $_selectedAuthor • $_selectedSort',
                      style: const TextStyle(color: Color(0xFF4F46E5), fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),

                const SizedBox(height: 16),

                // Liste des livres
                filteredBooks.isEmpty 
                  ? const Center(child: Text("No books found. Add one!"))
                  : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredBooks.length,
                    itemBuilder: (context, index) {
                      final book = filteredBooks[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: GestureDetector(
                           onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookDetailsScreen(book: book),
                              ),
                            );
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 120,
                                width: 80,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    image: DecorationImage(
                                      image: (book.thumbnail.isNotEmpty && !book.thumbnail.startsWith('http')) 
                                          ? FileImage(File(book.thumbnail)) as ImageProvider
                                          : (book.thumbnail.isNotEmpty && book.thumbnail.startsWith('http')) 
                                            ? NetworkImage(book.thumbnail) 
                                            : const AssetImage('assets/images/test.jpg'), // Fallback
                                      fit: BoxFit.cover,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 5,
                                      ),
                                    ]),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      book.title,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF111827),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      book.authors.join(', '),
                                      style: const TextStyle(
                                        color: Color(0xFF4F46E5),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      book.description,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.blueGrey.shade400,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(
                                  Icons.favorite,
                                  color: Color(0xFFFF4757),
                                  size: 24,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
      ),
    );
  }

  // ================= BOITE DE DIALOGUE FILTRE =================
  void _showFilterModal(BuildContext context, List<Book> books) {
    // On récupère la liste des auteurs au moment d'ouvrir la modale
    final authorsList = getUniqueAuthors(books);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Permet à la modale de s'adapter au contenu si besoin
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Filter Books',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),

                  // --- SECTION 1: STATUS ---
                  const Text(
                    'Status',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    children: [
                      _buildFilterChip('All', _selectedStatus, (val) {
                        setModalState(() => _selectedStatus = val);
                      }),
                      _buildFilterChip('Reading', _selectedStatus, (val) {
                        setModalState(() => _selectedStatus = val);
                      }),
                      _buildFilterChip('To Read', _selectedStatus, (val) {
                        setModalState(() => _selectedStatus = val);
                      }),
                      _buildFilterChip('Finished', _selectedStatus, (val) {
                        setModalState(() => _selectedStatus = val);
                      }),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // --- SECTION 2: AUTHORS (NOUVEAU) ---
                  const Text(
                    'Author',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  // Utilisation de SingleChildScrollView horizontal car il peut y avoir beaucoup d'auteurs
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: authorsList.map((author) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: _buildFilterChip(author, _selectedAuthor, (val) {
                            setModalState(() => _selectedAuthor = val);
                          }),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // --- SECTION 3: DATE ---
                  const Text(
                    'Sort by Date',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildSortOption('Newest', Icons.arrow_downward, setModalState),
                      const SizedBox(width: 16),
                      _buildSortOption('Oldest', Icons.arrow_upward, setModalState),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // --- BOUTON APPLIQUER ---
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1F2937),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        setState(() {}); // Appliquer au screen principal
                        Navigator.pop(context);
                      },
                      child: const Text('Apply Filters', style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 20), // Marge de sécurité pour le bas
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterChip(String label, String currentSelection, Function(String) onSelected) {
    bool isSelected = label == currentSelection;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: const Color(0xFF4F46E5),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: FontWeight.w600,
      ),
      backgroundColor: Colors.grey.shade100,
      onSelected: (bool selected) {
        if (selected) onSelected(label);
      },
    );
  }

  Widget _buildSortOption(String label, IconData icon, StateSetter setModalState) {
    bool isSelected = _selectedSort == label;
    return GestureDetector(
      onTap: () {
        setModalState(() {
          _selectedSort = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? const Color(0xFF4F46E5) : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? const Color(0xFF4F46E5).withOpacity(0.05) : Colors.white,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? const Color(0xFF4F46E5) : Colors.grey,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF4F46E5) : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _categoryChip(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
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

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_library/auth/database_helper.dart';
import 'package:smart_library/pages/book_datails_screen.dart';
import 'package:smart_library/providers/my_books_provider.dart';
import 'package:smart_library/providers/user_provider.dart';
import 'package:smart_library/providers/favorites_provider.dart';
import 'package:smart_library/models/books_model.dart';

class MyBooksScreen extends StatefulWidget {
  const MyBooksScreen({Key? key}) : super(key: key);

  @override
  State<MyBooksScreen> createState() => _MyBooksScreenState();
}

class _MyBooksScreenState extends State<MyBooksScreen> {
  String _selectedStatus = 'All';
  String _selectedAuthor = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.currentUser?.usrId;

    if (userId != null) {
      Provider.of<MyBooksProvider>(context, listen: false).fetchUserBooks(userId);
      Provider.of<FavoriteBooksProvider>(context, listen: false).fetchFavorites(userId);
    }
  }

  List<String> getUniqueAuthors(List<Book> books) {
    final authors = books.expand((book) => book.authors).map((a) => a.toString()).toSet().toList();
    return ['All', ...authors];
  }

  ImageProvider _buildBookImage(String thumbnail) {
    if (thumbnail.isEmpty) {
      return const AssetImage('assets/images/test.jpg');
    }
    if (thumbnail.startsWith('http')) {
      return NetworkImage(thumbnail);
    }
    return FileImage(File(thumbnail));
  }

  // --- NAVIGATION HELPER ---
  // This handles both History saving and Navigation to prevent errors
  void _navigateToDetails(Book book) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.currentUser?.usrId;

    if (userId != null) {
      // Save to history before moving to the next screen
      // This ensures the record exists when BookDetailsScreen loads
      await DatabaseHelper().updateReadingHistory(book.id, userId, 'Not Read');
    }

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookDetailsScreen(book: book),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final myBooksProvider = Provider.of<MyBooksProvider>(context);
    final favProvider = Provider.of<FavoriteBooksProvider>(context);

    final allBooks = myBooksProvider.myBooks.reversed.toList();
    final favoriteBooks = favProvider.favoriteBooks;
    final isLoading = myBooksProvider.isLoading || favProvider.isLoading;

    List<Book> filteredBooks = allBooks;
    if (_selectedAuthor != 'All') {
      filteredBooks = filteredBooks.where((book) => book.authors.contains(_selectedAuthor)).toList();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF1F2937)))
            : RefreshIndicator(
                onRefresh: () async => _loadData(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your Favorites',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                      ),
                      const SizedBox(height: 16),
                      favoriteBooks.isEmpty ? _buildEmptyFavorites() : _buildFavoritesList(favoriteBooks),
                      const SizedBox(height: 32),
                      const Text(
                        'Categories',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                      ),
                      const SizedBox(height: 16),
                      _buildCategoriesList(),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Recently Added',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                          ),
                          _buildFilterButton(allBooks),
                        ],
                      ),
                      const SizedBox(height: 16),
                      filteredBooks.isEmpty
                          ? const Center(child: Text("No books found."))
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: filteredBooks.length,
                              itemBuilder: (context, index) {
                                return _buildBookListTile(filteredBooks[index]);
                              },
                            ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  // --- SUB-WIDGETS ---

  Widget _buildFavoritesList(List<Book> books) {
    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: books.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final book = books[index];
          return GestureDetector(
            onTap: () => _navigateToDetails(book),
            child: Container(
              width: 130,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: _buildBookImage(book.thumbnail),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBookListTile(Book book) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () => _navigateToDetails(book),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              width: 85,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(image: _buildBookImage(book.thumbnail), fit: BoxFit.cover),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(book.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(book.authors.join(', '),
                      style: const TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(book.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.blueGrey.shade400, height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyFavorites() {
    return Container(
      width: double.infinity,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, color: Colors.grey, size: 40),
          SizedBox(height: 8),
          Text("No favorites found.", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildCategoriesList() {
    final List<String> categories = ['Short Stories', 'Science Fiction', 'Action', 'Romance', 'Fantasy'];
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(color: const Color(0xFF1F2937), borderRadius: BorderRadius.circular(24)),
            child: Text(categories[index],
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          );
        },
      ),
    );
  }

  Widget _buildFilterButton(List<Book> allBooks) {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: const Icon(Icons.tune_rounded, size: 20),
        onPressed: () => _showFilterModal(context, allBooks),
      ),
    );
  }

  void _showFilterModal(BuildContext context, List<Book> books) {
    final authorsList = getUniqueAuthors(books);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Filter Books', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  const Text('Author', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 50,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: authorsList.map((a) => Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(a),
                          selected: _selectedAuthor == a,
                          onSelected: (selected) { if(selected) setModalState(() => _selectedAuthor = a); },
                        ),
                      )).toList(),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1F2937),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () { setState(() {}); Navigator.pop(context); },
                      child: const Text('Apply Filters', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
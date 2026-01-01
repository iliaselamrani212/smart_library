import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_library/pages/book_datails_screen.dart';
import 'package:smart_library/providers/my_books_provider.dart';
import 'package:smart_library/providers/user_provider.dart';
import 'package:smart_library/providers/favorites_provider.dart';
import 'package:smart_library/models/books_model.dart';
import 'package:smart_library/theme/app_themes.dart';

class MyBooksScreen extends StatefulWidget {
  const MyBooksScreen({Key? key}) : super(key: key);

  @override
  State<MyBooksScreen> createState() => _MyBooksScreenState();
}

class _MyBooksScreenState extends State<MyBooksScreen> {
  String _selectedAuthor = 'All';
  String _selectedCategory = 'All';
  String _selectedStatus = 'All';
  String _sortOption = 'Recent';

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

  List<String> getUniqueCategories(List<Book> books) {
    final categories = books
        .map((book) => book.category.isNotEmpty ? book.category : 'General')
        .toSet()
        .toList();
    categories.sort();
    return ['All', ...categories];
  }
  
  final List<String> _statuses = ['All', 'Not Read', 'Reading', 'Finished'];

  final List<String> _sortOptions = ['Recent', 'Oldest', 'Title A-Z', 'Title Z-A'];

  ImageProvider _buildBookImage(String thumbnail) {
    if (thumbnail.isEmpty) {
      return const AssetImage('assets/images/empty.jpg');
    }
    if (thumbnail.startsWith('http')) {
      return NetworkImage(thumbnail);
    }
    return FileImage(File(thumbnail));
  }

  void _navigateToDetails(Book book) {
    final myBooksProvider = Provider.of<MyBooksProvider>(context, listen: false);
    
    if (!mounted) return;
    myBooksProvider.loadPagesCounter(book.pages);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookDetailsScreen(book: book),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final myBooksProvider = Provider.of<MyBooksProvider>(context);
    final favProvider = Provider.of<FavoriteBooksProvider>(context);

    List<Book> allBooks = List.from(myBooksProvider.myBooks);
    final favoriteBooks = favProvider.favoriteBooks;
    final isLoading = myBooksProvider.isLoading || favProvider.isLoading;

    List<Book> filteredBooks = allBooks;

    if (_selectedAuthor != 'All') {
      filteredBooks = filteredBooks.where((book) => book.authors.contains(_selectedAuthor)).toList();
    }

    if (_selectedCategory != 'All') {
      filteredBooks = filteredBooks.where((book) => book.category == _selectedCategory).toList();
    }
    
    if (_selectedStatus != 'All') {
       filteredBooks = filteredBooks.where((book) {
         if (_selectedStatus == 'Not Read') {
           return book.status == 'Not Read' || book.status.isEmpty;
         }
         return book.status == _selectedStatus;
       }).toList();
    }

    filteredBooks.sort((a, b) {
       switch (_sortOption) {
         case 'Oldest':
           if (a.addedDate == null) return 1;
           if (b.addedDate == null) return -1;
           return a.addedDate!.compareTo(b.addedDate!);
         case 'Title A-Z':
           return a.title.compareTo(b.title);
         case 'Title Z-A':
           return b.title.compareTo(a.title);
         case 'Recent':
         default:
           if (a.addedDate == null) return 1;
           if (b.addedDate == null) return -1;
           return b.addedDate!.compareTo(a.addedDate!);
       }
    });


    final uniqueCategories = getUniqueCategories(allBooks);

    return Scaffold(
      backgroundColor: isDark ? AppThemes.darkBg : Colors.white,
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: AppThemes.accentColor))
            : RefreshIndicator(
                onRefresh: () async => _loadData(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      favoriteBooks.isEmpty? const SizedBox.shrink():
                           Text(
                        'Your Favorites',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1F2937)),
                      )
                          ,
                      favoriteBooks.isEmpty ? SizedBox.shrink() : const SizedBox(height: 16),
                      favoriteBooks.isEmpty ? SizedBox.shrink() : _buildFavoritesList(favoriteBooks),

                      favoriteBooks.isEmpty ? SizedBox.shrink() : const SizedBox(height: 32),
                      
                      Text(
                        'Categories',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1F2937)),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 44,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: uniqueCategories.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final category = uniqueCategories[index];
                            final isSelected = category == _selectedCategory;
                            
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedCategory = category;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected 
                                    ? (isDark ? AppThemes.accentColor : const Color(0xFF1F2937))
                                    : (isDark ? AppThemes.darkSecondaryBg : Colors.grey.shade200),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Text(
                                  category,
                                  style: TextStyle(
                                    color: isSelected ? (isDark ? Colors.black : Colors.white) : (isDark ? Colors.white : Colors.black87),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 32),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'my books',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1F2937)),
                          ),
                          _buildFilterButton(allBooks),
                        ],
                      ),
                      
                      if (_selectedCategory != 'All' || _selectedAuthor != 'All' || _selectedStatus != 'All' || _sortOption != 'Recent')
                         Padding(
                           padding: const EdgeInsets.only(top: 8.0),
                           child: Text(
                             "Filtered by: ${_selectedCategory != 'All' ? 'Category: $_selectedCategory ' : ''}${_selectedAuthor != 'All' ? 'Author: $_selectedAuthor ' : ''}${_selectedStatus != 'All' ? 'Status: $_selectedStatus ' : ''}${_sortOption != 'Recent' ? 'Sort: $_sortOption' : ''}",
                             style: TextStyle(color: isDark ? AppThemes.accentColor : const Color(0xFF4F46E5), fontSize: 12),
                           ),
                         ),

                      const SizedBox(height: 16),
                      
                      filteredBooks.isEmpty
                          ? const Center(child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Text("No books match your filters."),
                            ))
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: filteredBooks.length,
                              itemBuilder: (context, index) {
                                final book = filteredBooks[index];
                                final isFavorite = favProvider.favorites.any((b) => b.id == book.id);
                                return _buildBookListTile(book, isFavorite, context);
                              },
                            ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

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

  Widget _buildBookListTile(Book book, bool isFavorite, BuildContext context) {
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
            IconButton(
              onPressed: () {
                final favProvider = Provider.of<FavoriteBooksProvider>(context, listen: false);
                if (isFavorite) {
                  favProvider.removeFavorite(book.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${book.title} removed from favorites')),
                  );
                } else {
                  favProvider.addFavorite(book);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${book.title} added to favorites')),
                  );
                }
              },
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border, 
                color: const Color(0xFFFF4757),
                size: 24,
              ),
            ),
          ],
        ),
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
                  const Text('Filter & Sort Books', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  
                  const Text('Sort By', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8.0,
                    children: _sortOptions.map((s) => ChoiceChip(
                        label: Text(s),
                        selected: _sortOption == s,
                        onSelected: (selected) { if(selected) setModalState(() => _sortOption = s); },
                      )).toList(),
                  ),
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
                  const SizedBox(height: 24),

                  const Text('Status', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 50,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: _statuses.map((s) => Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(s),
                          selected: _selectedStatus == s,
                          onSelected: (selected) { if(selected) setModalState(() => _selectedStatus = s); },
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
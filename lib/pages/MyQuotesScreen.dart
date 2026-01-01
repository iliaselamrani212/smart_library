import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:smart_library/auth/database_helper.dart';
import 'package:smart_library/providers/user_provider.dart';
import 'package:smart_library/providers/my_books_provider.dart';
import 'package:smart_library/models/books_model.dart';
import 'package:smart_library/theme/app_themes.dart';
import 'AddNoteScreen.dart';


class MyQuotesScreen extends StatefulWidget {
  final String? bookId;

  const MyQuotesScreen({Key? key, this.bookId}) : super(key: key);

  @override
  State<MyQuotesScreen> createState() => _MyQuotesScreenState();
}

class _MyQuotesScreenState extends State<MyQuotesScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  void _navigateToAddNote() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddNoteScreen()),
    );

    if (result == true) {
      setState(() {});
    }
  }

  void _deleteQuote(int noteId) async {
    await _dbHelper.deleteNote(noteId);
    setState(() {});
  }

  void _navigateToEditNotePage(Map<String, dynamic> quote) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddNoteScreen(
          note: quote,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.currentUser?.usrId;
    if (userId != null) {
      Provider.of<MyBooksProvider>(context, listen: false).fetchUserBooks(userId);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.currentUser?.usrId;
    if (userId != null) {
      Provider.of<MyBooksProvider>(context, listen: false).fetchUserBooks(userId).then((_) {
        setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final int? userId = userProvider.currentUser?.usrId;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppThemes.darkBg : const Color(0xFFF5F7FA),
      appBar: widget.bookId != null ? AppBar(
        title: Text("Book Quotes", style: TextStyle(color: isDark ? Colors.white : Colors.black)),
        backgroundColor: isDark ? AppThemes.darkBg : Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      ) : null,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddNote,
        backgroundColor: isDark ? AppThemes.accentColor : Colors.black,
        icon: Icon(Icons.edit, color: isDark ? Colors.black : Colors.white),
        label: Text("Add Note", style: TextStyle(color: isDark ? Colors.black : Colors.white)),
      ),
      body: userId == null
          ? const Center(child: Text("Please log in to see your quotes."))
          : FutureBuilder<List<Map<String, dynamic>>>(
              future: widget.bookId != null 
                  ? _dbHelper.getBookNotes(userId, widget.bookId!) 
                  : _dbHelper.getNotes(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final quotes = snapshot.data ?? [];

                if (quotes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.format_quote, size: 80, color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                        const SizedBox(height: 20),
                        Text(
                          "No quotes saved yet",
                          style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: quotes.length,
                  itemBuilder: (context, index) {
                    final quote = quotes[index];

                    return Dismissible(
                      key: Key(quote['id'].toString()),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) => _deleteQuote(quote['id']),
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.delete, color: Colors.red),
                      ),
                      child: _buildQuoteCard(quote, isDark),
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _buildQuoteCard(Map<String, dynamic> quote, bool isDark) {
    final bookTitle = Provider.of<MyBooksProvider>(context, listen: false)
        .myBooks
        .firstWhere((book) => book.id == quote['bookId'], orElse: () => Book(id: 'unknown', title: 'Unknown Book', authors: [], thumbnail: '', description: '', category: '', status: 'Not Read', pages: 0, totalPages: 0))
        .title;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppThemes.darkCardBg : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.black).withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.book, size: 18, color: isDark ? AppThemes.textSecondary : Colors.black54),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        bookTitle,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? AppThemes.darkSecondaryBg : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "Page ${quote['pageNumber'] ?? '?'}",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isDark ? Colors.white : Colors.black),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.format_quote_rounded, color: isDark ? Colors.grey.shade600 : Colors.grey, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  quote['noteText'] ?? '',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    fontStyle: FontStyle.italic,
                    color: isDark ? Colors.grey.shade300 : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Divider(color: isDark ? Colors.grey.shade700 : Colors.grey.shade200),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Added on ${quote['date']}",
                style: TextStyle(color: isDark ? Colors.grey.shade500 : Colors.grey.shade500, fontSize: 12),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: isDark ? AppThemes.accentColor : Colors.blue),
                    onPressed: () {
                      _navigateToEditNotePage(quote);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _deleteQuote(quote['id']);
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:smart_library/auth/database_helper.dart';
import 'package:smart_library/providers/user_provider.dart';
import 'AddNoteScreen.dart';

class MyQuotesScreen extends StatefulWidget {
  const MyQuotesScreen({Key? key}) : super(key: key);

  @override
  State<MyQuotesScreen> createState() => _MyQuotesScreenState();
}

class _MyQuotesScreenState extends State<MyQuotesScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Navigation to the AddNoteScreen
  void _navigateToAddNote() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddNoteScreen()),
    );

    // If result is true, it means a note was saved to the DB
    if (result == true) {
      setState(() {}); // This triggers the FutureBuilder to reload the list
    }
  }

  void _deleteQuote(int noteId) async {
    await _dbHelper.deleteNote(noteId);
    setState(() {}); // Refresh the list after deleting
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Copied to clipboard!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. Get the current User ID from the Provider
    final userProvider = context.watch<UserProvider>();
    final int? userId = userProvider.currentUser?.usrId;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddNote,
        backgroundColor: Colors.black,
        icon: const Icon(Icons.edit, color: Colors.white),
        label: const Text("Add Note", style: TextStyle(color: Colors.white)),
      ),
      body: userId == null
          ? const Center(child: Text("Please log in to see your quotes."))
          : FutureBuilder<List<Map<String, dynamic>>>(
              // 2. Fetch notes filtered by this specific User ID
              future: _dbHelper.getNotes(userId),
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
                        Icon(Icons.format_quote, size: 80, color: Colors.grey.shade300),
                        const SizedBox(height: 20),
                        Text(
                          "No quotes saved yet",
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
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
                      key: Key(quote['noteId'].toString()),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) => _deleteQuote(quote['noteId']),
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.delete, color: Colors.red),
                      ),
                      child: _buildQuoteCard(quote),
                    );
                  },
                );
              },
            ),
    );
  }

  // UI helper for the card design
  Widget _buildQuoteCard(Map<String, dynamic> quote) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                    const Icon(Icons.book, size: 18, color: Colors.black54),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        quote['bookTitle'] ?? 'Unknown Book',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
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
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "Page ${quote['pageNumber'] ?? '?'}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.format_quote_rounded, color: Colors.grey, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  quote['noteText'] ?? '',
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    fontStyle: FontStyle.italic,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Divider(color: Colors.grey.shade200),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Added on ${quote['date']}",
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
              IconButton(
                icon: const Icon(Icons.copy, size: 18, color: Colors.blue),
                onPressed: () => _copyToClipboard(quote['noteText'] ?? ''),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'AddNoteScreen.dart';

class MyQuotesScreen extends StatefulWidget {
  const MyQuotesScreen({Key? key}) : super(key: key);

  @override
  State<MyQuotesScreen> createState() => _MyQuotesScreenState();
}

class _MyQuotesScreenState extends State<MyQuotesScreen> {
  // Liste des citations
  final List<Map<String, String>> _quotes = [
    {
      'book': "The Silent Patient",
      'text': "The greatest secret of happiness is to be at peace with oneself.",
      'page': '42',
      'date': '22/12/2025'
    },
  ];

  // --- MODIFICATION ICI : On utilise la navigation au lieu du Dialog ---
  void _navigateToAddNote() async {
    // On va vers la page AddNoteScreen et on attend le résultat (await)
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddNoteScreen()),
    );

    // Si on revient avec des données (l'utilisateur a cliqué sur Save)
    if (result != null && result is Map<String, String>) {
      setState(() {
        _quotes.insert(0, result); // Ajoute la nouvelle note en haut de la liste
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Note added successfully!"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _deleteQuote(int index) {
    setState(() {
      _quotes.removeAt(index);
    });
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Copied to clipboard!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
   


      // Le bouton ouvre maintenant la nouvelle page
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddNote,
        backgroundColor: Colors.black,
        icon: const Icon(Icons.edit, color: Colors.white),
        label: const Text("Add Note", style: TextStyle(color: Colors.white)),
      ),

      body: _quotes.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.library_books, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 20),
            Text(
              "No quotes saved yet",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _quotes.length,
        itemBuilder: (context, index) {
          final quote = _quotes[index];

          return Dismissible(
            key: UniqueKey(),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.delete, color: Colors.red),
            ),
            onDismissed: (direction) => _deleteQuote(index),
            child: Container(
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
                  // HEADER: BOOK NAME + PAGE NUMBER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(Icons.book, size: 18, color: Colors.black54),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                quote['book']!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "Page ${quote['page']}",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // QUOTE TEXT
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.format_quote_rounded, color: Colors.grey, size: 24),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          quote['text']!,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.5,
                            fontFamily: 'Serif',
                            fontStyle: FontStyle.italic,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 5),
                  Divider(color: Colors.grey.shade200),

                  // FOOTER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Added on ${quote['date']}",
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 18, color: Colors.blue),
                        onPressed: () => _copyToClipboard(quote['text']!),
                        tooltip: "Copy text",
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}


import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_library/models/books_model.dart';
import 'package:smart_library/providers/user_provider.dart';
import 'package:smart_library/providers/my_books_provider.dart';
import 'package:intl/intl.dart'; // Importer pour le formatage de la date
import 'package:smart_library/pages/edit_book_screen.dart'; // Importer l'écran d'édition

import '../providers/favorites_provider.dart';
import 'layout.dart';

class BookDetailsScreen extends StatefulWidget {
  final Book? book; 

  const BookDetailsScreen({
    Key? key,
    this.book, 
  }) : super(key: key);

  @override
  State<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  double _currentPage = 0;
  late int _totalPages;
  late TextEditingController _pageController;
  int _bookIndex = -1;

  // We need to keep a local copy of the book to display updates
  Book? _displayedBook;

  @override
  void initState() {
    super.initState();
    _displayedBook = widget.book; // Initialize with the passed book
    _totalPages = _displayedBook?.totalPages ?? 0;
    _pageController = TextEditingController(text: "0");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_displayedBook != null) {
        final provider = Provider.of<MyBooksProvider>(context, listen: false);
        final index = provider.myBooks.indexWhere((b) => b.id == _displayedBook!.id);

        if (mounted) {
          setState(() {
            _bookIndex = index;
            _currentPage = _displayedBook!.pages.toDouble();
            _pageController.text = _currentPage.toInt().toString();
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _getLiveStatus() {
    final provider = Provider.of<MyBooksProvider>(context);
    if (_bookIndex == -1 || _bookIndex >= provider.bookStates.length) {
      return 'Not Read'; 
    }
    return provider.bookStates[_bookIndex];
  }

  void _updateBookStatus(String newStatus) {
    final userId = Provider.of<UserProvider>(context, listen: false).currentUser?.usrId;
    final provider = Provider.of<MyBooksProvider>(context, listen: false);

    if (userId != null && _bookIndex != -1) {
      provider.updateState(_bookIndex, _displayedBook!.id, userId, newStatus);
    }
  }

  void _toggleReading(bool currentIsReading) {
    if (currentIsReading) {
      _updateBookStatus('Not Read');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Stopped Reading")));
    } else {
      _updateBookStatus('Reading');
    }
  }

  void _markAsFinished() {
    setState(() {
      _currentPage = _totalPages.toDouble();
      _pageController.text = _totalPages.toString();
    });
    
    final userId = Provider.of<UserProvider>(context, listen: false).currentUser?.usrId;
    if (userId != null) {
      Provider.of<MyBooksProvider>(context, listen: false)
          .savePageToDatabase(_displayedBook!.id, userId, _totalPages);
    }

    _updateBookStatus('Finished');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Congratulations! Book Finished."), backgroundColor: Colors.black),
    );
  }

void _saveProgress() {
     final userId = Provider.of<UserProvider>(context, listen: false).currentUser?.usrId;

     if (userId != null) {
        _updateBookStatus('Reading');
        
        Provider.of<MyBooksProvider>(context, listen: false)
            .savePageToDatabase(_displayedBook!.id, userId, _currentPage.toInt());
            
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Progress Saved"), backgroundColor: Colors.green)
        );
     }
  }

  void _onPageInputChanged(String value) {
    final page = int.tryParse(value) ?? 0;
    if (page >= 0 && page <= _totalPages) {
      setState(() {
        _currentPage = page.toDouble();
      });
    }
  }

  void _showOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: const Text("Modify"),
                onTap: () async {
                  Navigator.pop(context); // Close modal before navigation
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EditBookScreen(book: _displayedBook!)),
                  );

                  if (result != null && result is Book) {
                    if (mounted) {
                      setState(() {
                        _displayedBook = result;
                        _totalPages = result.totalPages;
                        _currentPage = result.pages.toDouble();
                        _pageController.text = _currentPage.toInt().toString();
                      });
                    }

                    final userId = Provider.of<UserProvider>(context, listen: false).currentUser?.usrId;
                    if (userId != null) {
                      await Provider.of<MyBooksProvider>(context, listen: false).fetchUserBooks(userId);
                    }
                  }
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text("Delete", style: TextStyle(color: Colors.red)),
                onTap: () async {
                  Navigator.pop(context); // Close modal before deletion
                  final bookId = _displayedBook!.id;
                  final userId = Provider.of<UserProvider>(context, listen: false).currentUser?.usrId;
                  if (userId != null) {
                    await Provider.of<FavoriteBooksProvider>(context, listen: false).removeFavorite(bookId);
                    await Provider.of<MyBooksProvider>(context, listen: false).removeBook(bookId, userId);
                    if (mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => Layout(id_page: 1)),
                        (route) => false,
                      );
                    }
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_displayedBook == null) return const Scaffold(body: Center(child: Text("Book not found")));

    final status = _getLiveStatus(); 
    final isReading = status == 'Reading';
    final isFinished = status == 'Finished';

    final title = _displayedBook!.title;
    final authors = _displayedBook!.authors.isNotEmpty ? _displayedBook!.authors.join(', ') : "Unknown Author";
    final description = _displayedBook!.description;
    
    String addedDateText = "Not specified";
    if (_displayedBook!.addedDate != null) {
      try {
        final date = DateTime.parse(_displayedBook!.addedDate!);
        addedDateText = DateFormat.yMMMd().format(date);
      } catch (e) {
      }
    }

    ImageProvider imageProvider;
    if (_displayedBook!.thumbnail.isNotEmpty) {
      imageProvider = _displayedBook!.thumbnail.startsWith('http')
          ? NetworkImage(_displayedBook!.thumbnail)
          : FileImage(File(_displayedBook!.thumbnail)) as ImageProvider;
    } else {
      imageProvider = const AssetImage('assets/images/empty.png');
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context), 
        ),
        actions: [
          IconButton(icon: const Icon(Icons.format_quote, color: Colors.black), onPressed:(){}),
          IconButton(icon: const Icon(Icons.more_horiz, color: Colors.black), onPressed: _showOptions),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Center(
              child: Container(
                height: 320, width: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10)),
                  ],
                  image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Serif')),
            const SizedBox(height: 8),
            Text(authors, textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey.shade700, fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),
            Text(_displayedBook?.category ?? "General", style: TextStyle(color: Colors.grey.shade600)),
            
            const SizedBox(height: 10),
            Center(
              child: Text(
                "Added on: $addedDateText",
                style: TextStyle(color: Colors.grey.shade500, fontStyle: FontStyle.italic),
              ),
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: const Color(0xFFF5F7FA), borderRadius: BorderRadius.circular(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text("$_totalPages Pages", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                  const SizedBox(height: 20),
                  Text(description, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, color: Colors.black87)),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: isFinished ? null : () => _toggleReading(isReading),
                          icon: Icon(isReading ? Icons.stop_circle_outlined : Icons.menu_book, size: 18, color: isReading ? Colors.red : Colors.black),
                          label: Text(isReading ? "Stop Reading" : "Read", style: TextStyle(color: isReading ? Colors.red : Colors.black)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: isFinished ? Colors.grey.shade300 : (isReading ? Colors.red : Colors.black)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isReading ? _saveProgress : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            disabledBackgroundColor: Colors.grey.shade300,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: const Text("Save", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 16),

            if (!isFinished)
              AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: isReading ? 1.0 : 0.6,
                child: AbsorbPointer(
                  absorbing: !isReading,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(20),
                      border: isReading ? Border.all(color: Colors.black, width: 1.5) : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Reading Progress", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text("${_totalPages > 0 ? (_currentPage / _totalPages * 100).toInt() : 0}%", style: TextStyle(fontWeight: FontWeight.bold, color: isReading ? Colors.black : Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        
                        Slider(
                          value: _currentPage, 
                          min: 0, 
                          max: _totalPages > 0 ? _totalPages.toDouble() : 1, 
                          activeColor: Colors.black,
                          onChanged: (value) {
                            setState(() {
                              _currentPage = value;
                              _pageController.text = value.toInt().toString();
                            });
                          },
                        ),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Text("Page ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                SizedBox(
                                  width: 70, height: 35,
                                  child: TextField(
                                    controller: _pageController,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    onChanged: _onPageInputChanged,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                    decoration: InputDecoration(
                                      filled: true, fillColor: Colors.white,
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Text("of $_totalPages", style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 20),

            Center(
              child: ElevatedButton(
                onPressed: isFinished ? null : _markAsFinished,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  disabledBackgroundColor: Colors.grey.shade300,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 0,
                ),
                child: Text(
                  isFinished ? 'Finished' : "Mark as Finished",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

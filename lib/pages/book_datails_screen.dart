import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_library/models/books_model.dart';
import 'package:smart_library/providers/user_provider.dart';
import 'package:smart_library/providers/my_books_provider.dart';
import 'package:intl/intl.dart';
import 'package:smart_library/pages/edit_book_screen.dart';
import 'package:smart_library/theme/app_themes.dart';
import 'package:smart_library/pages/MyQuotesScreen.dart';

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

  Book? _displayedBook;

  @override
  void initState() {
    super.initState();
    _displayedBook = widget.book;
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
                  Navigator.pop(context);
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
                  Navigator.pop(context);
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
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
      backgroundColor: isDark ? AppThemes.darkBg : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? AppThemes.darkBg : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context), 
        ),
        actions: [
          IconButton(icon: Icon(Icons.format_quote, color: isDark ? Colors.white : Colors.black), onPressed:(){
            if (_displayedBook != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyQuotesScreen(bookId: _displayedBook!.id),
                ),
              );
            }
          }),
          IconButton(icon: Icon(Icons.more_horiz, color: isDark ? Colors.white : Colors.black), onPressed: _showOptions),
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
            Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Serif', color: isDark ? Colors.white : Colors.black)),
            const SizedBox(height: 8),
            Text(authors, textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: isDark ? Colors.grey.shade400 : Colors.grey.shade700, fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),
            Text(_displayedBook?.category ?? "General", style: TextStyle(color: isDark ? Colors.grey.shade500 : Colors.grey.shade600)),
            
            const SizedBox(height: 10),
            Center(
              child: Text(
                "Added on: $addedDateText",
                style: TextStyle(color: isDark ? Colors.grey.shade600 : Colors.grey.shade500, fontStyle: FontStyle.italic),
              ),
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: isDark ? AppThemes.darkCardBg : const Color(0xFFF5F7FA), borderRadius: BorderRadius.circular(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text("$_totalPages Pages", style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 13)),
                  const SizedBox(height: 20),
                  Text(description, maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14, color: isDark ? Colors.grey.shade300 : Colors.black87)),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: isFinished ? null : () => _toggleReading(isReading),
                          icon: Icon(isReading ? Icons.stop_circle_outlined : Icons.menu_book, size: 18, color: isReading ? Colors.red : (isDark ? Colors.white : Colors.black)),
                          label: Text(isReading ? "Stop Reading" : "Read", style: TextStyle(color: isReading ? Colors.red : (isDark ? Colors.white : Colors.black))),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: isFinished ? Colors.grey.shade300 : (isReading ? Colors.red : (isDark ? Colors.grey.shade600 : Colors.black))),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isReading ? _saveProgress : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? AppThemes.accentColor : Colors.black,
                            disabledBackgroundColor: Colors.grey.shade300,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: Text("Save", style: TextStyle(color: isDark ? Colors.black : Colors.white, fontWeight: FontWeight.bold)),
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
                      color: isDark ? AppThemes.darkCardBg : const Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(20),
                      border: isReading ? Border.all(color: isDark ? AppThemes.accentColor : Colors.black, width: 1.5) : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Reading Progress", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : Colors.black)),
                            Text("${_totalPages > 0 ? (_currentPage / _totalPages * 100).toInt() : 0}%", style: TextStyle(fontWeight: FontWeight.bold, color: isReading ? (isDark ? AppThemes.accentColor : Colors.black) : Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        
                        Slider(
                          value: _currentPage, 
                          min: 0, 
                          max: _totalPages > 0 ? _totalPages.toDouble() : 1, 
                          activeColor: isDark ? AppThemes.accentColor : Colors.black,
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
                                Text("Page ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isDark ? Colors.white : Colors.black)),
                                SizedBox(
                                  width: 70, height: 35,
                                  child: TextField(
                                    controller: _pageController,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    onChanged: _onPageInputChanged,
                                    style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? AppThemes.accentColor : Colors.black, fontSize: 16),
                                    decoration: InputDecoration(
                                      filled: true, fillColor: isDark ? AppThemes.darkSecondaryBg : Colors.white,
                                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isDark ? AppThemes.borderColor : Colors.grey.shade300)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Text("of $_totalPages", style: TextStyle(color: isDark ? AppThemes.textSecondary : Colors.grey.shade600, fontSize: 14)),
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
                  backgroundColor: isDark ? AppThemes.accentColor : Colors.black,
                  disabledBackgroundColor: Colors.grey.shade300,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 0,
                ),
                child: Text(
                  isFinished ? 'Finished' : "Mark as Finished",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.black : Colors.white,
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

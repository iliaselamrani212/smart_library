import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_library/models/books_model.dart';
import 'package:smart_library/providers/user_provider.dart';
import 'package:smart_library/providers/my_books_provider.dart';

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
  // Only visual variables for the slider/input stay local
  double _currentPage = 0;
  late int _totalPages;
  late TextEditingController _pageController;
  
  // This index attaches this screen to the specific slot in the Provider's list
  int _bookIndex = -1;

  @override
  void initState() {
    super.initState();
    _totalPages = 300; 
    _pageController = TextEditingController(text: "0");

    // 1. ATTACH TO PROVIDER ON STARTUP
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.book != null) {
        final provider = Provider.of<MyBooksProvider>(context, listen: false);
        // Find the index of this book in the provider's list
        final index = provider.myBooks.indexWhere((b) => b.id == widget.book!.id);
        
        setState(() {
          _bookIndex = index;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // --- 2. GET VARIABLES FROM PROVIDER (NOT LOCAL) ---
String _getLiveStatus() {
    final provider = Provider.of<MyBooksProvider>(context);
    
    // SAFETY CHECK:
    // If the index is -1 (not found) OR the index is larger than the list size
    // We return 'Not Read' instead of crashing the app.
    if (_bookIndex == -1 || _bookIndex >= provider.bookStates.length) {
      return 'Not Read'; 
    }
    
    return provider.bookStates[_bookIndex];
  }

  // --- 3. UPDATE PROVIDER & DATABASE ---
  void _updateBookStatus(String newStatus) {
    final userId = Provider.of<UserProvider>(context, listen: false).currentUser?.usrId;
    final provider = Provider.of<MyBooksProvider>(context, listen: false);

    if (userId != null && _bookIndex != -1) {
      // This function updates the parallel list AND the Database
      provider.updateState(_bookIndex, widget.book!.id, userId, newStatus);
    }
  }

  // --- ACTIONS ---
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
    _updateBookStatus('Finished');
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Congratulations! Book Finished."), backgroundColor: Colors.black),
    );
  }

  void _saveProgress() {
     // Ensure status stays 'Reading' in DB
     _updateBookStatus('Reading');
     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Progress Saved"), backgroundColor: Colors.green));
  }

  void _onPageInputChanged(String value) {
    int? newPage = int.tryParse(value);
    if (newPage != null) {
      setState(() => _currentPage = newPage.toDouble());
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
                title: const Text("Modifier"),
                onTap: () => Navigator.pop(context),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text("Supprimer", style: TextStyle(color: Colors.red)),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.book == null) return const Scaffold(body: Center(child: Text("Book not found")));

    // --- 4. ATTACH UI VARIABLES TO PROVIDER STATE ---
    // These update automatically when notifyListeners() is called in Provider
    final status = _getLiveStatus(); 
    final isReading = status == 'Reading';
    final isFinished = status == 'Finished';

    final title = widget.book!.title;
    final authors = widget.book!.authors.isNotEmpty ? widget.book!.authors.join(', ') : "Unknown Author";
    final description = widget.book!.description;
    
    ImageProvider imageProvider;
    if (widget.book!.thumbnail.isNotEmpty) {
      imageProvider = widget.book!.thumbnail.startsWith('http')
          ? NetworkImage(widget.book!.thumbnail)
          : FileImage(File(widget.book!.thumbnail)) as ImageProvider;
    } else {
      imageProvider = const AssetImage('assets/images/placeholder.png');
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context), // Just close, state is already saved in Provider
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
            // IMAGE
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
            // TEXT
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Serif')),
            const SizedBox(height: 8),
            Text(authors, textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey.shade700, fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),
            Text(widget.book?.category ?? "General", style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 10),

            // BUTTONS
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
                          // --- 5. LOGIC ATTACHED TO PROVIDER ---
                          onPressed: isFinished ? null : () => _toggleReading(isReading),
                          icon: Icon(
                            isReading ? Icons.stop_circle_outlined : Icons.menu_book, 
                            size: 18, 
                            color: isReading ? Colors.red : Colors.black
                          ),
                          // Text depends on Provider state, NOT local state
                          label: Text(
                            isReading ? "Stop Reading" : "Read", 
                            style: TextStyle(color: isReading ? Colors.red : Colors.black)
                          ),
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
                          // Only save if Provider says we are reading
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

            // PROGRESSION (Depends on Provider State)
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
                            Text("${(_currentPage / _totalPages * 100).toInt()}%", style: TextStyle(fontWeight: FontWeight.bold, color: isReading ? Colors.black : Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Slider(
                          value: _currentPage, min: 0, max: _totalPages.toDouble(),
                          activeColor: Colors.black,
                          onChanged: (value) => setState(() {
                            _currentPage = value;
                            _pageController.text = value.toInt().toString();
                          }),
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

            // FINISHED BUTTON (Updates Provider)
            Center(
              child: ElevatedButton(
                // Disable if Provider says finished
                onPressed: isFinished ? null : _markAsFinished,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  disabledBackgroundColor: Colors.grey.shade300,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 0,
                ),
                child: Text(isFinished ? 'Finished' : "Mark as Finished", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
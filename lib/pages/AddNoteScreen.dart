import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:provider/provider.dart';
import 'package:smart_library/auth/database_helper.dart';
import 'package:smart_library/providers/user_provider.dart';
import 'package:smart_library/providers/my_books_provider.dart';
import 'package:smart_library/models/books_model.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:smart_library/theme/app_themes.dart';

class AddNoteScreen extends StatefulWidget {
  final Map<String, dynamic>? note;

  const AddNoteScreen({Key? key, this.note}) : super(key: key);

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  Book? _selectedBook;
  final _pageController = TextEditingController();
  final _noteController = TextEditingController();
  final _bookSearchController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();

    if (widget.note != null) {
      _pageController.text = widget.note!['pageNumber']?.toString() ?? '';
      _noteController.text = widget.note!['noteText'] ?? '';

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userId = userProvider.currentUser?.usrId;
      if (userId != null) {
        Provider.of<MyBooksProvider>(context, listen: false)
            .fetchUserBooks(userId)
            .then((_) {
          final booksProvider = Provider.of<MyBooksProvider>(context, listen: false);
          final books = booksProvider.myBooks;
          _selectedBook = books.firstWhere(
            (book) => book.id == widget.note!['bookId'],
            orElse: () => Book(
              id: '',
              title: 'Unknown Book',
              authors: [],
              thumbnail: '',
              description: '',
              category: 'General',
              status: 'Not Read',
              pages: 0,
              totalPages: 0,
            ),
          );
          setState(() {});
        });
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _noteController.dispose();
    _bookSearchController.dispose();
    super.dispose();
  }

  void _submitData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final int? userId = userProvider.currentUser?.usrId;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: No user session found.")),
      );
      return;
    }

    if (_selectedBook == null && widget.note == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a book.")),
      );
      return;
    }

    if (_pageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a page number.")),
      );
      return;
    }

    if (_noteController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please write a note.")),
      );
      return;
    }

    try {
      final noteForDb = {
        'usrId': userId,
        'bookId': _selectedBook?.id ?? widget.note!['bookId'],
        'pageNumber': _pageController.text,
        'noteText': _noteController.text,
        'date': widget.note != null
            ? widget.note!['date']
            : "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
      };

      if (widget.note != null) {
        noteForDb['id'] = widget.note!['id'];
        await _dbHelper.updateNote(noteForDb);
      } else {
        await _dbHelper.insertNote(noteForDb);
      }

      if (!mounted) return;
      Navigator.pop(context, true);

      final quotesProvider = Provider.of<MyBooksProvider>(context, listen: false);
      quotesProvider.fetchUserBooks(userId).then((_) {
        setState(() {}); 
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save: $e"), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _captureAndExtractText() async {
    final picker = ImagePicker();

    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Recadrer',
            toolbarColor: Colors.black,       
            toolbarWidgetColor: Colors.white, 
            statusBarColor: Colors.black,     
            backgroundColor: Colors.black,
            activeControlsWidgetColor: Colors.blue,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            hideBottomControls: false,
          ),
          IOSUiSettings(
            title: 'Recadrer',
          ),
        ],
      );

      if (croppedFile == null) return;

      final inputImage = InputImage.fromFilePath(croppedFile.path);
      final textRecognizer = TextRecognizer();

      try {
        final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

        setState(() {
          if (_noteController.text.isEmpty) {
            _noteController.text = recognizedText.text;
          } else {
            _noteController.text += "\n${recognizedText.text}";
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Text extracted!"), backgroundColor: Colors.green),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("OCR Failed: $e"), backgroundColor: Colors.red),
        );
      } finally {
        textRecognizer.close();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Consumer<MyBooksProvider>(
      builder: (context, myBooksProvider, child) {
        final myBooks = myBooksProvider.myBooks;

        return Scaffold(
          backgroundColor: isDark ? AppThemes.darkBg : Colors.white,
          appBar: AppBar(
            backgroundColor: isDark ? AppThemes.darkBg : Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.close, color: isDark ? Colors.white : Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              "New Note",
              style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            actions: [
              TextButton(
                onPressed: _submitData,
                child: Text(
                  "Save",
                  style: TextStyle(color: AppThemes.accentColor, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              )
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Book Details", style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? AppThemes.textSecondary : Colors.grey)),
                const SizedBox(height: 15),

                LayoutBuilder(builder: (context, constraints) {
                  return DropdownMenu<Book>(
                    controller: _bookSearchController,
                    width: constraints.maxWidth,
                    enableFilter: true,
                    requestFocusOnTap: true,
                    leadingIcon: Icon(Icons.book, color: isDark ? AppThemes.accentColor : Colors.black54),
                    label: Text("Select Book", style: TextStyle(color: isDark ? AppThemes.textSecondary : Colors.black)),
                    inputDecorationTheme: InputDecorationTheme(
                      filled: true,
                      fillColor: isDark ? AppThemes.darkSecondaryBg : const Color(0xFFF5F7FA),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    menuHeight: 300,
                    dropdownMenuEntries: myBooks.map<DropdownMenuEntry<Book>>((Book book) {
                      return DropdownMenuEntry<Book>(
                        value: book,
                        label: book.title,
                        style: MenuItemButton.styleFrom(
                          foregroundColor: isDark ? Colors.white : Colors.black87,
                        ),
                      );
                    }).toList(),
                    onSelected: (Book? book) {
                      setState(() {
                        _selectedBook = book;
                      });
                    },
                  );
                }),

                const SizedBox(height: 15),
                TextField(
                  controller: _pageController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: isDark ? AppThemes.darkSecondaryBg : const Color(0xFFF5F7FA),
                    prefixIcon: Icon(Icons.bookmark_border, color: isDark ? AppThemes.accentColor : Colors.black54),
                    hintText: "Page Number",
                    hintStyle: TextStyle(color: isDark ? AppThemes.textTertiary : Colors.grey),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 30),
                Text("Your Thoughts", style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? AppThemes.textSecondary : Colors.grey)),
                const SizedBox(height: 15),
                Container(
                  height: 320,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? AppThemes.darkSecondaryBg : const Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _noteController,
                    maxLines: null,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 18, fontWeight: FontWeight.w500),
                    decoration: InputDecoration(
                      hintText: "Write or scan your quote...",
                      hintStyle: TextStyle(color: isDark ? AppThemes.textTertiary : Colors.grey, fontSize: 18, fontWeight: FontWeight.w500),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: _captureAndExtractText,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Scan Text"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? AppThemes.accentColor : Colors.blue,
                      foregroundColor: isDark ? Colors.black : Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
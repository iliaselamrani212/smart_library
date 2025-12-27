import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:provider/provider.dart';
import 'package:smart_library/auth/database_helper.dart';
import 'package:smart_library/providers/user_provider.dart';
import 'package:smart_library/providers/my_books_provider.dart';
import 'package:smart_library/models/books_model.dart';
import 'package:image_cropper/image_cropper.dart';

class AddNoteScreen extends StatefulWidget {
  const AddNoteScreen({Key? key}) : super(key: key);

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

    // --- CORRECTION CRITIQUE ICI ---
    // On attend que la page soit construite avant de charger les livres
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userId = userProvider.currentUser?.usrId;
      if (userId != null) {
        Provider.of<MyBooksProvider>(context, listen: false).fetchUserBooks(userId);
      }
    });
    // -------------------------------
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

    if (_selectedBook == null || _noteController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a book and enter a note.")),
      );
      return;
    }

    try {
      final noteForDb = {
        'usrId': userId,
        'bookId': _selectedBook!.title,
        'content': _noteController.text,
        'createdAt': "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
      };

      await _dbHelper.insertNote(noteForDb);

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save: $e"), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _captureAndExtractText() async {
    final picker = ImagePicker();

    // 1. PRENDRE LA PHOTO
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      // 2. RECADRER LA PHOTO (CROP)
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        // Configuration Android pour éviter les boutons cachés
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Recadrer',
            toolbarColor: Colors.black,       // Fond noir
            toolbarWidgetColor: Colors.white, // Icones blanches
            statusBarColor: Colors.black,     // Barre d'état noire (IMPORTANT)
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

      // Si l'utilisateur annule le crop
      if (croppedFile == null) return;

      // 3. OCR SUR L'IMAGE RECADRÉE
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
    // Utilisation de Consumer pour éviter les erreurs de rebuild si le provider change
    return Consumer<MyBooksProvider>(
      builder: (context, myBooksProvider, child) {
        final myBooks = myBooksProvider.myBooks;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              "New Note",
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            actions: [
              TextButton(
                onPressed: _submitData,
                child: const Text(
                  "Save",
                  style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              )
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Book Details", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 15),

                // --- DROPDOWN MENU ---
                LayoutBuilder(builder: (context, constraints) {
                  return DropdownMenu<Book>(
                    controller: _bookSearchController,
                    width: constraints.maxWidth,
                    enableFilter: true,
                    requestFocusOnTap: true,
                    leadingIcon: const Icon(Icons.book, color: Colors.black54),
                    label: const Text("Select Book"),
                    inputDecorationTheme: InputDecorationTheme(
                      filled: true,
                      fillColor: const Color(0xFFF5F7FA),
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
                          foregroundColor: Colors.black87,
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
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF5F7FA),
                    prefixIcon: const Icon(Icons.bookmark_border, color: Colors.black54),
                    hintText: "Page Number",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 30),
                const Text("Your Thoughts", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 15),
                Container(
                  height: 250,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: const Color(0xFFF5F7FA), borderRadius: BorderRadius.circular(12)),
                  child: TextField(
                    controller: _noteController,
                    maxLines: null,
                    decoration: const InputDecoration(hintText: "Write or scan your quote...", border: InputBorder.none),
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
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
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
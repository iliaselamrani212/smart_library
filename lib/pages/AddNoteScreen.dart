import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:provider/provider.dart';
import 'package:smart_library/auth/database_helper.dart';
import 'package:smart_library/providers/user_provider.dart';

class AddNoteScreen extends StatefulWidget {
  const AddNoteScreen({Key? key}) : super(key: key);

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _bookController = TextEditingController();
  final _pageController = TextEditingController();
  final _noteController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void dispose() {
    _bookController.dispose();
    _pageController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // --- Logic to save the quote to the Database ---
  void _submitData() async {
    // 1. Get the current user ID from the Provider
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final int? userId = userProvider.currentUser?.usrId;

    // Check if user is logged in
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: No user session found.")),
      );
      return;
    }

    // Check if required fields are filled
    if (_bookController.text.isEmpty || _noteController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a book name and a note.")),
      );
      return;
    }

    // 2. Prepare the data for SQLite
    final newNote = {
      'usrId': userId,
      'bookTitle': _bookController.text,
      'pageNumber': _pageController.text.isEmpty ? '?' : _pageController.text,
      'noteText': _noteController.text,
      'date': "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
    };

    try {
      // 3. Insert into the database
      await _dbHelper.insertNote(newNote);
      
      if (!mounted) return;
      // Close the screen and return 'true' to tell the previous screen to refresh
      Navigator.pop(context, true); 
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save: $e"), backgroundColor: Colors.red),
      );
    }
  }

  // --- Logic for OCR (Text Recognition) ---
  Future<void> _captureAndExtractText() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final inputImage = InputImage.fromFilePath(pickedFile.path);
      final textRecognizer = TextRecognizer();

      try {
        final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
        setState(() {
          _noteController.text = recognizedText.text;
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
            TextField(
              controller: _bookController,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF5F7FA),
                prefixIcon: const Icon(Icons.book, color: Colors.black54),
                hintText: "Book Title",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
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
  }
}
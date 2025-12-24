import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:io';

class AddNoteScreen extends StatefulWidget {
  const AddNoteScreen({Key? key}) : super(key: key);

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _bookController = TextEditingController();
  final _pageController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _bookController.dispose();
    _pageController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submitData() {
    if (_bookController.text.isEmpty || _noteController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a book name and a note.")),
      );
      return;
    }

    final newNote = {
      'book': _bookController.text,
      'page': _pageController.text.isEmpty ? '?' : _pageController.text,
      'text': _noteController.text,
      'date':
          "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
    };

    Navigator.pop(context, newNote);
  }

  Future<void> _captureAndExtractText() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final inputImage = InputImage.fromFilePath(pickedFile.path);
      final textRecognizer = TextRecognizer();

      try {
        final RecognizedText recognizedText =
            await textRecognizer.processImage(inputImage);
        setState(() {
          _noteController.text = recognizedText.text;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Text extracted successfully!"),
              backgroundColor: Colors.green),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Failed to extract text: $e"),
              backgroundColor: Colors.red),
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
              style: TextStyle(
                  color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Book Details",
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _bookController,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF5F7FA),
                prefixIcon: const Icon(Icons.book, color: Colors.black54),
                hintText: "Book Title (e.g. 1984)",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _pageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF5F7FA),
                prefixIcon:
                    const Icon(Icons.bookmark_border, color: Colors.black54),
                hintText: "Page Number",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Your Thoughts",
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 15),
            Container(
              height: 300,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _noteController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                style: const TextStyle(fontSize: 16, height: 1.5),
                decoration: const InputDecoration(
                  hintText: "Write your favorite quote or thought here...",
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: _captureAndExtractText,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Scan Text"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
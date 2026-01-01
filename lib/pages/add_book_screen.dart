import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:smart_library/models/books_model.dart';
import 'package:smart_library/providers/my_books_provider.dart';
import 'package:smart_library/providers/user_provider.dart';
import 'package:smart_library/providers/favorites_provider.dart';
import 'package:smart_library/theme/app_themes.dart';

import 'layout.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorCont = TextEditingController();
  final TextEditingController _isbnController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  
  final TextEditingController _pagesController = TextEditingController(); 

  dynamic _selectedImage; 
  bool _isFavorite = false;

  Future<void> _scanISBN() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BarcodeScannerScreen()),
    );

    if (result != null) {
      setState(() => _isbnController.text = result);

      try {
        final response = await http.get(Uri.parse('https://www.googleapis.com/books/v1/volumes?q=isbn:$result'));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['totalItems'] > 0) {
            final book = data['items'][0]['volumeInfo'];

            setState(() {
              _titleController.text = book['title'] ?? '';
              _authorCont.text = (book['authors'] as List?)?.join(', ') ?? '';
              _yearController.text = book['publishedDate']?.split('-')[0] ?? '';
              _categoryController.text = (book['categories'] as List?)?.join(', ') ?? 'General';
              _noteController.text = book['description'] ?? '';
              
              _pagesController.text = book['pageCount']?.toString() ?? '';

              if (book['imageLinks'] != null && book['imageLinks']['thumbnail'] != null) {
                _selectedImage = book['imageLinks']['thumbnail'].replaceFirst('http://', 'https://');
              }
            });
            _showSnackBar("Book details imported!", Colors.green);
          } else {
            _showSnackBar("No book found for this ISBN.", Colors.orange);
          }
        }
      } catch (e) {
        _showSnackBar("API Error: $e", Colors.red);
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a photo'),
              onTap: () async {
                Navigator.pop(ctx);
                final res = await picker.pickImage(source: ImageSource.camera, imageQuality: 50);
                if (res != null) setState(() => _selectedImage = File(res.path));
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () async {
                Navigator.pop(ctx);
                final res = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
                if (res != null) setState(() => _selectedImage = File(res.path));
              },
            ),
          ],
        ),
      ),
    );
  }

  void _saveBook() async {
    if (_formKey.currentState!.validate()) {
      try {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final int? userId = userProvider.currentUser?.usrId;

        if (userId == null) {
          _showSnackBar("Please login first", Colors.red);
          return;
        }

        String imagePath = '';
        if (_selectedImage is File) {
          imagePath = (_selectedImage as File).path;
        } else if (_selectedImage is String) {
          imagePath = _selectedImage;
        }

        final newBook = Book(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: _titleController.text,
          authors: _authorCont.text.split(',').map((e) => e.trim()).toList(),
          thumbnail: imagePath,
          description: _noteController.text,
          category: _categoryController.text.isEmpty ? 'General' : _categoryController.text,
          totalPages: int.tryParse(_pagesController.text) ?? 0, 
          pages: 0, 
        );

        await Provider.of<MyBooksProvider>(context, listen: false).addBook(newBook, userId);

        if (_isFavorite) {
          final favProvider = Provider.of<FavoriteBooksProvider>(context, listen: false);
          favProvider.setCurrentUserId(userId);
          await favProvider.addFavorite(newBook);
        }

        if (mounted) {
          _showSnackBar("Book saved successfully!", Colors.green);
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => Layout(id_page: 1)),
                (route) => false,
          );
        }
      } catch (e) {
        _showSnackBar("Error saving: $e", Colors.red);
      }
    }
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppThemes.darkBg : Colors.white,
      appBar: AppBar(
        title: Text("Add a Book", style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? AppThemes.darkBg : Colors.white,
        elevation: 0, centerTitle: true,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _scanISBN,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppThemes.accentColor : Colors.black,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.qr_code_scanner, color: isDark ? Colors.black : Colors.white),
                      const SizedBox(width: 12),
                      Text("Scan ISBN Code", style: TextStyle(color: isDark ? Colors.black : Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 180, width: 120,
                    decoration: BoxDecoration(
                      color: isDark ? AppThemes.darkCardBg : const Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isDark ? AppThemes.borderColor : Colors.grey.shade300),
                      image: _selectedImage != null ? _buildDecorationImage() : null,
                    ),
                    child: _selectedImage == null 
                        ? Icon(Icons.add_a_photo, color: isDark ? Colors.grey.shade600 : Colors.grey, size: 40) 
                        : null,
                  ),
                ),
              ),
              
              const SizedBox(height: 25),
              _buildLabel("Book Title", isDark),
              _buildTextField(_titleController, "Title", Icons.book, isDark),
              
              const SizedBox(height: 15),
              _buildLabel("Author", isDark),
              _buildTextField(_authorCont, "Author(s)", Icons.person_outline, isDark),
              
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, 
                      children: [
                        _buildLabel("Category", isDark),
                        _buildTextField(_categoryController, "Category", Icons.category_outlined, isDark),
                      ]
                    )
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, 
                      children: [
                        _buildLabel("Year", isDark),
                        _buildTextField(_yearController, "Year", Icons.calendar_today, isDark, isNumber: true),
                      ]
                    )
                  ),
                ],
              ),
              
              const SizedBox(height: 15),
              _buildLabel("Description", isDark),
              _buildTextField(_noteController, "Description...", Icons.notes, isDark, maxLines: 3, isRequired: false),

              const SizedBox(height: 15),
              _buildLabel("Page Number", isDark),
              _buildTextField(
                _pagesController,
                "Enter page number",
                Icons.format_list_numbered,
                isDark,
                isNumber: true,
                isRequired: false, 
              ),

              const SizedBox(height: 20),
              SwitchListTile(
                value: _isFavorite,
                activeColor: isDark ? AppThemes.accentColor : Colors.black,
                onChanged: (v) => setState(() => _isFavorite = v),
                title: Text("Mark as Favorite", style: TextStyle(color: isDark ? Colors.white : Colors.black)),
              ),
              
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveBook,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? AppThemes.accentColor : Colors.black, 
                    padding: const EdgeInsets.all(16),
                  ),
                  child: Text("SAVE BOOK", style: TextStyle(color: isDark ? Colors.black : Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  DecorationImage _buildDecorationImage() {
    if (_selectedImage is String) {
      return DecorationImage(image: NetworkImage(_selectedImage), fit: BoxFit.cover);
    } else {
      return DecorationImage(image: FileImage(_selectedImage as File), fit: BoxFit.cover);
    }
  }

  Widget _buildLabel(String text, bool isDark) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
  );

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, bool isDark, {bool isNumber = false, int maxLines = 1, bool isRequired = true}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      validator: (v) => isRequired && (v == null || v.isEmpty) ? "Required" : null,
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, size: 20, color: isDark ? AppThemes.accentColor : Colors.black54),
        hintText: hint,
        hintStyle: TextStyle(color: isDark ? Colors.grey.shade600 : Colors.grey.shade500),
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        filled: true, fillColor: isDark ? AppThemes.darkSecondaryBg : const Color(0xFFF5F7FA),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: isDark ? BorderSide(color: AppThemes.borderColor) : BorderSide.none),
      ),
    );
  }
}

class BarcodeScannerScreen extends StatelessWidget {
  const BarcodeScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppThemes.darkBg : Colors.white,
      appBar: AppBar(
        title: Text("Scan ISBN", style: TextStyle(color: isDark ? Colors.white : Colors.black)),
        backgroundColor: isDark ? AppThemes.darkBg : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      ),
      body: MobileScanner(
        onDetect: (capture) {
          final barcode = capture.barcodes.first;
          if (barcode.rawValue != null) {
            Navigator.pop(context, barcode.rawValue); 
          }
        },
      ),
    );
  }
}
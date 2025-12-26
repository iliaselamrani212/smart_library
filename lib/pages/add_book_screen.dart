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

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();

  // Text Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _isbnController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  // State Variables
  String _readingStatus = 'To Read';
  dynamic _selectedImage; // Changed to dynamic to accommodate both File and String
  bool _isFavorite = false;

  final List<String> _statusOptions = ['To Read', 'Reading', 'Finished'];

  // --- FONCTION POUR SCANNER L'ISBN ---
  Future<void> _scanISBN() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BarcodeScannerScreen()),
    );

    if (result != null) {
      setState(() {
        _isbnController.text = result;
      });

      try {
        // Fetch book data from Google Books API
        final response = await http.get(Uri.parse('https://www.googleapis.com/books/v1/volumes?q=isbn:$result'));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['totalItems'] > 0) {
            final book = data['items'][0]['volumeInfo'];

            setState(() {
              _titleController.text = book['title'] ?? '';
              _authorController.text = (book['authors'] != null && book['authors'].isNotEmpty) ? book['authors'].join(', ') : '';
              _yearController.text = book['publishedDate']?.split('-')[0] ?? '';
              _categoryController.text = (book['categories'] != null && book['categories'].isNotEmpty) ? book['categories'][0] : '';
              _noteController.text = book['description'] ?? '';

              // Fetch and set the book's thumbnail image
              if (book['imageLinks'] != null && book['imageLinks']['thumbnail'] != null) {
                _selectedImage = book['imageLinks']['thumbnail'];
              }
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Book data added to the form!"), backgroundColor: Colors.green),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("No book data found for this ISBN."), backgroundColor: Colors.red),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to fetch book data."), backgroundColor: Colors.red),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Function to pick an image
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        height: 150,
        color: Colors.white,
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a photo'),
              onTap: () async {
                Navigator.pop(ctx);
                final pickedFile = await picker.pickImage(source: ImageSource.camera);
                if (pickedFile != null) {
                  setState(() => _selectedImage = File(pickedFile.path));
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () async {
                Navigator.pop(ctx);
                final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  setState(() => _selectedImage = File(pickedFile.path));
                }
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
        // Fallback user ID 1 if not logged in (for testing purposes)
        final userId = userProvider.currentUser?.usrId ?? 1;

        String imagePath = '';
        if (_selectedImage is File) {
          imagePath = (_selectedImage as File).path;
        } else if (_selectedImage is String) {
          imagePath = _selectedImage;
        }

        final newBook = Book(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: _titleController.text,
          authors: _authorController.text.split(',').map((e) => e.trim()).toList(),
          thumbnail: imagePath,
          description: _noteController.text,
        );

        // Add to My Books
        await Provider.of<MyBooksProvider>(context, listen: false).addBook(newBook, userId);

        // Add to Favorites if selected
        if (_isFavorite) {
           final favProvider = Provider.of<FavoriteBooksProvider>(context, listen: false);
           // Ensure fav provider knows current user
           favProvider.setCurrentUserId(userId);
           await favProvider.addFavorite(newBook);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(_isFavorite
                    ? 'Book added to Library & Favorites!'
                    : 'Book added to Library successfully!'),
                backgroundColor: Colors.green
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error saving book: $e"), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
            "Add a Book",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 40),


              // ===============================================
              // 0. BOUTON SCAN EN HAUT (NOUVEAU)
              // ===============================================
              GestureDetector(
                onTap: _scanISBN,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black, // Fond noir pour attirer l'attention
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.qr_code_scanner, color: Colors.white, size: 28),
                      SizedBox(width: 12),
                      Text(
                        "Scan ISBN Code",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 50),

              const Center(child: Text("— OR FILL MANUALLY —", style: TextStyle(color: Colors.grey, fontSize: 12))),

              const SizedBox(height: 20),
              // ===============================================


              // 1. IMAGE SELECTION (Reste inchangé)
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 200,
                    width: 140,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                      image: _selectedImage != null
                          ? (_selectedImage is String && _selectedImage.startsWith('http')
                              ? DecorationImage(
                                  image: NetworkImage(_selectedImage),
                                  fit: BoxFit.cover,
                                )
                              : DecorationImage(
                                  image: FileImage(File(_selectedImage.path ?? _selectedImage)),
                                  fit: BoxFit.cover,
                                ))
                          : null,
                    ),
                    child: _selectedImage == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                              SizedBox(height: 8),
                              Text("Add Cover", style: TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          )
                        : null,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // 2. MAIN FIELDS
              _buildLabel("Book Title"),
              _buildTextField(_titleController, "Ex: Don't Let Him In", Icons.book),

              const SizedBox(height: 20),

              _buildLabel("Author"),
              _buildTextField(_authorController, "Ex: Lisa Jewell", Icons.person_outline),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Category"),
                        _buildTextField(_categoryController, "Ex: Thriller", Icons.category_outlined),
                      ],
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Year"),
                        _buildTextField(_yearController, "2025", Icons.calendar_today, isNumber: true),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 3. ISBN (J'ai retiré le bouton de scan d'ici pour ne le laisser qu'en haut)
              _buildLabel("ISBN (Optional)"),
              _buildTextField(
                _isbnController,
                "978-3-16-148410-0",
                Icons.qr_code,
                isRequired: false,
              ),

              const SizedBox(height: 20),

              _buildLabel("Description"),
              _buildTextField(
                  _noteController,
                  "Write your thoughts here...",
                  Icons.edit_note,
                  maxLines: 4,
                  isRequired: false
              ),

              const SizedBox(height: 25),

              // 4. READING STATUS
              _buildLabel("Reading Status"),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _readingStatus,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items: _statusOptions.map((String status) {
                      return DropdownMenuItem<String>(
                        value: status,
                        child: Text(status, style: const TextStyle(fontWeight: FontWeight.w500)),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _readingStatus = newValue!;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // 5. FAVORITES SWITCH
              _buildLabel("Options"),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SwitchListTile(
                  title: const Text(
                    "Add to Favorites",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  secondary: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? Colors.red : Colors.grey,
                    size: 28,
                  ),
                  value: _isFavorite,
                  activeColor: Colors.black,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onChanged: (bool value) {
                    setState(() {
                      _isFavorite = value;
                    });
                  },
                ),
              ),

              const SizedBox(height: 40),

              // 6. SAVE BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveBook,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Save Book",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // --- UTILITY WIDGETS ---

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String hint,
      IconData icon,
      {
        bool isNumber = false,
        int maxLines = 1,
        bool isRequired = true,
        // J'ai gardé le paramètre optionnel mais je ne l'utilise plus dans ce code
        Widget? suffixIcon,
      }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          return 'This field is required';
        }
        return null;
      },
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF5F7FA),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.grey.shade600, size: 20),

        suffixIcon: suffixIcon,

        prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 0),
        alignLabelWithHint: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
    );
  }
}

// ==========================================
// ECRAN DE SCAN SÉPARÉ (Toujours nécessaire)
// ==========================================
class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  late final MobileScannerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      returnImage: false,
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // Properly dispose of the scanner controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan ISBN')),
      body: MobileScanner(
        controller: _controller,
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            if (barcode.rawValue != null) {
              Navigator.pop(context, barcode.rawValue);
              break;
            }
          }
        },
      ),
    );
  }
}

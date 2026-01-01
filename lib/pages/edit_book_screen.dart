import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/books_model.dart';
import '../providers/my_books_provider.dart';
import '../providers/user_provider.dart';


class EditBookScreen extends StatefulWidget {
  final Book book; 

  const EditBookScreen({Key? key, required this.book}) : super(key: key);

  @override
  State<EditBookScreen> createState() => _EditBookScreenState();
}

class _EditBookScreenState extends State<EditBookScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _descController;
  late TextEditingController _categoryController;
  late TextEditingController _pagesController;
  late TextEditingController _totalPagesController;
  late TextEditingController _thumbnailController;

  String _status = 'To Read';
  final List<String> _statusOptions = ['To Read', 'Reading', 'Finished'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.book.title);

    String authorsString = widget.book.authors.join(', ');
    _authorController = TextEditingController(text: authorsString);

    _descController = TextEditingController(text: widget.book.description);
    _categoryController = TextEditingController(text: widget.book.category);
    _pagesController = TextEditingController(text: widget.book.pages.toString());
    _totalPagesController = TextEditingController(text: widget.book.totalPages.toString());
    _thumbnailController = TextEditingController(text: widget.book.thumbnail);

    if (_statusOptions.contains(widget.book.status)) {
      _status = widget.book.status;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _descController.dispose();
    _categoryController.dispose();
    _pagesController.dispose();
    _totalPagesController.dispose();
    _thumbnailController.dispose();
    super.dispose();
  }

  Future<void> _saveBook() async {
    if (_formKey.currentState!.validate()) {

      List<String> updatedAuthors = _authorController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      Book updatedBook = Book(
        id: widget.book.id, 
        title: _titleController.text,
        authors: updatedAuthors,
        thumbnail: _thumbnailController.text,
        description: _descController.text,
        category: _categoryController.text,
        status: _status,
        pages: int.tryParse(_pagesController.text) ?? 0,
        totalPages: int.tryParse(_totalPagesController.text) ?? 0,
        addedDate: widget.book.addedDate, 
      );

      try {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final userId = userProvider.currentUser?.usrId;

        if (userId != null) {
          await Provider.of<MyBooksProvider>(context, listen: false)
              .updateBook(updatedBook, userId);
          
          if (!mounted) return;
          
          Navigator.pop(context, updatedBook);
        } else {
           if (!mounted) return;
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text("User not found")),
           );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error updating book: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Edit Book", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.blue),
            onPressed: _saveBook,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Center(
                child: Container(
                  height: 150,
                  width: 100,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: AssetImage(widget.book.thumbnail), 
                        fit: BoxFit.cover,
                        onError: (_,__) => const Icon(Icons.broken_image),
                      )
                  ),
                ),
              ),
              const SizedBox(height: 20),

              _buildTextField("Title", _titleController, Icons.book),
              const SizedBox(height: 16),
              _buildTextField("Authors (comma separated)", _authorController, Icons.person),
              const SizedBox(height: 16),
              _buildTextField("Category", _categoryController, Icons.category),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(child: _buildTextField("Current Page", _pagesController, Icons.bookmark, isNumber: true)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField("Total Pages", _totalPagesController, Icons.format_list_numbered, isNumber: true)),
                ],
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _status,
                    isExpanded: true,
                    items: _statusOptions.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (val) => setState(() => _status = val!),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              _buildTextField("Description", _descController, Icons.description, maxLines: 5),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                  ),
                  onPressed: _saveBook,
                  child: const Text("Save Changes", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController ctrl, IconData icon, {bool isNumber = false, int maxLines = 1}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      validator: (v) => v!.isEmpty ? "Required" : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: maxLines == 1 ? Icon(icon, color: Colors.grey) : null,
        filled: true,
        fillColor: const Color(0xFFF5F7FA),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}

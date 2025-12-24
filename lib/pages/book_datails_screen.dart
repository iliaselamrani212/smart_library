import 'package:flutter/material.dart';

class BookDetailsScreen extends StatefulWidget {
  final Map<String, String> book;

  const BookDetailsScreen({
    Key? key,
    this.book = const {
      'title': 'Ne le laissez pas entrer',
      'author': 'Lisa Jewell',
      'image': 'assets/images/logo.jpg',
      'rating': '4.1',
      'reviews': '83',
      'category': 'Crime & Thrillers',
      'pages': '448',
    },
  }) : super(key: key);

  @override
  State<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  double _currentPage = 0;
  late int _totalPages;
  bool _isFinished = false;
  bool _isEditingProgress = false;

  late TextEditingController _pageController;

  @override
  void initState() {
    super.initState();
    _totalPages = int.tryParse(widget.book['pages'] ?? '300') ?? 300;
    _pageController = TextEditingController(text: _currentPage.toInt().toString());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _enableReading() {
    setState(() {
      _isEditingProgress = true;
      _isFinished = false;
    });
  }

  void _saveProgress() {
    setState(() {
      _isEditingProgress = false;
      _pageController.text = _currentPage.toInt().toString();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Saved at page ${_currentPage.toInt()}!"),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    });
  }

  void _markAsFinished() {
    setState(() {
      _currentPage = _totalPages.toDouble();
      _pageController.text = _totalPages.toString();
      _isEditingProgress = false;
      _isFinished = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Congratulations! You finished the book!"),
        backgroundColor: Colors.black, // CHANGÉ : Noir au lieu de Bleu
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _onPageInputChanged(String value) {
    int? newPage = int.tryParse(value);
    if (newPage != null) {
      setState(() {
        if (newPage > _totalPages) {
          _currentPage = _totalPages.toDouble();
        } else if (newPage < 0) {
          _currentPage = 0;
        } else {
          _currentPage = newPage.toDouble();
        }
      });
    }
  }

  void _showOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: const Text("Modifier"),
                onTap: () {
                  Navigator.pop(context);
                  print("Modifier cliqué");
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text("Supprimer", style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  print("Supprimer cliqué");
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
    return Scaffold(
      backgroundColor: Colors.white,

      // ---------- APP BAR ----------
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border, color: Colors.black),
            onPressed: _showOptions,
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.black),
            onPressed: _showOptions,
          ),
        ],
      ),

      // ---------- BODY ----------
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // 1. IMAGE
            Center(
              child: Container(
                height: 320,
                width: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  image: const DecorationImage(
                    image: AssetImage('assets/images/femme.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // 2. TEXTES
            Text(
              widget.book['title']!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontFamily: 'Serif',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "${widget.book['author']} & Adèle Rolland-Le Dem >",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.book['category']!,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // 4. BOUTONS READ / SAVE
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    "French • 5 November 2025 • $_totalPages Pages",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isEditingProgress ? null : _enableReading,
                          icon: const Icon(Icons.menu_book, size: 18, color: Colors.black),
                          label: const Text("Read", style: TextStyle(color: Colors.black)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: _isEditingProgress ? Colors.grey.shade300 : Colors.black),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isEditingProgress ? _saveProgress : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            disabledBackgroundColor: Colors.grey.shade300,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: const Text(
                            "Save",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 5. PROGRESSION
            _isFinished
                ? const SizedBox()
                : AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _isEditingProgress ? 1.0 : 0.6,
              child: AbsorbPointer(
                absorbing: !_isEditingProgress,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(20),
                    border: _isEditingProgress
                        ? Border.all(color: Colors.black, width: 1.5)
                        : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Text(
                                "Reading Progress",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              if (!_isEditingProgress)
                                const Padding(
                                  padding: EdgeInsets.only(left: 8.0),
                                  child: Icon(Icons.lock_outline, size: 18, color: Colors.grey),
                                ),
                            ],
                          ),
                          Text(
                            "${(_currentPage / _totalPages * 100).toInt()}%",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _isEditingProgress ? Colors.black : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: Colors.black,
                          inactiveTrackColor: Colors.grey.shade300,
                          thumbColor: Colors.black,
                          overlayColor: Colors.black.withOpacity(0.1),
                          trackHeight: 6.0,
                        ),
                        child: Slider(
                          value: _currentPage,
                          min: 0,
                          max: _totalPages.toDouble(),
                          onChanged: (value) {
                            setState(() {
                              _currentPage = value;
                              _pageController.text = value.toInt().toString();
                            });
                          },
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Text("Page ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 70,
                                height: 35,
                                child: TextField(
                                  controller: _pageController,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  onChanged: _onPageInputChanged,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: const EdgeInsets.only(bottom: 10),
                                    isDense: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(color: Colors.grey.shade400),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(color: Colors.black, width: 2),
                                    ),
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

            // 6. BOUTON FINISHED (MODIFIÉ ICI)
            Center(
              child: ElevatedButton(
                onPressed: _isFinished ? null : _markAsFinished,
                style: ElevatedButton.styleFrom(
                  disabledBackgroundColor: Colors.grey.shade300,
                  backgroundColor: Colors.black, // CHANGÉ : Noir pour le thème
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 0,
                ),
                child: Text(
                  _isFinished ? 'Finished' : "Mark as Finished",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // CHANGÉ : Blanc sur fond noir
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
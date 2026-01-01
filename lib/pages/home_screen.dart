import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:smart_library/auth/database_helper.dart'; 
import 'package:smart_library/models/books_model.dart';
import 'package:smart_library/providers/my_books_provider.dart';
import 'package:smart_library/providers/favorites_provider.dart';
import 'package:smart_library/providers/user_provider.dart';
import 'package:smart_library/pages/book_datails_screen.dart';
import 'package:smart_library/theme/app_themes.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  final Function(int) onTabChange;

  const HomeScreen({Key? key, required this.onTabChange}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper(); 
  int _pagesReadThisMonth = 0; 

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.currentUser?.usrId;

    if (userId != null) {
      Provider.of<MyBooksProvider>(context, listen: false).fetchUserBooks(userId);
      Provider.of<FavoriteBooksProvider>(context, listen: false).fetchFavorites(userId);

      final pages = await _dbHelper.getPagesReadThisMonth(userId);
      if (mounted) {
        setState(() {
          _pagesReadThisMonth = pages;
        });
      }
    }
  }

  ImageProvider _buildBookImage(String thumbnail) {
    if (thumbnail.isEmpty) {
      return const AssetImage('assets/images/test.jpg');
    }
    if (thumbnail.startsWith('http')) {
      return NetworkImage(thumbnail);
    }
    return const AssetImage('assets/images/test.jpg');
  }

  void _navigateToDetails(Book book) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookDetailsScreen(book: book),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final myBooksProvider = Provider.of<MyBooksProvider>(context);
    final allBooks = myBooksProvider.myBooks;
    
    final recentBooks = allBooks.reversed.take(3).toList();

    final finishedCount = allBooks.where((b) => b.status == 'Finished').length;
    final readingCount = allBooks.where((b) => b.status == 'Reading').length;
    final toReadCount = allBooks.where((b) => b.status == 'Not Read' || b.status == 'To Read').length;
    final totalCount = allBooks.length;

    final int monthlyGoal = 300;
    
    double progressPercent = _pagesReadThisMonth / monthlyGoal;
    if (progressPercent > 1.0) progressPercent = 1.0;


    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                _buildProgressCard(progressPercent, _pagesReadThisMonth, monthlyGoal),

                const SizedBox(height: 30),

                const Text(
                  "Statistics",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),

                ReadingStatusChart(
                  finished: finishedCount,
                  reading: readingCount,
                  toRead: toReadCount,
                ),
                const SizedBox(height: 15),

                CategoryBarChart(books: allBooks),
                const SizedBox(height: 15),

                const MonthlyProgressChart(),

                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Overview",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {
                        widget.onTabChange(1);
                      },
                      child: Text(
                        "View All",
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(child: _buildCategoryCard("Total Books", "$totalCount Books", Icons.collections_bookmark_outlined)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildCategoryCard("Finished", "$finishedCount Books", Icons.done_all)), 
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildCategoryCard("Reading", "$readingCount Books", Icons.menu_book)), 
                    const SizedBox(width: 16),
                    Expanded(child: _buildCategoryCard("To Read", "$toReadCount Books", Icons.bookmark_border)), 
                  ],
                ),

                const SizedBox(height: 40),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Recently Added",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                     IconButton(
                      icon: const Icon(Icons.tune),
                      onPressed: () {
                         widget.onTabChange(1);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                if (recentBooks.isEmpty)
                  const Text("No books added recently.")
                else
                  Consumer<FavoriteBooksProvider>(
                    builder: (context, favoritesProvider, child) {
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: recentBooks.length,
                        itemBuilder: (context, index) {
                          final book = recentBooks[index];
                          final isFavorite = favoritesProvider.favorites.any((b) => b.id == book.id);
                          return _buildRecentBookItem(context, book, isFavorite);
                        },
                      );
                    },
                  ),
                  
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentBookItem(BuildContext context, Book book, bool isFavorite) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () => _navigateToDetails(book),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              width: 80,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: _buildBookImage(book.thumbnail),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                    ),
                  ]),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.authors.join(', '),
                    style: const TextStyle(
                      color: Color(0xFF4F46E5),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    book.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.blueGrey.shade400,
                      height: 1.4,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                final provider = Provider.of<FavoriteBooksProvider>(context, listen: false);
                if (isFavorite) {
                   provider.removeFavorite(book.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${book.title} removed from favorites')),
                    );
                } else {
                   provider.addFavorite(book);
                   ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${book.title} added to favorites')),
                   );
                }
              },
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: const Color(0xFFFF4757),
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(double percent, int pagesRead, int goal) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black, 
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Monthly Goal",
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "$pagesRead / $goal pages",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Keep reading to reach your goal!",
                  style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    widget.onTabChange(1);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black, 
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: const Text("Continue Reading", style: TextStyle(fontWeight: FontWeight.bold)),
                )
              ],
            ),
          ),
          const SizedBox(width: 20),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 80, height: 80,
                child: CircularProgressIndicator(
                  value: percent,
                  strokeWidth: 8,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Text("${(percent * 100).toInt()}%", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String title, String count, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA), 
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.black, size: 22),
          ),
          const SizedBox(height: 20),
          Text(count, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black)),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class ReadingStatusChart extends StatelessWidget {
  final int finished;
  final int reading;
  final int toRead;

  const ReadingStatusChart({super.key, required this.finished, required this.reading, required this.toRead});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    bool isEmpty = (finished == 0 && reading == 0 && toRead == 0);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppThemes.darkCardBg : const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Reading Status", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : Colors.black)),
          const SizedBox(height: 20),
          SizedBox(
            height: 150,
            child: Row(
              children: [
                Expanded(
                  child: isEmpty 
                  ? Center(child: Text("No data yet", style: TextStyle(color: isDark ? Colors.grey.shade500 : Colors.grey)))
                  : PieChart(
                    PieChartData(
                      sectionsSpace: 0,
                      centerSpaceRadius: 30,
                      sections: [
                        if (finished > 0)
                        PieChartSectionData(value: finished.toDouble(), color: isDark ? AppThemes.accentColor : Colors.black, radius: 25, showTitle: false),
                        if (reading > 0)
                        PieChartSectionData(value: reading.toDouble(), color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, radius: 25, showTitle: false),
                        if (toRead > 0)
                        PieChartSectionData(value: toRead.toDouble(), color: isDark ? Colors.grey.shade700 : Colors.grey.shade300, radius: 25, showTitle: false),
                      ],
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLegendItem(isDark ? AppThemes.accentColor : Colors.black, "Finished ($finished)", isDark),
                    _buildLegendItem(isDark ? Colors.grey.shade400 : Colors.grey.shade600, "Reading ($reading)", isDark),
                    _buildLegendItem(isDark ? Colors.grey.shade700 : Colors.grey.shade300, "To Read ($toRead)", isDark),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(color: isDark ? Colors.grey.shade300 : Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class CategoryBarChart extends StatelessWidget {
  final List<Book> books;
  const CategoryBarChart({super.key, required this.books});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    Map<String, int> counts = {};
    for (var book in books) {
      String cat = (book.category.isEmpty) ? "General" : book.category;
      counts[cat] = (counts[cat] ?? 0) + 1;
    }
    
    var sortedKeys = counts.keys.toList()..sort((a,b) => counts[b]!.compareTo(counts[a]!));
    var top5 = sortedKeys.take(5).toList();

    if (top5.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: isDark ? AppThemes.darkCardBg : const Color(0xFFF5F7FA), borderRadius: BorderRadius.circular(20)),
          child: const Center(child: Text("No category data yet")),
        );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppThemes.darkCardBg : const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Categories", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : Colors.black)),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index < 0 || index >= top5.length) return const SizedBox();
                        String text = top5[index];
                        if (text.length > 4) text = text.substring(0, 3);
                        
                        TextStyle style = TextStyle(color: isDark ? AppThemes.textSecondary : Colors.grey, fontWeight: FontWeight.bold, fontSize: 10);
                        return SideTitleWidget(meta: meta, child: Text(text, style: style));
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(top5.length, (index) {
                   return _makeBarData(index, counts[top5[index]]!.toDouble(), isDark);
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _makeBarData(int x, double y, bool isDark) {
    return BarChartGroupData(x: x, barRods: [
      BarChartRodData(
        toY: y, 
        color: isDark ? AppThemes.accentColor : Colors.blue.shade400, 
        width: 12, 
        borderRadius: BorderRadius.circular(4),
        backDrawRodData: BackgroundBarChartRodData(
          show: true,
          toY: (y * 1.2),
          color: isDark ? AppThemes.darkSecondaryBg : Colors.grey.shade200,
        ),
      )
    ]);
  }
}

class MonthlyProgressChart extends StatefulWidget {
  const MonthlyProgressChart({super.key});

  @override
  State<MonthlyProgressChart> createState() => _MonthlyProgressChartState();
}

class _MonthlyProgressChartState extends State<MonthlyProgressChart> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<FlSpot> _spots = [];
  bool _isLoading = true;
  List<String> _monthsLabels = []; 

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.currentUser?.usrId;

    if (userId != null) {
      try {
        final stats = await _dbHelper.getMonthlyReadingStats(userId);
        
        List<FlSpot> spots = [];
        List<String> labels = [];
        
        final now = DateTime.now();
        for (int i = 5; i >= 0; i--) {
            final date = DateTime(now.year, now.month - i, 1);
            final key = DateFormat('yyyy-MM').format(date);
            final monthName = DateFormat('MMM').format(date); 
            
            double value = (stats[key] ?? 0).toDouble();
            
            
            spots.add(FlSpot((5-i).toDouble(), value));
            labels.add(monthName);
        }

        if (mounted) {
          setState(() {
            _spots = spots;
            _monthsLabels = labels;
            _isLoading = false;
          });
        }
      } catch (e) {
        debugPrint("Erreur chargement stats mensuelles: $e");
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppThemes.darkCardBg : const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Monthly Activity (Pages Read)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : Colors.black)),
          const SizedBox(height: 20),
          SizedBox(
            height: 150,
            child: _isLoading 
            ? const Center(child: CircularProgressIndicator())
            : LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index < 0 || index >= _monthsLabels.length) return const SizedBox();
                        if (index % 2 != 0 && _monthsLabels.length > 4) return const SizedBox(); 
                        
                        TextStyle style = TextStyle(color: isDark ? AppThemes.textSecondary : Colors.grey, fontSize: 10, fontWeight: FontWeight.bold);
                        return Text(_monthsLabels[index], style: style);
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: _spots,
                    isCurved: true,
                    color: isDark ? AppThemes.accentColor : Colors.black,
                    barWidth: 3,
                    dotData: FlDotData(show: true, getDotPainter: (spot, percent, barData, index) {
                         return FlDotCirclePainter(radius: 4, color: isDark ? AppThemes.accentColor : Colors.black, strokeWidth: 1, strokeColor: Colors.white);
                    }),
                    belowBarData: BarAreaData(
                      show: true,
                      color: (isDark ? AppThemes.accentColor : Colors.black).withOpacity(0.05),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
// import '../widgets/calender.dart'; // Décommentez si vous avez ce fichier

class HomeScreen extends StatefulWidget {
  // Callback pour changer d'onglet depuis le Home
  final Function(int) onTabChange;

  const HomeScreen({Key? key, required this.onTabChange}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // 1. CALENDRIER (Placeholder si vous ne l'avez pas encore intégré)
          // const CalendarWidget(),
          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // --- A. CARTE PROGRESSION (Noire) ---
                _buildProgressCard(),

                const SizedBox(height: 30),

                // ==========================================================
                // --- SECTION STATISTIQUES (FL_CHART) ---
                // ==========================================================
                const Text(
                  "Statistics",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),

                // 1. Pie Chart (Statut de lecture)
                const ReadingStatusChart(),
                const SizedBox(height: 15),

                // 2. Bar Chart (Catégories)
                const CategoryBarChart(),
                const SizedBox(height: 15),

                // 3. Line Chart (Progression mensuelle)
                const MonthlyProgressChart(),

                const SizedBox(height: 30),
                // ==========================================================

                // --- C. OVERVIEW HEADER ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Overview",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {
                        // Redirige aussi vers "My Books" (index 1)
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

                // --- CARTES CATÉGORIES (Thème Gris/Noir) ---
                Row(
                  children: [
                    Expanded(child: _buildCategoryCard("Total Books", "25 Books", Icons.collections_bookmark_outlined)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildCategoryCard("Finished", "12 Books", Icons.done_all)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildCategoryCard("Reading", "3 Books", Icons.menu_book)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildCategoryCard("To Read", "10 Books", Icons.bookmark_border)),
                  ],
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET : CARTE NOIRE ---
  Widget _buildProgressCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black, // Fond Noir
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Keep going,\nyour progress is great!",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1.3
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // C'EST ICI QUE LA MAGIE OPÈRE :
                    // On demande au parent (Layout) de changer l'onglet vers l'index 1 (My Books)
                    widget.onTabChange(1);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black, // Texte noir
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: const Text("My Books", style: TextStyle(fontWeight: FontWeight.bold)),
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
                  value: 0.63,
                  strokeWidth: 8,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeCap: StrokeCap.round,
                ),
              ),
              const Text("63%", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          )
        ],
      ),
    );
  }

  // --- WIDGET : CARTE CATÉGORIE ---
  Widget _buildCategoryCard(String title, String count, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA), // Gris Clair
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

// ==============================================================================
// WIDGETS GRAPHIQUES (FL_CHART) - Placé ici pour faciliter le copier-coller
// ==============================================================================

// --- 1. PIE CHART : STATUT ---
class ReadingStatusChart extends StatelessWidget {
  const ReadingStatusChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Reading Status", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 20),
          SizedBox(
            height: 150,
            child: Row(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 0,
                      centerSpaceRadius: 30,
                      sections: [
                        PieChartSectionData(value: 12, color: Colors.black, radius: 25, showTitle: false),
                        PieChartSectionData(value: 3, color: Colors.grey.shade600, radius: 25, showTitle: false),
                        PieChartSectionData(value: 10, color: Colors.grey.shade300, radius: 25, showTitle: false),
                      ],
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLegendItem(Colors.black, "Finished (12)"),
                    _buildLegendItem(Colors.grey.shade600, "Reading (3)"),
                    _buildLegendItem(Colors.grey.shade300, "To Read (10)"),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// --- 2. BAR CHART : CATÉGORIES ---
class CategoryBarChart extends StatelessWidget {
  const CategoryBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Categories", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                        const style = TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 10);
                        String text;
                        switch (value.toInt()) {
                          case 0: text = 'Thril'; break;
                          case 1: text = 'Rom'; break;
                          case 2: text = 'Sci'; break;
                          case 3: text = 'Dra'; break;
                          case 4: text = 'His'; break;
                          default: text = '';
                        }
                        return SideTitleWidget(meta: meta, child: Text(text, style: style));
                      },
                    ),
                  ),
                ),
                barGroups: [
                  _makeBarData(0, 8),
                  _makeBarData(1, 10),
                  _makeBarData(2, 4),
                  _makeBarData(3, 6),
                  _makeBarData(4, 3),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _makeBarData(int x, double y) {
    return BarChartGroupData(x: x, barRods: [
      BarChartRodData(toY: y, color: Colors.black, width: 12, borderRadius: BorderRadius.circular(4))
    ]);
  }
}

// --- 3. LINE CHART : PROGRESSION MENSUELLE ---
class MonthlyProgressChart extends StatelessWidget {
  const MonthlyProgressChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Monthly Activity", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 20),
          SizedBox(
            height: 150,
            child: LineChart(
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
                        const style = TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold);
                        switch(value.toInt()) {
                          case 0: return const Text('Jan', style: style);
                          case 2: return const Text('Mar', style: style);
                          case 4: return const Text('May', style: style);
                          case 6: return const Text('Jul', style: style);
                          default: return const Text('');
                        }
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 1), FlSpot(1, 3), FlSpot(2, 2), FlSpot(3, 5),
                      FlSpot(4, 4), FlSpot(5, 7), FlSpot(6, 6),
                    ],
                    isCurved: true,
                    color: Colors.black,
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.black.withOpacity(0.05),
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
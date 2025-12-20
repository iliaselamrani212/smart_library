import 'package:flutter/material.dart';
// Assurez-vous que le chemin correspond à votre projet
import '../widgets/calender.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 1. CALENDRIER (Votre widget personnalisé)
            const CalendarWidget(),

            const SizedBox(height: 20),

            // 2. DASHBOARD CONTENT
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // --- A. CARTE BLEUE CORRIGÉE ---
                  _buildBlueProgressCard(),

                  const SizedBox(height: 30),

                  // --- B. ONGOING TASKS HEADER ---
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     const Text(
                  //       "Ongoing Tasks",
                  //       style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  //     ),
                  //     TextButton(
                  //       onPressed: () {},
                  //       child: Text(
                  //         "View All",
                  //         style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                  //       ),
                  //     ),
                  //   ],
                  // ),

                  const SizedBox(height: 10),

                  // // --- LISTE HORIZONTALE DES TÂCHES ---
                  // SizedBox(
                  //   height: 150, // Hauteur définie pour le scroll horizontal
                  //   child: ListView(
                  //     scrollDirection: Axis.horizontal,
                  //     clipBehavior: Clip.none, // Permet aux ombres de ne pas être coupées
                  //     children: [
                  //       _buildTaskCard(
                  //         title: "Mobile UI Kit",
                  //         subtitle: "Odama Studio",
                  //         progress: 0.76,
                  //         timeLeft: "3 Days left",
                  //       ),
                  //       const SizedBox(width: 16),
                  //       _buildTaskCard(
                  //         title: "Illustration",
                  //         subtitle: "Paperpillar",
                  //         progress: 0.45,
                  //         timeLeft: "5 Days left",
                  //       ),
                  //       const SizedBox(width: 16),
                  //       _buildTaskCard(
                  //         title: "Website Design",
                  //         subtitle: "Freelance",
                  //         progress: 0.20,
                  //         timeLeft: "9 Days left",
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  //
                  // const SizedBox(height: 30),

                  // --- C. CATEGORY HEADER ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Category",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          "View All",
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // --- CARTES CATÉGORIES ---
                  Row(
                    children: [
                      Expanded(
                          child: _buildCategoryCard(
                              "Total Books",
                              "2 Books",
                              Colors.orangeAccent,
                              Icons.collections_bookmark_sharp
                          )
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                          child: _buildCategoryCard(
                              "Finished",
                              "19 Books",
                              Colors.blueAccent,
                              Icons.done_outline_sharp
                          )
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                          child: _buildCategoryCard(
                              "Reading",
                              "2 Books",
                              Colors.orangeAccent,
                              Icons.menu_book_outlined
                          )
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                          child: _buildCategoryCard(
                              "To read",
                              "19 Books",
                              Colors.blueAccent,
                              Icons.book
                          )
                      ),
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

  // ===========================================================================
  // WIDGETS MÉTHODES
  // ===========================================================================

  Widget _buildBlueProgressCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2E77F6),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E77F6).withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Partie Gauche (Texte + Bouton)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Important : Aligne à gauche
              children: [
                const Text(
                  "Great, your progress\nis almost done!!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF2E77F6),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: const Text(
                      "View Task",
                      style: TextStyle(fontWeight: FontWeight.bold)
                  ),
                )
              ],
            ),
          ),

          // Espace physique entre le texte et le cercle
          const SizedBox(width: 20),

          // Partie Droite (Cercle)
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: 0.80,
                  strokeWidth: 8,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const Text(
                "80%",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTaskCard({
    required String title,
    required String subtitle,
    required double progress,
    required String timeLeft,
  }) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Header carte
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                ],
              ),
              const Icon(Icons.more_horiz, color: Colors.grey),
            ],
          ),

          // Barre de progression
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Progress", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                  Text("${(progress * 100).toInt()}%", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                ],
              ),
              const SizedBox(height: 6),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                borderRadius: BorderRadius.circular(10),
                minHeight: 6,
              ),
            ],
          ),

          // Footer (Temps + Avatars)
          Row(
            children: [
              Icon(Icons.access_time, size: 14, color: Colors.grey.shade400),
              const SizedBox(width: 4),
              Text(timeLeft, style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
              const Spacer(),
              // Fake Avatar Stack (Cercles colorés)
              SizedBox(
                width: 50,
                height: 24,
                child: Stack(
                  children: [
                    const Positioned(left: 0, child: CircleAvatar(radius: 12, backgroundColor: Colors.redAccent, child: Text("A", style: TextStyle(fontSize: 10, color: Colors.white)))),
                    const Positioned(left: 15, child: CircleAvatar(radius: 12, backgroundColor: Colors.green, child: Text("B", style: TextStyle(fontSize: 10, color: Colors.white)))),
                    const Positioned(left: 30, child: CircleAvatar(radius: 12, backgroundColor: Colors.blue, child: Text("C", style: TextStyle(fontSize: 10, color: Colors.white)))),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String title, String tasks, Color iconColor, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const Icon(Icons.more_horiz, color: Colors.grey, size: 18),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            tasks,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
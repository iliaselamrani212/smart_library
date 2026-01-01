import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_library/providers/history_provider.dart';
import 'package:smart_library/providers/user_provider.dart';
import 'package:smart_library/theme/app_themes.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHistory();
    });
  }

  Future<void> _loadHistory() async {
    final userId = Provider.of<UserProvider>(context, listen: false).currentUser?.usrId;
    if (userId != null) {
      await Provider.of<HistoryProvider>(context, listen: false).fetchHistory(userId);
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "Unknown Date";
    try {
      DateTime dt = DateTime.parse(dateStr);
      return DateFormat('MMM dd, yyyy').format(dt);
    } catch (e) {
      return "Invalid date";
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final historyProvider = Provider.of<HistoryProvider>(context);

    return Scaffold(
      backgroundColor: isDark ? AppThemes.darkBg : Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: isDark ? Colors.white : Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Reading History",
          style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: isDark ? AppThemes.darkBg : Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: historyProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : RefreshIndicator(
              color: Colors.blue,
              onRefresh: _loadHistory, 
              child: historyProvider.history.isEmpty
                  ? _buildEmptyState(isDark)
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      physics: const AlwaysScrollableScrollPhysics(), 
                      itemCount: historyProvider.history.length,
                      itemBuilder: (context, index) {
                        final item = historyProvider.history[historyProvider.history.length - 1 - index];
                        bool isLast = index == historyProvider.history.length - 1;
                        return _buildHistoryItem(item, isLast, isDark);
                      },
                    ),
            ),
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> item, bool isLast, bool isDark) {
    String status = item['status'] ?? 'Not Read';
    bool isFinished = status == 'Finished';
    
    String dateLabel = _formatDate(item['startDate']);
    String? finishedDate = item['endDate'];

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: isFinished ? Colors.green : (status == 'Reading' ? (isDark ? AppThemes.accentColor : Colors.black) : Colors.blue),
                  shape: BoxShape.circle,
                  border: Border.all(color: isDark ? AppThemes.darkBg : Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateLabel,
                    style: TextStyle(
                      color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? AppThemes.darkCardBg : const Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? AppThemes.borderColor : Colors.grey.shade100),
                    ),
                    child: Row(
                      children: [
                        _buildBookCover(item['thumbnail']),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['title'] ?? 'Unknown Title',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: isDark ? Colors.white : const Color(0xFF1F2937),
                                ),
                              ),
                              const SizedBox(height: 6),
                              _buildStatusBadge(status, isDark),
                              
                              if (isFinished) ...[
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.check_circle_outline, size: 12, color: Colors.green),
                                    const SizedBox(width: 4),
                                    Text(
                                      finishedDate != null 
                                          ? "Finished: ${_formatDate(finishedDate)}" 
                                          : "Completed",
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.green,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ]
                            ],
                          ),
                        ),
                      ],
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

  Widget _buildBookCover(String? path) {
    return Container(
      width: 45,
      height: 65,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: (path != null && path.isNotEmpty && path.startsWith('http'))
            ? Image.network(path, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade300, child: const Icon(Icons.book, color: Colors.white)))
            : (path != null && path.isNotEmpty)
                ? Image.file(File(path), fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade300, child: const Icon(Icons.book, color: Colors.white)))
                : Container(color: Colors.grey.shade300, child: const Icon(Icons.book, color: Colors.white)),
      ),
    );
  }

  Widget _buildStatusBadge(String status, bool isDark) {
    Color color;
    if (status == 'Finished') {
      color = Colors.green;
    } else if (status == 'Reading') {
      color = isDark ? AppThemes.accentColor : Colors.black; 
    } else {
      color = isDark ? Colors.grey.shade500 : Colors.grey;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return ListView( 
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.auto_stories_outlined, size: 80, color: isDark ? Colors.grey.shade600 : Colors.grey.shade300),
              const SizedBox(height: 20),
              Text(
                "No reading history yet",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.grey.shade300 : Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                "Tap on a book in your library to start.",
                style: TextStyle(color: isDark ? Colors.grey.shade500 : Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
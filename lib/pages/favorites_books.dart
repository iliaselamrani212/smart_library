import 'dart:io';
import 'package:smart_library/models/books_model.dart';
import 'package:smart_library/providers/favorites_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FavoritesBooksWidget extends StatelessWidget {
  const FavoritesBooksWidget({super.key});

  ImageProvider _buildImage(String thumbnail) {
    if (thumbnail.isEmpty) return const AssetImage('assets/images/empty.jpg');
    if (thumbnail.startsWith('http')) return NetworkImage(thumbnail);
    return FileImage(File(thumbnail));
  }

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoriteBooksProvider>(context);
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF2B2B2B) : Colors.blue[50];

    if (favoritesProvider.isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.blue));
    }

    final books = favoritesProvider.favoriteBooks;

    if (books.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 40),
          child: Text('No favorite books added yet.', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return Card(
          elevation: 0,
          color: cardColor,
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            onTap: () {
              showDialog(
                context: context,
                barrierColor: Colors.black.withOpacity(0.6),
                builder: (context) => ShowFavorites(book: book),
              );
            },
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image(
                image: _buildImage(book.thumbnail),
                width: 45,
                height: 65,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(width: 45, color: Colors.grey[300]),
              ),
            ),
            title: Text(
              book.title,
              maxLines: 1,
              style: const TextStyle(fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis),
            ),
            subtitle: Text(
              book.authors.join(', '),
              maxLines: 1,
              style: const TextStyle(overflow: TextOverflow.ellipsis),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () => _showDeleteDialog(context, book),
            ),
          ),
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, Book book) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Favorite'),
        content: Text.rich(
          TextSpan(
            text: 'Are you sure you want to remove ',
            children: [
              TextSpan(
                text: book.title,
                style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: ' from your favorites?'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Provider.of<FavoriteBooksProvider>(context, listen: false).removeFavorite(book.id);
              Navigator.pop(context);
              _showSnackBar(context, book.title);
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(BuildContext context, String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        content: Text('$title removed from favorites.'),
      ),
    );
  }
}

class ShowFavorites extends StatelessWidget {
  final Book book;
  const ShowFavorites({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image(
                image: FavoritesBooksWidget()._buildImage(book.thumbnail),
                width: 140,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              book.title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "Author: ${book.authors.join(', ')}",
              style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700]),
            ),
            const SizedBox(height: 5),
            Chip(
              label: Text(book.category, style: const TextStyle(fontSize: 12)),
              backgroundColor: Colors.blue.withOpacity(0.1),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close", style: TextStyle(color: Colors.red, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
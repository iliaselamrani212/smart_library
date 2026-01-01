import 'package:smart_library/models/books_model.dart';
import 'package:smart_library/providers/favorites_provider.dart';
import 'package:smart_library/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Search extends StatelessWidget{
  final String query;
  const Search({
    super.key,
    required this.query,
  });

  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);
    final cardColor = Theme.of(context).brightness == Brightness.dark
        ? Color(0xFF2B2B2B)
        : Colors.blue[50];

    return Scaffold(
      backgroundColor: currentTheme.brightness == Brightness.dark ? Colors.black : Colors.white,
      appBar: AppBar(title: const Text('Search Results')),
      body: FutureBuilder<List<Book>>(
        future: ApiService().fetchBooks(query),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final books = snapshot.data ?? [];
          if (books.isEmpty) {
            return const Center(child: Text('No results found.'));
          }
          return ListView.builder(
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return Card(
                color: cardColor,
                margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
                child: ListTile(
                  onTap: (){
                    showDialog(
                      context: context,
                      barrierColor: Colors.black.withOpacity(0.5),
                      builder: (context) => ShowSearch(book: book),
                    );
                  },
                  leading: book.thumbnail.isNotEmpty
                      ? Image.network(book.thumbnail, width: 50, fit: BoxFit.cover)
                      : Container(width: 50, color: Colors.grey),
                  title: Text(book.title,maxLines: 1,style: TextStyle(overflow: TextOverflow.ellipsis),),
                  subtitle: Text(book.authors.join(', '),maxLines: 1,style: TextStyle(overflow: TextOverflow.ellipsis),),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ShowSearch extends StatelessWidget {
  final Book book;
  const ShowSearch({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);
    return Dialog(
      backgroundColor: currentTheme.brightness == Brightness.dark ? Colors.black : Colors.white,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: currentTheme.brightness == Brightness.dark ? Colors.grey[850] : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: book.thumbnail.isNotEmpty
                  ? Image.network(book.thumbnail, width: 150, height: 200, fit: BoxFit.cover)
                  : Container(width: 150, height: 200, color: Colors.grey),
            ),
            SizedBox(height: 16),
            Text(
              book.title,
              style: currentTheme.textTheme.titleSmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              "Author(s): ${book.authors.join(', ')}",
              style: currentTheme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                    onPressed: () async {
                      await Provider.of<FavoriteBooksProvider>(context, listen: false).addFavorite(book);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                            margin: EdgeInsets.only(bottom: 16.0, left: 16.0, right: 16.0),
                            duration: Duration(seconds: 1),
                            content: Text('Book saved to favorites!',style: TextStyle(color: Colors.white),)),
                      );
                      Navigator.of(context).pop();
                    }, child: Text('Add to Favorites',style: TextStyle(color: Colors.green,fontSize: 15))),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Close", style: TextStyle(color: Colors.red,fontSize: 15)),
                ),
              ],
            ),
          ],
        ),
      ),
    );

  }
}
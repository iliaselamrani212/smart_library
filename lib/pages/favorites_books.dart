import 'package:smart_library/models/books_model.dart';
import 'package:smart_library/providers/favorites_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FavoritesBooksWidget extends StatelessWidget {
  const FavoritesBooksWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoriteBooksProvider>(context);
    final cardColor = Theme.of(context).brightness == Brightness.dark
        ? Color(0xFF2B2B2B) // Dark theme
        : Colors.blue[50]; // Light theme




    if (favoritesProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final books = favoritesProvider.favorites;
    if (books.isEmpty) {
      return const Center(child: Text('No favorite books added yet.'));
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return Card(
          color: cardColor,
          margin: const EdgeInsets.symmetric(vertical: 5),
          child: ListTile(
            onTap: (){
              showDialog(
                context: context,
                barrierColor: Colors.black.withOpacity(0.5), // background opacity
                builder: (context) => ShowFavorites(book: book),
              );
            },
            leading: book.thumbnail.isNotEmpty
                ? Image.network(book.thumbnail, width: 50, fit: BoxFit.cover)
                : Container(width: 50, color: Colors.grey),
            title: Text(book.title,maxLines: 1,style: TextStyle(overflow: TextOverflow.ellipsis),),
            subtitle: Text(book.authors.join(', '),maxLines: 1, style: TextStyle(overflow: TextOverflow.ellipsis),),
            trailing: IconButton(
              icon: Icon(Icons.delete_outlined,),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Delete Favorite Book'),
                      content: Text.rich(
                        TextSpan(
                          text: 'Are you sure you want to delete ',
                          children: [
                            TextSpan(
                              text: book.title,
                              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold), // Change the color here
                            ),
                            TextSpan(
                              text: ' from your favorites?',
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Cancel',style: TextStyle(color: Colors.green),),
                        ),
                        TextButton(
                          onPressed: () {
                            Provider.of<FavoriteBooksProvider>(context, listen: false).removeFavorite(book.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating, // Make it float
                                margin: EdgeInsets.only(bottom: 16.0, left: 16.0, right: 16.0),
                                content: Text.rich(
                                  TextSpan(
                                   children: [
                                     TextSpan(
                                       text: book.title,
                                       style: TextStyle(color: Colors.white,),
                                     ),
                                     TextSpan(
                                       text: ' removed from favorites.',style: TextStyle(color: Colors.white),
                                     ),
                                   ]
                                  ),

                                ),
                              ),
                            );
                            Navigator.of(context).pop();
                          },
                          child: Text('Delete',style: TextStyle(color: Colors.red),),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}


// show favorite book detail
class ShowFavorites extends StatelessWidget {
  final Book book;
  const ShowFavorites({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);
    return Dialog(
      backgroundColor: currentTheme.brightness == Brightness.dark ? Colors.black : Colors.white,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: currentTheme.brightness == Brightness.dark ? Colors.grey[850] : Colors.white, // Main dialog box color
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
              style: currentTheme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              "Author(s): ${book.authors.join(', ')}",
              style: currentTheme.textTheme.bodySmall,
              textAlign: TextAlign.justify,
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Close", style: TextStyle(color: Colors.red,fontSize: 18)),
                ),
              ],
            ),
          ],
        ),
      ),
    );

  }
}
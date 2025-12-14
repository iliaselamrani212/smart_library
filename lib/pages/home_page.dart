import 'package:smart_library/auth/database_helper.dart';
import 'package:smart_library/models/user_model.dart';
import 'package:smart_library/pages/favorites_books.dart';
import 'package:smart_library/pages/search_result.dart';
import 'package:smart_library/pages/trending_books.dart';
import 'package:smart_library/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget{
  final String? usrName;
  const HomePage({super.key, required this.usrName});

  @override
  State<StatefulWidget> createState() => _HomePageState();

}

class _HomePageState  extends State<HomePage>{
final TextEditingController _searchController = TextEditingController();


late Future<String?> _fullNameFuture;

@override
void initState() {
  super.initState();

  // Fetch the user's full name using the provided username
  _fullNameFuture = _fetchFullName(widget.usrName);
}

Future<String?> _fetchFullName(String? usrName) async {
  if (usrName == null) {
    return 'Guest'; // Default value if usrName is null
  }

  final DatabaseHelper dbHelper = DatabaseHelper();
  final Users? user = await dbHelper.getUser(usrName);
  return user?.fullName;
}

void _performSearch(BuildContext context) {
  if (_searchController.text.trim().isNotEmpty) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Search(query: _searchController.text.trim()),
      ),
    );
  }
}



  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);
    final textFillColor = Theme.of(context).brightness == Brightness.dark
        ? Color(0xFF2B2B2B) // Dark theme fill color of text field
        : Colors.blue.shade50; // Light theme fill color of text field
    final textIconColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade400 // Dark theme icon color of text field
        : Colors.grey.shade800; // Light theme icon color of text field
    final textFieldStyle = TextStyle(
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.white // Dark theme text color of text field
          : Colors.black, // Light theme text color of text field
    );

   return PopScope(
     canPop: false,
     child: Scaffold(
       backgroundColor: currentTheme.brightness == Brightness.dark ? Colors.black : Colors.white,
       appBar: AppBar(
         automaticallyImplyLeading: false,
         title: Text('SmartLibrary',style: GoogleFonts.reggaeOne(),),
         actions: [
           PopupMenuButton<String>(
             color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[850] : Colors.white,
             onSelected: (value) {
               if (value == 'item1') {
                 Provider.of<ThemeManager>(context, listen: false).toggleTheme();
               } else if (value == 'item2') {
                 Navigator.pop(context,);
               }
             },
             itemBuilder: (BuildContext context) {
               return [
                 PopupMenuItem<String>(
                   value: 'item1',
                   child: Row(
                     children: [
                       Icon(Icons.brightness_6,color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,),
                       SizedBox(width: 10,),
                       Text('Change Theme',style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),),
                     ],
                   ),
                 ),
                 PopupMenuItem<String>(
                   value: 'item2',
                   child: Row(
                     children: [
                       Icon(Icons.logout,color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,),
                       SizedBox(width: 10,),
                       Text('Sign out',style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),),
                     ],
                   ),
                 ),
               ];
             },
             offset:  Offset(0, kToolbarHeight),   // This places the dropdown slightly below the app bar.
           )
         ],
       ),
       body: Padding(
         padding: const EdgeInsets.all(16.0),
         child: SingleChildScrollView(
           physics: const AlwaysScrollableScrollPhysics(),
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Center(
                 child:FutureBuilder<String?>(
                   future: _fullNameFuture,
                   builder: (context, snapshot) {
                     if (snapshot.connectionState == ConnectionState.waiting) {
                       return Center(child: CircularProgressIndicator());
                     } else if (snapshot.hasError) {
                       return Text('Error loading user details');
                     } else {
                       final fullName =
                           snapshot.data ?? 'Guest'; // Default to 'Guest' if null
                       return ShaderMask(
                         shaderCallback: (Rect bounds) {
                           return LinearGradient(
                             colors: currentTheme.brightness == Brightness.dark
                                 ? [Colors.blue, Colors.purple]
                                 : [Colors.orange, Colors.pink],
                             begin: Alignment.topLeft,
                             end: Alignment.bottomRight,
                           ).createShader(bounds);
                         },
                         blendMode: BlendMode.srcIn,
                         child: Text(
                           'Hi👋, $fullName',
                           style: GoogleFonts.reggaeOne(
                             fontSize: 24,
                             fontWeight: FontWeight.bold,
                             color: Colors.white, // Placeholder color for gradient
                           ),
                         ),
                       );
                     }
                   },
                 ),
               ),
               SizedBox(height: 10),
               TextField(
                 onTapOutside: (value) => FocusScope.of(context).unfocus(),
                 autofocus: false,
                 controller: _searchController,
                 decoration: InputDecoration(
                   hintText: 'Search a book by (title or author name)',
                   hintStyle: TextStyle(
                     color: Theme.of(context).brightness == Brightness.dark
                         ? Colors.grey
                         : Colors.blueGrey,
                     fontSize: 16,
                     fontWeight: FontWeight.w400,
                   ),
                   fillColor: textFillColor,
                   filled: true,
                   suffixIcon: IconButton(
                     onPressed: () {
                       _performSearch(context);
                       FocusScope.of(context).unfocus();
                     },
                     icon: Icon(Icons.search, color: textIconColor),
                   ),
                   contentPadding: EdgeInsets.all(16),
                   border: OutlineInputBorder(
                     borderRadius: BorderRadius.circular(16),
                     borderSide: BorderSide.none,
                   ),
                 ),
                 style: textFieldStyle,
                 onSubmitted: (_) => _performSearch(context),
               ),
               SizedBox(height: 10),
               Text('Favorites Books', style: currentTheme.textTheme.headlineMedium),
               SizedBox(height: 10),
               FavoritesBooksWidget(),
               SizedBox(height: 10),
               Text('Trending Books', style: currentTheme.textTheme.headlineMedium),
               SizedBox(height: 10),
               TrendingBooksWidget(),
             ],
           ),
         ),
       )

     ),
   );
  }
}





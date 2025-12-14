import 'package:smart_library/auth/database_helper.dart';
import 'package:smart_library/auth/validators.dart';
import 'package:smart_library/models/user_model.dart';
import 'package:smart_library/pages/home_page.dart';
import 'package:smart_library/providers/favorites_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<StatefulWidget> createState() => _LoginState();

}

class _LoginState extends State<Login> {

  bool isLoginTrue = false;
  bool isPasswordVisible = false;
  final formKey = GlobalKey<FormState>();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final db = DatabaseHelper();

  login() async {
    var res = await db.authenticate(Users(
      usrName: userNameController.text,
      password: passwordController.text,
    ));

    if (res == true) {
      // Get user data to retrieve usrId
      Users? user = await DatabaseHelper().getUser(userNameController.text);

      if (user != null) {
        // Set user ID in favorites provider
        Provider.of<FavoriteBooksProvider>(context, listen: false)
            .setCurrentUserId(user.usrId!);

        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage(usrName: user.usrName,)),
        );
      }
    } else {
      // Error handling
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
          duration: Duration(seconds: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          content: Text(
            'Invalid username or password',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
      setState(() {
        isLoginTrue = true;
      });
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



    return Scaffold(
      backgroundColor: currentTheme.brightness == Brightness.dark ? Colors.black : Colors.white,
      appBar: null,
      body: Center(
        child: Padding(padding: EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
            child:SingleChildScrollView(
              child: Column(
                children: [
                  FlutterLogo(size: 120),
                  Text("Welcome Back!",style: currentTheme.textTheme.titleLarge,),
                  const SizedBox(height: 20,),
                  TextFormField(
                    controller: userNameController,
                    validator: Validators.validateUserName,
                    decoration: InputDecoration(
                        hintText: 'Username',
                        prefixIcon: Icon(Icons.person,
                        color: textIconColor,
                        ),
                        filled: true,
                        fillColor: textFillColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide.none
                        ),
                    ),
                    style: textFieldStyle,
                  ),
                  const SizedBox(height: 10,),
                  TextFormField(
                    controller: passwordController,
                    validator: Validators.validatePassword,
                    obscureText: !isPasswordVisible,
                    obscuringCharacter: '*',
                    decoration: InputDecoration(
                      filled: true,
                        fillColor: textFillColor,
                        prefixIcon: Icon(Icons.password,
                        color: textIconColor,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(isPasswordVisible ? Icons.visibility:Icons.visibility_off,
                          color: textIconColor,
                          ),
                          onPressed: ()
                          {
                            setState((){
                              isPasswordVisible  =  !isPasswordVisible;
                            });
              
                          },),
                        hintText: 'Password',
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide.none
                        )
                    ),
                    style: textFieldStyle,
                  ),
                  const SizedBox(height: 20,),
                  ElevatedButton(
                    onPressed: ()  {
                        login();
                        FocusScope.of(context).unfocus();
                    },
                    child: Text('Login',
                      style: TextStyle(
                          color: currentTheme.brightness == Brightness.dark ?Colors.white :Colors.white,
                      ),
                    ),
              
                  ),
                  TextButton(
                    onPressed: () async {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SignUp()),);
                    },
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Don't have an Account? ",
                            style: currentTheme.textTheme.bodyMedium
                          ),
                          TextSpan(
                            text: "SignUp",
                            style: currentTheme.textTheme.bodyMedium?.copyWith(
                              color: currentTheme.primaryColor,
                              fontWeight: FontWeight.bold, // added bold weight
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ) ),
        ),
      )
    );
  }
}


class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<StatefulWidget> createState() => _SignUpState();

}

class _SignUpState extends State<SignUp>{
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  final formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();


  final db = DatabaseHelper();
  signUp()async{
    var res = await db.createUser(
        Users(
            fullName: nameController.text,
            usrName: userNameController.text,
            password: passwordController.text)
    );
    if(res>0){
      if(!mounted)return;
      Navigator.push(context, MaterialPageRoute(builder: (context)=> const Login()));
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




    return Scaffold(
      backgroundColor: currentTheme.brightness == Brightness.dark ? Colors.black : Colors.white,
      appBar: null,
      body: Center(
        child: Padding(padding: EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
            child:SingleChildScrollView(
              child: Column(
                children: [
                  FlutterLogo(size: 120),
                  Text('Create your Account',style: currentTheme.textTheme.titleLarge,),
                  const SizedBox(height: 20,),
                  TextFormField(
                    controller: nameController,
                    validator: Validators.validateName,
                    decoration: InputDecoration(
                        hintText: 'Full Name',
                        prefixIcon: Icon(Icons.person,
                        color: textIconColor,
                        ),
                        filled: true,
                        fillColor: textFillColor,
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide.none
                        )
                    ),
                    style: textFieldStyle,
                  ),
                  const SizedBox(height: 10,),
                  TextFormField(
                    controller: userNameController,
                    validator: Validators.validateName,
                    decoration: InputDecoration(
                        hintText: 'Username',
                        prefixIcon: Icon(Icons.person,
                        color: textIconColor,
                        ),
                        filled: true,
                        fillColor: textFillColor,
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide.none
                        )
                    ),
                    style: textFieldStyle,
                  ),
                  const SizedBox(height: 10,),
                  TextFormField(
                    controller: passwordController,
                    validator: Validators.validatePassword,
                    obscureText: !isPasswordVisible,
                    obscuringCharacter: '*',
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.password,
                        color: textIconColor,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(isPasswordVisible ? Icons.visibility:Icons.visibility_off,
                          color: textIconColor,
                          ),
                          onPressed: ()
                          {
                            setState((){
                              isPasswordVisible  =  !isPasswordVisible;
                            });
              
                          },),
                        hintText: 'Password',
                        filled: true,
                        fillColor: textFillColor,
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide.none
                        )
                    ),
                    style: textFieldStyle,
                  ),
                  const SizedBox(height: 10,),
                  TextFormField(
                    controller: confirmPasswordController,
                    validator: (value) => Validators.validateConfirmPassword(value, passwordController.text),
                    obscureText: !isConfirmPasswordVisible,
                    obscuringCharacter: '*',
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.password,
                        color: textIconColor,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(isConfirmPasswordVisible ? Icons.visibility:Icons.visibility_off,
                          color: textIconColor,
                          ),
                          onPressed: ()
                          {
                            setState((){
                              isConfirmPasswordVisible  =  !isConfirmPasswordVisible;
                            });
              
                          },),
                        hintText: 'Confirm Password',
                        filled: true,
                        fillColor: textFillColor,
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide.none
                        )
                    ),
                    style: textFieldStyle,
                  ),
                  const SizedBox(height: 20,),
                  ElevatedButton(
                    onPressed: ()  {
                      if(formKey.currentState!.validate()){
                        signUp();
                      }
                    },
                    child: Text('Sign Up',
                      style: TextStyle(
                          color: currentTheme.brightness == Brightness.dark ?Colors.white :Colors.white,
              
                      ),
                    ),
              
                  ),
                  TextButton(
                    onPressed: () async {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Login()),);
                    },
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                              text: "Already have an Account? ",
                              style: currentTheme.textTheme.bodyMedium
                          ),
                          TextSpan(
                            text: "Login",
                            style: currentTheme.textTheme.bodyMedium?.copyWith(
                              color: currentTheme.primaryColor,
                              fontWeight: FontWeight.bold, // added bold weight
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ) ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_library/auth/validators.dart';
import 'package:smart_library/models/user_model.dart';
import 'package:smart_library/pages/layout.dart';
import 'package:smart_library/providers/user_provider.dart';

import '../theme/theme.dart';
import '../widgets/input_field.dart';
import '../widgets/primary_button.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 1. Define the GlobalKey for validation
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool passwordVisible = false;

  void togglePassword() {
    setState(() {
      passwordVisible = !passwordVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Allow scrolling when the keyboard appears
      resizeToAvoidBottomInset: true, 
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24.0, 80.0, 24.0, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Login to your\naccount',
                    style: heading2.copyWith(color: textBlack),
                  ),
                  SizedBox(height: 20),
                  Image.asset(
                    'assets/images/accent.png',
                    width: 99,
                    height: 4,
                  ),
                ],
              ),
              SizedBox(height: 48),

              // 2. Wrap input fields in a Form widget
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    InputField(
                      hintText: 'Username', // Changed to Username as per your UserProvider
                      controller: emailController,
                      validator: Validators.validateUserName, // Applied validator
                    ),
                    SizedBox(height: 32),
                    InputField(
                      hintText: 'Password',
                      controller: passwordController,
                      obscureText: !passwordVisible,
                      validator: Validators.validatePassword, // Applied validator
                      suffixIcon: IconButton(
                        color: textGrey,
                        icon: Icon(passwordVisible
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined),
                        onPressed: togglePassword,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 64),

              CustomPrimaryButton(
                buttonColor: primaryBlue,
                textValue: 'Login',
                textColor: Colors.white,
                onPressed: () async {
                  // 3. Trigger Form Validation
                  if (_formKey.currentState!.validate()) {
                    
                    // 4. Call Login from Provider
                    final userProvider = Provider.of<UserProvider>(context, listen: false);
                    bool success = await userProvider.login(
                      emailController.text, 
                      passwordController.text
                    );

                    if (success) {
                      // Login success: Navigate to Layout
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => Layout()),
                        (route) => false,
                      );
                    } else {
                      // Login fail: Show error
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Invalid Username or Password"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
              ),

              SizedBox(height: 24),
              Center(
                child: Text(
                  'OR',
                  style: heading6.copyWith(color: textGrey),
                ),
              ),
              SizedBox(height: 24),

              CustomPrimaryButton(
                buttonColor: Color(0xfffbfbfb),
                textValue: 'Login with Google',
                textColor: textBlack,
                onPressed: () {
                  // Logic for Google login would go here
                },
              ),
              SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: regular16pt.copyWith(color: textGrey),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegisterScreen()),
                      );
                    },
                    child: Text(
                      'Register',
                      style: regular16pt.copyWith(color: primaryBlue),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}




class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // 1. Key to manage form validation
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool passwordVisible = false;

  void togglePassword() {
    setState(() {
      passwordVisible = !passwordVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24.0, 40.0, 24.0, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Register new\naccount',
                    style: heading2.copyWith(color: textBlack),
                  ),
                  const SizedBox(height: 20),
                  Image.asset(
                    'assets/images/accent.png',
                    width: 99,
                    height: 4,
                  ),
                ],
              ),
              const SizedBox(height: 48),
              
              // 2. Form wrapper for validation
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    InputField(
                      hintText: 'Name',
                      controller: nameController,
                      validator: Validators.validateName,
                    ),
                    const SizedBox(height: 32),
                    InputField(
                      hintText: 'Email',
                      controller: emailController,
                      validator: Validators.validateEmail,
                    ),
                    const SizedBox(height: 32),
                    InputField(
                      hintText: 'Password',
                      controller: passwordController,
                      obscureText: !passwordVisible,
                      validator: Validators.validatePassword,
                      suffixIcon: IconButton(
                        color: textGrey,
                        icon: Icon(passwordVisible ? Icons.visibility : Icons.visibility_off),
                        onPressed: togglePassword,
                      ),
                    ),
                    const SizedBox(height: 32),
                    InputField(
                      hintText: 'Confirm Password',
                      controller: confirmPasswordController,
                      obscureText: !passwordVisible,
                      // Pass both current value and original password to compare
                      validator: (value) => Validators.validateConfirmPassword(value, passwordController.text),
                      suffixIcon: IconButton(
                        color: textGrey,
                        icon: Icon(passwordVisible ? Icons.visibility : Icons.visibility_off),
                        onPressed: togglePassword,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('By creating an account, you agree to our', style: regular16pt.copyWith(color: textGrey)),
                  Text('Terms & Conditions', style: regular16pt.copyWith(color: primaryBlue)),
                ],
              ),
              const SizedBox(height: 32),

              // 3. Register Button with Logic
              CustomPrimaryButton(
                buttonColor: primaryBlue,
                textValue: 'Register',
                textColor: Colors.white,
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // Create user object matching your updated model
                    final newUser = Users(
                      fullName: nameController.text,
                      email: emailController.text,
                      password: passwordController.text,
                    );
                  
                    // Call Provider to save to DB
                    final userProvider = Provider.of<UserProvider>(context, listen: false);
                    bool success = await userProvider.register(newUser);
                  
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Account created! Please login."), 
                          backgroundColor: Colors.green
                        ),
                      );
                  
                      // --- CHANGE THIS LINE FOR EXPLICIT NAVIGATION ---
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                        (route) => false, // This clears the navigation stack
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Failed. Email already exists."), 
                          backgroundColor: Colors.red
                        ),
                      );
                    }
                  }
                  },
              ),
              const SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account? ", style: regular16pt.copyWith(color: textGrey)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text('Login', style: regular16pt.copyWith(color: primaryBlue)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
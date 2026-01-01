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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      resizeToAvoidBottomInset: true, 
      backgroundColor: isDarkMode ? const Color(0xFF0F0F0F) : Colors.white,
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
                    style: heading2.copyWith(color: isDarkMode ? Colors.white : textBlack),
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

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    InputField(
                      hintText: 'Email', 
                      controller: emailController,
                      validator: Validators.validateUserName, 
                    ),
                    SizedBox(height: 32),
                    InputField(
                      hintText: 'Password',
                      controller: passwordController,
                      obscureText: !passwordVisible,
                      validator: Validators.validatePassword, 
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
                  if (_formKey.currentState!.validate()) {
                    
                    final userProvider = Provider.of<UserProvider>(context, listen: false);
                    bool success = await userProvider.login(
                      emailController.text, 
                      passwordController.text
                    );

                    if (success) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => Layout()),
                        (route) => false,
                      );
                    } else {
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: isDarkMode ? const Color(0xFF0F0F0F) : Colors.white,
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
                    style: heading2.copyWith(color: isDarkMode ? Colors.white : textBlack),
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

              CustomPrimaryButton(
                buttonColor: primaryBlue,
                textValue: 'Register',
                textColor: Colors.white,
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final newUser = Users(
                      fullName: nameController.text,
                      email: emailController.text,
                      password: passwordController.text,
                    );

                    final userProvider = Provider.of<UserProvider>(context, listen: false);
                    bool success = await userProvider.register(newUser);

                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Account created! Please login."), 
                          backgroundColor: Colors.green
                        ),
                      );

                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                        (route) => false, 
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
                    onTap: () => Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                        (route) => false, 
                      ),
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
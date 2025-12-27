import 'package:flutter/material.dart';


class InputField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final Widget? suffixIcon;
  final bool obscureText;
  // 1. ADD THIS LINE: Define the validator type
  final String? Function(String?)? validator; 

  const InputField({
    Key? key,
    required this.hintText,
    required this.controller,
    this.suffixIcon,
    this.obscureText = false,
    this.validator, // 2. ADD THIS LINE: Receive it in constructor
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 3. CHANGE THIS: Use TextFormField instead of TextField
    return TextFormField( 
      controller: controller,
      obscureText: obscureText,
      validator: validator, // 4. ADD THIS LINE: Pass it to the core widget
      decoration: InputDecoration(
        hintText: hintText,
        suffixIcon: suffixIcon,
        // Add your existing theme/styling here
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:smart_library/auth/database_helper.dart';
import 'package:smart_library/models/user_model.dart';
import 'package:smart_library/providers/user_provider.dart';
import 'package:smart_library/theme/app_themes.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super();

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;

  dynamic _selectedImage;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false).currentUser;
    _nameController = TextEditingController(text: user?.fullName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    
    if (user?.profilePicture != null && user!.profilePicture!.isNotEmpty) {
      final file = File(user.profilePicture!);
      if (file.existsSync()) {
        _selectedImage = file;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a photo'),
              onTap: () async {
                Navigator.pop(ctx);
                final res = await picker.pickImage(source: ImageSource.camera, imageQuality: 50);
                if (res != null) setState(() => _selectedImage = File(res.path));
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () async {
                Navigator.pop(ctx);
                final res = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
                if (res != null) setState(() => _selectedImage = File(res.path));
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final currentUser = userProvider.currentUser;

      if (currentUser == null) {
        _showSnackBar('User not found', Colors.red);
        return;
      }

      String newPassword = currentUser.password;
      if (_passwordController.text.isNotEmpty) {
        if (_passwordController.text != _confirmPasswordController.text) {
          _showSnackBar('Passwords do not match', Colors.red);
          return;
        }
        newPassword = _passwordController.text;
      }

      String? profilePicturePath = currentUser.profilePicture;
      if (_selectedImage is File && _selectedImage.path != currentUser.profilePicture) {
        try {
          final appDir = await getApplicationDocumentsDirectory();
          final profileDir = Directory('${appDir.path}/profile_pictures');
          if (!profileDir.existsSync()) {
            profileDir.createSync(recursive: true);
          }
          
          final fileName = 'profile_${currentUser.usrId}.png';
          final savedImage = await _selectedImage.copy('${profileDir.path}/$fileName');
          profilePicturePath = savedImage.path;
        } catch (e) {
          _showSnackBar('Error saving profile picture: ${e.toString()}', Colors.orange);
        }
      }

      final updatedUser = Users(
        usrId: currentUser.usrId,
        fullName: _nameController.text,
        email: _emailController.text,
        password: newPassword,
        profilePicture: profilePicturePath,
      );

      await _dbHelper.updateUser(updatedUser);

      userProvider.setUser(updatedUser);

      _showSnackBar('Profile updated successfully!', Colors.green);
      Navigator.pop(context, true);
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppThemes.darkBg : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? AppThemes.darkBg : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Profile',
          style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppThemes.borderColor, width: 3),
                        image: DecorationImage(
                          image: _selectedImage is File
                              ? FileImage(_selectedImage as File)
                              : const AssetImage('assets/images/userlogo.png') as ImageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark ? AppThemes.accentColor : Colors.blue,
                      ),
                      child: Icon(Icons.camera_alt, color: isDark ? Colors.black : Colors.white, size: 20),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Tap to change photo',
                style: TextStyle(color: isDark ? Colors.grey : Colors.grey.shade600, fontSize: 12),
              ),
              const SizedBox(height: 40),

              _buildTextField(
                controller: _nameController,
                label: 'Full Name',
                icon: Icons.person,
                isDark: isDark,
                validator: (value) => value?.isEmpty ?? true ? 'Name is required' : null,
              ),
              const SizedBox(height: 20),

              _buildTextField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email,
                isDark: isDark,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Email is required';
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),

              Text(
                'Change Password (Optional)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : Colors.black),
              ),
              const SizedBox(height: 15),

              _buildPasswordField(
                controller: _passwordController,
                label: 'New Password',
                icon: Icons.lock,
                isDark: isDark,
                isVisible: _passwordVisible,
                onToggle: () => setState(() => _passwordVisible = !_passwordVisible),
              ),
              const SizedBox(height: 20),

              _buildPasswordField(
                controller: _confirmPasswordController,
                label: 'Confirm Password',
                icon: Icons.lock_outline,
                isDark: isDark,
                isVisible: _confirmPasswordVisible,
                onToggle: () => setState(() => _confirmPasswordVisible = !_confirmPasswordVisible),
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? AppThemes.accentColor : Colors.blue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isLoading ? null : _saveChanges,
                  child: _isLoading
                      ? const SizedBox(width: 25, height: 25, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(
                          'Save Changes',
                          style: TextStyle(
                            color: isDark ? Colors.black : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isDark ? Colors.grey : Colors.grey.shade600),
        prefixIcon: Icon(icon, color: isDark ? AppThemes.accentColor : Colors.blue),
        filled: true,
        fillColor: isDark ? AppThemes.darkSecondaryBg : const Color(0xFFF5F7FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    required bool isVisible,
    required VoidCallback onToggle,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !isVisible,
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isDark ? Colors.grey : Colors.grey.shade600),
        prefixIcon: Icon(icon, color: isDark ? AppThemes.accentColor : Colors.blue),
        suffixIcon: IconButton(
          icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off, color: isDark ? AppThemes.accentColor : Colors.blue),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: isDark ? AppThemes.darkSecondaryBg : const Color(0xFFF5F7FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

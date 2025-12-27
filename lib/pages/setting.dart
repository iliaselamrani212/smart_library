import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_library/auth/auth.dart';
import 'package:smart_library/providers/user_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // État pour les switchs
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20), // Un peu plus d'espace (20 au lieu de 16)
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ---------- PROFIL SECTION ----------
          _buildProfileSection(),

          const SizedBox(height: 30),

          // ---------- GENERAL SETTINGS ----------
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'General',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),

          _buildSettingItem(
            icon: Icons.person_outline,
            title: 'Edit Profile',
            onTap: () {},
          ),
          _buildSettingItem(
            icon: Icons.language,
            title: 'Language',
            trailing: const Text('English', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
            onTap: () {},
          ),

          const SizedBox(height: 24),

          // ---------- PREFERENCES ----------
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'Preferences',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),

          _buildSettingSwitch(
            icon: Icons.dark_mode_outlined,
            title: 'Dark Mode',
            value: _isDarkMode,
            onChanged: (val) {
              setState(() {
                _isDarkMode = val;
              });
            },
          ),
          _buildSettingSwitch(
            icon: Icons.notifications_none,
            title: 'Notifications',
            value: _notificationsEnabled,
            onChanged: (val) {
              setState(() {
                _notificationsEnabled = val;
              });
            },
          ),

          const SizedBox(height: 30),

          // ---------- LOGOUT BUTTON ----------
          // ---------- LOGOUT BUTTON ----------
SizedBox(
  width: double.infinity,
  height: 55,
  child: ElevatedButton(
    onPressed: () {
      // 1. Access the Provider and clear the user
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.logout();

      // 2. Show a small confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Logged out successfully")),
      );

      // 3. Navigate to Login and clear the navigation history
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (route) => false,
      );
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFFFF0F0),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
    ),
    child: const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.logout, color: Colors.red, size: 20),
        SizedBox(width: 8),
        Text(
          'Log Out',
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    ),
  ),
),

          const SizedBox(height: 80), // Espace pour la BottomBar
        ],
      ),
    );
  }

  // --- WIDGET : SECTION PROFIL ---
  Widget _buildProfileSection() {
    return Row(
      children: [
        // Avatar avec une bordure légère
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade200, width: 2),
            image: const DecorationImage(
              // Assurez-vous d'avoir cette image ou mettez une NetworkImage
              image: AssetImage('assets/images/femme.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Lisa Jewell', // Exemple de nom
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'lisa.jewell@email.com',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const Spacer(),
        // Bouton Edit rond et noir
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.05), // Gris très léger
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.edit_outlined, color: Colors.black),
          ),
        ),
      ],
    );
  }

  // --- WIDGET : ITEM CLASSIQUE ---
  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA), // LE GRIS DE VOTRE THEME
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Colors.white, // Fond blanc pour l'icône pour faire ressortir
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.black, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      ),
    );
  }

  // --- WIDGET : ITEM AVEC SWITCH ---
  Widget _buildSettingSwitch({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA), // LE GRIS DE VOTRE THEME
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.black, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.black, // Switch Noir quand activé
          activeTrackColor: Colors.black.withOpacity(0.3),
          inactiveThumbColor: Colors.grey,
          inactiveTrackColor: Colors.grey.shade300,
        ),
      ),
    );
  }
}
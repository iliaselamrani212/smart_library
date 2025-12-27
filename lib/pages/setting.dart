import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_library/auth/auth.dart';
import 'package:smart_library/pages/history.dart';
import 'package:smart_library/providers/user_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    // Access the current user data
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------- PROFIL SECTION (Real Data) ----------
          _buildProfileSection(user?.fullName ?? 'Guest', user?.email ?? 'No email'),

          const SizedBox(height: 30),

          // ---------- GENERAL SETTINGS ----------
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'General',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
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
          
          // ---------- HISTORY BUTTON HERE ----------
          _buildSettingItem(
            icon: Icons.history_rounded,
            title: 'Reading History',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryScreen()),
              );
            },
          ),

          const SizedBox(height: 24),

          // ---------- PREFERENCES ----------
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'Preferences',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ),

          _buildSettingSwitch(
            icon: Icons.dark_mode_outlined,
            title: 'Dark Mode',
            value: _isDarkMode,
            onChanged: (val) {
              setState(() => _isDarkMode = val);
            },
          ),
          _buildSettingSwitch(
            icon: Icons.notifications_none,
            title: 'Notifications',
            value: _notificationsEnabled,
            onChanged: (val) {
              setState(() => _notificationsEnabled = val);
            },
          ),

          const SizedBox(height: 30),

          // ---------- LOGOUT BUTTON ----------
          _buildLogoutButton(context),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // --- WIDGET : SECTION PROFIL (Updated with dynamic data) ---
  Widget _buildProfileSection(String name, String email) {
    return Row(
      children: [
        Container(
          width: 70, height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade200, width: 2),
            image: const DecorationImage(
              image: AssetImage('assets/images/femme.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 4),
            Text(
              email,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ],
        ),
        const Spacer(),
        Container(
          decoration: BoxDecoration(color: Colors.black.withOpacity(0.05), shape: BoxShape.circle),
          child: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.edit_outlined, color: Colors.black),
          ),
        ),
      ],
    );
  }

  // --- LOGOUT BUTTON COMPONENT ---
  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () {
          Provider.of<UserProvider>(context, listen: false).logout();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Logged out successfully")),
          );
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
            (route) => false,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFF0F0),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: Colors.red, size: 20),
            SizedBox(width: 8),
            Text('Log Out', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  // (Keep your _buildSettingItem and _buildSettingSwitch methods exactly as they were)
  Widget _buildSettingItem({required IconData icon, required String title, Widget? trailing, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: const Color(0xFFF5F7FA), borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: Icon(icon, color: Colors.black, size: 22),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      ),
    );
  }

  Widget _buildSettingSwitch({required IconData icon, required String title, required bool value, required ValueChanged<bool> onChanged}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: const Color(0xFFF5F7FA), borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: Icon(icon, color: Colors.black, size: 22),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.black,
          activeTrackColor: Colors.black.withOpacity(0.3),
        ),
      ),
    );
  }
}
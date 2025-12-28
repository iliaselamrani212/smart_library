import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_library/auth/auth.dart';
import 'package:smart_library/pages/history.dart';
import 'package:smart_library/providers/user_provider.dart';
import 'package:smart_library/providers/theme_provider.dart';
import 'package:smart_library/theme/app_themes.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    // Access the current user data
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;
    
    // Access the theme provider
    final themeProvider = Provider.of<ThemeProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------- PROFIL SECTION (Real Data) ----------
          _buildProfileSection(user?.fullName ?? 'Guest', user?.email ?? 'No email'),

          const SizedBox(height: 30),

          // ---------- GENERAL SETTINGS ----------
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Builder(
              builder: (context) {
                final isDark = Theme.of(context).brightness == Brightness.dark;
                return Text(
                  'General',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
                );
              },
            ),
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
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Builder(
              builder: (context) {
                final isDark = Theme.of(context).brightness == Brightness.dark;
                return Text(
                  'Preferences',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
                );
              },
            ),
          ),

          _buildSettingSwitch(
            icon: Icons.dark_mode_outlined,
            title: 'Dark Mode',
            value: themeProvider.isDarkMode,
            onChanged: (val) {
              themeProvider.setDarkMode(val);
            },
          ),
          _buildSettingSwitch(
            icon: Icons.notifications_none,
            title: 'Notifications',
            value: true,
            onChanged: (val) {
              // Notifications handling
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
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Row(
          children: [
            Container(
              width: 70, height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppThemes.borderColor, width: 2),
                image: const DecorationImage(
                  image: AssetImage('assets/images/userlogo.png'),
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
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: TextStyle(
                    color: isDark ? AppThemes.textSecondary : Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const Spacer(),

          ],
        );
      },
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
          backgroundColor: Colors.redAccent,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Log Out', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  // (Keep your _buildSettingItem and _buildSettingSwitch methods exactly as they were)
  Widget _buildSettingItem({required IconData icon, required String title, Widget? trailing, required VoidCallback onTap}) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isDark ? AppThemes.darkSecondaryBg : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: isDark ? AppThemes.borderColor : Colors.grey.shade300, width: 0.5),
          ),
          child: ListTile(
            onTap: onTap,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? AppThemes.darkCardBg : Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppThemes.accentColor, size: 22),
            ),
            title: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            trailing: trailing ?? Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isDark ? AppThemes.textTertiary : Colors.grey.shade600,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettingSwitch({required IconData icon, required String title, required bool value, required ValueChanged<bool> onChanged}) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isDark ? AppThemes.darkSecondaryBg : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: isDark ? AppThemes.borderColor : Colors.grey.shade300, width: 0.5),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? AppThemes.darkCardBg : Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppThemes.accentColor, size: 22),
            ),
            title: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            trailing: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: AppThemes.accentColor,
              activeTrackColor: AppThemes.accentColor.withOpacity(0.4),
            ),
          ),
        );
      },
    );
  }
}
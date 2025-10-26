import 'package:flutter/material.dart';
import 'package:word_create/screens/levels/level_screen.dart';
import '../../core/constants/app_colors.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('كلمة مخفية'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildButton(
                context,
                title: 'ابدأ اللعب',
                onTap: () 
                => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LevelsScreen()),
                ),
              ),
              const SizedBox(height: 20),
              _buildButton(
                context,
                title: 'الإعدادات',
                onTap: () 
                => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context,
      {required String title, required VoidCallback onTap}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: onTap,
      child: Text(title,
          style: const TextStyle(fontSize: 20, color: Colors.white)),
    );
  }
}

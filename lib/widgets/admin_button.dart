import 'package:flutter/material.dart';

class AdminButton extends StatelessWidget {
  const AdminButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Align(
        alignment: Alignment.bottomRight,
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.of(context).pushNamed('/admin-login');
          },
          label: const Text(
            'Admin',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          icon: const Icon(
            Icons.admin_panel_settings,
            color: Colors.white,
          ),
          backgroundColor: const Color(0xFF8FA68E),
          elevation: 4,
        ),
      ),
    );
  }
}
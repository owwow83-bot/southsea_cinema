import 'package:flutter/material.dart';
import 'package:southsea_cinema/models/user_settings.dart';
import 'package:southsea_cinema/widgets/nav_drawer.dart';
import 'package:southsea_cinema/widgets/primary_button.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final TextEditingController _nameController =
      TextEditingController();
  final TextEditingController _addressController =
      TextEditingController();
  final TextEditingController _emailController =
      TextEditingController();

  bool _receiveNewsletter = false;
  String _confirmationMessage = '';

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    final settings = UserSettings(
      name: _nameController.text.trim(),
      address: _addressController.text.trim(),
      email: _emailController.text.trim(),
      receiveNewsletter: _receiveNewsletter,
    );

    setState(() {
      _confirmationMessage =
          'Settings saved for ${settings.name}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Settings'),
      ),
      drawer: const NavDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Customer Profile',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Full name',
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _addressController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Address',
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Email address',
              ),
            ),
            const SizedBox(height: 16),

            SwitchListTile(
              title: const Text('Receive newsletter and offers'),
              value: _receiveNewsletter,
              onChanged: (bool value) {
                setState(() {
                  _receiveNewsletter = value;
                });
              },
            ),
            const SizedBox(height: 20),

            PrimaryButton(
              label: 'Save Settings',
              onPressed: _saveSettings,
            ),

            if (_confirmationMessage.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                _confirmationMessage,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:southsea_cinema/models/user_settings.dart';
import 'package:southsea_cinema/widgets/nav_drawer.dart';
import 'package:southsea_cinema/widgets/primary_button.dart';

const String prefName = 'user_name';
const String prefAddress = 'user_address';
const String prefEmail = 'user_email';
const String prefNewsletter = 'user_newsletter';

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
  bool _loading = true;

  String _confirmationMessage = '';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final SharedPreferencesAsync prefs =
          SharedPreferencesAsync();

      final String? savedName =
          await prefs.getString(prefName);

      final String? savedAddress =
          await prefs.getString(prefAddress);

      final String? savedEmail =
          await prefs.getString(prefEmail);

      final bool? savedNewsletter =
          await prefs.getBool(prefNewsletter);

      if (!mounted) {
        return;
      }

      setState(() {
        _nameController.text = savedName ?? '';
        _addressController.text = savedAddress ?? '';
        _emailController.text = savedEmail ?? '';
        _receiveNewsletter = savedNewsletter ?? false;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
        _confirmationMessage =
            'Could not load settings: $error';
      });
    }
  }

  Future<void> _saveSettings() async {
    final String name = _nameController.text.trim();
    final String address = _addressController.text.trim();
    final String email = _emailController.text.trim();
    final bool newsletter = _receiveNewsletter;

    final UserSettings settings = UserSettings(
      name: name,
      address: address,
      email: email,
      receiveNewsletter: newsletter,
    );

    try {
      final SharedPreferencesAsync prefs =
          SharedPreferencesAsync();

      await prefs.setString(prefName, settings.name);

      await prefs.setString(
        prefAddress,
        settings.address,
      );

      await prefs.setString(prefEmail, settings.email);

      await prefs.setBool(
        prefNewsletter,
        settings.receiveNewsletter,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _confirmationMessage =
            'Settings saved for ${settings.name}';
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _confirmationMessage =
            'Could not save settings: $error';
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Settings'),
      ),
      drawer: const NavDrawer(),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
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
                    title: const Text(
                      'Receive newsletter and offers',
                    ),
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_state.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    AppState.watchAll(ref);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.green,
      ),

      body: ListView(
        children: [

          ListTile(
            leading: const Icon(
              Icons.language,
              color: Colors.green,
            ),
            title: const Text("Language"),
            subtitle: Text(AppState.selectedLanguage),

            trailing: DropdownButton<String>(
              value: AppState.selectedLanguage,

              items: const [
                DropdownMenuItem(
                  value: "English",
                  child: Text("English"),
                ),
                DropdownMenuItem(
                  value: "Malayalam",
                  child: Text("Malayalam"),
                ),
                DropdownMenuItem(
                  value: "Hindi",
                  child: Text("Hindi"),
                ),
                DropdownMenuItem(
                  value: "Tamil",
                  child: Text("Tamil"),
                ),
              ],

              onChanged: (value) {
                setState(() {
                  ref.read(languageProvider.notifier).setLanguage(value!);
                });
              },
            ),
          ),

          const Divider(),

          const ListTile(
            leading: Icon(
              Icons.notifications,
              color: Colors.green,
            ),
            title: Text("Notifications"),
            subtitle: Text(
              "Manage notification settings",
            ),
          ),

          Divider(),

          const ListTile(
            leading: Icon(
              Icons.lock,
              color: Colors.green,
            ),
            title: Text("Privacy & Security"),
            subtitle: Text(
              "Manage privacy settings",
            ),
          ),

          Divider(),

          const ListTile(
            leading: Icon(
              Icons.help_outline,
              color: Colors.green,
            ),
            title: Text("Help & Support"),
            subtitle: Text("Contact support"),
          ),

          Divider(),

          const ListTile(
            leading: Icon(
              Icons.info_outline,
              color: Colors.green,
            ),
            title: Text("About AGRI KEY"),
            subtitle: Text("Version 1.0"),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_config.dart';
import '../core/app_state.dart';
import '../services/update_service.dart';

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

          const Divider(),

          ListTile(
            leading: const Icon(
              Icons.system_update_rounded,
              color: Colors.green,
            ),
            title: const Text("App Update"),
            subtitle: const Text("Current Version: ${ApiConfig.appVersion}"),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: const Text(
                "Check",
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            onTap: () => UpdateService.checkForUpdate(context, manual: true),
          ),

          const Divider(),

          const ListTile(
            leading: Icon(
              Icons.info_outline,
              color: Colors.green,
            ),
            title: Text("About AGRI KEY"),
            subtitle: Text("Autonomous Agricultural Intelligence Companion"),
          ),
        ],
      ),
    );
  }
}
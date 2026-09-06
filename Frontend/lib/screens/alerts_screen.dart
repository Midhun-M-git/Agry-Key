import 'package:flutter/material.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Farmer Alerts"),
        backgroundColor: Colors.green,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [

          Card(
            child: ListTile(
              leading: Icon(Icons.warning,color: Colors.orange),
              title: Text("Heavy rainfall expected tomorrow"),
              subtitle: Text("Take precautions for harvested crops."),
            ),
          ),

          Card(
            child: ListTile(
              leading: Icon(Icons.campaign,color: Colors.green),
              title: Text("Government subsidy available"),
              subtitle: Text("Apply before 30 September."),
            ),
          ),

          Card(
            child: ListTile(
              leading: Icon(Icons.bug_report,color: Colors.red),
              title: Text("Pest outbreak reported nearby"),
              subtitle: Text("Monitor crop conditions carefully."),
            ),
          ),
        ],
      ),
    );
  }
}
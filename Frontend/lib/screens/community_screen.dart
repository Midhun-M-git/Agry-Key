import 'package:flutter/material.dart';
import '../core/app_state.dart';
import 'create_post_screen.dart';
import 'post_details_screen.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  String getText(
    String english,
    String malayalam,
    String hindi,
    String tamil,
  ) {
    switch (AppState.selectedLanguage) {
      case "Malayalam":
        return malayalam;
      case "Hindi":
        return hindi;
      case "Tamil":
        return tamil;
      default:
        return english;
    }
  }

  void openPost(
    BuildContext context,
    String user,
    String question,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PostDetailsScreen(
          userName: user,
          question: question,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          getText(
            "Farmer Community",
            "കർഷക സമൂഹം",
            "किसान समुदाय",
            "விவசாயிகள் சமூகம்",
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            Card(
              child: ListTile(
                onTap: () {
                  openPost(
                    context,
                    "Ravi Kumar",
                    "Rice crop showing yellow leaves. Any solution?",
                  );
                },
                leading: const CircleAvatar(
                  child: Icon(Icons.person),
                ),
                title: const Text("Ravi Kumar"),
                subtitle: const Text(
                  "Rice crop showing yellow leaves. Any solution?",
                ),
                trailing: const Icon(Icons.chat),
              ),
            ),

            Card(
              child: ListTile(
                onTap: () {
                  openPost(
                    context,
                    "Anil Farmer",
                    "Tomato prices increased today.",
                  );
                },
                leading: const CircleAvatar(
                  child: Icon(Icons.person),
                ),
                title: const Text("Anil Farmer"),
                subtitle: const Text(
                  "Tomato prices increased today.",
                ),
                trailing: const Icon(Icons.chat),
              ),
            ),

            Card(
              child: ListTile(
                onTap: () {
                  openPost(
                    context,
                    "Suresh",
                    "Best fertilizer for banana farming?",
                  );
                },
                leading: const CircleAvatar(
                  child: Icon(Icons.person),
                ),
                title: const Text("Suresh"),
                subtitle: const Text(
                  "Best fertilizer for banana farming?",
                ),
                trailing: const Icon(Icons.chat),
              ),
            ),

          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreatePostScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
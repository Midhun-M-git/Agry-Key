import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_state.dart';
import '../services/community_service.dart';
import '../services/token_service.dart';
import '../utils/localization.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserDistrict();
  }

  Future<void> _loadUserDistrict() async {
    final session = await TokenService.loadSession();
    if (session.district.isNotEmpty && mounted) {
      _districtController.text = session.district;
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    _districtController.dispose();
    super.dispose();
  }

  Future<void> _submitPost() async {
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            L10n.get(
              "Please enter your question or observation.",
              "ദയവായി നിങ്ങളുടെ ചോദ്യം നൽകുക.",
              "कृपया अपना प्रश्न या अनुभव दर्ज करें।",
              "உங்கள் கேள்வியை உள்ளிடவும்.",
            ),
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final post = await CommunityService.createPost(
      content: content,
      district: _districtController.text.trim().isNotEmpty ? _districtController.text.trim() : null,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (post != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              L10n.get(
                "Post shared with farmers successfully!",
                "പോസ്റ്റ് വിജയകരമായി പങ്കിട്ടു!",
                "पोस्ट सफलतापूर्वक साझा की गई!",
                "பதிவு வெற்றிகரமாக பகிரப்பட்டது!",
              ),
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              L10n.get(
                "Failed to post. Please verify login.",
                "പോസ്റ്റ് ചെയ്യാൻ കഴിഞ്ഞില്ല. ലോഗിൻ പരിശോധിക്കുക.",
                "पोस्ट करने में विफल। कृपया लॉगिन जांचें।",
                "பதிவு செய்ய முடியவில்லை. உள்நுழைவை சரிபார்க்கவும்.",
              ),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    AppState.watchAll(ref);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          L10n.get("Ask Community", "ചോദ്യം ചോദിക്കുക", "समुदाय से पूछें", "சமூகத்திடம் கேளுங்கள்"),
        ),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              L10n.get(
                "Ask a question or share farm updates with fellow farmers across India.",
                "ഇന്ത്യയിലുടനീളമുള്ള കർഷകരുമായി കൃഷി സംശയങ്ങൾ പങ്കുവെക്കൂ.",
                "पूरे भारत के किसानों के साथ प्रश्न पूछें या कृषि अनुभव साझा करें।",
                "இந்தியா முழுவதும் உள்ள விவசாயிகளுடன் உங்கள் சந்தேகங்களை பகிருங்கள்.",
              ),
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _districtController,
              decoration: InputDecoration(
                labelText: L10n.get("Your District / Area (Optional)", "ജില്ല / പ്രദേശം", "जिला / क्षेत्र", "மாவட்டம் / பகுதி"),
                prefixIcon: const Icon(Icons.location_on, color: Colors.green),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: L10n.get(
                  "Describe your crop disease, pest issue, weather update, or farming tip...",
                  "വിള രോഗം, കീടബാധ, അല്ലെങ്കിൽ കൃഷി അനുഭവങ്ങൾ വിശദീകരിക്കൂ...",
                  "फसल रोग, कीट समस्या, या सुझाव के बारे में विस्तार से बताएं...",
                  "பயிர் நோய், பூச்சி தாக்குதல் பற்றி விவரிக்கவும்...",
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _submitPost,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.send),
              label: Text(
                _isLoading
                    ? L10n.get("Posting...", "പോസ്റ്റ് ചെയ്യുന്നു...", "पोस्ट हो रहा है...", "பதிவாகிறது...")
                    : L10n.get("Share Post", "പോസ്റ്റ് പങ്കിടുക", "पोस्ट साझा करें", "பதிவு செய்"),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
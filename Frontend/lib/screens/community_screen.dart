import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_state.dart';
import '../services/community_service.dart';
import '../utils/localization.dart';
import 'create_post_screen.dart';
import 'post_details_screen.dart';

class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> {
  List<CommunityPost> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() => _isLoading = true);
    final posts = await CommunityService.getPosts();
    if (mounted) {
      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    }
  }

  void _openPost(CommunityPost post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PostDetailsScreen(
          initialPost: post,
          postId: post.id,
          userName: post.authorName,
          question: post.content,
        ),
      ),
    ).then((_) {
      // Reload on return to catch up on new replies
      _loadPosts();
    });
  }

  Future<void> _toggleLike(CommunityPost post) async {
    final originalState = post.likedByCurrentUser;
    final originalCount = post.likeCount;

    setState(() {
      post.likedByCurrentUser = !post.likedByCurrentUser;
      post.likeCount += post.likedByCurrentUser ? 1 : -1;
    });

    final success = await CommunityService.likePost(post.id);
    if (!success && mounted) {
      setState(() {
        post.likedByCurrentUser = originalState;
        post.likeCount = originalCount;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    AppState.watchAll(ref);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          L10n.get(
            "Farmer Community",
            "കർഷക സമൂഹം",
            "किसान समुदाय",
            "விவசாயிகள் சமூகம்",
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPosts,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadPosts,
              child: _posts.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.forum_outlined, size: 64, color: Colors.grey.shade400),
                              const SizedBox(height: 16),
                              Text(
                                L10n.get(
                                  "No community posts yet.",
                                  "പോസ്റ്റുകൾ ലഭ്യമല്ല.",
                                  "अभी तक कोई पोस्ट नहीं है।",
                                  "பதிவுகள் எதுவும் இல்லை.",
                                ),
                                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                L10n.get(
                                  "Be the first to ask a question!",
                                  "ആദ്യത്തെ സംശയം ചോദിക്കൂ!",
                                  "पहले प्रश्न पूछें!",
                                  "முதலில் கேள்வி கேளுங்கள்!",
                                ),
                                style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      itemCount: _posts.length,
                      itemBuilder: (context, index) {
                        final post = _posts[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => _openPost(post),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header: Author & District
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Colors.green.shade100,
                                        child: Text(
                                          post.authorName.isNotEmpty
                                              ? post.authorName[0].toUpperCase()
                                              : 'F',
                                          style: const TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              post.authorName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                            ),
                                            if (post.district != null && post.district!.isNotEmpty)
                                              Text(
                                                post.district!,
                                                style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                  fontSize: 12,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),

                                  // Post Content
                                  Text(
                                    post.content,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      height: 1.35,
                                    ),
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 12),

                                  // Action Bar: Likes & Replies
                                  Row(
                                    children: [
                                      InkWell(
                                        borderRadius: BorderRadius.circular(20),
                                        onTap: () => _toggleLike(post),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                post.likedByCurrentUser
                                                    ? Icons.favorite
                                                    : Icons.favorite_border,
                                                size: 20,
                                                color: post.likedByCurrentUser
                                                    ? Colors.red
                                                    : Colors.grey.shade600,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                "${post.likeCount}",
                                                style: TextStyle(
                                                  color: post.likedByCurrentUser
                                                      ? Colors.red
                                                      : Colors.grey.shade700,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.chat_bubble_outline,
                                            size: 18,
                                            color: Colors.grey.shade600,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            "${post.commentCount} ${L10n.get("Replies", "മറുപടികൾ", "जवाब", "பதில்கள்")}",
                                            style: TextStyle(
                                              color: Colors.grey.shade700,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      Text(
                                        L10n.get("Read more", "കൂടുതൽ വായിക്കുക", "और पढ़ें", "மேலும் படிக்க"),
                                        style: const TextStyle(
                                          color: Colors.green,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.green,
        onPressed: () async {
          final created = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => const CreatePostScreen(),
            ),
          );
          if (created == true) {
            _loadPosts();
          }
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          L10n.get("Ask / Post", "ചോദിക്കുക", "पूछें / पोस्ट", "கேட்கவும்"),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
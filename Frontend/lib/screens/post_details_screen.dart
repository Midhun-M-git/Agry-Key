import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_state.dart';
import '../services/community_service.dart';
import '../utils/localization.dart';

class PostDetailsScreen extends ConsumerStatefulWidget {
  final CommunityPost? initialPost;
  final int? postId;
  final String? userName;
  final String? question;

  const PostDetailsScreen({
    super.key,
    this.initialPost,
    this.postId,
    this.userName,
    this.question,
  });

  @override
  ConsumerState<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends ConsumerState<PostDetailsScreen> {
  CommunityPost? _post;
  bool _isLoading = true;
  bool _isSendingComment = false;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _post = widget.initialPost;
    _loadPostDetails();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  int get _effectivePostId {
    if (_post != null && _post!.id > 0) return _post!.id;
    if (widget.postId != null && widget.postId! > 0) return widget.postId!;
    return 0;
  }

  Future<void> _loadPostDetails() async {
    final pid = _effectivePostId;
    if (pid <= 0) {
      setState(() => _isLoading = false);
      return;
    }

    final fetched = await CommunityService.getPost(pid);
    if (mounted) {
      setState(() {
        if (fetched != null) {
          _post = fetched;
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleLike() async {
    if (_post == null || _post!.id <= 0) return;
    final originalState = _post!.likedByCurrentUser;
    final originalCount = _post!.likeCount;

    setState(() {
      _post!.likedByCurrentUser = !_post!.likedByCurrentUser;
      _post!.likeCount += _post!.likedByCurrentUser ? 1 : -1;
    });

    final success = await CommunityService.likePost(_post!.id);
    if (!success && mounted) {
      setState(() {
        _post!.likedByCurrentUser = originalState;
        _post!.likeCount = originalCount;
      });
    }
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty || _effectivePostId <= 0 || _isSendingComment) return;

    setState(() => _isSendingComment = true);

    final newComment = await CommunityService.addComment(
      postId: _effectivePostId,
      content: text,
    );

    if (mounted) {
      setState(() {
        _isSendingComment = false;
        if (newComment != null) {
          _commentController.clear();
          if (_post != null) {
            _post = CommunityPost(
              id: _post!.id,
              authorId: _post!.authorId,
              authorName: _post!.authorName,
              content: _post!.content,
              district: _post!.district,
              imageUrl: _post!.imageUrl,
              likeCount: _post!.likeCount,
              commentCount: _post!.commentCount + 1,
              likedByCurrentUser: _post!.likedByCurrentUser,
              createdAt: _post!.createdAt,
              comments: [..._post!.comments, newComment],
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                L10n.get(
                  "Failed to post reply. Please login first.",
                  "മറുപടി പോസ്റ്റ് ചെയ്യാൻ കഴിഞ്ഞില്ല. ദയവായി ലോഗിൻ ചെയ്യുക.",
                  "जवाब पोस्ट करने में विफल। कृपया पहले लॉगिन करें।",
                  "பதில் பதிவு செய்ய முடியவில்லை. முதலில் உள்நுழைக.",
                ),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    AppState.watchAll(ref);

    final displayAuthor = _post?.authorName ?? widget.userName ?? "Farmer";
    final displayContent = _post?.content ?? widget.question ?? "";
    final displayDistrict = _post?.district;
    final comments = _post?.comments ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          L10n.get(
            "Community Discussion",
            "കർഷക ചർച്ച",
            "किसान चर्चा",
            "விவசாயிகள் கலந்துரையாடல்",
          ),
        ),
        backgroundColor: Colors.green,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Post author header
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.green.shade100,
                              child: Text(
                                displayAuthor.isNotEmpty ? displayAuthor[0].toUpperCase() : "F",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    displayAuthor,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (displayDistrict != null && displayDistrict.isNotEmpty)
                                    Text(
                                      displayDistrict,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Post content Card
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              displayContent,
                              style: const TextStyle(fontSize: 16, height: 1.4),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Engagement Action Bar
                        Row(
                          children: [
                            TextButton.icon(
                              onPressed: _post != null ? _toggleLike : null,
                              icon: Icon(
                                _post?.likedByCurrentUser == true
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: _post?.likedByCurrentUser == true ? Colors.red : Colors.grey,
                              ),
                              label: Text(
                                "${_post?.likeCount ?? 0} Likes",
                                style: TextStyle(
                                  color: _post?.likedByCurrentUser == true ? Colors.red : Colors.grey.shade700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            TextButton.icon(
                              onPressed: null,
                              icon: const Icon(Icons.chat_bubble_outline, color: Colors.grey),
                              label: Text(
                                "${comments.length} Replies",
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),

                        // Replies section
                        Text(
                          L10n.get(
                            "Replies (${comments.length})",
                            "മറുപടികൾ (${comments.length})",
                            "जवाब (${comments.length})",
                            "பதில்கள் (${comments.length})",
                          ),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),

                        if (comments.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: Text(
                                L10n.get(
                                  "No replies yet. Be the first to advise!",
                                  "മറുപടികൾ ഒന്നുമില്ല. ആദ്യം ഉപദേശം നൽകൂ!",
                                  "अभी तक कोई जवाब नहीं। पहले सलाह दें!",
                                  "இன்னும் பதில்கள் இல்லை. முதலில் கருத்து தெரிவிக்கவும்!",
                                ),
                                style: TextStyle(color: Colors.grey.shade500),
                              ),
                            ),
                          )
                        else
                          ...comments.map(
                            (c) => Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.green.shade50,
                                  child: Text(
                                    c.authorName.isNotEmpty ? c.authorName[0].toUpperCase() : 'M',
                                    style: const TextStyle(color: Colors.green),
                                  ),
                                ),
                                title: Text(
                                  c.authorName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    c.content,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Reply Input Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            decoration: InputDecoration(
                              hintText: L10n.get(
                                "Write your advice or answer...",
                                "നിങ്ങളുടെ ഉപദേശം നൽകൂ...",
                                "अपनी सलाह या उत्तर लिखें...",
                                "உங்கள் ஆலோசனையை எழுதவும்...",
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _isSendingComment
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : IconButton(
                                icon: const Icon(Icons.send, color: Colors.green),
                                onPressed: _submitComment,
                              ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/api_config.dart';
import 'token_service.dart';

class CommunityComment {
  final int id;
  final int postId;
  final int authorId;
  final String authorName;
  final String content;
  final DateTime? createdAt;

  CommunityComment({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.authorName,
    required this.content,
    this.createdAt,
  });

  factory CommunityComment.fromJson(Map<String, dynamic> json) {
    return CommunityComment(
      id: json['id'] as int? ?? 0,
      postId: json['post_id'] as int? ?? 0,
      authorId: json['author_id'] as int? ?? 0,
      authorName: json['author_name'] as String? ?? 'Kisan Mitra',
      content: json['content'] as String? ?? '',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }
}

class CommunityPost {
  final int id;
  final int authorId;
  final String authorName;
  final String content;
  final String? district;
  final String? imageUrl;
  int likeCount;
  int commentCount;
  bool likedByCurrentUser;
  final DateTime? createdAt;
  final List<CommunityComment> comments;

  CommunityPost({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.content,
    this.district,
    this.imageUrl,
    required this.likeCount,
    required this.commentCount,
    required this.likedByCurrentUser,
    this.createdAt,
    this.comments = const [],
  });

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    final rawComments = json['comments'] as List<dynamic>? ?? [];
    return CommunityPost(
      id: json['id'] as int? ?? 0,
      authorId: json['author_id'] as int? ?? 0,
      authorName: json['author_name'] as String? ?? 'Farmer Friend',
      content: json['content'] as String? ?? '',
      district: json['district'] as String?,
      imageUrl: json['image_url'] as String?,
      likeCount: json['like_count'] as int? ?? 0,
      commentCount: json['comment_count'] as int? ?? 0,
      likedByCurrentUser: json['liked_by_current_user'] as bool? ?? false,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      comments: rawComments.map((c) => CommunityComment.fromJson(c as Map<String, dynamic>)).toList(),
    );
  }
}

class CommunityService {
  static Future<Map<String, String>> _headers({bool needsAuth = false}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final token = await TokenService.getAccessToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<List<CommunityPost>> getPosts({int page = 1, String? district}) async {
    try {
      final headers = await _headers();
      var uriString = '${ApiConfig.baseUrl}/community/posts?page=$page&page_size=30';
      if (district != null && district.trim().isNotEmpty) {
        uriString += '&district=${Uri.encodeComponent(district.trim())}';
      }
      final response = await http
          .get(Uri.parse(uriString), headers: headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final items = (decoded['items'] as List<dynamic>?) ?? [];
        return items.map((item) => CommunityPost.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return [];
  }

  static Future<CommunityPost?> getPost(int postId) async {
    try {
      final headers = await _headers();
      final response = await http
          .get(Uri.parse('${ApiConfig.baseUrl}/community/posts/$postId'), headers: headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return CommunityPost.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      }
    } catch (_) {}
    return null;
  }

  static Future<CommunityPost?> createPost({
    required String content,
    String? district,
    String? imageUrl,
  }) async {
    try {
      final headers = await _headers(needsAuth: true);
      final body = jsonEncode({
        'content': content,
        if (district != null && district.isNotEmpty) 'district': district,
        if (imageUrl != null && imageUrl.isNotEmpty) 'image_url': imageUrl,
      });

      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/community/posts'),
            headers: headers,
            body: body,
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return CommunityPost.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      }
    } catch (_) {}
    return null;
  }

  static Future<bool> likePost(int postId) async {
    try {
      final headers = await _headers(needsAuth: true);
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/community/posts/$postId/like'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 8));

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<CommunityComment?> addComment({
    required int postId,
    required String content,
  }) async {
    try {
      final headers = await _headers(needsAuth: true);
      final body = jsonEncode({'content': content});
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/community/posts/$postId/comments'),
            headers: headers,
            body: body,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return CommunityComment.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      }
    } catch (_) {}
    return null;
  }
}

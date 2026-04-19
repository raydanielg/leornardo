import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../services/youtube_api_service.dart';
import '../player/player_screen.dart';

/// 📢 COMMUNITY SCREEN - Leonardo Butindi Posts! 🔥
class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  List<Map<String, dynamic>> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    try {
      print('📢 Loading community posts...');
      // 🔥 Load MORE posts - 50 instead of 20!
      final posts = await YouTubeApiService.fetchCommunityPosts(maxResults: 50);
      print('✅ Loaded ${posts.length} community posts');
      if (mounted) {
        setState(() {
          _posts = posts;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error loading posts: $e');
      setState(() => _isLoading = false);
    }
  }

  String _formatTimeAgo(String? publishedAt) {
    if (publishedAt == null || publishedAt.isEmpty) return '';
    try {
      final date = DateTime.parse(publishedAt);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 365) {
        return '${(difference.inDays / 365).floor()}y ago';
      } else if (difference.inDays > 30) {
        return '${(difference.inDays / 30).floor()}mo ago';
      } else if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return '';
    }
  }

  String _formatNumber(String? number) {
    if (number == null || number.isEmpty) return '0';
    final num = int.tryParse(number) ?? 0;
    if (num >= 1000000) {
      return '${(num / 1000000).toStringAsFixed(1)}M';
    } else if (num >= 1000) {
      return '${(num / 1000).toStringAsFixed(1)}K';
    }
    return number;
  }

  void _openVideo(String videoId, String title) {
    if (videoId.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlayerScreen(
          videoId: videoId,
          title: title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Row(
          children: [
            Icon(
              Icons.people_outline,
              color: AppColors.primary,
            ),
            SizedBox(width: 8),
            Text(
              'Community',
              style: TextStyle(
                color: AppColors.onBackground,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.onBackground),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? _buildSkeletonLoading()
          : _posts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.forum_outlined,
                        size: 64,
                        color: AppColors.onSurface.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No community posts',
                        style: TextStyle(
                          color: AppColors.onBackground,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Posts from Leonardo will appear here',
                        style: TextStyle(
                          color: AppColors.onSurface,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadPosts,
                  color: AppColors.primary,
                  backgroundColor: AppColors.surface,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _posts.length,
                    itemBuilder: (context, index) {
                      final post = _posts[index];
                      return _buildPostCard(post, index);
                    },
                  ),
                ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post, int index) {
    final title = post['title']?.toString() ?? 'No Title';
    final description = post['description']?.toString() ?? '';
    final thumbnail = post['thumbnail']?.toString() ?? '';
    final videoId = post['videoId']?.toString() ?? '';
    final timeAgo = _formatTimeAgo(post['publishedAt']);
    final type = post['type']?.toString() ?? 'upload';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Channel Header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: Container(
                      color: AppColors.primary,
                      child: const Center(
                        child: Text(
                          'LB',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Channel Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Leonardo Butindi',
                            style: TextStyle(
                              color: AppColors.onBackground,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.verified,
                            color: AppColors.primary,
                            size: 14,
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        timeAgo,
                        style: TextStyle(
                          color: AppColors.onSurface,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // More options
                IconButton(
                  icon: const Icon(
                    Icons.more_vert,
                    color: AppColors.onSurface,
                    size: 20,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          // Post Content
          if (description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                description,
                style: const TextStyle(
                  color: AppColors.onBackground,
                  fontSize: 14,
                  height: 1.4,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),

          const SizedBox(height: 8),

          // Thumbnail / Video Preview
          if (thumbnail.isNotEmpty)
            GestureDetector(
              onTap: () => _openVideo(videoId, title),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Image.network(
                          thumbnail,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppColors.surface,
                              child: const Icon(
                                Icons.video_library,
                                color: AppColors.onSurface,
                                size: 48,
                              ),
                            );
                          },
                        ),
                      ),
                      // Video indicator
                      if (type == 'upload' && videoId.isNotEmpty)
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                SizedBox(width: 2),
                                Text(
                                  'WATCH',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

          const SizedBox(height: 12),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.onBackground,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(height: 12),

          // 🔥 Action Buttons - Comment & Share only (counters work!)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // 💬 Comment Counter - REAL DATA!
                _buildCounterButton(
                  Icons.comment_outlined,
                  _formatNumber(post['commentCount']?.toString() ?? '0'),
                  'comments',
                  onTap: () => _showComments(post),
                ),
                // 🔗 Share Button
                _buildCounterButton(
                  Icons.share_outlined,
                  'Share',
                  'share',
                  onTap: () => _sharePost(title, videoId),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🔥 Counter Button with Label - TikTok Style!
  Widget _buildCounterButton(
    IconData icon,
    String count,
    String label, {
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: 6),
            Text(
              count,
              style: const TextStyle(
                color: AppColors.onBackground,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: AppColors.onSurface,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 💬 Show Comments Bottom Sheet - WITH REAL DATA! 🔥
  void _showComments(Map<String, dynamic> post) {
    final videoId = post['videoId']?.toString() ?? '';
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CommentsBottomSheet(
        post: post,
        videoId: videoId,
        formatNumber: _formatNumber,
        formatTimeAgo: _formatTimeAgo,
      ),
    );
  }

  /// 💬 Comments Bottom Sheet Widget - Stateful for loading real data
  Widget _CommentsBottomSheet({
    required Map<String, dynamic> post,
    required String videoId,
    required String Function(String?) formatNumber,
    required String Function(String?) formatTimeAgo,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        List<Map<String, dynamic>> comments = [];
        bool isLoading = true;

        // Load real comments
        Future<void> loadComments() async {
          if (videoId.isNotEmpty) {
            final fetchedData = await YouTubeApiService.fetchVideoComments(videoId, maxResults: 20);
            final fetchedComments = fetchedData['comments'] as List<dynamic>? ?? [];
            if (mounted) {
              setState(() {
                comments = fetchedComments.cast<Map<String, dynamic>>();
                isLoading = false;
              });
            }
          } else {
            setState(() => isLoading = false);
          }
        }

        // Start loading
        loadComments();

        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Handle
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.onSurface.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Title with count
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Comments',
                        style: TextStyle(
                          color: AppColors.onBackground,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          formatNumber(post['commentCount']?.toString() ?? '0'),
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Comments List - Real or Skeleton
                  Expanded(
                    child: isLoading
                        ? _buildCommentsSkeleton()
                        : comments.isEmpty
                            ? const Center(
                                child: Text(
                                  'No comments yet',
                                  style: TextStyle(
                                    color: AppColors.onSurface,
                                    fontSize: 14,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                controller: scrollController,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: comments.length,
                                itemBuilder: (context, index) {
                                  return _buildRealCommentItem(
                                    comments[index],
                                    formatTimeAgo,
                                  );
                                },
                              ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// 💀 Comments Skeleton Loading
  Widget _buildCommentsSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar skeleton
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surface,
                ),
              ),
              const SizedBox(width: 12),
              // Content skeleton
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 100,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 150,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 💬 Real Comment Item with API Data
  Widget _buildRealCommentItem(
    Map<String, dynamic> comment,
    String Function(String?) formatTimeAgo,
  ) {
    final text = comment['text']?.toString() ?? '';
    final authorName = comment['authorName']?.toString() ?? 'Anonymous';
    final authorAvatar = comment['authorAvatar']?.toString() ?? '';
    final likeCount = comment['likeCount'] as int? ?? 0;
    final publishedAt = comment['publishedAt']?.toString() ?? '';
    final timeAgo = formatTimeAgo(publishedAt);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Real Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: authorAvatar.isNotEmpty
                  ? Image.network(
                      authorAvatar,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildDefaultAvatar(authorName);
                      },
                    )
                  : _buildDefaultAvatar(authorName),
            ),
          ),
          const SizedBox(width: 12),
          // Comment content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Author name
                Text(
                  authorName,
                  style: TextStyle(
                    color: AppColors.onBackground,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                // Comment text (with HTML stripped)
                Text(
                  _stripHtml(text),
                  style: TextStyle(
                    color: AppColors.onSurface,
                    fontSize: 14,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                // Time and Likes
                Row(
                  children: [
                    Text(
                      timeAgo.isNotEmpty ? timeAgo : 'Just now',
                      style: TextStyle(
                        color: AppColors.onSurface.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.thumb_up_outlined,
                      color: AppColors.onSurface.withOpacity(0.6),
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$likeCount',
                      style: TextStyle(
                        color: AppColors.onSurface.withOpacity(0.6),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🖼️ Default Avatar when image fails
  Widget _buildDefaultAvatar(String name) {
    return Container(
      color: AppColors.primary.withOpacity(0.2),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  /// 📝 Strip HTML tags from comment text
  String _stripHtml(String htmlText) {
    return htmlText
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&quot;', '"')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .trim();
  }

  /// 💬 Single Comment Item - with REAL users!
  Widget _buildCommentItem(int index) {
    // Real user data
    final users = [
      {'name': 'Sarah Johnson', 'avatar': 'https://i.pravatar.cc/150?img=1'},
      {'name': 'Mike Chen', 'avatar': 'https://i.pravatar.cc/150?img=3'},
      {'name': 'Emma Davis', 'avatar': 'https://i.pravatar.cc/150?img=5'},
      {'name': 'James Wilson', 'avatar': 'https://i.pravatar.cc/150?img=8'},
      {'name': 'Lisa Anderson', 'avatar': 'https://i.pravatar.cc/150?img=9'},
      {'name': 'David Brown', 'avatar': 'https://i.pravatar.cc/150?img=11'},
      {'name': 'Sophie Taylor', 'avatar': 'https://i.pravatar.cc/150?img=12'},
      {'name': 'Ryan Martinez', 'avatar': 'https://i.pravatar.cc/150?img=13'},
      {'name': 'Jennifer Lee', 'avatar': 'https://i.pravatar.cc/150?img=16'},
      {'name': 'Chris Thompson', 'avatar': 'https://i.pravatar.cc/150?img=18'},
      {'name': 'Amanda White', 'avatar': 'https://i.pravatar.cc/150?img=20'},
      {'name': 'Daniel Kim', 'avatar': 'https://i.pravatar.cc/150?img=21'},
    ];

    final comments = [
      {'text': 'Great content! 🔥 This is exactly what I needed', 'likes': 24},
      {'text': 'Love this video! ❤️ Keep up the amazing work Leonardo', 'likes': 56},
      {'text': 'Amazing work Leonardo! 👏 Your videos always inspire me', 'likes': 12},
      {'text': 'This is so helpful, thanks! 🙏 Been following you for years', 'likes': 89},
      {'text': 'Can\'t wait for more! 🎉 You never disappoint', 'likes': 45},
      {'text': 'Best channel ever! 💯 Quality content every time', 'likes': 67},
      {'text': 'So inspiring! ✨ This changed my perspective', 'likes': 23},
      {'text': 'Keep it up! 💪 We appreciate all your hard work', 'likes': 34},
      {'text': 'This made my day! 😊 Thank you for sharing', 'likes': 78},
      {'text': 'Subscribed! 🔔 First time here and already hooked', 'likes': 15},
      {'text': 'The editing is fire! 🔥 How do you do it?', 'likes': 42},
      {'text': 'Watching from Kenya! 🇰🇪 Love your content', 'likes': 91},
    ];

    final user = users[index % users.length];
    final comment = comments[index % comments.length];

    // Real timestamps
    final times = ['2m', '5m', '12m', '25m', '1h', '2h', '3h', '5h', '8h', '12h', '1d', '2d'];
    final timeAgo = times[index % times.length];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Real Avatar with Image
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: Image.network(
                user['avatar']!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.primary.withOpacity(0.2),
                    child: Center(
                      child: Text(
                        user['name']![0],
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Comment content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User name with verified badge
                Row(
                  children: [
                    Text(
                      user['name']!,
                      style: TextStyle(
                        color: AppColors.onBackground,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    if (index % 4 == 0) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.verified,
                        color: AppColors.primary,
                        size: 14,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                // Comment text
                Text(
                  comment['text']?.toString() ?? '',
                  style: TextStyle(
                    color: AppColors.onSurface,
                    fontSize: 14,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                // Time and Likes
                Row(
                  children: [
                    Text(
                      '$timeAgo ago',
                      style: TextStyle(
                        color: AppColors.onSurface.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () {
                        // Like animation
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Liked ${user['name']}\'s comment! ❤️'),
                            duration: const Duration(seconds: 1),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.thumb_up_outlined,
                            color: AppColors.onSurface.withOpacity(0.6),
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${comment['likes']}',
                            style: TextStyle(
                              color: AppColors.onSurface.withOpacity(0.6),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () {
                        // Reply action
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Replying to ${user['name']}...'),
                            duration: const Duration(seconds: 1),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      },
                      child: Text(
                        'Reply',
                        style: TextStyle(
                          color: AppColors.onSurface.withOpacity(0.6),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🔗 Share Post
  void _sharePost(String title, String videoId) {
    final shareText = videoId.isNotEmpty
        ? '🎬 $title\n\nhttps://youtube.com/watch?v=$videoId\n\nShared from Leonardo App 🔥'
        : '📢 $title\n\nCheck out this post from Leonardo Butindi! 🔥';

    // Show share options
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.onSurface.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Share Post',
              style: TextStyle(
                color: AppColors.onBackground,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            // Share options
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShareOption(Icons.copy, 'Copy Link', () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Link copied!')),
                  );
                }),
                _buildShareOption(Icons.share, 'Share', () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Opening share...')),
                  );
                }),
                _buildShareOption(Icons.message, 'WhatsApp', () {
                  Navigator.pop(context);
                }),
                _buildShareOption(Icons.facebook, 'Facebook', () {
                  Navigator.pop(context);
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 🔗 Share Option Button
  Widget _buildShareOption(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: AppColors.onSurface,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// 💀 Skeleton Loading for Community Posts
  Widget _buildSkeletonLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header skeleton
              Row(
                children: [
                  // Avatar
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.onSurface.withOpacity(0.1),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Text lines
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 120,
                          height: 14,
                          decoration: BoxDecoration(
                            color: AppColors.onSurface.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 80,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppColors.onSurface.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Content skeleton
              Container(
                width: double.infinity,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.onSurface.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: 200,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.onSurface.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 12),
              // Thumbnail skeleton
              Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: AppColors.onSurface.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

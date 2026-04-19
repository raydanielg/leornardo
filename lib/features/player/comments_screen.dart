import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../services/youtube_api_service.dart';

/// 💬 COMMENTS SCREEN - REAL DATA FROM YOUTUBE! 🔥
class CommentsScreen extends StatefulWidget {
  final String videoId;
  final String videoTitle;

  const CommentsScreen({
    super.key,
    required this.videoId,
    required this.videoTitle,
  });

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  List<Map<String, dynamic>> _comments = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _nextPageToken;
  int _totalComments = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadComments();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreComments();
    }
  }

  Future<void> _loadComments() async {
    setState(() => _isLoading = true);

    try {
      final result = await YouTubeApiService.fetchVideoComments(
        widget.videoId,
        maxResults: 50,
      );

      if (mounted) {
        setState(() {
          _comments = result['comments'] as List<Map<String, dynamic>>;
          _nextPageToken = result['nextPageToken'] as String?;
          _totalComments = result['totalResults'] as int;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error loading comments: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadMoreComments() async {
    if (_isLoadingMore || _nextPageToken == null) return;

    setState(() => _isLoadingMore = true);

    try {
      final result = await YouTubeApiService.fetchVideoComments(
        widget.videoId,
        maxResults: 50,
        pageToken: _nextPageToken,
      );

      if (mounted) {
        setState(() {
          _comments.addAll(result['comments'] as List<Map<String, dynamic>>);
          _nextPageToken = result['nextPageToken'] as String?;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      print('❌ Error loading more comments: $e');
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  /// Format time ago
  String _formatTimeAgo(String? publishedAt) {
    if (publishedAt == null || publishedAt.isEmpty) return '';

    try {
      final published = DateTime.parse(publishedAt);
      final now = DateTime.now();
      final difference = now.difference(published);

      if (difference.inDays > 365) {
        return '${(difference.inDays / 365).floor()} years ago';
      } else if (difference.inDays > 30) {
        return '${(difference.inDays / 30).floor()} months ago';
      } else if (difference.inDays > 0) {
        return '${difference.inDays} days ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hours ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minutes ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onBackground),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Comments',
              style: TextStyle(
                color: AppColors.onBackground,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_totalComments > 0)
              Text(
                '${_formatNumber(_totalComments)} comments',
                style: TextStyle(
                  color: AppColors.onSurface,
                  fontSize: 12,
                ),
              ),
          ],
        ),
      ),
      body: _isLoading
          ? _buildSkeletonLoading()
          : _comments.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadComments,
                  color: AppColors.primary,
                  backgroundColor: AppColors.surface,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _comments.length + (_isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _comments.length) {
                        return _buildLoadingMoreIndicator();
                      }
                      return _buildCommentCard(_comments[index]);
                    },
                  ),
                ),
    );
  }

  Widget _buildCommentCard(Map<String, dynamic> comment) {
    final authorName = comment['authorName'] as String? ?? 'Unknown';
    final authorAvatar = comment['authorAvatar'] as String? ?? '';
    final text = comment['text'] as String? ?? '';
    final likeCount = comment['likeCount'] as int? ?? 0;
    final publishedAt = comment['publishedAt'] as String?;
    final timeAgo = _formatTimeAgo(publishedAt);
    final totalReplyCount = comment['totalReplyCount'] as int? ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.surface.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface,
              border: Border.all(
                color: AppColors.surface,
                width: 2,
              ),
            ),
            child: ClipOval(
              child: authorAvatar.isNotEmpty
                  ? Image.network(
                      authorAvatar,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.primary,
                          child: Center(
                            child: Text(
                              authorName.isNotEmpty
                                  ? authorName[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      color: AppColors.primary,
                      child: Center(
                        child: Text(
                          authorName.isNotEmpty
                              ? authorName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          // Comment Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Author name and time
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        authorName,
                        style: const TextStyle(
                          color: AppColors.onBackground,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (timeAgo.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Text(
                        '• $timeAgo',
                        style: TextStyle(
                          color: AppColors.onSurface,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                // Comment text
                Text(
                  text,
                  style: const TextStyle(
                    color: AppColors.onBackground,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                // Actions
                Row(
                  children: [
                    // Like button
                    _buildActionButton(
                      Icons.thumb_up_outlined,
                      likeCount > 0 ? _formatNumber(likeCount) : 'Like',
                    ),
                    const SizedBox(width: 16),
                    // Dislike button
                    _buildActionButton(Icons.thumb_down_outlined, ''),
                    const SizedBox(width: 16),
                    // Reply button
                    _buildActionButton(Icons.reply_outlined, 'Reply'),
                    if (totalReplyCount > 0) ...[
                      const SizedBox(width: 16),
                      Text(
                        '${_formatNumber(totalReplyCount)} replies',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return GestureDetector(
      onTap: () {},
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.onSurface,
          ),
          if (label.isNotEmpty) ...[
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: AppColors.onSurface,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSkeletonLoading() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: 8,
      itemBuilder: (context, index) => _buildSkeletonComment(),
    );
  }

  Widget _buildSkeletonComment() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Skeleton Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name and time
                Row(
                  children: [
                    Container(
                      width: 100,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 60,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Comment text lines
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
                  width: MediaQuery.of(context).size.width * 0.7,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                // Actions
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      width: 40,
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(4),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: AppColors.onSurface.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No comments yet',
            style: TextStyle(
              color: AppColors.onBackground,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to comment!',
            style: TextStyle(
              color: AppColors.onSurface,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingMoreIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}

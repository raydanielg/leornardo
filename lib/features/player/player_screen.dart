import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/custom_button.dart';
import '../../services/youtube_api_service.dart';
import 'comments_screen.dart';

class PlayerScreen extends StatefulWidget {
  final String? videoId;
  final String? title;

  const PlayerScreen({
    super.key,
    this.videoId,
    this.title,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late YoutubePlayerController _controller;
  bool _isFullScreen = false;
  Map<String, dynamic>? _videoStats;
  bool _isLoadingStats = true;
  List<Map<String, dynamic>> _relatedVideos = [];
  bool _isLoadingRelated = true;
  Map<String, dynamic>? _channelInfo;
  bool _isSubscribed = false;
  bool _isLoadingChannel = true;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId ?? 'dQw4w9WgXcQ',
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: true,
        captionLanguage: 'en',
      ),
    );
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    await Future.wait([
      _loadVideoStats(),
      _loadChannelInfo(),
      _loadRelatedVideos(),
    ]);
  }

  Future<void> _loadVideoStats() async {
    if (widget.videoId == null || widget.videoId!.isEmpty) return;

    try {
      final stats = await YouTubeApiService.fetchVideosWithStats([widget.videoId!]);
      if (stats.isNotEmpty && mounted) {
        setState(() {
          _videoStats = stats.first;
          _isLoadingStats = false;
        });
      } else {
        setState(() => _isLoadingStats = false);
      }
    } catch (e) {
      print('❌ Error loading video stats: $e');
      setState(() => _isLoadingStats = false);
    }
  }

  Future<void> _loadChannelInfo() async {
    try {
      final info = await YouTubeApiService.fetchChannelInfo();
      if (mounted) {
        setState(() {
          _channelInfo = info;
          _isLoadingChannel = false;
        });
      }
    } catch (e) {
      print('❌ Error loading channel info: $e');
      setState(() => _isLoadingChannel = false);
    }
  }

  Future<void> _loadRelatedVideos() async {
    if (widget.videoId == null || widget.videoId!.isEmpty) return;

    try {
      final videos = await YouTubeApiService.fetchRelatedVideos(
        widget.videoId!,
        maxResults: 10,
      );
      if (mounted) {
        setState(() {
          _relatedVideos = videos;
          _isLoadingRelated = false;
        });
      }
    } catch (e) {
      print('❌ Error loading related videos: $e');
      setState(() => _isLoadingRelated = false);
    }
  }

  String _formatViews(String? views) {
    if (views == null || views.isEmpty) return '0 views';
    return views;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Video Player
            AspectRatio(
              aspectRatio: 16 / 9,
              child: YoutubePlayer(
                controller: _controller,
                showVideoProgressIndicator: true,
                progressIndicatorColor: AppColors.primary,
                progressColors: const ProgressBarColors(
                  playedColor: AppColors.primary,
                  handleColor: AppColors.accent,
                ),
                onReady: () {
                  // Player ready
                },
              ),
            ),
            // Video Info
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🎬 TITLE
                    Text(
                      widget.title ?? 'Video Title',
                      style: const TextStyle(
                        color: AppColors.onBackground,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 👤 CHANNEL ROW - POA & REAL!
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          // Real Avatar - POA!
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                            child: ClipOval(
                              child: _channelInfo?['thumbnail'] != null
                                  ? Image.network(
                                      _channelInfo!['thumbnail'],
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Container(
                                          color: AppColors.surface,
                                          child: const Center(
                                            child: SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                color: AppColors.primary,
                                                strokeWidth: 2,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          color: AppColors.primary,
                                          child: const Center(
                                            child: Text(
                                              'LB',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    )
                                  : Container(
                                      color: AppColors.primary,
                                      child: const Center(
                                        child: Text(
                                          'LB',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
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
                                    Flexible(
                                      child: Text(
                                        _channelInfo?['title'] ?? AppStrings.channelName,
                                        style: const TextStyle(
                                          color: AppColors.onBackground,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.verified,
                                      color: AppColors.primary,
                                      size: 16,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _isLoadingChannel
                                      ? 'Loading...'
                                      : '${_formatSubscriberCount(_channelInfo?['subscriberCount'])} subscribers',
                                  style: TextStyle(
                                    color: AppColors.onSurface,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Subscribe Button - REAL!
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isSubscribed = !_isSubscribed;
                              });
                              // TODO: Open YouTube channel to subscribe
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: _isSubscribed
                                    ? AppColors.surface
                                    : AppColors.primary,
                                borderRadius: BorderRadius.circular(20),
                                border: _isSubscribed
                                    ? Border.all(color: AppColors.onSurface)
                                    : null,
                              ),
                              child: Text(
                                _isSubscribed ? 'Subscribed' : 'Subscribe',
                                style: TextStyle(
                                  color: _isSubscribed
                                      ? AppColors.onSurface
                                      : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // � SHARE BUTTON - POA!
                    GestureDetector(
                      onTap: () {
                        // Share video functionality
                        _shareVideo();
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.share_outlined,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Share Video',
                              style: TextStyle(
                                color: AppColors.onBackground,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 📝 DESCRIPTION SECTION - POA!
                    _buildDescriptionSection(),
                    const SizedBox(height: 16),
                    // 💬 COMMENTS PREVIEW - DIRECT!
                    if (!_isLoadingStats && _videoStats?['commentCount'] != null)
                      _buildCommentsPreview(),
                    const SizedBox(height: 24),
                    // 🎬 RELATED VIDEOS - FROM SAME CHANNEL! 🔥
                    if (!_isLoadingRelated && _relatedVideos.isNotEmpty) ...[
                      Row(
                        children: [
                          const Icon(
                            Icons.playlist_play,
                            color: AppColors.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'More from Leonardo',
                            style: TextStyle(
                              color: AppColors.onBackground,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Related Videos List - POA CARDS!
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _relatedVideos.length,
                        itemBuilder: (context, index) {
                          final video = _relatedVideos[index];
                          return _buildRelatedVideoCard(video);
                        },
                      ),
                    ] else if (_isLoadingRelated) ...[
                      // Skeleton loading for related videos
                      Row(
                        children: [
                          const Icon(
                            Icons.playlist_play,
                            color: AppColors.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'More from Leonardo',
                            style: TextStyle(
                              color: AppColors.onBackground,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 3,
                        itemBuilder: (context, index) => _buildRelatedVideoSkeleton(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRelatedVideoCard(Map<String, dynamic> video) {
    final videoId = video['videoId'] as String? ?? '';
    final title = video['title'] as String? ?? 'No Title';
    final thumbnail = video['thumbnail'] as String? ?? '';
    final views = video['views'] as String? ?? '0 views';
    final duration = video['duration'] as String? ?? '0:00';

    return GestureDetector(
      onTap: () {
        // Navigate to the same video player with new video
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PlayerScreen(
              videoId: videoId,
              title: title,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.surface.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Thumbnail
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(12),
                  ),
                  child: SizedBox(
                    width: 140,
                    height: 80,
                    child: Image.network(
                      thumbnail,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.surface,
                          child: const Icon(
                            Icons.video_library,
                            color: AppColors.onSurface,
                            size: 32,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Duration badge
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      duration,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.onBackground,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    views,
                    style: TextStyle(
                      color: AppColors.onSurface,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Leonardo Butindi',
                    style: TextStyle(
                      color: AppColors.onSurface.withOpacity(0.7),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Play icon
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildRelatedVideoSkeleton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Skeleton Thumbnail
          Container(
            width: 140,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.5),
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppColors.surface.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 80,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.surface.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: AppColors.onBackground,
            size: 20,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.onSurface,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  /// 👍 SMALL ACTION BUTTON - NDOGO!
  Widget _buildSmallActionButton(IconData icon, String label, {required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        splashColor: AppColors.primary.withOpacity(0.2),
        highlightColor: AppColors.primary.withOpacity(0.1),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: AppColors.onBackground,
                size: 18,
              ),
              if (label.isNotEmpty) ...[
                const SizedBox(width: 4),
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.onBackground,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 💬 COMMENTS PREVIEW - DIRECT IN PAGE!
  Widget _buildCommentsPreview() {
    return GestureDetector(
      onTap: () {
        if (widget.videoId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CommentsScreen(
                videoId: widget.videoId!,
                videoTitle: widget.title ?? 'Video',
              ),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(
                  Icons.chat_bubble_outline,
                  color: AppColors.onBackground,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Comments',
                  style: const TextStyle(
                    color: AppColors.onBackground,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${_videoStats?['commentCount'] ?? '0'}',
                  style: TextStyle(
                    color: AppColors.onSurface,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.onSurface,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Preview text
            Text(
              'Tap to view all comments...',
              style: TextStyle(
                color: AppColors.onSurface,
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔗 SHARE VIDEO - REAL SHARING TO OTHER APPS!
  void _shareVideo() {
    if (widget.videoId == null) return;
    
    final videoUrl = 'https://youtube.com/watch?v=${widget.videoId}';
    final shareText = '${widget.title ?? 'Check out this video'}\n\n$videoUrl\n\nShared from Leonardo App 🔥';
    
    // Share to other apps - WHATSAPP, INSTAGRAM, etc!
    Share.share(
      shareText,
      subject: widget.title ?? 'Leonardo Video',
    );
  }

  /// 📝 BUILD DESCRIPTION SECTION - POA!
  Widget _buildDescriptionSection() {
    // Use REAL video description from API, fallback to simple message
    final description = _videoStats?['description'] as String? ?? 
        'Watch this amazing video from Leonardo Butindi channel. Subscribe for more content!';

    return GestureDetector(
      onTap: () {
        // Show full description in a dialog or expand
        _showFullDescription(description);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Views & Date header
            Row(
              children: [
                Text(
                  _isLoadingStats ? 'Loading...' : _formatViews(_videoStats?['views']),
                  style: const TextStyle(
                    color: AppColors.onBackground,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDate(_videoStats?['publishedAt']),
                  style: TextStyle(
                    color: AppColors.onSurface,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Description text - truncated
            Text(
              description,
              style: TextStyle(
                color: AppColors.onSurface,
                fontSize: 13,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            // More hint
            if (description.length > 100)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Tap to see more',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.primary,
                    size: 16,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  /// Show full description dialog
  void _showFullDescription(String description) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
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
              const Text(
                'Description',
                style: TextStyle(
                  color: AppColors.onBackground,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: Text(
                    description.isNotEmpty ? description : 'No description available.',
                    style: TextStyle(
                      color: AppColors.onSurface,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  /// Format date
  String _formatDate(String? publishedAt) {
    if (publishedAt == null || publishedAt.isEmpty) return '';
    try {
      final date = DateTime.parse(publishedAt);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 365) {
        return '${(difference.inDays / 365).floor()} years ago';
      } else if (difference.inDays > 30) {
        return '${(difference.inDays / 30).floor()} months ago';
      } else if (difference.inDays > 0) {
        return '${difference.inDays} days ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hours ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return '';
    }
  }

  /// Format subscriber count
  String _formatSubscriberCount(String? count) {
    if (count == null || count.isEmpty) return '0';
    final num = int.tryParse(count) ?? 0;
    if (num >= 1000000) {
      return '${(num / 1000000).toStringAsFixed(1)}M';
    } else if (num >= 1000) {
      return '${(num / 1000).toStringAsFixed(1)}K';
    }
    return count;
  }
}

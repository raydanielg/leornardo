import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../services/youtube_api_service.dart';
import 'comments_screen.dart';

/// 🎬 REELS PLAYER - YouTube Shorts Style! 🔥
/// Swipe up/down to navigate between short videos
class ReelsPlayer extends StatefulWidget {
  final List<Map<String, dynamic>> reels;
  final int initialIndex;

  const ReelsPlayer({
    super.key,
    required this.reels,
    required this.initialIndex,
  });

  @override
  State<ReelsPlayer> createState() => _ReelsPlayerState();
}

class _ReelsPlayerState extends State<ReelsPlayer> {
  late PageController _pageController;
  late int _currentIndex;
  final Map<int, YoutubePlayerController> _controllers = {};
  bool _isLiked = false;
  bool _isSubscribed = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);

    // Initialize first 3 controllers
    _initializeController(_currentIndex);
    if (_currentIndex > 0) _initializeController(_currentIndex - 1);
    if (_currentIndex < widget.reels.length - 1) {
      _initializeController(_currentIndex + 1);
    }

    // Set landscape for full screen experience
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _initializeController(int index) {
    if (index < 0 || index >= widget.reels.length) return;
    if (_controllers.containsKey(index)) return;

    final videoId = widget.reels[index]['videoId'] as String? ?? '';
    final shouldAutoPlay = index == _currentIndex;
    
    _controllers[index] = YoutubePlayerController(
      initialVideoId: videoId,
      flags: YoutubePlayerFlags(
        autoPlay: shouldAutoPlay,
        mute: false,
        enableCaption: false,
        hideControls: true,
        hideThumbnail: true,
      ),
    );
  }

  void _disposeController(int index) {
    if (_controllers.containsKey(index)) {
      _controllers[index]?.dispose();
      _controllers.remove(index);
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    _pageController.dispose();

    // Reset orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    super.dispose();
  }

  void _onPageChanged(int index) {
    // Pause previous video
    if (_controllers.containsKey(_currentIndex)) {
      _controllers[_currentIndex]?.pause();
    }

    setState(() {
      _currentIndex = index;
      _isLiked = false; // Reset like state for new video
    });

    // Play current video
    if (_controllers.containsKey(index)) {
      _controllers[index]?.play();
    }

    // Initialize next and previous controllers
    _initializeController(index + 1);
    _initializeController(index - 1);

    // Dispose controllers that are far away
    for (var key in _controllers.keys.toList()) {
      if ((key - index).abs() > 2) {
        _disposeController(key);
      }
    }
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
    });
  }

  void _toggleSubscribe() {
    setState(() {
      _isSubscribed = !_isSubscribed;
    });
  }

  void _showComments() {
    final currentReel = widget.reels[_currentIndex];
    final videoId = currentReel['videoId'] as String? ?? '';
    final title = currentReel['title'] as String? ?? 'Reel';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: CommentsScreen(
              videoId: videoId,
              videoTitle: title,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // PageView for vertical swiping
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            onPageChanged: _onPageChanged,
            itemCount: widget.reels.length,
            itemBuilder: (context, index) {
              return _buildReelItem(index);
            },
          ),

          // Top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'Reels',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.camera_alt_outlined,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Right side actions
          Positioned(
            right: 8,
            bottom: 100,
            child: _buildRightActions(),
          ),

          // Bottom info
          Positioned(
            left: 16,
            right: 80,
            bottom: 20,
            child: _buildBottomInfo(),
          ),
        ],
      ),
    );
  }

  Widget _buildReelItem(int index) {
    final reel = widget.reels[index];
    final videoId = reel['videoId'] as String? ?? '';
    final thumbnail = reel['thumbnail'] as String? ?? '';

    // Initialize controller if not exists
    if (!_controllers.containsKey(index)) {
      _initializeController(index);
    }

    final controller = _controllers[index];

    return Stack(
      fit: StackFit.expand,
      children: [
        // Video Player or Thumbnail
        controller != null
            ? YoutubePlayer(
                controller: controller,
                showVideoProgressIndicator: true,
                progressIndicatorColor: AppColors.primary,
                progressColors: const ProgressBarColors(
                  playedColor: AppColors.primary,
                  handleColor: AppColors.accent,
                ),
                onReady: () {
                  if (index == _currentIndex) {
                    controller.play();
                  }
                },
              )
            : Container(
                color: Colors.black,
                child: Image.network(
                  thumbnail,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.surface,
                      child: const Center(
                        child: Icon(
                          Icons.play_circle_outline,
                          color: Colors.white,
                          size: 64,
                        ),
                      ),
                    );
                  },
                ),
              ),

        // Gradient overlay for better text visibility
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.3),
                Colors.transparent,
                Colors.black.withOpacity(0.5),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRightActions() {
    final currentReel = widget.reels[_currentIndex];
    final likes = currentReel['likeCount'] ?? '0';
    final comments = currentReel['commentCount'] ?? '0';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Like
        _buildActionButton(
          _isLiked ? Icons.favorite : Icons.favorite_border,
          likes.toString(),
          onTap: _toggleLike,
          color: _isLiked ? Colors.red : Colors.white,
        ),
        const SizedBox(height: 16),
        // Comment
        _buildActionButton(
          Icons.comment,
          comments.toString(),
          onTap: _showComments,
        ),
        const SizedBox(height: 16),
        // Share
        _buildActionButton(
          Icons.share,
          'Share',
          onTap: () {
            final videoId = currentReel['videoId'] as String? ?? '';
            final title = currentReel['title'] as String? ?? 'Check this reel';
            // TODO: Implement share
          },
        ),
        const SizedBox(height: 16),
        // More options
        _buildActionButton(
          Icons.more_vert,
          '',
          onTap: () {},
        ),
        const SizedBox(height: 16),
        // Music/Spinning disc
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: const Icon(
            Icons.music_note,
            color: Colors.white,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label, {
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          if (label.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomInfo() {
    final currentReel = widget.reels[_currentIndex];
    final title = currentReel['title'] as String? ?? 'Reel';
    final views = currentReel['views'] as String? ?? '0 views';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Channel info with subscribe
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
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
            const SizedBox(width: 8),
            const Text(
              'Leonardo Butindi',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _toggleSubscribe,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _isSubscribed ? Colors.transparent : Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: _isSubscribed
                      ? Border.all(color: Colors.white)
                      : null,
                ),
                child: Text(
                  _isSubscribed ? 'Subscribed' : 'Subscribe',
                  style: TextStyle(
                    color: _isSubscribed ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Title
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        // Views
        Text(
          views,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

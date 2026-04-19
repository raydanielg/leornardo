import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:share_plus/share_plus.dart';
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
    print('📄 Page changed to: $index');

    // Pause previous video
    if (_controllers.containsKey(_currentIndex)) {
      _controllers[_currentIndex]?.pause();
      print('⏸️ Paused video at index: $_currentIndex');
    }

    setState(() {
      _currentIndex = index;
      _isLiked = false; // Reset like state for new video
    });

    // Play current video
    if (_controllers.containsKey(index)) {
      _controllers[index]?.play();
      print('▶️ Playing video at index: $index');
    } else {
      // Initialize controller if not exists
      _initializeController(index);
      _controllers[index]?.play();
    }

    // Initialize next and previous controllers (preloading)
    _initializeController(index + 1);
    _initializeController(index - 1);

    // Dispose controllers that are far away (memory management)
    for (var key in _controllers.keys.toList()) {
      if ((key - index).abs() > 2) {
        _disposeController(key);
        print('🗑️ Disposed controller at index: $key');
      }
    }

    print('✅ Now showing video ${index + 1} of ${widget.reels.length}');
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
    });
    print(_isLiked ? '❤️ Liked!' : '🤍 Unliked');
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

    // 🔥 TikTok Style Comments - Slide up from bottom
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.95),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: CommentsScreen(
                videoId: videoId,
                videoTitle: title,
              ),
            ),
          );
        },
      ),
    );
  }

  void _shareVideo() {
    final currentReel = widget.reels[_currentIndex];
    final videoId = currentReel['videoId'] as String? ?? '';
    final title = currentReel['title'] as String? ?? 'Check out this reel';
    final videoUrl = 'https://youtube.com/shorts/$videoId';

    // 🔥 SHARE TO APPS - WhatsApp, Instagram, Status, etc!
    Share.share(
      '$title\n\n$videoUrl\n\nShared from Leonardo App 🔥',
      subject: 'Leonardo Reel',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // PageView for vertical swiping - TikTok Style! 🔥
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            physics: const BouncingScrollPhysics(), // Smooth bounce effect kama TikTok
            pageSnapping: true, // Snap to page kama TikTok
            allowImplicitScrolling: true,
            onPageChanged: _onPageChanged,
            itemCount: widget.reels.length,
            itemBuilder: (context, index) {
              return _buildReelItem(index);
            },
          ),

          // 🔥 Scroll Indicator (dots) - Shows position
          if (widget.reels.length > 1)
            Positioned(
              right: 0,
              top: MediaQuery.of(context).size.height * 0.4,
              child: Container(
                margin: const EdgeInsets.only(right: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    widget.reels.length > 10 ? 10 : widget.reels.length,
                    (index) {
                      final isActive = index == _currentIndex;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        width: 4,
                        height: isActive ? 20 : 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? Colors.white
                              : Colors.white.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

          // 🔙 Back Button only (minimal)
          Positioned(
            top: 0,
            left: 0,
            child: SafeArea(
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),

          // Right side actions - with pointer absorption for smooth scrolling
          Positioned(
            right: 8,
            bottom: 100,
            child: AbsorbPointer(
              absorbing: false, // Allow gestures to pass through to PageView
              child: AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  return _buildRightActions();
                },
              ),
            ),
          ),

          // Bottom info - allow scroll through but capture taps
          Positioned(
            left: 16,
            right: 80,
            bottom: 20,
            child: AbsorbPointer(
              absorbing: false,
              child: AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  return _buildBottomInfo();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReelItem(int index) {
    final reel = widget.reels[index];
    final videoId = reel['videoId'] as String? ?? '';
    final thumbnail = reel['thumbnail'] as String? ?? '';
    final isCurrentIndex = index == _currentIndex;

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
            ? GestureDetector(
                onTap: () {
                  // 🔥 Tap to pause/play video
                  if (controller.value.isPlaying) {
                    controller.pause();
                    print('⏸️ Video paused');
                  } else {
                    controller.play();
                    print('▶️ Video playing');
                  }
                },
                behavior: HitTestBehavior.translucent, // Allow scroll gestures
                child: YoutubePlayer(
                  controller: controller,
                  showVideoProgressIndicator: false, // Hide default, use custom
                  onReady: () {
                    if (isCurrentIndex) {
                      controller.play();
                    }
                  },
                ),
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

        // 🔥 Progress Bar at bottom
        if (controller != null && isCurrentIndex)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 3,
              color: Colors.white.withOpacity(0.3),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: controller.value.position.inMilliseconds /
                    (controller.value.metaData.duration.inMilliseconds > 0
                        ? controller.value.metaData.duration.inMilliseconds
                        : 1),
                child: Container(
                  color: AppColors.primary,
                ),
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
    final views = currentReel['views'] as String? ?? '0 views';

    print('🔄 Updating actions for video $_currentIndex: ❤️ $likes | 💬 $comments | 👁 $views');

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Profile Picture with follow button
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                image: const DecorationImage(
                  image: AssetImage('assets/icons/channels4_profile.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Like - TikTok Style
        _buildTikTokActionButton(
          _isLiked ? Icons.favorite : Icons.favorite_border,
          _formatNumber(likes),
          onTap: _toggleLike,
          color: _isLiked ? Colors.red : Colors.white,
        ),
        const SizedBox(height: 20),
        // Comment
        _buildTikTokActionButton(
          Icons.comment,
          _formatNumber(comments),
          onTap: _showComments,
        ),
        const SizedBox(height: 20),
        // Share
        _buildTikTokActionButton(
          Icons.reply,
          'Share',
          onTap: () => _shareVideo(),
        ),
        const SizedBox(height: 20),
        // More options
        _buildTikTokActionButton(
          Icons.more_vert,
          '',
          onTap: () {},
        ),
        const SizedBox(height: 20),
        // Spinning Music Disc
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            image: const DecorationImage(
              image: AssetImage('assets/icons/channels4_profile.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withOpacity(0.3),
            ),
            child: const Icon(
              Icons.music_note,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  String _formatNumber(dynamic number) {
    if (number == null) return '0';
    if (number is String) return number;
    final num = number as int;
    if (num >= 1000000) {
      return '${(num / 1000000).toStringAsFixed(1)}M';
    } else if (num >= 1000) {
      return '${(num / 1000).toStringAsFixed(1)}K';
    }
    return num.toString();
  }

  Widget _buildTikTokActionButton(
    IconData icon,
    String label, {
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.translucent, // Allow scroll to pass through
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // TikTok style - no background circle, just the icon
          Container(
            padding: const EdgeInsets.all(8), // Larger hit area
            child: Icon(
              icon,
              color: color,
              size: 35,
            ),
          ),
          if (label.isNotEmpty) ...[
            const SizedBox(height: 2),
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
    final description = currentReel['description'] as String? ?? '';
    final views = currentReel['views'] as String? ?? '0 views';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Channel info - TikTok Style (@username)
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '@leonardobutindi',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.verified,
                    color: Colors.blue,
                    size: 14,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Title with hashtags - TikTok Style
        GestureDetector(
          onTap: () {
            // 🔥 Tap to expand description
            _showFullDescription(title, description);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              if (description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 4),
              Text(
                'more',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Music/Marquee - TikTok Style with animation
        Row(
          children: [
            const Icon(
              Icons.music_note,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                'Original Sound - Leonardo Butindi 🔥',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showFullDescription(String title, String description) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (description.isNotEmpty)
              Text(
                description,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            const SizedBox(height: 20),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _shareVideo(),
                    icon: const Icon(Icons.share, color: Colors.white),
                    label: const Text(
                      'Share',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

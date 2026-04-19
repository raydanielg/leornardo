import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../services/youtube_api_service.dart';
import '../player/player_screen.dart';

/// 📋 PLAYLIST DETAIL SCREEN - Show Videos in Playlist! 🔥
class PlaylistDetailScreen extends StatefulWidget {
  final String playlistId;
  final String playlistTitle;
  final String? thumbnailUrl;
  final int videoCount;

  const PlaylistDetailScreen({
    super.key,
    required this.playlistId,
    required this.playlistTitle,
    this.thumbnailUrl,
    required this.videoCount,
  });

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  List<Map<String, dynamic>> _videos = [];
  bool _isLoading = true;
  bool _isPlayingAll = false;
  int _currentPlayingIndex = -1;

  @override
  void initState() {
    super.initState();
    _loadPlaylistVideos();
  }

  Future<void> _loadPlaylistVideos() async {
    try {
      final videos = await YouTubeApiService.fetchPlaylistVideos(
        widget.playlistId,
        maxResults: 50,
      );
      if (mounted) {
        setState(() {
          _videos = videos;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error loading playlist videos: $e');
      setState(() => _isLoading = false);
    }
  }

  void _playVideo(int index) {
    if (index < 0 || index >= _videos.length) return;

    final video = _videos[index];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlayerScreen(
          videoId: video['videoId']?.toString() ?? '',
          title: video['title']?.toString() ?? '',
        ),
      ),
    );

    setState(() {
      _currentPlayingIndex = index;
    });
  }

  void _playAll() {
    if (_videos.isEmpty) return;
    setState(() {
      _isPlayingAll = true;
      _currentPlayingIndex = 0;
    });
    _playVideo(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // 🔥 App Bar with Playlist Info
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.background,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Thumbnail Background
                  if (widget.thumbnailUrl != null && widget.thumbnailUrl!.isNotEmpty)
                    Image.network(
                      widget.thumbnailUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.surface,
                          child: const Icon(
                            Icons.playlist_play,
                            color: AppColors.onSurface,
                            size: 64,
                          ),
                        );
                      },
                    )
                  else
                    Container(
                      color: AppColors.surface,
                      child: const Icon(
                        Icons.playlist_play,
                        color: AppColors.primary,
                        size: 64,
                      ),
                    ),
                  // Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppColors.background.withOpacity(0.9),
                        ],
                        stops: const [0.5, 1.0],
                      ),
                    ),
                  ),
                  // Title at bottom
                  Positioned(
                    bottom: 60,
                    left: 16,
                    right: 16,
                    child: Text(
                      widget.playlistTitle,
                      style: const TextStyle(
                        color: AppColors.onBackground,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Video Count
                  Positioned(
                    bottom: 35,
                    left: 16,
                    child: Text(
                      '${widget.videoCount} videos',
                      style: TextStyle(
                        color: AppColors.onSurface,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),

          // 🔥 Play All Button
          if (!_isLoading && _videos.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Play All Button
                    Expanded(
                      flex: 3,
                      child: GestureDetector(
                        onTap: _playAll,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Play All',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Shuffle Button
                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.shuffle,
                                color: AppColors.onBackground,
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Shuffle',
                                style: TextStyle(
                                  color: AppColors.onBackground,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ⏳ Loading
          if (_isLoading)
            const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),

          // 📹 Videos List
          if (!_isLoading)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final video = _videos[index];
                  return _buildVideoCard(video, index);
                },
                childCount: _videos.length,
              ),
            ),

          // Empty State
          if (!_isLoading && _videos.isEmpty)
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(
                        Icons.video_library_outlined,
                        size: 64,
                        color: AppColors.onSurface.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No videos in this playlist',
                        style: TextStyle(
                          color: AppColors.onBackground,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVideoCard(Map<String, dynamic> video, int index) {
    final title = video['title']?.toString() ?? 'No Title';
    final thumbnail = video['thumbnail']?.toString() ?? '';
    final views = video['views']?.toString() ?? '0 views';
    final duration = video['duration']?.toString() ?? '0:00';
    final isPlaying = index == _currentPlayingIndex;

    return GestureDetector(
      onTap: () => _playVideo(index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isPlaying
              ? AppColors.primary.withOpacity(0.15)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: isPlaying
              ? Border.all(color: AppColors.primary.withOpacity(0.5))
              : null,
        ),
        child: Row(
          children: [
            // Index Number or Playing Indicator
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isPlaying
                    ? AppColors.primary
                    : AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isPlaying
                    ? const Icon(
                        Icons.volume_up,
                        color: Colors.white,
                        size: 16,
                      )
                    : Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: isPlaying ? Colors.white : AppColors.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            // Thumbnail
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 120,
                    height: 68,
                    child: Image.network(
                      thumbnail,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.surface,
                          child: const Icon(
                            Icons.video_library,
                            color: AppColors.onSurface,
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
                    style: TextStyle(
                      color: isPlaying
                          ? AppColors.primary
                          : AppColors.onBackground,
                      fontSize: 14,
                      fontWeight: isPlaying ? FontWeight.w600 : FontWeight.w500,
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
    );
  }
}

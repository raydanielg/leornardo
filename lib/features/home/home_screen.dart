import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/video_card.dart';
import '../../data/youtube_data.dart';
import '../../services/youtube_api_service.dart';
import '../player/player_screen.dart';
import '../player/reels_player.dart';
import '../channel/channel_webview_screen.dart';
import 'home_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeController _controller = HomeController();
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const _HomeContent(),
    const _ChannelContent(),
    const _PlaylistsContent(),
    const _MoviesContent(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: AppStrings.home,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: AppStrings.channel,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.playlist_play),
            label: AppStrings.playlists,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.movie),
            label: AppStrings.movies,
          ),
        ],
      ),
    );
  }
}

class _HomeContent extends StatefulWidget {
  const _HomeContent();

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  String _selectedPlaylist = 'all';
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _useRealData = false;
  List<Map<String, dynamic>> _videos = [];
  final HomeController _controller = HomeController();
  final ScrollController _scrollController = ScrollController();

  // 🎬 REELS STATE
  List<Map<String, dynamic>> _reels = [];
  bool _isLoadingReels = true;

  @override
  void initState() {
    super.initState();
    // Load first 20 videos - FAST! ⚡
    _loadFirstPage();
    // Load reels
    _loadReels();
    // Add scroll listener for lazy loading
    _scrollController.addListener(_onScroll);
  }

  /// 🎬 Load Reels (Shorts)
  Future<void> _loadReels() async {
    try {
      final reels = await YouTubeApiService.fetchReels(maxResults: 15);
      if (mounted) {
        setState(() {
          _reels = reels;
          _isLoadingReels = false;
        });
      }
    } catch (e) {
      print('❌ Error loading reels: $e');
      setState(() => _isLoadingReels = false);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Handle scroll for lazy loading
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Near bottom, load more!
      _loadMoreVideos();
    }
  }

  /// Load first 20 videos - FAST START!
  Future<void> _loadFirstPage() async {
    setState(() => _isLoading = true);

    try {
      final videos = await _controller.fetchFirstPage();
      if (videos.isNotEmpty) {
        setState(() {
          _videos = videos;
          _useRealData = true;
        });
      } else {
        // Fallback to mock data
        _loadMockData();
      }
    } catch (e) {
      print('Error loading first page: $e');
      _loadMockData();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Load more videos when scrolling - LAZY LOADING!
  Future<void> _loadMoreVideos() async {
    if (_isLoadingMore || !_controller.hasMoreVideos) return;

    setState(() => _isLoadingMore = true);

    try {
      final moreVideos = await _controller.loadMoreVideos();
      if (moreVideos.isNotEmpty) {
        setState(() {
          _videos.addAll(moreVideos);
        });
      }
    } catch (e) {
      print('Error loading more videos: $e');
    } finally {
      setState(() => _isLoadingMore = false);
    }
  }

  /// Fallback to mock data
  void _loadMockData() {
    setState(() {
      _videos = YoutubeData.getTrendingVideos()
          .map((v) => v as Map<String, dynamic>)
          .toList();
      _useRealData = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final videos = _videos;

    return SafeArea(
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // 🔥 App Bar with Search
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text(
                    AppStrings.appName,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.search, color: AppColors.onBackground),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
          // 🎬 REELS SECTION - YouTube Shorts Style! 🔥
          if (!_isLoadingReels && _reels.isNotEmpty)
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Reels Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.play_circle_fill,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Reels',
                          style: TextStyle(
                            color: AppColors.onBackground,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            // Open all reels
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReelsPlayer(
                                  reels: _reels,
                                  initialIndex: 0,
                                ),
                              ),
                            );
                          },
                          child: Text(
                            'See All',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Horizontal Reels List - POA!
                  SizedBox(
                    height: 240,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: _reels.length,
                      itemBuilder: (context, index) {
                        final reel = _reels[index];
                        return _buildReelCard(reel, index);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            )
          else if (_isLoadingReels)
            const SliverToBoxAdapter(
              child: SizedBox(
                height: 240,
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          // ⏳ SKELETON LOADING - POA & VIZURI! 💀✨
          _isLoading
              ? SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => const VideoCardSkeleton(),
                    childCount: 5, // Show 5 skeleton cards
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final video = videos[index];
                      return VideoCard(
                        thumbnailUrl: video['thumbnail']?.toString() ?? '',
                        title: video['title']?.toString() ?? 'No Title',
                        channelName: video['channel']?.toString() ?? 'Unknown',
                        viewCount: video['views']?.toString() ?? '0 views',
                        duration: video['duration']?.toString() ?? '0:00',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PlayerScreen(
                                videoId: video['videoId']?.toString() ?? '',
                                title: video['title']?.toString() ?? '',
                              ),
                            ),
                          );
                        },
                      );
                    },
                    childCount: videos.length,
                  ),
                ),
          // 🔄 Loading More Indicator
          if (_isLoadingMore)
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 2,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Loading more...',
                        style: TextStyle(
                          color: AppColors.onSurface,
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
    );
  }

  /// 🎬 BUILD REEL CARD - POA!
  Widget _buildReelCard(Map<String, dynamic> reel, int index) {
    final thumbnail = reel['thumbnail'] as String? ?? '';
    final title = reel['title'] as String? ?? 'Reel';
    final views = reel['views'] as String? ?? '0 views';

    return GestureDetector(
      onTap: () {
        // Open Reels Player
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReelsPlayer(
              reels: _reels,
              initialIndex: index,
            ),
          ),
        );
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Thumbnail
              Image.network(
                thumbnail,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.surface,
                    child: const Icon(
                      Icons.play_circle_outline,
                      color: AppColors.primary,
                      size: 40,
                    ),
                  );
                },
              ),
              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                    stops: const [0.6, 1.0],
                  ),
                ),
              ),
              // Play icon
              Center(
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              // Bottom info
              Positioned(
                bottom: 8,
                left: 8,
                right: 8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      views,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              // Shorts badge
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'SHORTS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChannelContent extends StatefulWidget {
  const _ChannelContent();

  @override
  State<_ChannelContent> createState() => _ChannelContentState();
}

class _ChannelContentState extends State<_ChannelContent> {
  Map<String, dynamic>? _channelInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChannelInfo();
  }

  Future<void> _loadChannelInfo() async {
    try {
      final info = await YouTubeApiService.fetchChannelInfo();
      if (info != null && mounted) {
        setState(() {
          _channelInfo = info;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error loading channel info: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final channelInfo = _channelInfo;
    final avatarUrl = channelInfo?['thumbnail'] as String?;
    final subscriberCount = channelInfo?['subscriberCount'] as String? ?? AppStrings.channelSubscribers;
    final videoCount = channelInfo?['videoCount'] as String? ?? '500+';

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Channel Header with REAL Avatar
                  Row(
                    children: [
                      // 🔥 REAL Avatar - POA & CLEAR!
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: _isLoading
                              ? Container(
                                  color: AppColors.surface,
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      color: AppColors.primary,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                              : avatarUrl != null
                                  ? Image.network(
                                      avatarUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          color: AppColors.primary,
                                          child: const Center(
                                            child: Text(
                                              'LB',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
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
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              AppStrings.channelName,
                              style: TextStyle(
                                color: AppColors.onBackground,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppStrings.channelHandle,
                              style: TextStyle(
                                color: AppColors.onSurface,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '$subscriberCount subscribers • $videoCount videos',
                              style: TextStyle(
                                color: AppColors.onSurface,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 🔥 WATCH ON YOUTUBE - WebView Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ChannelWebViewScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 8,
                        shadowColor: AppColors.primary.withOpacity(0.5),
                      ),
                      icon: const Icon(Icons.play_circle_fill, size: 24),
                      label: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'WATCH ALL VIDEOS',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.open_in_new, size: 18),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Subscribe Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        // Open YouTube channel subscribe
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ChannelWebViewScreen(),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary, width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'SUBSCRIBE ON YOUTUBE',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Channel Link
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.link,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            AppStrings.channelUrl,
                            style: TextStyle(
                              color: AppColors.onBackground,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.open_in_new,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ChannelWebViewScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
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

class _PlaylistsContent extends StatelessWidget {
  const _PlaylistsContent();

  @override
  Widget build(BuildContext context) {
    final playlists = YoutubeData.playlists;
    final channelInfo = YoutubeData.getChannelInfo();

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text(
                    'Playlists',
                    style: TextStyle(
                      color: AppColors.onBackground,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${channelInfo['videos']} videos',
                      style: TextStyle(
                        color: AppColors.onSurface,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Playlists Grid
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.1,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final playlist = playlists[index];
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(playlist['color']),
                          Color(playlist['color']).withOpacity(0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Color(playlist['color']).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          // TODO: Open playlist
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Playlist Icon - First Letter
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    playlist['title'][0].toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              // Title & Count
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    playlist['title'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${_getVideoCount(playlist['id'])} videos',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
                childCount: playlists.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _getVideoCount(String playlistId) {
    switch (playlistId) {
      case 'all':
        return 156;
      case 'trending':
        return 24;
      case 'music':
        return 45;
      case 'vlogs':
        return 32;
      case 'tutorials':
        return 28;
      case 'entertainment':
        return 67;
      case 'live':
        return 12;
      default:
        return 0;
    }
  }
}

class _MoviesContent extends StatelessWidget {
  const _MoviesContent();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Movies',
        style: TextStyle(color: AppColors.onBackground),
      ),
    );
  }
}

/// 💀 SKELETON LOADING CARD - POA & VIZURI! ✨
class VideoCardSkeleton extends StatefulWidget {
  const VideoCardSkeleton({super.key});

  @override
  State<VideoCardSkeleton> createState() => _VideoCardSkeletonState();
}

class _VideoCardSkeletonState extends State<VideoCardSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Skeleton Thumbnail
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.grey.shade800.withOpacity(_animation.value),
                          Colors.grey.shade700.withOpacity(_animation.value + 0.1),
                          Colors.grey.shade800.withOpacity(_animation.value),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.video_library_outlined,
                        color: Colors.grey.shade600.withOpacity(0.5),
                        size: 48,
                      ),
                    ),
                  ),
                ),
              ),
              // Skeleton Info
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title skeleton
                    Container(
                      width: double.infinity,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade800.withOpacity(_animation.value),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Second line skeleton
                    Container(
                      width: MediaQuery.of(context).size.width * 0.6,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade800.withOpacity(_animation.value),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Channel & views skeleton
                    Row(
                      children: [
                        // Channel avatar skeleton
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.shade800.withOpacity(_animation.value),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Channel name skeleton
                        Container(
                          width: 100,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade800.withOpacity(_animation.value),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Dot
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Views skeleton
                        Container(
                          width: 60,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade800.withOpacity(_animation.value),
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
      },
    );
  }
}

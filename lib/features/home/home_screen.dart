import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/video_card.dart';
import '../../data/youtube_data.dart';
import '../../services/youtube_api_service.dart';
import '../player/player_screen.dart';
import '../player/reels_player.dart';
import '../channel/channel_webview_screen.dart';
import '../community/community_screen.dart';
import '../playlists/playlists_screen.dart';
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
    const _ReelsContent(),
    const _PlaylistsContent(),
    const _CommunityContent(),
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
            icon: Icon(Icons.play_circle_outline),
            label: 'Reels',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.playlist_play),
            label: AppStrings.playlists,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            label: 'Community',
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

  @override
  void initState() {
    super.initState();
    // Load first 20 videos - FAST! ⚡
    _loadFirstPage();
    // Add scroll listener for lazy loading
    _scrollController.addListener(_onScroll);
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
}

/// 🎬 REELS CONTENT - AUTO PLAY TIKTOK STYLE! 🔥
class _ReelsContent extends StatefulWidget {
  const _ReelsContent();

  @override
  State<_ReelsContent> createState() => _ReelsContentState();
}

class _ReelsContentState extends State<_ReelsContent> {
  List<Map<String, dynamic>> _reels = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReels();
  }

  Future<void> _loadReels() async {
    try {
      final reels = await YouTubeApiService.fetchReels(maxResults: 50);
      if (mounted) {
        setState(() {
          _reels = reels;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error loading reels: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ⏳ Loading state
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: AppColors.primary,
              ),
              SizedBox(height: 16),
              Text(
                'Loading Reels...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ❌ No reels found
    if (_reels.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {},
          ),
          title: const Text(
            'Reels',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.video_library_outlined,
                size: 64,
                color: Colors.white.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              const Text(
                'No reels found',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Short videos will appear here',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 🔥 AUTO PLAY - Direct to ReelsPlayer!
    return ReelsPlayer(
      reels: _reels,
      initialIndex: 0,
    );
  }
}

/// 📋 PLAYLISTS CONTENT - REAL DATA FROM YOUTUBE! 🔥
class _PlaylistsContent extends StatelessWidget {
  const _PlaylistsContent();

  @override
  Widget build(BuildContext context) {
    return const PlaylistsScreen();
  }
}

class _CommunityContent extends StatelessWidget {
  const _CommunityContent();

  @override
  Widget build(BuildContext context) {
    return const CommunityScreen();
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

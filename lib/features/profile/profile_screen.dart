import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../services/youtube_api_service.dart';
import '../player/player_screen.dart';
import 'subscribe_webview_screen.dart';

/// 👤 PROFILE SCREEN - Leonardo Butindi Channel! 🔥
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _channelInfo;
  List<Map<String, dynamic>> _videos = [];
  bool _isLoadingChannel = true;
  bool _isLoadingVideos = true;
  int _selectedTab = 0; // 0 = Videos, 1 = About

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    // 🔥 Load channel info FIRST (fast)
    _loadChannelInfo();
    
    // 🔥 Then load videos (can take longer)
    _loadVideos();
  }

  Future<void> _loadChannelInfo() async {
    try {
      final channelInfo = await YouTubeApiService.fetchChannelInfo();
      if (mounted) {
        setState(() {
          _channelInfo = channelInfo;
          _isLoadingChannel = false;
        });
      }
    } catch (e) {
      print('❌ Error loading channel info: $e');
      setState(() => _isLoadingChannel = false);
    }
  }

  Future<void> _loadVideos() async {
    try {
      final videos = await YouTubeApiService.fetchChannelVideos();
      if (mounted) {
        setState(() {
          _videos = videos;
          _isLoadingVideos = false;
        });
      }
    } catch (e) {
      print('❌ Error loading videos: $e');
      setState(() => _isLoadingVideos = false);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // 🔥 Banner & Profile Header - shows immediately with skeleton if loading
          SliverToBoxAdapter(
            child: _isLoadingChannel 
                ? _buildHeaderSkeleton() 
                : _buildHeader(),
          ),

          // 🔥 Stats Row
          SliverToBoxAdapter(
            child: _isLoadingChannel 
                ? _buildStatsSkeleton() 
                : _buildStats(),
          ),

          // 🔥 Action Buttons
          SliverToBoxAdapter(
            child: _isLoadingChannel 
                ? _buildActionButtonsSkeleton() 
                : _buildActionButtons(),
          ),

          // 🔥 Tabs (Videos / About)
          SliverToBoxAdapter(
            child: _buildTabs(),
          ),

          // 🔥 Content based on selected tab
          _selectedTab == 0
              ? _isLoadingVideos 
                  ? _buildVideosGridSkeleton() 
                  : _buildVideosGrid()
              : _buildAboutSection(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final bannerUrl = _channelInfo?['bannerUrl'] as String?;
    final thumbnailUrl = _channelInfo?['thumbnail'] as String?;
    final title = _channelInfo?['title'] as String? ?? 'Leonardo Butindi';
    final handle = _channelInfo?['customUrl'] as String? ?? '@leonardobutindi';

    return Column(
      children: [
        // 🔥 Banner Image
        Stack(
          children: [
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surface,
                image: bannerUrl != null && bannerUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(bannerUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: bannerUrl == null || bannerUrl.isEmpty
                  ? Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.8),
                            AppColors.accent.withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    )
                  : null,
            ),
            // Dark overlay for better visibility
            if (bannerUrl != null && bannerUrl.isNotEmpty)
              Container(
                height: 120,
                width: double.infinity,
                color: Colors.black.withOpacity(0.2),
              ),
          ],
        ),

        // 🔥 Profile Info
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Picture
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: thumbnailUrl != null && thumbnailUrl.isNotEmpty
                      ? Image.network(
                          thumbnailUrl,
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

              // Channel Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              color: AppColors.onBackground,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.verified,
                          color: Colors.blue,
                          size: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      handle,
                      style: TextStyle(
                        color: AppColors.onSurface,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStats() {
    final subscribers = _channelInfo?['subscriberCount'] as String? ?? '0';
    final videoCount = _channelInfo?['videoCount'] as String? ?? '0';
    final viewCount = _channelInfo?['viewCount'] as String? ?? '0';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(_formatNumber(subscribers), 'Subscribers'),
          _buildStatItem(_formatNumber(videoCount), 'Videos'),
          _buildStatItem(_formatNumber(viewCount), 'Views'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.onBackground,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: AppColors.onSurface,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    final channelUrl = 'https://youtube.com/${_channelInfo?['customUrl'] ?? '@leonardobutindi'}';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // 🔴 Subscribe Button - Opens WebView Inside App!
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () {
                // Open Subscribe WebView inside the app
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SubscribeWebViewScreen(
                      channelUrl: channelUrl,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.notifications_active, size: 18),
              label: const Text(
                'Subscribe',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // 🔗 Share Button - Shares channel
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                Share.share(
                  '🎬 Check out Leonardo Butindi on YouTube!\n\n'
                  '$channelUrl\n\n'
                  'Subscribe for amazing content! 🔥',
                  subject: 'Leonardo Butindi YouTube Channel',
                );
              },
              icon: const Icon(Icons.share, size: 18),
              label: const Text('Share'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.onBackground,
                side: const BorderSide(color: AppColors.surface),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildTab('Videos', 0),
          ),
          Expanded(
            child: _buildTab('About', 1),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildVideosGrid() {
    return SliverPadding(
      padding: const EdgeInsets.all(8),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 16 / 12,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final video = _videos[index];
            return _buildVideoCard(video);
          },
          childCount: _videos.length,
        ),
      ),
    );
  }

  Widget _buildVideoCard(Map<String, dynamic> video) {
    final thumbnail = video['thumbnail'] as String? ?? '';
    final title = video['title'] as String? ?? 'Video';
    final views = video['views'] as String? ?? '0 views';
    final videoId = video['videoId'] as String? ?? '';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlayerScreen(
              videoId: videoId,
              title: title,
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    thumbnail,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.surface,
                        child: const Icon(
                          Icons.play_circle_outline,
                          color: AppColors.primary,
                        ),
                      );
                    },
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
                        video['duration']?.toString() ?? '0:00',
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
            ),
          ),
          const SizedBox(height: 4),
          // Title
          Text(
            title,
            style: const TextStyle(
              color: AppColors.onBackground,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          // Views
          Text(
            views,
            style: TextStyle(
              color: AppColors.onSurface,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    final description = _channelInfo?['description'] as String? ??
        'Welcome to Leonardo Butindi channel! 🎬\n\n'
        'This channel features amazing content including:\n'
        '• Entertainment videos\n'
        '• Music and performances\n'
        '• Tutorials and educational content\n'
        '• Live streams and events\n\n'
        'Subscribe to stay updated with the latest videos! 🔥';

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Description',
              style: TextStyle(
                color: AppColors.onBackground,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                color: AppColors.onSurface,
                fontSize: 14,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Links',
              style: TextStyle(
                color: AppColors.onBackground,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildLinkItem(
              Icons.language,
              'YouTube',
              'youtube.com/@leonardobutindi',
              url: 'https://youtube.com/@leonardobutindi',
            ),
            _buildLinkItem(
              Icons.alternate_email,
              'Twitter/X',
              '@leonardobutindi',
            ),
            _buildLinkItem(
              Icons.business,
              'Business',
              'business@leonardo.com',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkItem(IconData icon, String label, String value, {String? url}) {
    return GestureDetector(
      onTap: () async {
        if (url != null) {
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppColors.onSurface,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: AppColors.onSurface,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      color: url != null ? AppColors.primary : AppColors.onBackground,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (url != null)
              Icon(
                Icons.open_in_new,
                color: AppColors.onSurface,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }

  // 🔥 SKELETON LOADING METHODS - POA & VIZURI!

  Widget _buildHeaderSkeleton() {
    return Column(
      children: [
        // Banner skeleton
        Container(
          height: 120,
          width: double.infinity,
          color: AppColors.surface,
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar skeleton
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surface,
                ),
              ),
              const SizedBox(width: 16),
              // Text skeletons
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Container(
                      width: 150,
                      height: 20,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 100,
                      height: 14,
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
        ),
      ],
    );
  }

  Widget _buildStatsSkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(3, (index) {
          return Column(
            children: [
              Container(
                width: 60,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 50,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildActionButtonsSkeleton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideosGridSkeleton() {
    return SliverPadding(
      padding: const EdgeInsets.all(8),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 16 / 12,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail skeleton
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Title skeleton
                Container(
                  width: double.infinity,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                // Views skeleton
                Container(
                  width: 80,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            );
          },
          childCount: 6, // Show 6 skeleton items
        ),
      ),
    );
  }
}

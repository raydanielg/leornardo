import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/video_card.dart';
import '../../data/youtube_data.dart';
import '../player/player_screen.dart';
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

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    final videos = YoutubeData.getTrendingVideos();

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // App Bar
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
                  IconButton(
                    icon: const Icon(Icons.notifications, color: AppColors.onBackground),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
          // Categories
          SliverToBoxAdapter(
            child: SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: YoutubeData.categories.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Chip(
                      label: Text(YoutubeData.categories[index]),
                      backgroundColor: index == 0
                          ? AppColors.primary
                          : AppColors.surface,
                      labelStyle: TextStyle(
                        color: index == 0
                            ? Colors.white
                            : AppColors.onSurface,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          // Trending Section
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                AppStrings.trending,
                style: TextStyle(
                  color: AppColors.onBackground,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          // Videos List
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final video = videos[index];
                return VideoCard(
                  thumbnailUrl: video['thumbnail']!,
                  title: video['title']!,
                  channelName: video['channel']!,
                  viewCount: video['views']!,
                  duration: video['duration']!,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlayerScreen(
                          videoId: video['videoId']!,
                          title: video['title']!,
                        ),
                      ),
                    );
                  },
                );
              },
              childCount: videos.length,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChannelContent extends StatelessWidget {
  const _ChannelContent();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Channel',
        style: TextStyle(color: AppColors.onBackground),
      ),
    );
  }
}

class _PlaylistsContent extends StatelessWidget {
  const _PlaylistsContent();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Playlists',
        style: TextStyle(color: AppColors.onBackground),
      ),
    );
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

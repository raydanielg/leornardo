import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/custom_button.dart';

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
                    // Title
                    Text(
                      widget.title ?? 'Video Title',
                      style: const TextStyle(
                        color: AppColors.onBackground,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Channel Info Row
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.surface,
                          child: const Icon(
                            Icons.person,
                            color: AppColors.onBackground,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'KVZR Channel',
                                style: TextStyle(
                                  color: AppColors.onBackground,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '1.2M subscribers',
                                style: TextStyle(
                                  color: AppColors.onSurface,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        CustomButton(
                          text: AppStrings.subscribe,
                          onPressed: () {},
                          height: 36,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionButton(Icons.thumb_up, '12K'),
                        _buildActionButton(Icons.thumb_down, 'Dislike'),
                        _buildActionButton(Icons.share, 'Share'),
                        _buildActionButton(Icons.download, 'Download'),
                        _buildActionButton(Icons.playlist_add, 'Save'),
                      ],
                    ),
                    const Divider(color: AppColors.surface, height: 32),
                    // Description
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '1.2M views',
                                style: TextStyle(
                                  color: AppColors.onBackground,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.circle,
                                size: 4,
                                color: AppColors.onSurface,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '2 days ago',
                                style: TextStyle(
                                  color: AppColors.onSurface,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Powered by Leonardo App - KVZR\\nWatch more amazing content on our channel!',
                            style: TextStyle(color: AppColors.onSurface),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Comments Preview
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Text(
                            AppStrings.comments,
                            style: TextStyle(
                              color: AppColors.onBackground,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '1.2K',
                            style: TextStyle(
                              color: AppColors.onSurface,
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.chevron_right,
                            color: AppColors.onSurface,
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
}

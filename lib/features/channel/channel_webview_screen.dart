import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';

/// 🔥 YouTube Channel WebView - BEST & SIMPLE OPTION
/// 
/// Haina API, haina errors, inaonyesha videos zote!
/// Channel: @leonardobutindi
class ChannelWebViewScreen extends StatefulWidget {
  const ChannelWebViewScreen({super.key});

  @override
  State<ChannelWebViewScreen> createState() => _ChannelWebViewScreenState();
}

class _ChannelWebViewScreenState extends State<ChannelWebViewScreen> {
  late WebViewController _controller;
  bool _isLoading = true;
  double _progress = 0;

  // 🎯 URLs za Channel - OPTION 1: Handle (Simple)
  static const String _channelUrl = 'https://www.youtube.com/@leonardobutindi/videos';
  static const String _channelHome = 'https://www.youtube.com/@leonardobutindi';
  static const String _channelPlaylists = 'https://www.youtube.com/@leonardobutindi/playlists';
  
  // 🎯 URLs za Channel - OPTION 2: Channel ID (More Reliable)
  // Ikiwa handle haifanyi kazi, tumia Channel ID
  static const String _channelIdUrl = 'https://www.youtube.com/channel/UCF4nv3dU6kcCJ_5JjPWcuvA/videos';
  static const String _channelIdHome = 'https://www.youtube.com/channel/UCF4nv3dU6kcCJ_5JjPWcuvA';
  static const String _channelIdPlaylists = 'https://www.youtube.com/channel/UCF4nv3dU6kcCJ_5JjPWcuvA/playlists';

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              _isLoading = true;
              _progress = 0;
            });
          },
          onProgress: (progress) {
            setState(() => _progress = progress / 100);
          },
          onPageFinished: (url) {
            setState(() => _isLoading = false);
            // Inject CSS to hide YouTube header kwa clean look
            _controller.runJavaScript('''
              document.querySelector('ytm-mobile-topbar-renderer')?.style.display='none';
              document.querySelector('#masthead-container')?.style.display='none';
            ''');
          },
          onNavigationRequest: (request) {
            // Zuia navigation nje ya YouTube
            if (!request.url.contains('youtube.com') && 
                !request.url.contains('google.com')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onWebResourceError: (error) {
            // Log error for debugging
            print('WebView Error: ${error.description} (Code: ${error.errorCode})');
          },
        ),
      )
      ..loadRequest(Uri.parse(_channelUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, Colors.redAccent],
                ),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.accent, width: 2),
              ),
              child: const Center(
                child: Text(
                  'LB',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Leonardo Butindi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '@leonardobutindi',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Refresh
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.onBackground),
            onPressed: () => _controller.reload(),
          ),
          // More options
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.onBackground),
            onSelected: (value) {
              switch (value) {
                case 'home':
                  _controller.loadRequest(Uri.parse(_channelHome));
                  break;
                case 'videos':
                  _controller.loadRequest(Uri.parse(_channelUrl));
                  break;
                case 'playlists':
                  _controller.loadRequest(Uri.parse(_channelPlaylists));
                  break;
                case 'use_channel_id':
                  _controller.loadRequest(Uri.parse(_channelIdUrl));
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'home',
                child: Row(
                  children: [
                    Icon(Icons.home, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text('Channel Home'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'videos',
                child: Row(
                  children: [
                    Icon(Icons.video_library, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text('All Videos'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'playlists',
                child: Row(
                  children: [
                    Icon(Icons.playlist_play, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text('Playlists'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'use_channel_id',
                child: Row(
                  children: [
                    Icon(Icons.swap_horiz, color: AppColors.accent),
                    SizedBox(width: 8),
                    Text('Use Channel ID (Backup)'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          // WebView
          WebViewWidget(controller: _controller),
          
          // Progress Indicator
          if (_isLoading)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                value: _progress > 0 ? _progress : null,
                backgroundColor: AppColors.surface,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 3,
              ),
            ),
          
          // Loading Indicator
          if (_isLoading && _progress == 0)
            Container(
              color: AppColors.background,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Loading Leonardo Butindi...',
                      style: TextStyle(
                        color: AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      // 🔥 Bottom Navigation kwa Quick Access
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(
              color: AppColors.onSurface.withOpacity(0.1),
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavButton(
                  icon: Icons.home,
                  label: 'Home',
                  onTap: () => _controller.loadRequest(Uri.parse(_channelHome)),
                ),
                _buildNavButton(
                  icon: Icons.video_library,
                  label: 'Videos',
                  onTap: () => _controller.loadRequest(Uri.parse(_channelUrl)),
                ),
                _buildNavButton(
                  icon: Icons.playlist_play,
                  label: 'Playlists',
                  onTap: () => _controller.loadRequest(Uri.parse(_channelPlaylists)),
                ),
                _buildNavButton(
                  icon: Icons.arrow_back,
                  label: 'Back',
                  onTap: () async {
                    if (await _controller.canGoBack()) {
                      _controller.goBack();
                    }
                  },
                ),
                _buildNavButton(
                  icon: Icons.arrow_forward,
                  label: 'Forward',
                  onTap: () async {
                    if (await _controller.canGoForward()) {
                      _controller.goForward();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: AppColors.onSurface,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.onSurface,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/constants/app_colors.dart';

/// 🔴 SUBSCRIBE WEBVIEW - Open YouTube Subscribe Page! 🔥
class SubscribeWebViewScreen extends StatefulWidget {
  final String channelUrl;

  const SubscribeWebViewScreen({
    super.key,
    required this.channelUrl,
  });

  @override
  State<SubscribeWebViewScreen> createState() => _SubscribeWebViewScreenState();
}

class _SubscribeWebViewScreenState extends State<SubscribeWebViewScreen> {
  late WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            // Try to auto-click subscribe button if user is logged in
            _autoClickSubscribe();
          },
        ),
      )
      ..loadRequest(Uri.parse('${widget.channelUrl}?sub_confirmation=1'));
  }

  void _autoClickSubscribe() async {
    // Try to find and click subscribe button
    // This may not always work due to YouTube's security
    try {
      await _controller.runJavaScript('''
        // Look for subscribe button
        var subscribeBtn = document.querySelector('button[aria-label*="Subscribe"]') ||
                          document.querySelector('[id*="subscribe"] button') ||
                          document.querySelector('yt-button-shape button');
        if (subscribeBtn && !subscribeBtn.disabled) {
          subscribeBtn.click();
        }
      ''');
    } catch (e) {
      print('Could not auto-click subscribe: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Row(
          children: [
            Icon(
              Icons.youtube_searched_for,
              color: Colors.red,
              size: 24,
            ),
            SizedBox(width: 8),
            Text(
              'Subscribe',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => _controller.reload(),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(
            controller: _controller,
          ),
          if (_isLoading)
            Container(
              color: Colors.black,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: Colors.red,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Loading YouTube...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tap Subscribe button when ready',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border(
            top: BorderSide(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Tap the RED "Subscribe" button above',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, size: 18),
                label: const Text(
                  'Done - Return to App',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

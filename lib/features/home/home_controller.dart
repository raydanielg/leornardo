import '../../data/youtube_data.dart';
import '../../services/youtube_api_service.dart';

class HomeController {
  List<Map<String, String>> get trendingVideos =>
      YoutubeData.getTrendingVideos();

  List<String> get categories => YoutubeData.categories;

  // Pagination state
  String? _nextPageToken;
  bool _hasMoreVideos = true;
  bool _isLoading = false;

  bool get hasMoreVideos => _hasMoreVideos;
  bool get isLoading => _isLoading;
  String? get nextPageToken => _nextPageToken;

  /// Fetch FIRST page of videos (20 videos) - FAST! ⚡
  Future<List<Map<String, dynamic>>> fetchFirstPage() async {
    _isLoading = true;
    _nextPageToken = null;
    _hasMoreVideos = true;

    try {
      final result = await YouTubeApiService.fetchChannelVideosPaginated(
        maxResults: 20,
      );

      final videos = result['videos'] as List<Map<String, dynamic>>;
      _nextPageToken = result['nextPageToken'] as String?;
      _hasMoreVideos = _nextPageToken != null;

      print('✅ First page loaded: ${videos.length} videos');
      return videos;
    } catch (e) {
      print('❌ Error loading first page: $e');
      return [];
    } finally {
      _isLoading = false;
    }
  }

  /// Load MORE videos (next page) - LAZY LOADING! 🚀
  Future<List<Map<String, dynamic>>> loadMoreVideos() async {
    if (_isLoading || !_hasMoreVideos || _nextPageToken == null) {
      return []; // Nothing more to load
    }

    _isLoading = true;

    try {
      final result = await YouTubeApiService.fetchChannelVideosPaginated(
        pageToken: _nextPageToken,
        maxResults: 20,
      );

      final videos = result['videos'] as List<Map<String, dynamic>>;
      _nextPageToken = result['nextPageToken'] as String?;
      _hasMoreVideos = _nextPageToken != null;

      print('✅ Loaded ${videos.length} more videos. Total pages: ${_hasMoreVideos ? "more" : "done"}');
      return videos;
    } catch (e) {
      print('❌ Error loading more videos: $e');
      return [];
    } finally {
      _isLoading = false;
    }
  }

  /// Fetch real trending videos from YouTube API
  Future<List<Map<String, dynamic>>> fetchRealTrendingVideos() async {
    return await YouTubeApiService.fetchTrendingVideos(
      regionCode: 'KE', // Kenya trending
      maxResults: 20,
    );
  }

  /// Fetch ALL videos from Leonardo Butindi channel - NO LIMIT!
  Future<List<Map<String, dynamic>>> fetchChannelVideos() async {
    return await YouTubeApiService.fetchChannelVideos();
  }

  /// Test API connection
  Future<bool> testApiConnection() async {
    return await YouTubeApiService.testApiConnection();
  }

  void refresh() {
    _nextPageToken = null;
    _hasMoreVideos = true;
  }
}

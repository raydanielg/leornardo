import '../../data/youtube_data.dart';
import '../../services/youtube_api_service.dart';

class HomeController {
  List<Map<String, String>> get trendingVideos =>
      YoutubeData.getTrendingVideos();

  List<String> get categories => YoutubeData.categories;

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
    // Refresh data logic
  }

  void loadMore() {
    // Pagination logic
  }
}

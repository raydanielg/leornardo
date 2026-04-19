import '../../data/youtube_data.dart';

class HomeController {
  List<Map<String, String>> get trendingVideos =>
      YoutubeData.getTrendingVideos();

  List<String> get categories => YoutubeData.categories;

  void refresh() {
    // Refresh data logic
  }

  void loadMore() {
    // Pagination logic
  }
}

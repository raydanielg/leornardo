class YoutubeData {
  static const List<String> categories = [
    'All',
    'Trending',
    'Music',
    'Gaming',
    'News',
    'Movies',
    'Sports',
    'Education',
    'Comedy',
  ];

  static List<Map<String, String>> getTrendingVideos() {
    return [
      {
        'videoId': 'dQw4w9WgXcQ',
        'title': 'KVZR Introduction - Powered by Leonardo',
        'channel': 'KVZR Official',
        'views': '2.5M views',
        'duration': '3:45',
        'thumbnail': 'https://img.youtube.com/vi/dQw4w9WgXcQ/0.jpg',
      },
      {
        'videoId': 'abc123',
        'title': 'Flutter Development Tips & Tricks',
        'channel': 'Tech Masters',
        'views': '850K views',
        'duration': '12:30',
        'thumbnail': 'https://img.youtube.com/vi/abc123/0.jpg',
      },
      {
        'videoId': 'xyz789',
        'title': 'Mobile App Design Tutorial',
        'channel': 'Design Pro',
        'views': '1.2M views',
        'duration': '8:15',
        'thumbnail': 'https://img.youtube.com/vi/xyz789/0.jpg',
      },
      {
        'videoId': 'def456',
        'title': 'YouTube Integration with Flutter',
        'channel': 'Flutter Dev',
        'views': '450K views',
        'duration': '15:20',
        'thumbnail': 'https://img.youtube.com/vi/def456/0.jpg',
      },
      {
        'videoId': 'ghi321',
        'title': 'Building Powerful Apps - KVZR Style',
        'channel': 'KVZR Tech',
        'views': '3.1M views',
        'duration': '6:45',
        'thumbnail': 'https://img.youtube.com/vi/ghi321/0.jpg',
      },
      {
        'videoId': 'jkl654',
        'title': 'Dart Programming Best Practices',
        'channel': 'Code Masters',
        'views': '720K views',
        'duration': '10:00',
        'thumbnail': 'https://img.youtube.com/vi/jkl654/0.jpg',
      },
    ];
  }

  static List<Map<String, String>> getChannelVideos(String channelId) {
    return getTrendingVideos();
  }

  static List<Map<String, String>> getSearchResults(String query) {
    return getTrendingVideos()
        .where((video) =>
            video['title']!.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}

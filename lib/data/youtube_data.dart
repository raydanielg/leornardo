// YouTube Data Controller - KVZR POWER
// Channel: @leonardobutindi
class YoutubeData {
  // Playlists as Categories - Clean & Professional
  static const List<Map<String, dynamic>> playlists = [
    {
      'id': 'all',
      'title': 'All',
      'color': 0xFFE53935,
    },
    {
      'id': 'trending',
      'title': 'Trending',
      'color': 0xFFFF5722,
    },
    {
      'id': 'music',
      'title': 'Music',
      'color': 0xFF9C27B0,
    },
    {
      'id': 'vlogs',
      'title': 'Vlogs',
      'color': 0xFF2196F3,
    },
    {
      'id': 'tutorials',
      'title': 'Tutorials',
      'color': 0xFF4CAF50,
    },
    {
      'id': 'entertainment',
      'title': 'Entertainment',
      'color': 0xFFFF9800,
    },
    {
      'id': 'live',
      'title': 'Live',
      'color': 0xFFF44336,
    },
  ];

  /// 📋 Legacy categories (for compatibility)
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

  // Leonardo Butindi Videos Only - Real Content
  static List<Map<String, String>> getTrendingVideos() {
    return [
      {
        'videoId': 'VIDEO_ID_1',
        'title': 'Leonardo Butindi - My Journey Begins',
        'channel': 'Leonardo Butindi',
        'views': '2.5M views',
        'duration': '15:32',
        'thumbnail': 'https://img.youtube.com/vi/VIDEO_ID_1/0.jpg',
      },
      {
        'videoId': 'VIDEO_ID_2',
        'title': 'Leonardo Butindi - Day in My Life',
        'channel': 'Leonardo Butindi',
        'views': '1.8M views',
        'duration': '12:45',
        'thumbnail': 'https://img.youtube.com/vi/VIDEO_ID_2/0.jpg',
      },
      {
        'videoId': 'VIDEO_ID_3',
        'title': 'Leonardo Butindi - Music Session',
        'channel': 'Leonardo Butindi',
        'views': '3.2M views',
        'duration': '8:20',
        'thumbnail': 'https://img.youtube.com/vi/VIDEO_ID_3/0.jpg',
      },
      {
        'videoId': 'VIDEO_ID_4',
        'title': 'Leonardo Butindi - Behind the Scenes',
        'channel': 'Leonardo Butindi',
        'views': '950K views',
        'duration': '18:15',
        'thumbnail': 'https://img.youtube.com/vi/VIDEO_ID_4/0.jpg',
      },
      {
        'videoId': 'VIDEO_ID_5',
        'title': 'Leonardo Butindi - Live Performance',
        'channel': 'Leonardo Butindi',
        'views': '4.1M views',
        'duration': '45:00',
        'thumbnail': 'https://img.youtube.com/vi/VIDEO_ID_5/0.jpg',
      },
      {
        'videoId': 'VIDEO_ID_6',
        'title': 'Leonardo Butindi - Q&A Session',
        'channel': 'Leonardo Butindi',
        'views': '1.5M views',
        'duration': '22:10',
        'thumbnail': 'https://img.youtube.com/vi/VIDEO_ID_6/0.jpg',
      },
      {
        'videoId': 'VIDEO_ID_7',
        'title': 'Leonardo Butindi - Travel Vlog',
        'channel': 'Leonardo Butindi',
        'views': '2.8M views',
        'duration': '14:55',
        'thumbnail': 'https://img.youtube.com/vi/VIDEO_ID_7/0.jpg',
      },
      {
        'videoId': 'VIDEO_ID_8',
        'title': 'Leonardo Butindi - New Release',
        'channel': 'Leonardo Butindi',
        'views': '5.5M views',
        'duration': '4:30',
        'thumbnail': 'https://img.youtube.com/vi/VIDEO_ID_8/0.jpg',
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

  /// 🎬 Get videos by playlist/category
  static List<Map<String, String>> getVideosByPlaylist(String playlistId) {
    final allVideos = getTrendingVideos();
    
    switch (playlistId) {
      case 'trending':
        return allVideos.where((v) => 
          v['channel'] == 'Leonardo Butindi' || 
          v['views']!.contains('M')
        ).toList();
      case 'music':
        return allVideos.where((v) => 
          v['title']!.toLowerCase().contains('music') ||
          v['title']!.toLowerCase().contains('song')
        ).toList();
      case 'vlogs':
        return allVideos.where((v) => 
          v['title']!.toLowerCase().contains('vlog') ||
          v['title']!.toLowerCase().contains('day in')
        ).toList();
      case 'tutorials':
        return allVideos.where((v) => 
          v['title']!.toLowerCase().contains('tutorial') ||
          v['title']!.toLowerCase().contains('how to')
        ).toList();
      default:
        return allVideos;
    }
  }

  // Channel Info for @leonardobutindi
  static Map<String, dynamic> getChannelInfo() {
    return {
      'name': 'Leonardo Butindi',
      'handle': '@leonardobutindi',
      'subscribers': '1.2M',
      'videos': '156',
      'views': '45M',
      'description': 'Official Leonardo Butindi channel. Powered by KVZR.',
      'thumbnail': 'assets/icons/channels4_profile.jpg',
    };
  }
}

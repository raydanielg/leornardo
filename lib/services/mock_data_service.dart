import '../data/youtube_data.dart';

/// 🔥 Mock Data Service - Fallback wakati API haipo
/// 
/// Inatumia data za @leonardobutindi kwa mfano
class MockDataService {
  
  /// 📋 Get Mock Playlists (Categories)
  static List<Map<String, dynamic>> getMockPlaylists() {
    return [
      {
        'playlistId': 'all',
        'title': 'All Videos',
        'thumbnail': 'https://img.youtube.com/vi/dQw4w9WgXcQ/0.jpg',
        'itemCount': 156,
      },
      {
        'playlistId': 'trending',
        'title': '🔥 Trending',
        'thumbnail': 'https://img.youtube.com/vi/ghi321/0.jpg',
        'itemCount': 24,
      },
      {
        'playlistId': 'music',
        'title': '🎵 Music',
        'thumbnail': 'https://img.youtube.com/vi/music1/0.jpg',
        'itemCount': 45,
      },
      {
        'playlistId': 'vlogs',
        'title': '📹 Vlogs',
        'thumbnail': 'https://img.youtube.com/vi/vlog1/0.jpg',
        'itemCount': 32,
      },
      {
        'playlistId': 'tutorials',
        'title': '📚 Tutorials',
        'thumbnail': 'https://img.youtube.com/vi/tut1/0.jpg',
        'itemCount': 28,
      },
      {
        'playlistId': 'entertainment',
        'title': '🎬 Entertainment',
        'thumbnail': 'https://img.youtube.com/vi/ent1/0.jpg',
        'itemCount': 67,
      },
      {
        'playlistId': 'live',
        'title': '🔴 Live Streams',
        'thumbnail': 'https://img.youtube.com/vi/live1/0.jpg',
        'itemCount': 12,
      },
    ];
  }

  /// 🎬 Get Mock Videos za Playlist
  static List<Map<String, dynamic>> getMockVideosForPlaylist(String playlistId) {
    final allVideos = YoutubeData.getTrendingVideos();
    
    // Filter videos based on playlist
    switch (playlistId) {
      case 'trending':
        return allVideos.where((v) => 
          v['title']!.contains('Leonardo Butindi') || 
          v['views']!.contains('M')
        ).toList();
      case 'music':
        return allVideos.where((v) => 
          v['title']!.toLowerCase().contains('music') ||
          v['title']!.toLowerCase().contains('song')
        ).toList();
      default:
        return allVideos;
    }
  }

  /// 👤 Get Mock Channel Info
  static Map<String, dynamic> getMockChannelInfo() {
    return {
      'title': 'Leonardo Butindi',
      'description': 'Official channel for Leonardo Butindi. Powered by Leonardo App - KVZR',
      'thumbnail': 'assets/icons/channels4_profile.jpg',
      'subscriberCount': '1250000',
      'videoCount': '156',
      'viewCount': '45000000',
    };
  }
}

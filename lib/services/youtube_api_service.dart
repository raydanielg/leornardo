import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// 🔥 YouTube Data API Service - KVZR POWER 🔥
/// 
/// Channel: @leonardobutindi
/// Powered by Leonardo App
class YouTubeApiService {
  // ✅ API Key for Leonardo App
  static const String _apiKey = 'AIzaSyBDzojnvualKf8Xz875ZIfX6gFGLzdz9cU';
  static const String _baseUrl = 'https://www.googleapis.com/youtube/v3';
  
  // Channel ID for @leonardobutindi
  static const String _channelId = 'UCF4nv3dU6kcCJ_5JjPWcuvA'; // Fetched via API
  
  /// � Fetch ALL videos from channel - NO LIMIT! POWER! 💪
  static Future<List<Map<String, dynamic>>> fetchChannelVideos() async {
    List<Map<String, dynamic>> allVideos = [];
    String? nextPageToken;
    int pageCount = 0;
    
    try {
      print('🔥 Fetching ALL videos from Leonardo Butindi channel...');
      
      do {
        // Build URL with pagination
        String url = '$_baseUrl/search?part=snippet&channelId=$_channelId&maxResults=50&order=date&type=video&key=$_apiKey';
        if (nextPageToken != null) {
          url += '&pageToken=$nextPageToken';
        }
        
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final items = data['items'] as List<dynamic>;
          
          // Convert and add videos
          final pageVideos = items.map((item) {
            final snippet = item['snippet'];
            return {
              'videoId': item['id']['videoId'],
              'title': snippet['title'],
              'channel': snippet['channelTitle'],
              'thumbnail': snippet['thumbnails']['high']?['url'] ?? 
                          snippet['thumbnails']['medium']?['url'] ?? 
                          snippet['thumbnails']['default']?['url'],
              'publishedAt': snippet['publishedAt'],
              'description': snippet['description'],
            };
          }).toList();
          
          allVideos.addAll(pageVideos);
          pageCount++;
          
          print('📄 Page $pageCount: ${pageVideos.length} videos fetched. Total: ${allVideos.length}');
          
          // Get next page token
          nextPageToken = data['nextPageToken'];
          
          // Add small delay to avoid rate limiting
          if (nextPageToken != null) {
            await Future.delayed(const Duration(milliseconds: 100));
          }
          
        } else {
          print('❌ API Error: ${response.statusCode}');
          break;
        }
        
      } while (nextPageToken != null && pageCount < 100); // Safety limit: 100 pages = 5000 videos max
      
      print('✅ TOTAL VIDEOS FETCHED: ${allVideos.length}');
      return allVideos;
      
    } catch (e) {
      print('❌ Error fetching all videos: $e');
      return allVideos; // Return whatever we got
    }
  }

  /// 📋 Fetch playlists za channel
  static Future<List<Map<String, dynamic>>> fetchPlaylists({
    int maxResults = 50,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/playlists?part=snippet&channelId=$_channelId&maxResults=$maxResults&key=$_apiKey',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List<dynamic>;
        
        return items.map((item) {
          final snippet = item['snippet'];
          return {
            'playlistId': item['id'],
            'title': snippet['title'],
            'thumbnail': snippet['thumbnails']['medium']?['url'] ?? 
                        snippet['thumbnails']['default']?['url'],
            'itemCount': item['contentDetails']?['itemCount'] ?? 0,
          };
        }).toList();
      } else {
        throw Exception('Failed to fetch playlists: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching playlists: $e');
      return [];
    }
  }

  /// 🎬 Fetch videos kutoka specific playlist
  static Future<List<Map<String, dynamic>>> fetchPlaylistVideos(
    String playlistId, {
    int maxResults = 20,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/playlistItems?part=snippet&playlistId=$playlistId&maxResults=$maxResults&key=$_apiKey',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List<dynamic>;
        
        return items.map((item) {
          final snippet = item['snippet'];
          return {
            'videoId': snippet['resourceId']['videoId'],
            'title': snippet['title'],
            'channel': snippet['channelTitle'],
            'thumbnail': snippet['thumbnails']['high']?['url'] ?? 
                        snippet['thumbnails']['medium']?['url'] ?? 
                        snippet['thumbnails']['default']?['url'],
            'position': snippet['position'],
          };
        }).toList();
      } else {
        throw Exception('Failed to fetch playlist videos: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching playlist videos: $e');
      return [];
    }
  }

  /// 👤 Get Channel Info
  static Future<Map<String, dynamic>?> fetchChannelInfo() async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/channels?part=snippet,statistics&id=$_channelId&key=$_apiKey',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final item = data['items'][0];
        final snippet = item['snippet'];
        final stats = item['statistics'];
        
        return {
          'title': snippet['title'],
          'description': snippet['description'],
          'thumbnail': snippet['thumbnails']['medium']?['url'],
          'subscriberCount': stats['subscriberCount'],
          'videoCount': stats['videoCount'],
          'viewCount': stats['viewCount'],
        };
      }
      return null;
    } catch (e) {
      print('❌ Error fetching channel info: $e');
      return null;
    }
  }

  /// 🔍 Search videos
  static Future<List<Map<String, dynamic>>> searchVideos(
    String query, {
    int maxResults = 20,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/search?part=snippet&channelId=$_channelId&q=$query&maxResults=$maxResults&type=video&key=$_apiKey',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List<dynamic>;
        
        return items.map((item) {
          final snippet = item['snippet'];
          return {
            'videoId': item['id']['videoId'],
            'title': snippet['title'],
            'thumbnail': snippet['thumbnails']['medium']?['url'] ?? 
                        snippet['thumbnails']['default']?['url'],
          };
        }).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('❌ Error searching videos: $e');
      return [];
    }
  }

  /// 🔥 Fetch Trending Videos (Most Popular)
  static Future<List<Map<String, dynamic>>> fetchTrendingVideos({
    String regionCode = 'KE', // Kenya
    int maxResults = 20,
  }) async {
    try {
      // Note: Chart parameter 'mostPopular' gets trending videos
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/videos?part=snippet,statistics,contentDetails&chart=mostPopular&regionCode=$regionCode&maxResults=$maxResults&key=$_apiKey',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List<dynamic>;
        
        return items.map((item) {
          final snippet = item['snippet'];
          final stats = item['statistics'];
          final content = item['contentDetails'];
          
          // Format duration from PT4M13S to 4:13
          String duration = content['duration'] ?? 'PT0M0S';
          duration = _formatDuration(duration);
          
          // Format view count
          String views = stats['viewCount'] ?? '0';
          views = _formatViewCount(views);
          
          return {
            'videoId': item['id'],
            'title': snippet['title'],
            'channel': snippet['channelTitle'],
            'thumbnail': snippet['thumbnails']['high']?['url'] ?? 
                        snippet['thumbnails']['medium']?['url'] ?? 
                        snippet['thumbnails']['default']?['url'],
            'views': '$views views',
            'duration': duration,
            'publishedAt': snippet['publishedAt'],
          };
        }).toList();
      } else {
        throw Exception('Failed to fetch trending: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching trending: $e');
      return [];
    }
  }

  /// 🔥 Fetch Videos with Statistics (Views, Duration)
  static Future<List<Map<String, dynamic>>> fetchVideosWithStats(
    List<String> videoIds, {
    int maxResults = 20,
  }) async {
    try {
      final ids = videoIds.take(maxResults).join(',');
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/videos?part=snippet,statistics,contentDetails&id=$ids&key=$_apiKey',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List<dynamic>;
        
        return items.map((item) {
          final snippet = item['snippet'];
          final stats = item['statistics'];
          final content = item['contentDetails'];
          
          String duration = _formatDuration(content['duration'] ?? 'PT0M0S');
          String views = _formatViewCount(stats['viewCount'] ?? '0');
          
          return {
            'videoId': item['id'],
            'title': snippet['title'],
            'channel': snippet['channelTitle'],
            'thumbnail': snippet['thumbnails']['high']?['url'] ?? 
                        snippet['thumbnails']['medium']?['url'] ?? 
                        snippet['thumbnails']['default']?['url'],
            'views': '$views views',
            'duration': duration,
          };
        }).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('❌ Error fetching video stats: $e');
      return [];
    }
  }

  // Helper: Format ISO 8601 duration to readable format
  static String _formatDuration(String isoDuration) {
    // PT4M13S -> 4:13
    // PT1H2M3S -> 1:02:03
    final regex = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?');
    final match = regex.firstMatch(isoDuration);
    
    if (match == null) return '0:00';
    
    final hours = int.tryParse(match.group(1) ?? '0') ?? 0;
    final minutes = int.tryParse(match.group(2) ?? '0') ?? 0;
    final seconds = int.tryParse(match.group(3) ?? '0') ?? 0;
    
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  // Helper: Format view count
  static String _formatViewCount(String count) {
    final num = int.tryParse(count) ?? 0;
    if (num >= 1000000) {
      return '${(num / 1000000).toStringAsFixed(1)}M';
    } else if (num >= 1000) {
      return '${(num / 1000).toStringAsFixed(1)}K';
    }
    return count;
  }

  /// ✅ Test API Key and Channel ID
  static Future<bool> testApiConnection() async {
    try {
      print('Testing YouTube API connection...');
      print('API Key: ${_apiKey.substring(0, 10)}...');
      print('Channel ID: $_channelId');
      
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/channels?part=snippet,statistics&id=$_channelId&key=$_apiKey',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final channel = data['items']?[0];
        if (channel != null) {
          print('✅ API Connection Successful!');
          print('Channel: ${channel['snippet']['title']}');
          print('Subscribers: ${channel['statistics']['subscriberCount']}');
          print('Videos: ${channel['statistics']['videoCount']}');
          return true;
        }
      } else {
        print('❌ API Error: ${response.statusCode}');
        print('Response: ${response.body}');
      }
      return false;
    } catch (e) {
      print('❌ Connection Error: $e');
      return false;
    }
  }
}

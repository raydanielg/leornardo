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
  
  /// 🚀 Fetch videos with PAGINATION - FAST! First page = 20 videos
  static Future<Map<String, dynamic>> fetchChannelVideosPaginated({
    String? pageToken,
    int maxResults = 20,
  }) async {
    List<Map<String, dynamic>> videos = [];
    String? nextPageToken;
    
    try {
      print('� Fetching videos page (max: $maxResults)...');
      
      // Step 1: Fetch video IDs from search
      String searchUrl = '$_baseUrl/search?part=snippet&channelId=$_channelId&maxResults=$maxResults&order=date&type=video&key=$_apiKey';
      if (pageToken != null) {
        searchUrl += '&pageToken=$pageToken';
      }
      
      final searchResponse = await http.get(Uri.parse(searchUrl));
      
      if (searchResponse.statusCode == 200) {
        final searchData = json.decode(searchResponse.body);
        final items = searchData['items'] as List<dynamic>;
        nextPageToken = searchData['nextPageToken'];
        
        if (items.isNotEmpty) {
          // Get video IDs
          final videoIds = items.map((item) => item['id']['videoId'] as String).toList();
          
          // Step 2: Fetch statistics for these videos
          videos = await _fetchVideosWithStatsByIds(videoIds);
        }
      } else {
        print('❌ Search API Error: ${searchResponse.statusCode}');
      }
      
      print('✅ Fetched ${videos.length} videos. Has more: ${nextPageToken != null}');
      return {
        'videos': videos,
        'nextPageToken': nextPageToken,
      };
      
    } catch (e) {
      print('❌ Error fetching paginated videos: $e');
      return {
        'videos': videos,
        'nextPageToken': null,
      };
    }
  }
  
  /// 🔥 Fetch ALL videos from channel - NO LIMIT! POWER! 💪
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
          
          // Get video IDs and fetch statistics
          if (items.isNotEmpty) {
            final videoIds = items.map((item) => item['id']['videoId'] as String).toList();
            final videosWithStats = await _fetchVideosWithStatsByIds(videoIds);
            allVideos.addAll(videosWithStats);
          }
          
          pageCount++;
          print('📄 Page $pageCount: ${items.length} videos fetched. Total: ${allVideos.length}');
          
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
  
  /// 📊 Fetch videos with statistics by IDs (real views, duration, etc)
  static Future<List<Map<String, dynamic>>> _fetchVideosWithStatsByIds(List<String> videoIds) async {
    try {
      if (videoIds.isEmpty) return [];
      
      // YouTube API allows max 50 IDs per request
      final ids = videoIds.take(50).join(',');
      
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

          // Format duration from PT4M13S to 4:13
          final isoDuration = content['duration'] ?? 'PT0M0S';
          String duration = _formatDuration(isoDuration);

          // Calculate total seconds for Shorts filtering (METHOD 1: BY DURATION)
          int durationSeconds = _getTotalSeconds(isoDuration);

          // Format view count - REAL VIEWS!
          String views = _formatViewCount(stats['viewCount'] ?? '0');

          // Get best thumbnail
          String thumbnail = snippet['thumbnails']['high']?['url'] ??
                            snippet['thumbnails']['medium']?['url'] ??
                            snippet['thumbnails']['default']?['url'];

          return {
            'videoId': item['id'],
            'title': snippet['title'],
            'channel': snippet['channelTitle'],
            'thumbnail': thumbnail,
            'views': '$views views',
            'duration': duration,
            'durationSeconds': durationSeconds, // For Shorts filtering!
            'publishedAt': snippet['publishedAt'],
            'description': snippet['description'],
            'likeCount': _formatViewCount(stats['likeCount'] ?? '0'),
            'commentCount': _formatViewCount(stats['commentCount'] ?? '0'),
          };
        }).toList();
      } else {
        print('❌ Stats API Error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Error fetching video stats: $e');
      return [];
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

  /// 👤 Get Channel Info - WITH BANNER! 🔥
  static Future<Map<String, dynamic>?> fetchChannelInfo() async {
    try {
      print('👤 Fetching channel info...');

      final response = await http.get(
        Uri.parse(
          '$_baseUrl/channels?part=snippet,statistics,brandingSettings&id=$_channelId&key=$_apiKey',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final item = data['items'][0];
        final snippet = item['snippet'];
        final stats = item['statistics'];
        final branding = item['brandingSettings'];

        final channelInfo = {
          'title': snippet['title'],
          'description': snippet['description'],
          'thumbnail': snippet['thumbnails']['high']?['url'] ??
                      snippet['thumbnails']['medium']?['url'],
          'bannerUrl': branding?['image']?['bannerExternalUrl'] ??
                       branding?['image']?['bannerMobileExtraHdImageUrl'] ??
                       branding?['image']?['bannerMobileHdImageUrl'] ??
                       '',
          'subscriberCount': stats['subscriberCount'] ?? '0',
          'videoCount': stats['videoCount'] ?? '0',
          'viewCount': stats['viewCount'] ?? '0',
          'customUrl': snippet['customUrl'] ?? '@leonardobutindi',
        };

        print('✅ Fetched channel: ${channelInfo['title']}');
        print('🎨 Banner: ${channelInfo['bannerUrl']}');
        return channelInfo;
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
          final isoDuration = content['duration'] ?? 'PT0M0S';
          String duration = _formatDuration(isoDuration);

          // Calculate total seconds for Shorts filtering (METHOD 1: BY DURATION)
          int durationSeconds = _getTotalSeconds(isoDuration);

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
            'durationSeconds': durationSeconds, // For Shorts filtering!
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

          // Format duration from PT4M13S to 4:13
          final isoDuration = content['duration'] ?? 'PT0M0S';
          String duration = _formatDuration(isoDuration);

          // Calculate total seconds for Shorts filtering (METHOD 1: BY DURATION)
          int durationSeconds = _getTotalSeconds(isoDuration);

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
            'durationSeconds': durationSeconds, // For Shorts filtering!
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

  // Helper: Calculate total seconds from ISO duration (for Shorts filtering)
  static int _getTotalSeconds(String isoDuration) {
    // PT45S -> 45 seconds
    // PT1M30S -> 90 seconds
    // PT1H2M3S -> 3723 seconds
    final regex = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?');
    final match = regex.firstMatch(isoDuration);

    if (match == null) return 0;

    final hours = int.tryParse(match.group(1) ?? '0') ?? 0;
    final minutes = int.tryParse(match.group(2) ?? '0') ?? 0;
    final seconds = int.tryParse(match.group(3) ?? '0') ?? 0;

    return (hours * 3600) + (minutes * 60) + seconds;
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

  /// 🎬 Fetch Related Videos from Channel (exclude current video) - POA! 🔥
  static Future<List<Map<String, dynamic>>> fetchRelatedVideos(
    String currentVideoId, {
    int maxResults = 20,
  }) async {
    try {
      print('🎬 Fetching related videos (excluding: $currentVideoId)...');

      // Fetch recent videos from channel
      final searchResponse = await http.get(
        Uri.parse(
          '$_baseUrl/search?part=snippet&channelId=$_channelId&maxResults=${maxResults + 5}&order=date&type=video&key=$_apiKey',
        ),
      );

      if (searchResponse.statusCode == 200) {
        final searchData = json.decode(searchResponse.body);
        final items = searchData['items'] as List<dynamic>;

        // Filter out current video and get video IDs
        final videoIds = items
            .where((item) => item['id']['videoId'] != currentVideoId)
            .take(maxResults)
            .map((item) => item['id']['videoId'] as String)
            .toList();

        if (videoIds.isEmpty) return [];

        // Fetch statistics for these videos
        return await _fetchVideosWithStatsByIds(videoIds);
      } else {
        print('❌ Related videos API Error: ${searchResponse.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Error fetching related videos: $e');
      return [];
    }
  }

  /// 🎬 Fetch Reels (Shorts) - YouTube Shorts Style! 🔥
  /// Videos with duration < 60 seconds
  static Future<List<Map<String, dynamic>>> fetchReels({
    int maxResults = 50,
  }) async {
    try {
      print('🎬 Fetching Reels (Shorts)...');

      // Fetch MORE videos from channel to find shorts
      final searchResponse = await http.get(
        Uri.parse(
          '$_baseUrl/search?part=snippet&channelId=$_channelId&maxResults=100&order=date&type=video&key=$_apiKey',
        ),
      );

      if (searchResponse.statusCode == 200) {
        final searchData = json.decode(searchResponse.body);
        final items = searchData['items'] as List<dynamic>;
        print('📊 Found ${items.length} total videos from channel');

        // Get video IDs
        final videoIds = items
            .map((item) => item['id']['videoId'] as String)
            .toList();

        if (videoIds.isEmpty) return [];

        // Fetch video details with contentDetails to check duration
        final videosWithDetails = await _fetchVideosWithStatsByIds(videoIds);
        print('📊 Got details for ${videosWithDetails.length} videos');

        // 🎯 METHOD 1: BY DURATION - Filter Shorts under 180 seconds (3 min)
        // YouTube Shorts = videos with duration <= 180 seconds (3 minutes)
        // NOTE: Leonardo channel has few true shorts, so we include short videos too
        final reels = videosWithDetails.where((video) {
          final durationSeconds = video['durationSeconds'] as int? ?? 0;
          // Include videos up to 3 minutes to get more content
          final isShort = durationSeconds > 0 && durationSeconds <= 180;
          if (isShort) {
            print('✅ Found Short Video: ${video['title']} - ${video['duration']} (${durationSeconds}s)');
          } else {
            print('⏭️ Skipped (too long): ${video['title']} - ${video['duration']} (${durationSeconds}s)');
          }
          return isShort;
        }).take(maxResults).toList();

        print('✅ Total Reels Fetched: ${reels.length} (filtered from ${videosWithDetails.length} videos)');
        print('💡 Tip: Leonardo channel has ${videosWithDetails.length} videos, but only ${reels.length} are under 3 minutes');
        return reels;
      } else {
        print('❌ Reels API Error: ${searchResponse.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Error fetching reels: $e');
      return [];
    }
  }

  /// 💬 Fetch Comments for a Video - REAL DATA! 🔥
  static Future<Map<String, dynamic>> fetchVideoComments(
    String videoId, {
    int maxResults = 50,
    String? pageToken,
  }) async {
    try {
      print('💬 Fetching comments for video: $videoId');

      String url =
          '$_baseUrl/commentThreads?part=snippet&videoId=$videoId&maxResults=$maxResults&key=$_apiKey';
      if (pageToken != null) {
        url += '&pageToken=$pageToken';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List<dynamic>? ?? [];
        final nextPageToken = data['nextPageToken'] as String?;
        final totalResults = data['pageInfo']?['totalResults'] ?? 0;

        // Parse comments
        final comments = items.map((item) {
          final snippet = item['snippet']?['topLevelComment']?['snippet'] ?? {};

          return {
            'commentId': item['id'],
            'text': snippet['textDisplay'] ?? snippet['textOriginal'] ?? '',
            'authorName': snippet['authorDisplayName'] ?? 'Unknown',
            'authorAvatar': snippet['authorProfileImageUrl'] ?? '',
            'authorChannel': snippet['authorChannelUrl'] ?? '',
            'likeCount': snippet['likeCount'] ?? 0,
            'publishedAt': snippet['publishedAt'] ?? '',
            'updatedAt': snippet['updatedAt'] ?? '',
            'canReply': snippet['canReply'] ?? false,
            'totalReplyCount': item['snippet']?['totalReplyCount'] ?? 0,
          };
        }).toList();

        print('✅ Fetched ${comments.length} comments (Total: $totalResults)');

        return {
          'comments': comments,
          'nextPageToken': nextPageToken,
          'totalResults': totalResults,
        };
      } else {
        print('❌ Comments API Error: ${response.statusCode}');
        print('Response: ${response.body}');
        return {
          'comments': [],
          'nextPageToken': null,
          'totalResults': 0,
        };
      }
    } catch (e) {
      print('❌ Error fetching comments: $e');
      return {
        'comments': [],
        'nextPageToken': null,
        'totalResults': 0,
      };
    }
  }

  /// 📋 Fetch Playlists from Channel - REAL DATA! 🔥
  static Future<List<Map<String, dynamic>>> fetchChannelPlaylists({
    int maxResults = 50,
  }) async {
    try {
      print('📋 Fetching channel playlists...');

      final response = await http.get(
        Uri.parse(
          '$_baseUrl/playlists?part=snippet,contentDetails&channelId=$_channelId&maxResults=$maxResults&key=$_apiKey',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List<dynamic>? ?? [];

        final playlists = items.map((item) {
          final snippet = item['snippet'] ?? {};
          final contentDetails = item['contentDetails'] ?? {};

          return {
            'playlistId': item['id'],
            'title': snippet['title'] ?? 'Untitled',
            'description': snippet['description'] ?? '',
            'thumbnail': snippet['thumbnails']?['medium']?['url'] ??
                        snippet['thumbnails']?['default']?['url'] ??
                        '',
            'videoCount': contentDetails['itemCount'] ?? 0,
            'publishedAt': snippet['publishedAt'] ?? '',
          };
        }).toList();

        print('✅ Fetched ${playlists.length} playlists');
        return playlists;
      } else {
        print('❌ Playlists API Error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Error fetching playlists: $e');
      return [];
    }
  }

  /// 🎬 Fetch Videos from Playlist - REAL DATA! 🔥
  static Future<List<Map<String, dynamic>>> fetchPlaylistVideos(
    String playlistId, {
    int maxResults = 50,
    String? pageToken,
  }) async {
    try {
      print('🎬 Fetching videos from playlist: $playlistId');

      String url =
          '$_baseUrl/playlistItems?part=snippet&playlistId=$playlistId&maxResults=$maxResults&key=$_apiKey';
      if (pageToken != null) {
        url += '&pageToken=$pageToken';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List<dynamic>? ?? [];

        // Get video IDs to fetch statistics
        final videoIds = items
            .where((item) => item['snippet']?['resourceId']?['videoId'] != null)
            .map((item) => item['snippet']['resourceId']['videoId'] as String)
            .toList();

        // Fetch video details with statistics
        List<Map<String, dynamic>> videosWithStats = [];
        if (videoIds.isNotEmpty) {
          videosWithStats = await _fetchVideosWithStatsByIds(videoIds);
        }

        // Map playlist positions
        final videos = items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final snippet = item['snippet'] ?? {};
          final videoId = snippet['resourceId']?['videoId'];

          // Find matching stats
          final stats = videosWithStats.firstWhere(
            (v) => v['videoId'] == videoId,
            orElse: () => {},
          );

          return {
            'videoId': videoId ?? '',
            'title': stats['title'] ?? snippet['title'] ?? 'No Title',
            'thumbnail': stats['thumbnail'] ??
                        snippet['thumbnails']?['high']?['url'] ??
                        snippet['thumbnails']?['medium']?['url'] ??
                        snippet['thumbnails']?['default']?['url'] ??
                        '',
            'position': snippet['position'] ?? index,
            'views': stats['views'] ?? '0 views',
            'duration': stats['duration'] ?? '0:00',
            'durationSeconds': stats['durationSeconds'] ?? 0, // For Shorts filtering!
            'description': stats['description'] ?? snippet['description'] ?? '',
          };
        }).toList();

        print('✅ Fetched ${videos.length} videos from playlist');
        return videos;
      } else {
        print('❌ Playlist Videos API Error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Error fetching playlist videos: $e');
      return [];
    }
  }

  /// 📢 Fetch Community Posts - CHANNEL ACTIVITIES! 🔥
  static Future<List<Map<String, dynamic>>> fetchCommunityPosts({
    int maxResults = 20,
  }) async {
    try {
      print('📢 Fetching community posts...');

      // Fetch channel activities (includes uploads, posts, etc)
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/activities?part=snippet,contentDetails&channelId=$_channelId&maxResults=$maxResults&key=$_apiKey',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List<dynamic>? ?? [];

        final posts = items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final snippet = item['snippet'] ?? {};
          final contentDetails = item['contentDetails'] ?? {};

          // Check if it's a video upload or other activity
          final type = snippet['type'] ?? 'upload';
          final title = snippet['title'] ?? 'No Title';
          final description = snippet['description'] ?? '';
          final publishedAt = snippet['publishedAt'] ?? '';
          
          // Get thumbnails if available
          final thumbnails = snippet['thumbnails'];
          String thumbnail = '';
          if (thumbnails != null) {
            thumbnail = thumbnails['high']?['url'] ??
                       thumbnails['medium']?['url'] ??
                       thumbnails['default']?['url'] ??
                       '';
          }

          // Get video ID if it's an upload
          String videoId = '';
          if (type == 'upload' && contentDetails['upload'] != null) {
            videoId = contentDetails['upload']['videoId'] ?? '';
          }

          return {
            'postId': item['id'],
            'type': type,
            'title': title,
            'description': description,
            'thumbnail': thumbnail,
            'videoId': videoId,
            'publishedAt': publishedAt,
            'channelTitle': snippet['channelTitle'] ?? 'Leonardo Butindi',
            'channelAvatar': snippet['thumbnails']?['default']?['url'] ?? '',
            'commentCount': (index + 1) * 5 + 12, // Simulated based on index
            'likeCount': (index + 1) * 10 + 25, // Simulated likes
          };
        }).toList();

        print('✅ Fetched ${posts.length} community posts');
        return posts;
      } else {
        print('❌ Community API Error: ${response.statusCode}');
        print('Response: ${response.body}');
        return [];
      }
    } catch (e) {
      print('❌ Error fetching community posts: $e');
      return [];
    }
  }
}

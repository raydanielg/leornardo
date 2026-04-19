# 🔥 YouTube API Setup - Leonardo App

## Channel: @leonardobutindi

### 📝 Steps za Kufanya:

#### 1. Create YouTube Data API Key
1. Nenda [Google Cloud Console](https://console.cloud.google.com/)
2. Create new project au tumia existing
3. Enable **YouTube Data API v3**
4. Create **API Key** (Credentials > Create Credentials > API Key)

#### 2. Pata Channel ID
Channel ID ya @leonardobutindi inaweza kupatikana kwa:
```
https://www.googleapis.com/youtube/v3/channels?part=id&forHandle=@leonardobutindi&key=YOUR_API_KEY
```

#### 3. Update Code
Weka API key na Channel ID kwenye file:
```dart
// lib/services/youtube_api_service.dart

static const String _apiKey = 'YOUR_YOUTUBE_API_KEY_HERE';
static const String _channelId = 'CHANNEL_ID_HERE';
```

### 🔄 Switch from Mock to Real Data

Kwenye `youtube_data.dart`, badilisha kutumia `YouTubeApiService`:

```dart
import '../services/youtube_api_service.dart';

// Real API call
static Future<List<Map<String, dynamic>>> getRealVideos() async {
  return await YouTubeApiService.fetchChannelVideos();
}
```

### 📋 API Quota Limits
- Default: 10,000 units/day
- Search: 100 units/request
- Videos list: 1 unit/request

### 🛡️ Security Tips
- Usiweke API key kwenye public repo
- Tumia environment variables kwa production
- Restrict API key kwa app yako tu

### 🔗 Useful Links
- [YouTube Data API Docs](https://developers.google.com/youtube/v3)
- [Channel ID Finder](https://commentpicker.com/youtube-channel-id.php)

---

**Powered by Leonardo App - KVZR** 💪

import 'package:flutter/material.dart';
import '../../features/home/home_screen.dart';
import '../../features/channel/channel_screen.dart';
import '../../features/playlists/playlists_screen.dart';
import '../../features/community/community_screen.dart';
import '../../features/player/player_screen.dart';
import '../../features/player/comments_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String channel = '/channel';
  static const String playlists = '/playlists';
  static const String community = '/community';
  static const String player = '/player';
  static const String comments = '/comments';

  static Map<String, WidgetBuilder> get routes => {
    home: (context) => const HomeScreen(),
    channel: (context) => const ChannelScreen(),
    playlists: (context) => const PlaylistsScreen(),
    community: (context) => const CommunityScreen(),
    player: (context) => const PlayerScreen(),
  };
}

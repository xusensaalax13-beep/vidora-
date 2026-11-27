import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_player/video_player.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://supabase.co',
    anonKey: 'sb_publishable_fSVPb0YuGQ5W9uOsD6IgYw_wsx7HXJ1',
  );
  runApp(const VidoraGlobalApp());
}

final supabase = Supabase.instance.client;

class VidoraGlobalApp extends StatelessWidget {
  const VidoraGlobalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VIDORA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF070B14),
        primaryColor: const Color(0xFFFFB800),
      ),
      home: const VidoraMainScreen(),
    );
  }
}

class VidoraMainScreen extends StatefulWidget {
  const VidoraMainScreen({super.key});

  @override
  State<VidoraMainScreen> createState() => _VidoraMainScreenState();
}

class _VidoraMainScreenState extends State<VidoraMainScreen> {
  int _currentIndex = 0;

  String username = '@vidora_creator';
  int joinsCount = 0;
  int totalViews = 0;
  bool joinedOfficial = false;

  void _toggleJoinOfficial() {
    setState(() {
      joinedOfficial = !joinedOfficial;
    });
  }

  void _addJoin() {
    setState(() {
      joinsCount += 1;
    });
  }

  void _addViews(int count) {
    setState(() {
      totalViews += count;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      GlobalFeedPage(onJoinCreator: _addJoin, onViewVideo: () => _addViews(1)),
      const TrendingStarsPage(),
      UploadVideoPage(username: username, onUploaded: () => setState(() => _currentIndex = 0)),
      FriendsChatPage(currentUser: username),
      ProfileRewardsPage(
        username: username,
        joinsCount: joinsCount,
        totalViews: totalViews,
        joinedOfficial: joinedOfficial,
        onToggleOfficial: _toggleJoinOfficial,
      ),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF0D1322),
        selectedItemColor: const Color(0xFFFFB800),
        unselectedItemColor: Colors.white54,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.public), label: 'Global'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Stars'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle, size: 34, color: Color(0xFFFFB800)), label: 'Post'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class GlobalFeedPage extends StatefulWidget {
  final VoidCallback onJoinCreator;
  final VoidCallback onViewVideo;
  const GlobalFeedPage({super.key, required this.onJoinCreator, required this.onViewVideo});

  @override
  State<GlobalFeedPage> createState() => _GlobalFeedPageState();
}

class _GlobalFeedPageState extends State<GlobalFeedPage> {
  List<Map<String, dynamic>> feedItems = [
    {
      'isAd': false,
      'url': 'https://github.io',
      'user': '@vidora_official',
      'badge': 'OFFICIAL',
      'desc': 'Ku soo biir @vidora_official si aad u furto abaalmarinta 10k Joins = \$100/bishii!',
      'loves': 540,
      'comments': 48,
      'shares': 92,
      'loved': false,
      'joined': false,
    },
    {
      'isAd': false,
      'url': 'https://github.io',
      'user': '@alex_london',
      'badge': '1M STAR',
      'desc': 'Hello from London! Loving VIDORA Global — caddaan iyo madow hal meel!',
      'loves': 12400,
      'comments': 320,
      'shares': 810,
      'loved': false,
      'joined': false,
    },
    {
      'isAd': true,
      'url': 'https://github.io',
      'user': 'VIDORA Ads • Sponsored',
      'badge': 'AD',
      'desc': 'Ku xayeysii ganacsigaaga adduunka oo dhan — VIDORA Ads!',
      'loves': 120,
      'comments': 5,
      'shares': 14,
      'loved': false,
      'joined': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadSupabaseVideos();
  }

  Future<void> _loadSupabaseVideos() async {
    try {
      final data = await supabase.from('videos').select().order('created_at', ascending: false);
      if (data.isNotEmpty) {
        setState(() {
          for (var v in data) {
            feedItems.insert(0, {
              'isAd': false,
              'url': v['video_url'],
              'user': v['username'] ?? '@creator',
              'badge': 'NEW',
              'desc': v['caption'] ?? '',
              'loves': v['loves_count'] ?? 0,
              'comments': v['comments_count'] ?? 0,
              'shares': v['shares_count'] ?? 0,
              'loved': false,
              'joined': false,
            });
          }
        });
      }
    } catch (_) {}
  }

  void _showGiftSheet(String creatorName) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111827),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('U dir Hadiyad (Gift) -> $creatorName', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFFFB800))),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _giftOption(ctx, '🌹 Ubax', '10 Coins', creatorName),
                _giftOption(ctx, '🔥 Dab', '50 Coins', creatorName),
                _giftOption(ctx, '👑 Taaj', '200 Coins', creatorName),
                _giftOption(ctx, '🦁 Libaax', '1000 Coins', creatorName),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _giftOption(BuildContext ctx, String title, String price, String toUser) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(ctx);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Waxaad u dirtay $title -> $toUser!')),
        );
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(16)),
            child: Text(title.split(' ')[0], style: const TextStyle(fontSize: 28)),
          ),
          const SizedBox(height: 6),
          Text(title.split(' ')[1], style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(price, style: const TextStyle(fontSize: 11, color: Color(0xFFFFB800))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('VIDORA GLOBAL', style: TextStyle(color: Color(0xFFFFB800), fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        centerTitle: true,
      ),
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        onPageChanged: (_) => widget.onViewVideo(),
        itemCount: feedItems.length,
        itemBuilder: (context, index) {
          final item = feedItems[index];
          return VideoPlayerCard(
            item: item,
            onLove: () {
              setState(() {
                item['loved'] = !item['loved'];
                item['loves'] += item['loved'] ? 1 : -1;
              });
            },
            onJoin: () {
              setState(() {
                item['joined'] = !item['joined'];
              });
              widget.onJoinCreator();
            },
            onGift: () => _showGiftSheet(item['user']),
          );
        },
      ),
    );
  }
}

class VideoPlayerCard extends StatefulWidget {
  final Map<String, dynamic> item;
  final VoidCallback onLove;
  final VoidCallback onJoin;
  final VoidCallback onGift;

  const VideoPlayerCard({super.key, required this.item, required this.onLove, required this.onJoin, required this.onGift});

  @override
  State<VideoPlayerCard> createState() => _VideoPlayerCardState();
}

class _VideoPlayerCardState extends State<VideoPlayerCard> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.item['url']))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});
          _controller.play();
          _controller.setLooping(true);
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Center(
          child: _controller.value.isInitialized
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: AspectRatio(aspectRatio: _controller.value.aspectRatio, child: VideoPlayer(_controller)),
                )
              : const CircularProgressIndicator(color: Color(0xFFFFB800)),
        ),
        Positioned(
          bottom: 24,
          left: 16,
          right: 85,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [

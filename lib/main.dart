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
  int _idx = 0;
  String user = '@vidora_creator';
  int joins = 0;
  int views = 0;
  bool official = false;

  @override
  Widget build(BuildContext context) {
    final pages = [
      FeedTab(
        onJoin: () => setState(() => joins++),
        onView: () => setState(() => views++),
      ),
      const SearchStarsTab(),
      UploadTab(user: user, onDone: () => setState(() => _idx = 0)),
      ChatTab(user: user),
      ProfileTab(
        user: user,
        joins: joins,
        views: views,
        official: official,
        onOfficial: () => setState(() => official = !official),
      ),
    ];

    return Scaffold(
      body: pages[_idx],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _idx,
        onTap: (i) => setState(() => _idx = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF0D1322),
        selectedItemColor: const Color(0xFFFFB800),
        unselectedItemColor: Colors.white54,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.public), label: 'Global'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle, size: 32, color: Color(0xFFFFB800)), label: 'Post'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class FeedTab extends StatefulWidget {
  final VoidCallback onJoin;
  final VoidCallback onView;
  const FeedTab({super.key, required this.onJoin, required this.onView});

  @override
  State<FeedTab> createState() => _FeedTabState();
}

class _FeedTabState extends State<FeedTab> {
  List<Map<String, dynamic>> items = [
    {
      'ad': false,
      'url': 'https://github.io',
      'user': '@vidora_official',
      'badge': 'OFFICIAL',
      'desc': 'Ku biir @vidora_official si aad u furto 10k Joins = 100 Dollar/bishii!',
      'loves': 540,
      'comments': 48,
      'shares': 92,
      'loved': false,
      'joined': false,
    },
    {
      'ad': false,
      'url': 'https://github.io',
      'user': '@alex_london',
      'badge': '1M STAR',
      'desc': 'Hello from London! VIDORA Global — caddaan iyo madow hal meel!',
      'loves': 12400,
      'comments': 320,
      'shares': 810,
      'loved': false,
      'joined': false,
    },
    {
      'ad': true,
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
    _fetchVideos();
  }

  Future<void> _fetchVideos() async {
    try {
      final res = await supabase.from('videos').select().order('created_at', ascending: false);
      if (res.isNotEmpty && mounted) {
        setState(() {
          for (var v in res) {
            items.insert(0, {
              'ad': false,
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

  void _openGifts(String toUser) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111827),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('U dir Gift -> $toUser', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFFFB800))),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _giftBtn(ctx, Icons.local_florist, 'Ubax', '10 Coins', toUser),
                _giftBtn(ctx, Icons.local_fire_department, 'Dab', '50 Coins', toUser),
                _giftBtn(ctx, Icons.workspace_premium, 'Taaj', '200 Coins', toUser),
                _giftBtn(ctx, Icons.diamond, 'Dheeman', '1000 Coins', toUser),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _giftBtn(BuildContext ctx, IconData icon, String name, String price, String toUser) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(ctx);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Waxaad u dirtay $name -> $toUser!')));
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, size: 30, color: const Color(0xFFFFB800)),
          ),
          const SizedBox(height: 4),
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
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
        title: const Text('VIDORA GLOBAL', style: TextStyle(color: Color(0xFFFFB800), fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        onPageChanged: (_) => widget.onView(),
        itemCount: items.length,
        itemBuilder: (context, i) {
          final item = items[i];
          return VideoCard(
            item: item,
            onLove: () => setState(() {
              item['loved'] = !item['loved'];
              item['loves'] += item['loved'] ? 1 : -1;
            }),
            onJoin: () {
              setState(() => item['joined'] = !item['joined']);
              widget.onJoin();
            },
            onGift: () => _openGifts(item['user']),
          );
        },
      ),
    );
  }
}

class VideoCard extends StatefulWidget {
  final Map<String, dynamic> item;
  final VoidCallback onLove;
  final VoidCallback onJoin;
  final VoidCallback onGift;
  const VideoCard({super.key, required this.item, required this.onLove, required this.onJoin, required this.onGift});

  @override
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  late VideoPlayerController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = VideoPlayerController.networkUrl(Uri.parse(widget.item['url']))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});
          _ctrl.play();
          _ctrl.setLooping(true);
        }
      });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Center(
          child: _ctrl.value.isInitialized
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: AspectRatio(aspectRatio: _ctrl.value.aspectRatio, child: VideoPlayer(_ctrl)),
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
                  Text(widget.item['user'], style: const TextStyle(color: Color(0xFFFFB800), fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: Colors.amber.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                    child: Text(widget.item['badge'], style: const TextStyle(fontSize: 10, color: Color(0xFFFFB800))),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(widget.item['desc'], style: const TextStyle(color: Colors.white, fontSize: 14)),

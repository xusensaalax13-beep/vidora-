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
  runApp(const VidoraApp());
}

final db = Supabase.instance.client;

class VidoraApp extends StatelessWidget {
  const VidoraApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VIDORA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF070B14),
        primaryColor: const Color(0xFFFFB800),
      ),
      home: const MainHome(),
    );
  }
}

class MainHome extends StatefulWidget {
  const MainHome({super.key});
  @override
  State<MainHome> createState() => _MainHomeState();
}

class _MainHomeState extends State<MainHome> {
  int idx = 0;
  int joins = 0;
  int views = 0;
  bool official = false;

  @override
  Widget build(BuildContext context) {
    final screens = [
      FeedScreen(
        onJoin: () => setState(() => joins++),
        onView: () => setState(() => views++),
      ),
      const SearchScreen(),
      UploadScreen(onDone: () => setState(() => idx = 0)),
      const ChatScreen(),
      ProfileScreen(
        joins: joins,
        views: views,
        official: official,
        onOfficial: () => setState(() => official = !official),
      ),
    ];
    return Scaffold(
      body: screens[idx],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: idx,
        onTap: (i) => setState(() => idx = i),
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

class FeedScreen extends StatefulWidget {
  final VoidCallback onJoin;
  final VoidCallback onView;
  const FeedScreen({super.key, required this.onJoin, required this.onView});
  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  List<Map<String, dynamic>> list = [
    {
      'ad': false,
      'url': 'https://github.io',
      'user': '@vidora_official',
      'tag': 'OFFICIAL',
      'desc': 'Ku biir @vidora_official si aad u furto 10k Joins = 100 Dollar/bishii!',
      'loves': 540,
      'comments': 2,
      'shares': 92,
      'loved': false,
      'joined': false,
      'commentList': ['@amina: App cajiib ah!', '@john_usa: Love VIDORA Global!'],
    },
    {
      'ad': false,
      'url': 'https://github.io',
      'user': '@alex_london',
      'tag': '1M+ STAR',
      'desc': 'Hello from London! VIDORA Global — caddaan iyo madow hal meel!',
      'loves': 12400,
      'comments': 1,
      'shares': 810,
      'loved': false,
      'joined': false,
      'commentList': ['@kismaayo_star: Soo dhawoow saaxiib!'],
    },
    {
      'ad': true,
      'url': 'https://github.io',
      'user': 'VIDORA Ads • Sponsored',
      'tag': 'AD',
      'desc': 'Ku xayeysii ganacsigaaga adduunka oo dhan — VIDORA Ads!',
      'loves': 120,
      'comments': 0,
      'shares': 14,
      'loved': false,
      'joined': false,
      'commentList': <String>[],
    },
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await db.from('videos').select().order('created_at', ascending: false);
      if (res.isNotEmpty && mounted) {
        setState(() {
          for (var v in res) {
            list.insert(0, {
              'ad': false,
              'url': v['video_url'],
              'user': v['username'] ?? '@creator',
              'tag': 'NEW',
              'desc': v['caption'] ?? '',
              'loves': v['loves_count'] ?? 0,
              'comments': 0,
              'shares': v['shares_count'] ?? 0,
              'loved': false,
              'joined': false,
              'commentList': <String>[],
            });
          }
        });
      }
    } catch (_) {}
  }

  void _openComments(int index) {
    final txt = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF111827),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 16, right: 16, top: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Comments (Faallooyinka)', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFFB800))),
            const SizedBox(height: 10),
            ...(list[index]['commentList'] as List<String>).map((c) => ListTile(title: Text(c))),
            Row(
              children: [
                Expanded(child: TextField(controller: txt, decoration: const InputDecoration(hintText: 'Qor faallo...'))),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFFFFB800)),
                  onPressed: () {
                    if (txt.text.trim().isEmpty) return;
                    setState(() {
                      (list[index]['commentList'] as List<String>).add('@vidora_creator: ${txt.text.trim()}');
                      list[index]['comments'] += 1;
                    });
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _gift(String to) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111827),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(icon: const Icon(Icons.local_florist, color: Color(0xFFFFB800), size: 36), onPressed: () => Navigator.pop(ctx)),
            IconButton(icon: const Icon(Icons.local_fire_department, color: Color(0xFFFFB800), size: 36), onPressed: () => Navigator.pop(ctx)),
            IconButton(icon: const Icon(Icons.workspace_premium, color: Color(0xFFFFB800), size: 36), onPressed: () => Navigator.pop(ctx)),
            IconButton(icon: const Icon(Icons.diamond, color: Color(0xFFFFB800), size: 36), onPressed: () => Navigator.pop(ctx)),
          ],
        ),
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
        itemCount: list.length,
        itemBuilder: (c, i) => VideoTile(
          item: list[i],
          onLove: () => setState(() {
            list[i]['loved'] = !list[i]['loved'];
            list[i]['loves'] += list[i]['loved'] ? 1 : -1;
          }),
          onJoin: () {
            setState(() => list[i]['joined'] = !list[i]['joined']);
            widget.onJoin();
          },
          onComment: () => _openComments(i),
          onShare: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Link-ga muuqaalka waa la koobiyayay!'))),
          onGift: () => _gift(list[i]['user']),
        ),
      ),
    );
  }
}

class VideoTile extends StatefulWidget {
  final Map<String, dynamic> item;
  final VoidCallback onLove;
  final VoidCallback onJoin;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onGift;
  const VideoTile({
    super.key,
    required this.item,
    required this.onLove,
    required this.onJoin,
    required this.onComment,
    required this.onShare,
    required this.onGift,
  });
  @override
  State<VideoTile> createState() => _VideoTileState();
}

class _VideoTileState extends State<VideoTile> {
  late VideoPlayerController vc;

  @override
  void initState() {
    super.initState();
    vc = VideoPlayerController.networkUrl(Uri.parse(widget.item['url']))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});
          vc.play();
          vc.setLooping(true);
        }
      });
  }

  @override
  void dispose() {
    vc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Center(
          child: vc.value.isInitialized
              ? AspectRatio(aspectRatio: vc.value.aspectRatio, child: VideoPlayer(vc))
              : const CircularProgressIndicator(color: Color(0xFFFFB800)),
        ),
        Positioned(
          bottom: 24,
          left: 16,
          right: 85,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

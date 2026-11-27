import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(const VidoraApp());
}

class VidoraApp extends StatelessWidget {
  const VidoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VIDORA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A0E17),
        primaryColor: const Color(0xFFFFB800),
      ),
      home: const VidoraHome(),
    );
  }
}

class VidoraHome extends StatefulWidget {
  const VidoraHome({super.key});

  @override
  State<VidoraHome> createState() => _VidoraHomeState();
}

class _VidoraHomeState extends State<VidoraHome> {
  final List<Map<String, dynamic>> videos = [
    {
      'url': 'https://github.io',
      'user': '@xuseen_vidora',
      'desc': 'Ku soo dhawoow VIDORA! App-ka cusub ee muuqaallada casriga ah.',
      'likes': 124,
      'liked': false,
    },
    {
      'url': 'https://github.io',
      'user': '@kismaayo_vibes',
      'desc': 'Nashqad cusub oo ka duwan TikTok. Maxaad ka aaminsan tahay?',
      'likes': 89,
      'liked': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'VIDORA',
          style: TextStyle(
            color: Color(0xFFFFB800),
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: videos.length,
        itemBuilder: (context, index) {
          return VideoCardItem(
            data: videos[index],
            onLike: () {
              setState(() {
                videos[index]['liked'] = !videos[index]['liked'];
                videos[index]['likes'] += videos[index]['liked'] ? 1 : -1;
              });
            },
          );
        },
      ),
    );
  }
}

class VideoCardItem extends StatefulWidget {
  final Map<String, dynamic> data;
  final VoidCallback onLike;

  const VideoCardItem({super.key, required this.data, required this.onLike});

  @override
  State<VideoCardItem> createState() => _VideoCardItemState();
}

class _VideoCardItemState extends State<VideoCardItem> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.data['url']))
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
        _controller.setLooping(true);
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
                  borderRadius: BorderRadius.circular(24),
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                )
              : const CircularProgressIndicator(color: Color(0xFFFFB800)),
        ),
        Positioned(
          bottom: 30,
          left: 20,
          right: 80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.data['user'],
                style: const TextStyle(
                  color: Color(0xFFFFB800),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.data['desc'],
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 40,
          right: 16,
          child: Column(
            children: [
              IconButton(
                iconSize: 36,
                icon: Icon(
                  widget.data['liked'] ? Icons.favorite : Icons.favorite_border,
                  color: widget.data['liked'] ? Colors.redAccent : Colors.white,
                ),
                onPressed: widget.onLike,
              ),
              Text('${widget.data['likes']}', style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 16),
              const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 32),
              const Text('12', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ],
    );
  }
}

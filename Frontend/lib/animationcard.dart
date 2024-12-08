import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class AnimatedCard extends StatefulWidget {
  final String title;
  final String imagePath;
  final Widget screen;

  const AnimatedCard({
    Key? key,
    required this.title,
    required this.imagePath,
    required this.screen,
  }) : super(key: key);

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isExpanded = false;
  bool _showVideo = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap() {
    if (!_isExpanded) {
      _controller.forward();
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _showVideo = true;
        });
      });
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => widget.screen),
      );
    }
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
              child: _showVideo
                  ? VideoBackground()
                  : Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        image: DecorationImage(
                          image: AssetImage(widget.imagePath),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            color: Colors.black.withOpacity(0.1),
                            padding: const EdgeInsets.all(10),
                            child: Text(
                              widget.title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }
}

class VideoBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<VideoPlayerController>(
      future: _initializeVideo(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return AspectRatio(
            aspectRatio: snapshot.data!.value.aspectRatio,
            child: VideoPlayer(snapshot.data!),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  Future<VideoPlayerController> _initializeVideo() async {
    final controller = VideoPlayerController.asset('assets/videos/space.mp4');
    await controller.initialize();
    await controller.setLooping(true);
    await controller.play();
    return controller;
  }
}

import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: "Space Live",
//       debugShowCheckedModeBanner: false,
//       home: LiveBackground(),
//     );
//   }
// }

class LiveBackground extends StatefulWidget {
  const LiveBackground({super.key}); // Make sure the constructor includes `super.key`
  @override
  State<StatefulWidget> createState() {
    return _LiveBackgroundState();
  }
}

class _LiveBackgroundState extends State<LiveBackground> {
  late YoutubePlayerController _controller;
  late bool _isPlayerReady;

  @override
  void initState() {
    super.initState();
    const videoUrl = "https://www.youtube.com/watch?v=0FBiyFpV__g";
    _controller = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(videoUrl)!,
      flags: YoutubePlayerFlags(
        autoPlay: true,
        loop: true,
        hideControls: true, // Hide the YouTube player controls
        controlsVisibleAtStart: false, // Ensure controls are not visible at the start
      ),
    );
    _isPlayerReady = false;
    _controller.addListener(() {
      if (_isPlayerReady) {
        _controller.play();
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
    return Scaffold(
      body: Stack(
        children: [
          YoutubePlayerBuilder(
            player: YoutubePlayer(
              controller: _controller,
              showVideoProgressIndicator: false,
              onReady: () {
                setState(() {
                  _isPlayerReady = true;
                });
              },
            ),
            builder: (context, player) {
              return SizedBox.expand(
                child: player,
              );
            },
          ),
          if (!_isPlayerReady)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}

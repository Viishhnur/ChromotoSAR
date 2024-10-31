
import "package:flutter/material.dart";
import "package:youtube_player_flutter/youtube_player_flutter.dart";

void main(){
  runApp( MyApp());
}
class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title:"Space live",
      debugShowCheckedModeBanner: false,
      home:LiveBackground()
    );
    
  }
}

class LiveBackground extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _LiveBackgroundState(); // this is a state object 
  }
}

class _LiveBackgroundState extends State<LiveBackground>{
  late YoutubePlayerController _controller; // this will be initalised later
  // late bool _isPlayerReady;
  //  This method is called when the state object is first created. It is used for one-time initialization.
  @override
  void initState(){
    // call the State class constructor
    super.initState();
    const videoUrl = "https://www.youtube.com/watch?v=0FBiyFpV__g";
    _controller = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(videoUrl)!,
      flags:YoutubePlayerFlags(
        autoPlay: true,
        loop:true,
        hideControls: true,
        controlsVisibleAtStart: false,
      ),
    );

   

      
  }

  @override
  void dispose() {
    _controller.dispose(); // Disposes the YouTube player controller
    super.dispose(); // Calls the dispose method of the parent class
  }

  @override
  Widget build(BuildContext context){
    return Positioned.fill(
          child:YoutubePlayer(
            controller: _controller,
            // showVideoProgressIndicator: false,
            onReady: (){
              _controller.play(); // it playes the video
            },


            ),
        );
    
  }
}
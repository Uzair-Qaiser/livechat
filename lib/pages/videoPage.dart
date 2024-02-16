import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class videoPage extends StatefulWidget {
  const videoPage({Key? key, required this.videoUrl})
      : super(key: key);
  final String? videoUrl;


  @override
  State<videoPage> createState() => _videoPageState();
}

class _videoPageState extends State<videoPage> {
   VideoPlayerController? videoController;
   ChewieController? chewieController;
  @override
  void initState() {
    // TODO: implement initState
    videoController =  VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl!));
    chewieController =ChewieController(videoPlayerController: videoController!,
    allowFullScreen: true,
      looping: true,
      autoPlay: true,

    );
  }
   @override
   void dispose() {

     videoController!.dispose();
     chewieController!.dispose();
     super.dispose();
   }
  @override

  Widget build(BuildContext context) {
    return Scaffold(
      // floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      // floatingActionButton: FloatingActionButton(onPressed: (){Navigator.pop(context);},child: Icon(Icons.arrow_back),backgroundColor: Colors.grey.withOpacity(0.2),),
      backgroundColor: Colors.black,
        body: Container(
          child: Chewie(
            controller: chewieController!,

          ),
        ) );
  }
}
//Stack(
//           alignment: Alignment.center,
//           children: [
//             Container(
//
//
//               child: videoController!.value.isInitialized
//                   ? AspectRatio(
//                       aspectRatio: videoController!.value.aspectRatio,
//                       child: VideoPlayer(videoController!),
//                     )
//                   : Container(),
//             ),
//             Center(
//               child: Container(
//                 child: IconButton(
//                     onPressed: () {
//                       setState(() {
//                         videoController!.value.isPlaying
//                             ? videoController!.pause()
//                             : videoController!.play();
//                       });
//                     },
//                     icon: Icon(
//                       videoController!.value.isPlaying
//                           ? Icons.pause
//                           : Icons.play_arrow,
//                       size: 40,
//                       color: Colors.grey.withOpacity(0.5),
//                     )),
//               ),
//             ),
//           ],
//         )
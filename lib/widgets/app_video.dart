import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class AppVideo extends StatefulWidget {
  final bool isYouTube;
  final String url;
  const AppVideo({
    Key? key,
    required this.isYouTube,
    required this.url,
  }) : super(key: key);

  @override
  _AppVideoState createState() => _AppVideoState();
}

class _AppVideoState extends State<AppVideo> {
  late VideoPlayerController _controller;
  late YoutubePlayerController _youtubeController;
  bool _mute = false;
  bool _playing = true;
  bool _showAction = true;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.url);
    bool autoPlay = true;
    _youtubeController = YoutubePlayerController(
        params: const YoutubePlayerParams(
          
      mute: true,
      showControls: true,
      showFullscreenButton: true,
    ))
      ..onInit = () {
        // _youtubeController.mute(){
        //   _onMute();
        // };
        _youtubeController.loadVideoById(
            videoId: 'K18cpp_-gP8', startSeconds: 30);
        // _youtubeController.cueVideoById(videoId: 'K18cpp_-gP8', startSeconds: 30);
      };

    _controller.setLooping(true);
    _controller.initialize();
    _controller.play();
    _showAction = false;
  }

  @override
  void dispose() {
    _controller.dispose();
    _youtubeController.close();
    super.dispose();
  }

  void _onPlay() {
    setState(() {
      _playing = !_playing;
      _showAction = true;
    });
    if (_playing) {
      _controller.play();
      _youtubeController.playVideo();
    } else {
      _controller.pause();
      _youtubeController.pauseVideo();
    }
  }

  void _onMute() {
    setState(() {
      _mute = !_mute;
    });
    _controller.setVolume(_mute ? 0.0 : 1.0);
    _youtubeController.setVolume(_mute ? 0 : 16);
  }

  @override
  Widget build(BuildContext context) {
    // if (widget.isYouTube) {
    //   return Expanded(
    //     child: YoutubePlayerScaffold(
    //       autoFullScreen: true,
    //       controller: _youtubeController,
    //       aspectRatio: 16 / 9,
    //       builder: (context, player) {
    //         return Scaffold(
    //             appBar: AppBar(
    //               title: Text('YouTube Player'),
    //             ),
    //             body: LayoutBuilder(builder: (context, constraints) {
    //               // if (constraints.maxWidth > 750) {
    //               return Row(
    //                 crossAxisAlignment: CrossAxisAlignment.start,
    //                 children: [
    //                   Expanded(
    //                     flex: 3,
    //                     child: Column(
    //                       children: [
    //                         player,
    //                         const VideoPositionIndicator(),
    //                       ],
    //                     ),
    //                   ),
    //                   const Expanded(
    //                     flex: 2,
    //                     child: SingleChildScrollView(
    //                         // child: Controls(),
    //                         ),
    //                   ),
    //                 ],
    //               );
    //               // }
    //               //               return ListView(
    //               //   children: [
    //               //     player,
    //               //     const VideoPositionIndicator(),
    //               //     const Controls(),
    //               //   ],
    //               // );
    //             }));
    //       },
    //     ),
    //   );
    // }

    // if (widget.isYouTube) {
    //   return YoutubePlayerScaffold(
    //     autoFullScreen: true,
    //     controller: _youtubeController,
    //     aspectRatio: 16 / 9,
    //     builder: (context, player) {
    //       return Container(
    //         child: player,
    //       );
    //     },
    //   );
    // }

    return AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: Stack(
        alignment: Alignment.center,
        children: [
          InkWell(
            onTap: _onPlay,
            child: widget.isYouTube
                ? YoutubePlayer(controller: _youtubeController)
                : VideoPlayer(_controller),
          ),
          AnimatedOpacity(
            opacity: _showAction ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 500),
            onEnd: () {
              setState(() {
                _showAction = false;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.withOpacity(0.3),
              ),
              child: Icon(
                _playing ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            bottom: 8,
            right: 8,
            child: InkWell(
              onTap: _onMute,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.withOpacity(0.3),
                ),
                child: Icon(
                  _mute ? Icons.volume_mute_outlined : Icons.volume_up_outlined,
                  color: Colors.white,
                ),
              ),
            ),
          )
        ],
      ),
    );
    return AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: Stack(
        alignment: Alignment.center,
        children: [
          InkWell(
            onTap: _onPlay,
            child: VideoPlayer(_controller),
          ),
          AnimatedOpacity(
            opacity: _showAction ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 500),
            onEnd: () {
              setState(() {
                _showAction = false;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.withOpacity(0.3),
              ),
              child: Icon(
                _playing ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            bottom: 8,
            right: 8,
            child: InkWell(
              onTap: _onMute,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.withOpacity(0.3),
                ),
                child: Icon(
                  _mute ? Icons.volume_mute_outlined : Icons.volume_up_outlined,
                  color: Colors.white,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class VideoPositionIndicator extends StatelessWidget {
  ///
  const VideoPositionIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.ytController;

    return StreamBuilder<Duration>(
      stream: controller.getCurrentPositionStream(),
      initialData: Duration.zero,
      builder: (context, snapshot) {
        final position = snapshot.data?.inMilliseconds ?? 0;
        final duration = controller.metadata.duration.inMilliseconds;

        return LinearProgressIndicator(
          value: duration == 0 ? 0 : position / duration,
          minHeight: 1,
        );
      },
    );
  }
}

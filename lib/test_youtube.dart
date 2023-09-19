import 'dart:async';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '/utils/color.dart';
import '/utils/default_logger.dart';
import '/utils/sizedbox_utils.dart';
import '/utils/text.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart'
    hide ProgressBar;

import 'sl_container.dart';

/// Homepage
class YoutubePlayerDemoApp extends StatefulWidget {
  @override
  _YoutubePlayerDemoAppState createState() => _YoutubePlayerDemoAppState();
}

class _YoutubePlayerDemoAppState extends State<YoutubePlayerDemoApp> {
  var provider = sl.get<PlayerProvider>();
  @override
  void initState() {
    super.initState();
    provider.init();
  }

  @override
  void deactivate() {
    // Pauses video while navigating to next page.
    provider.controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    provider.controller.dispose();
    provider.idController.dispose();
    provider.seekToController.dispose();
    provider.timer.cancel();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // return Container();
    return Consumer<PlayerProvider>(builder: (context, provider, _) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            YoutubePlayerBuilder(
              onExitFullScreen: () {
                SystemChrome.setPreferredOrientations([
                  DeviceOrientation.portraitUp,
                  DeviceOrientation.portraitDown
                ]);
              },
              onEnterFullScreen: () {
                SystemChrome.setPreferredOrientations([
                  DeviceOrientation.landscapeLeft,
                  DeviceOrientation.landscapeRight
                ]);
              },
              player: YoutubePlayer(
                controller: provider.controller,
                showVideoProgressIndicator: true,
                progressIndicatorColor: Colors.white,
                progressColors: ProgressBarColors(
                    playedColor: Colors.blueAccent,
                    handleColor: Colors.blueAccent),
                topActions: <Widget>[
                  // const SizedBox(width: 8.0),
                  // Expanded(
                  //   child: Text(
                  //     provider.controller.metadata.title,
                  //     style: const TextStyle(
                  //       color: Colors.white,
                  //       fontSize: 18.0,
                  //     ),
                  //     overflow: TextOverflow.ellipsis,
                  //     maxLines: 1,
                  //   ),
                  // ),
                  // IconButton(
                  //   icon: const Icon(
                  //     Icons.settings,
                  //     color: Colors.white,
                  //     size: 25.0,
                  //   ),
                  //   onPressed: () {
                  //     Get.to(PlayVideoFromNetwork());
                  //   },
                  // ),
                ],
                onReady: () {
                  provider.isPlayerReady = true;
                },
                onEnded: (data) {
                  provider.controller.load(provider.ids[
                      (provider.ids.indexOf(data.videoId) + 1) %
                          provider.ids.length]);
                  _showSnackBar('Next Video Started!');
                },
              ),
              builder: (context, player) => Scaffold(
                appBar: AppBar(
                  backgroundColor: Color.fromARGB(255, 227, 20, 20),
                  title: const Text(
                    'Live Videos',
                    style: TextStyle(color: Colors.white),
                  ),
                  actions: [],
                ),
                body: Column(
                  children: [
                    Stack(
                      children: [
                        player,

                        ///Skip screen
                        if (!provider.controller.value.isFullScreen)
                          buildCutomScreenTapSkipWidget(provider),

                        //thumbnail image
                        if (!provider.controller.value.isFullScreen)
                          buildCutomThumbnailWidget(provider),

                        ///Live indicator
                        if (!provider.controller.value.isFullScreen)
                          buildCutomLiveIndicator(provider),

                        /// progress bar and full screen button
                        if (!provider.controller.value.isFullScreen)
                          buildCustomProgressBarWidget(provider),

                        // ///play button
                        // if (!provider.controller.value.isFullScreen)
                        //   buildCustomPlayButton(provider)
                      ],
                    ),

                    // FilledButton.icon(
                    // onPressed: () async {
                    //   var web = provider.controller.value.webViewController;
                    //   var data = web?.javaScriptHandlersMap;

                    //   // errorLog(data.toString());
                    //   web?.addJavaScriptHandler(
                    //     handlerName: 'onPlaybackQualityChange',
                    //     callback: (args) {
                    //       // provider.controller.updateValue(
                    //       //  provider. controller.value.copyWith(errorCode: int.parse(args.first)),
                    //       // );
                    //       errorLog(args.toString());
                    //     },
                    //   );

                    // errorLog(d2.toString());
                    // provider.controller.load(provider.ids[
                    //     (provider.ids.indexOf(data.videoId) + 1) %
                    //         provider.ids.length]);
                    // _showSnackBar('Next Video Started!'
                    // },
                    // icon: Icon(Icons.youtube_searched_for),
                    // label: Text('Experiments'))

                    // Padding(
                    //   padding: const EdgeInsets.all(8.0),
                    //   child: Column(
                    //     crossAxisAlignment: CrossAxisAlignment.stretch,
                    //     children: [
                    //       IconButton(
                    //         icon: const Icon(
                    //           Icons.settings,
                    //           // color: Colors.white,
                    //           size: 25.0,
                    //         ),
                    //         onPressed: () {
                    //           Get.to(PlayVideoFromNetwork());
                    //         },
                    //       ),
                    //       _space,
                    //       _text('Title', videoMetaData.title),
                    //       _space,
                    //       _text('Channel', videoMetaData.author),
                    //       _space,
                    //       _text('Video Id', videoMetaData.videoId),
                    //       _space,
                    //       Row(
                    //         children: [
                    //           _text(
                    //             'Playback Quality',
                    //             provider.controller.value.playbackQuality ?? '',
                    //           ),
                    //           const Spacer(),
                    //           _text(
                    //             'Playback Rate',
                    //             '${provider.controller.value.playbackRate}x  ',
                    //           ),
                    //         ],
                    //       ),
                    //       _space,
                    //       TextField(
                    //         enabled: provider.isPlayerReady,
                    //         controller: provider.idController,
                    //         decoration: InputDecoration(
                    //           border: InputBorder.none,
                    //           hintText: 'Enter youtube \<video id\> or \<link\>',
                    //           fillColor: Colors.blueAccent.withAlpha(20),
                    //           filled: true,
                    //           hintStyle: const TextStyle(
                    //             fontWeight: FontWeight.w300,
                    //             color: Colors.blueAccent,
                    //           ),
                    //           suffixIcon: IconButton(
                    //             icon: const Icon(Icons.clear),
                    //             onPressed: () => provider.idController.clear(),
                    //           ),
                    //         ),
                    //       ),
                    //       _space,
                    //       Row(
                    //         children: [
                    //           _loadCueButton('LOAD'),
                    //           const SizedBox(width: 10.0),
                    //           _loadCueButton('CUE'),
                    //         ],
                    //       ),
                    //       _space,
                    //       Row(
                    //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    //         children: [
                    //           IconButton(
                    //             icon: const Icon(Icons.skip_previous),
                    //             onPressed: provider.isPlayerReady
                    //                 ? () => provider.controller.load(provider.ids[
                    //                     (provider.ids.indexOf(provider.controller.metadata.videoId) -
                    //                             1) %
                    //                         provider.ids.length])
                    //                 : null,
                    //           ),
                    //           IconButton(
                    //             icon: Icon(
                    //               provider.controller.value.isPlaying
                    //                   ? Icons.pause
                    //                   : Icons.play_arrow,
                    //             ),
                    //             onPressed: provider.isPlayerReady
                    //                 ? () {
                    //                     provider.controller.value.isPlaying
                    //                         ? provider.controller.pause()
                    //                         : provider.controller.play();
                    //                     setState(() {});
                    //                   }
                    //                 : null,
                    //           ),
                    //           IconButton(
                    //             icon: Icon(_muted ? Icons.volume_off : Icons.volume_up),
                    //             onPressed: provider.isPlayerReady
                    //                 ? () {
                    //                     _muted
                    //                         ? provider.controller.unMute()
                    //                         : provider.controller.mute();
                    //                     setState(() {
                    //                       _muted = !_muted;
                    //                     });
                    //                   }
                    //                 : null,
                    //           ),
                    //           FullScreenButton(
                    //             controller: provider.controller,
                    //             color: Colors.blueAccent,
                    //           ),
                    //           IconButton(
                    //             icon: const Icon(Icons.skip_next),
                    //             onPressed: provider.isPlayerReady
                    //                 ? () => provider.controller.load(provider.ids[
                    //                     (provider.ids.indexOf(provider.controller.metadata.videoId) +
                    //                             1) %
                    //                         provider.ids.length])
                    //                 : null,
                    //           ),
                    //         ],
                    //       ),
                    //       _space,
                    //       Row(
                    //         children: <Widget>[
                    //           const Text(
                    //             "Volume",
                    //             style: TextStyle(fontWeight: FontWeight.w300),
                    //           ),
                    //           Expanded(
                    //             child: Slider(
                    //               inactiveColor: Colors.transparent,
                    //               value: _volume,
                    //               min: 0.0,
                    //               max: 100.0,
                    //               divisions: 10,
                    //               label: '${(_volume).round()}',
                    //               onChanged: provider.isPlayerReady
                    //                   ? (value) {
                    //                       setState(() {
                    //                         _volume = value;
                    //                       });
                    //                       provider.controller.setVolume(_volume.round());
                    //                     }
                    //                   : null,
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //       _space,
                    //       AnimatedContainer(
                    //         duration: const Duration(milliseconds: 800),
                    //         decoration: BoxDecoration(
                    //           borderRadius: BorderRadius.circular(20.0),
                    //           color: _getStateColor(playerState),
                    //         ),
                    //         padding: const EdgeInsets.all(8.0),
                    //         child: Text(
                    //           playerState.toString(),
                    //           style: const TextStyle(
                    //             fontWeight: FontWeight.w300,
                    //             color: Colors.white,
                    //           ),
                    //           textAlign: TextAlign.center,
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),

            ///Skip screen
            if (provider.controller.value.isFullScreen)
              buildCutomScreenTapSkipWidget(provider),

            //thumbnail image
            if (provider.controller.value.isFullScreen)
              buildCutomThumbnailWidget(provider),

            ///Live indicator
            if (provider.controller.value.isFullScreen)
              buildCutomLiveIndicator(provider),

            /// progress bar and full screen button
            if (provider.controller.value.isFullScreen)
              buildCustomProgressBarWidget(provider),

            // ///play button
            // if (provider.controller.value.isFullScreen)
            // buildCustomPlayButton(provider)
          ],
        ),
      );
    });
  }

  Positioned buildCustomPlayButton(PlayerProvider provider) {
    return Positioned(
        top: 0,
        right: 0,
        bottom: 0,
        left: 0,
        child: AnimatedSwitcher(
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            duration: const Duration(milliseconds: 300),
            child: IconButton(
              icon: provider.controller.value.isPlaying
                  ? Icon(Icons.pause, color: Colors.white, size: 45.0)
                  : Icon(Icons.play_arrow, color: Colors.white, size: 45.0),
              onPressed: () {
                setState(() {
                  provider.controller.value.isPlaying
                      ? provider.controller.pause()
                      : provider.controller.play();
                });
              },
            )));
  }

  Positioned buildCustomProgressBarWidget(PlayerProvider provider) {
    return Positioned(
        left: 0,
        right: 0,
        bottom: 0,
        child: Container(
          padding: const EdgeInsets.all(5.0),
          margin: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            gradient: LinearGradient(
              colors: [
                Colors.blueGrey.withOpacity(0.8),
                Colors.blueGrey.withOpacity(0.8),
                Colors.blueGrey.withOpacity(0.8),
                Colors.blueGrey.withOpacity(0.8),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Row(
            children: [
              AnimatedSwitcher(
                  transitionBuilder: (child, animation) =>
                      FadeTransition(opacity: animation, child: child),
                  duration: const Duration(milliseconds: 300),
                  child: GestureDetector(
                    child: provider.controller.value.isPlaying
                        ? Icon(Icons.pause, color: Colors.white)
                        : Icon(Icons.play_arrow, color: Colors.white),
                    onTap: () {
                      setState(() {
                        provider.controller.value.isPlaying
                            ? provider.controller.pause()
                            : provider.controller.play();
                      });
                    },
                  )),
              width5(),
              Expanded(
                child: ProgressBar(
                  progress: Duration(
                      seconds: provider.controller.value.position.inSeconds),
                  buffered: Duration(
                      seconds: provider.controller.value.buffered.toInt()),
                  total: Duration(
                      seconds: provider
                          .controller.value.metaData.duration.inSeconds),
                  progressBarColor: Colors.red,
                  baseBarColor: Colors.white.withOpacity(0.24),
                  bufferedBarColor: Colors.white.withOpacity(0.24),
                  thumbColor: Colors.white,
                  barHeight: 10.0,
                  thumbRadius: 5.0,
                  timeLabelType: TimeLabelType.totalTime,
                  timeLabelLocation: TimeLabelLocation.above,
                  timeLabelPadding: 5,
                  timeLabelTextStyle:
                      TextStyle(color: Colors.white, fontSize: 12.0),
                  onSeek: (duration) {
                    provider.controller.seekTo(duration);
                  },
                ),
              ),
              width5(),
              PopupMenuButton<double>(
                constraints: const BoxConstraints(maxWidth: 70),
                itemBuilder: (_) => [
                  0.25,
                  0.5,
                  0.75,
                  1.0,
                  1.25,
                  1.50,
                  1.75,
                  2.0
                ]
                    .map((e) => PopupMenuItem(
                          child: capText(e.toString() + 'x', context,
                              color: provider.controller.value.playbackRate == e
                                  ? appLogoColor
                                  : Color.fromRGBO(0, 0, 0, 1)),
                          value: e,
                        ))
                    .toList(),
                onSelected: (val) {
                  provider.setPlaybackRate(val);
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                child: Container(
                  padding: const EdgeInsets.all(5.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    color: Colors.white,
                  ),
                  child: Text(
                    '${provider.controller.value.playbackRate}x',
                    style: const TextStyle(color: Colors.black, fontSize: 10),
                  ),
                ),
              ),
              width5(),
              GestureDetector(
                child: const Icon(Icons.fullscreen,
                    color: Colors.white, size: 25.0),
                onTap: () {
                  provider.controller.toggleFullScreenMode();
                },
              ),
            ],
          ),
        ));
  }

  Positioned buildCutomThumbnailWidget(PlayerProvider provide) {
    return Positioned(
        top: 0,
        right: 0,
        bottom: 0,
        left: 0,
        child: Visibility(
          visible: provider.timer.tick < 4,
          child: AnimatedOpacity(
            opacity: provider.timer.tick < 3 ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 4000),
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: NetworkImage(
                        'https://img.youtube.com/vi/${provider.controller.initialVideoId}/0.jpg'),
                    fit: BoxFit.cover),
              ),
            ),
          ),
        ));
  }

  Positioned buildCutomScreenTapSkipWidget(PlayerProvider provide) {
    return Positioned(
        top: 0,
        right: 0,
        bottom: 0,
        left: 0,
        child: Container(
            child: Row(children: [
          Expanded(
            child: GestureDetector(
              onDoubleTap: () {
                provider.controller.seekTo(Duration(
                    seconds:
                        provider.controller.value.position.inSeconds - 10));
              },
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onDoubleTap: () {
                provider.controller.seekTo(Duration(
                    seconds:
                        provider.controller.value.position.inSeconds + 10));
              },
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
        ])));
  }

  Positioned buildCutomLiveIndicator(PlayerProvider provide) {
    return Positioned(
        top: 10,
        right: 10,
        child: Visibility(
          visible: provider.controller.flags.isLive,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 2.0),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(2.0),
            ),
            child: Center(
              child: capText('Live', context),
            ),
          ),
        ));
  }

  Widget _text(String title, String value) {
    return RichText(
      text: TextSpan(
        text: '$title : ',
        style: const TextStyle(
          color: Colors.blueAccent,
          fontWeight: FontWeight.bold,
        ),
        children: [
          TextSpan(
            text: value,
            style: const TextStyle(
              color: Colors.blueAccent,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStateColor(PlayerState state) {
    switch (state) {
      case PlayerState.unknown:
        return Colors.grey[700]!;
      case PlayerState.unStarted:
        return Colors.pink;
      case PlayerState.ended:
        return Colors.red;
      case PlayerState.playing:
        return Colors.blueAccent;
      case PlayerState.paused:
        return Colors.orange;
      case PlayerState.buffering:
        return Colors.yellow;
      case PlayerState.cued:
        return Colors.blue[900]!;
      default:
        return Colors.blue;
    }
  }

  Widget get _space => const SizedBox(height: 10);

  Widget _loadCueButton(String action) {
    return Expanded(
      child: MaterialButton(
        color: Colors.blueAccent,
        onPressed: provider.isPlayerReady
            ? () {
                if (provider.idController.text.isNotEmpty) {
                  var id = YoutubePlayer.convertUrlToId(
                        provider.idController.text,
                      ) ??
                      '';
                  if (action == 'LOAD') provider.controller.load(id);
                  if (action == 'CUE') provider.controller.cue(id);
                  FocusScope.of(context).requestFocus(FocusNode());
                } else {
                  _showSnackBar('Source can\'t be empty!');
                }
              }
            : null,
        disabledColor: Colors.grey,
        disabledTextColor: Colors.black,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14.0),
          child: Text(
            action,
            style: const TextStyle(
              fontSize: 18.0,
              color: Colors.white,
              fontWeight: FontWeight.w300,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.w300,
            fontSize: 16.0,
          ),
        ),
        backgroundColor: Colors.blueAccent,
        behavior: SnackBarBehavior.floating,
        elevation: 1.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.0),
        ),
      ),
    );
  }
}

class PlayerProvider extends ChangeNotifier {
  late YoutubePlayerController controller;
  late TextEditingController idController;
  late TextEditingController seekToController;

  late PlayerState playerState;
  late YoutubeMetaData videoMetaData;
  double volume = 100;
  bool muted = false;
  bool isPlayerReady = false;
  List<String> ids = [];

  late Timer timer;
  void init() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      infoLog('timer is running ${timer.tick}');
      if (timer.tick > 3) {
        timer.cancel();
      }
      notifyListeners();
    });
    ids = [
      // 'iD9G6JqIyXE',
      // 'j0ez9lSNdFE',
      'ePplpyOQd74',
      'SMO2vY2yq1Q',
      '_WoCV4c6XOE',
      'KmzdUe0RSJo',
      '6jZDSSZZxjQ',
      'p2lYr3vM_1w',
      '7QUtEmBT_-w',
      '34_PXCzGw1M'
    ];
    controller = YoutubePlayerController(
      initialVideoId: ids.first,
      flags: const YoutubePlayerFlags(
        mute: false,
        autoPlay: true,
        disableDragSeek: false,
        loop: false,
        isLive: true,
        forceHD: true,
        enableCaption: false,
        hideControls: true,

        // startAt: 10,
        // coTimer.periodic(duration, (timer) { }), (timer) { })
      ),
    )
      ..addListener(listener)
      ..setVolume(100);
    idController = TextEditingController();
    seekToController = TextEditingController();
    videoMetaData = const YoutubeMetaData();
    playerState = PlayerState.unknown;
  }

  void listener() {
    infoLog(controller.value.playerState.toString());
    if (isPlayerReady && !controller.value.isFullScreen) {
      // infoLog('listener is running ${controller.flags.isLive}');
      // infoLog('listener is running ${controller.value.position.inSeconds}');
      infoLog('listener is running ${controller.value.buffered}');
      // errorLog());
      // controller
      // .updateValue(controller.value.copyWith(playbackQuality: 'hd1080'));

      errorLog(
          'listener is running ${controller.value.playbackQuality.toString()}');
      infoLog(
          'listener is running ${controller.value.metaData.duration.inSeconds}');
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      playerState = controller.value.playerState;
      videoMetaData = controller.metadata;
      controller.value.copyWith(playbackQuality: 'small');

      // change video qaulity
      controller.setSize(Size(Get.height, Get.width));
    } else {}
    notifyListeners();
  }

  setPlaybackRate(double val) {
    controller.setPlaybackRate(val);
    notifyListeners();
  }
}

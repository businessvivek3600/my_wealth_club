import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '/database/functions.dart';
import '/constants/assets_constants.dart';
import '/utils/picture_utils.dart';
import '/utils/color.dart';
import '/utils/default_logger.dart';
import '/utils/sizedbox_utils.dart';
import '/utils/text.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart'
    hide ProgressBar;

import '../sl_container.dart';

/// Homepage
class YoutubePlayerPage extends StatefulWidget {
  const YoutubePlayerPage({Key? key}) : super(key: key);

  static const String routeName = '/ytLive';

  @override
  _YoutubePlayerPageState createState() => _YoutubePlayerPageState();
}

class _YoutubePlayerPageState extends State<YoutubePlayerPage> {
  var provider = sl.get<PlayerProvider>();
  String? videoId;
  bool isLive = false;
  bool rotate = false;
  Map<String, dynamic>? eventData;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final args = ModalRoute.of(context)!.settings.arguments;
      successLog('arguments--> $args ${args.runtimeType}');
      if (args != null && args is String && args.isNotEmpty) {
        Map<String, dynamic> data = jsonDecode(args);
        setState(() {
          videoId = data['videoId'];
          isLive = data['isLive'];
          rotate = data['rotate'];
          eventData = data['data'];
        });
        if (videoId != null) {
          provider.init(videoId: videoId!, isLive: isLive);
        }
      }
      if (rotate) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight
        ]);
      }
    });
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
    provider.controlTimer?.cancel();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DateTime? date = DateTime.tryParse(eventData?['webinar_time'] ?? '');
    // return Container();
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<PlayerProvider>(builder: (context, provider, _) {
        return OrientationBuilder(builder: (context, orientation) {
          return Stack(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                    vertical: orientation == Orientation.portrait ? 0 : 35.0),
                child: YoutubePlayerBuilder(
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
                    topActions: <Widget>[],
                    onReady: () {
                      provider.isPlayerReady = true;
                    },
                    onEnded: (data) {
                      Get.back();
                      _showSnackBar('Thank you for watching!');
                    },
                  ),
                  builder: (context, player) => Scaffold(
                    backgroundColor: Colors.black,
                    appBar: buildAppBar(isLive: isLive, provider: provider),
                    body: Column(
                      children: [
                        Stack(
                          children: [
                            AspectRatio(
                                aspectRatio: 16 /
                                    9, //provider.controller.value.aspectRatio
                                child: player),

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
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      backgroundColor:
                                          (!isLive ? Colors.red : appLogoColor)
                                              .withOpacity(0.2),
                                      child: assetImages(Assets.appLogo_S,
                                          height: 25, width: 25),
                                    ),
                                    width10(),
                                    Expanded(
                                      child: titleLargeText(
                                          (eventData?['webinar_title'] ?? '')
                                              .toString()
                                              .capitalize!,
                                          context),
                                    ),
                                  ],
                                ),
                                height10(),
                                // create ui for time when started and total duration
                                if (date != null)
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Icon(Icons.calendar_month_rounded,
                                          color: Colors.white, size: 20),
                                      width10(),
                                      Expanded(
                                        child: bodyLargeText(
                                            'Started ${getTimeDifference(date)}',
                                            context,
                                            useGradient: false),
                                      ),
                                    ],
                                  ),

                                height10(),
                                // show location
                                // Row(
                                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                //   children: [
                                //     Icon(Icons.location_on,
                                //         color: Colors.pink, size: 20),
                                //     width10(),
                                //     Expanded(
                                //       child: bodyLargeText(
                                //           'Location: 123, ABC, XYZ', context,
                                //           useGradient: false),
                                //     ),
                                //   ],
                                // ),

                                // description headline
                                Divider(color: Colors.white),
                                if (eventData != null &&
                                    eventData!['webinar_desc'] != null)
                                  Expanded(
                                    child: ListView(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            width30(),
                                            Expanded(
                                                child: bodyLargeText(
                                                    (eventData?[
                                                            'webinar_desc'] ??
                                                        ''),
                                                    context,
                                                    useGradient: false,
                                                    color: Colors.white70,
                                                    maxLines: 200))
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
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

              /// progress bar and full screen button
              if (provider.controller.value.isFullScreen)
                buildFullScreenCloseWidget(provider),

              // ///play button
              // if (provider.controller.value.isFullScreen)
              // buildCustomPlayButton(provider)
            ],
          );
        });
      }),
    );
  }

  AppBar buildAppBar({required bool isLive, required PlayerProvider provider}) {
    return AppBar(
      backgroundColor:
          !isLive ? appLogoColor : Color.fromARGB(255, 227, 20, 20),
      title: Text('Event Name', style: TextStyle(color: Colors.white)),
      actions: [],
    );
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

  Positioned buildFullScreenCloseWidget(PlayerProvider provider) {
    return Positioned(
        top: 0,
        left: 0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          child: AnimatedOpacity(
            opacity: provider.showControls ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 500),
            child: Container(
              padding: const EdgeInsets.all(0.0),
              margin: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                // borderRadius: BorderRadius.circular(5.0),
                shape: BoxShape.circle,
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
              child: IconButton(
                  onPressed: () => Get.back(),
                  icon:
                      Icon(Icons.close_rounded, color: Colors.white, size: 20)),
            ),
          ),
        ));
  }

  Positioned buildCustomProgressBarWidget(PlayerProvider provider) {
    return Positioned(
        left: 0,
        right: 0,
        bottom: 0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          child: AnimatedOpacity(
            opacity: provider.showControls ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 500),
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
                            if (!provider.controller.value.isPlaying) {
                              provider.setShowControls(false);
                            } else {
                              provider.setShowControls(true);
                            }
                            errorLog(
                                'playing: ${provider.controller.value.isPlaying}, showControls ${provider.showControls}');
                          });
                        },
                      )),
                  width5(),
                  Expanded(
                    child: ProgressBar(
                      progress: Duration(
                          seconds:
                              provider.controller.value.position.inSeconds),
                      buffered: Duration(
                          seconds: provider.controller.value.buffered.toInt()),
                      total: Duration(
                          seconds: provider
                              .controller.value.metaData.duration.inSeconds),
                      progressBarColor:
                          _getStateColor(provider.controller.value.playerState),
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
                    itemBuilder: (_) =>
                        [0.25, 0.5, 0.75, 1.0, 1.25, 1.50, 1.75, 2.0]
                            .map((e) => PopupMenuItem(
                                  child: capText(e.toString() + 'x', context,
                                      color: provider.controller.value
                                                  .playbackRate ==
                                              e
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
                        style:
                            const TextStyle(color: Colors.black, fontSize: 10),
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
            ),
          ),
        ));
  }

  Positioned buildCutomThumbnailWidget(PlayerProvider provider) {
    return Positioned(
        top: 0,
        right: 0,
        bottom: 0,
        left: 0,
        child: Visibility(
          visible: provider.controller.value.isPlaying &&
              provider.controller.value.position.inSeconds < 4,
          child: AnimatedOpacity(
            opacity:
                provider.controller.value.position.inSeconds < 4 ? 1.0 : 0.0,
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
              onTap: () {
                provider.setShowControls(!provider.showControls);
                // provider.setShowControls(false, 3000);
              },
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
              onTap: () {
                provider.setShowControls(!provider.showControls);
              },
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
        return Color.fromARGB(255, 86, 54, 244);
      case PlayerState.playing:
        return isLive ? Colors.red : appLogoColor;
      case PlayerState.paused:
        return Colors.orange;
      case PlayerState.buffering:
        return Color.fromARGB(255, 241, 226, 85);
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
          style: const TextStyle(fontWeight: FontWeight.w300, fontSize: 16.0),
        ),
        backgroundColor: appLogoColor,
        behavior: SnackBarBehavior.floating,
        elevation: 1.0,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
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
  bool showControls = true;

  late Timer timer;
  Timer? controlTimer;
  void init({required String videoId, bool isLive = false}) {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      infoLog('timer is running ${timer.tick}');
      if (timer.tick > 4) {
        timer.cancel();
      }
      notifyListeners();
    });

    controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: YoutubePlayerFlags(
        mute: false,
        autoPlay: true,
        disableDragSeek: false,
        loop: false,
        isLive: isLive,
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
    // setShowControls(true, 3);
  }

  void listener() {
    // infoLog(controller.value.playerState.toString());
    if (isPlayerReady && !controller.value.isFullScreen) {
      // infoLog('listener is running ${controller.flags.isLive}');
      // infoLog('listener is running ${controller.value.position.inSeconds}');
      // infoLog('listener is running ${controller.value.buffered}');
      // errorLog());
      // controller
      // .updateValue(controller.value.copyWith(playbackQuality: 'hd1080'));

      // errorLog(
      //     'listener is running ${controller.value.playbackQuality.toString()}');
      // infoLog(
      //     'listener is running ${controller.value.metaData.duration.inSeconds}');
      infoLog('showControls $showControls');
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      playerState = controller.value.playerState;
      videoMetaData = controller.metadata;
      controller.value.copyWith(playbackQuality: 'small');
      successLog('metadata--> ${videoMetaData}');

      // change video qaulity
      // controller.setSize(Size(Get.height, Get.width));
    } else {}
    notifyListeners();
  }

  setPlaybackRate(double val) {
    controller.setPlaybackRate(val);
    notifyListeners();
  }

  setShowControls(bool val, [int s = 1]) {
    showControls = val;
    warningLog('playing: showControls $showControls');
    if (controlTimer != null) {
      controlTimer!.cancel();
    }
    controlTimer = Timer.periodic(Duration(seconds: s), (timer) {
      errorLog('playing: ${timer.tick}');
      if (timer.tick == 3) {
        showControls = false;
        notifyListeners();
        controlTimer?.cancel();
        infoLog('playing: showControls $showControls');
      }
    });
  }
}

/*

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
                

*/

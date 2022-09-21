import 'dart:async';
import 'package:flutter/material.dart';
import 'music.dart';
import 'song.dart';
import 'package:audioplayer/audioplayer.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Music',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Music'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// Future<List> fetchSongs() async {
//   const Map<String, dynamic> queryParams = {
//     'key': '484129036',
//     'locale': 'en-US'
//   };

//   const String url = 'https://shazam.p.rapidapi.com/songs/list-recommendations';

//   Uri uri = Uri.parse(url).replace(queryParameters: queryParams);

//   print('=== URI === : $uri');

//   final response = await http.get(
//     uri,
//     headers: {
//       'X-RapidAPI-Key': '4abb4befe9msh351e32036b75f09p1da1e7jsncf611b7b13f0',
//       'X-RapidAPI-Host': 'shazam.p.rapidapi.com'
//     },
//   );

//   print('StatusCode : ${response.statusCode}');

//   var body = json.decode(response.body);
//   var tracks = body['tracks'];
//   var firstTrack = tracks[0];
//   var title = firstTrack['title'];

//   print('=== TITLE === : $title');

//   if (response.statusCode == 200) {
//     var body = jsonDecode(response.body);
//     return body['tracks'];
//   } else {
//     throw Exception(' === ERROR ====  : $response');
//   }
// }

// Enum
enum ActionMusic { play, pause, rewind, forward }

enum PlayerState { stopped, playing, paused }

class _MyHomePageState extends State<MyHomePage> {
  // Musics
  final List<Music> musicList = [
    Music('Musique 1', 'Pink Floyd', 'assets/ecran1.jpeg',
        'https://codabee.com/wp-content/uploads/2018/06/un.mp3'),
    Music('Musique 2', 'Pink Floyd', 'assets/ecran2.jpeg',
        'https://codabee.com/wp-content/uploads/2018/06/deux.mp3')
  ];

  // late List songs;

  // Audio player
  late StreamSubscription positionSub;
  late StreamSubscription stateSubscription;
  late AudioPlayer audioPlayer;
  PlayerState status = PlayerState.stopped;

  late Music currentMusic;
  Duration sliderPosition = const Duration(seconds: 0);
  Duration duration = const Duration(seconds: 0);
  int index = 0;

  @override
  void initState() {
    super.initState();
    // songs = await fetchSongs();
    currentMusic = musicList[index];
    initAudioPlayer();
  }

  // display text
  Container displayText(String text, double scale) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Text(
          text,
          textScaleFactor: scale,
          textAlign: TextAlign.center,
          style: const TextStyle(
              color: Colors.white, fontSize: 20.0, fontStyle: FontStyle.italic),
        ));
  }

  // button
  IconButton button(IconData icon, double size, ActionMusic action) {
    return IconButton(
        iconSize: size,
        color: Colors.white,
        icon: Icon(icon),
        onPressed: () {
          switch (action) {
            case ActionMusic.play:
              print('play');
              playMusic();
              break;
            case ActionMusic.pause:
              print('pause');
              pauseMusic();
              break;
            case ActionMusic.rewind:
              print('rewind');
              rewind();
              break;
            case ActionMusic.forward:
              print('forward');
              forward();
              break;
          }
        });
  }

  // Audio player configuration
  void initAudioPlayer() {
    audioPlayer = AudioPlayer();
    positionSub = audioPlayer.onAudioPositionChanged.listen((p) => setState(() {
          sliderPosition = p;
        }));
    stateSubscription = audioPlayer.onPlayerStateChanged.listen((s) {
      if (s == AudioPlayerState.PLAYING) {
        setState(() {
          duration = audioPlayer.duration;
        });
      } else if (s == AudioPlayerState.STOPPED) {
        setState(() {
          status = PlayerState.stopped;
        });
      }
    }, onError: (msg) {
      print('Erreur : $msg');
      setState(() {
        status = PlayerState.stopped;
        duration = const Duration(seconds: 0);
        sliderPosition = const Duration(seconds: 0);
      });
    });
  }

  // Play music
  Future playMusic() async {
    await audioPlayer.play(currentMusic.song);
    setState(() {
      status = PlayerState.playing;
    });
  }

  // Pause music
  Future pauseMusic() async {
    await audioPlayer.pause();
    setState(() {
      status = PlayerState.paused;
    });
  }

  // Next
  void forward() {
    if (index == musicList.length - 1)
      index = 0;
    else
      index++;

    currentMusic = musicList[index];
    audioPlayer.stop();
    initAudioPlayer();
    playMusic();
  }

  // Get Duration on String
  String fromDuration(Duration duration) {
    print(duration);
    return duration.toString().split('.').first;
  }

  // Previous
  void rewind() {
    if (sliderPosition > const Duration(seconds: 3)) {
      audioPlayer.seek(0.0);
    } else if (index == 0) {
      index = musicList.length - 1;
    } else {
      index--;
    }
    currentMusic = musicList[index];
    audioPlayer.stop();
    initAudioPlayer();
    playMusic();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.grey.shade900,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // FutureBuilder<Song>(
            //   future: songs,
            //   builder: (context, snapshot) {
            //     if (snapshot.hasData) {
            //       return Text(snapshot.data!.title);
            //     } else if (snapshot.hasError) {
            //       return Text('${snapshot.error}');
            //     }

            //     return const CircularProgressIndicator();
            //   },
            // ),
            Card(
                elevation: 9.0,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width / 1.5,
                  child: Image.asset(currentMusic.image),
                )),
            displayText(currentMusic.title, 1.5),
            displayText(currentMusic.artist, 1.0),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              button(Icons.fast_rewind, 30.0, ActionMusic.rewind),
              button(
                  status == PlayerState.playing
                      ? Icons.pause
                      : Icons.play_arrow,
                  45.0,
                  status == PlayerState.playing
                      ? ActionMusic.pause
                      : ActionMusic.play),
              button(Icons.fast_forward, 30.0, ActionMusic.forward),
            ]),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                displayText(fromDuration(sliderPosition), 0.8),
                displayText(fromDuration(duration), 0.8)
              ],
            ),
            Slider(
              value: sliderPosition.inSeconds.toDouble(),
              min: 0.0,
              max: 30.0,
              inactiveColor: Colors.white,
              activeColor: Colors.red,
              onChanged: (double d) {
                setState(() {
                  audioPlayer.seek(d);
                });
              },
            )
          ],
        ),
      ),
      backgroundColor: Colors.grey.shade800,
    );
  }
}

import 'dart:ui';
import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/track_player.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'home_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:toast/toast.dart';
class Player extends StatefulWidget {
  final Song data;
  Player({
    Key key,
    @required this.data,
  }) : super(key: key);

  @override
  _PlayerState createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  bool isplaying = false;
  bool isrepeat = false;
  bool isloading = true;
  double sliderCurrentPosition = 0.0;
  String _playerTxt = '00:00';
  double maxDuration = 1.0;
  StreamSubscription _playerSubscription;
  TrackPlayer trackPlayer = TrackPlayer();
  Track track;
  List<int> favsongid = [];

  Future<String> getJSONFavList() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "User.db");
    var database = await openDatabase(
      path,
    );
    List<Map> list = await database.rawQuery('SELECT * FROM userTable');
    var url = 'https://raagmusic.herokuapp.com/favid?name=' + list[0]['username'];
    var response = await http.get(url);
    if (response.statusCode == 200) {
      if (response.body != '[]') {
        var jsonResponse = convert.jsonDecode(response.body);
        if (this.mounted){
        setState(() {
          for (int i = 0; i < jsonResponse[0]['favouritesong'].length; i++) {
            favsongid.add(jsonResponse[0]['favouritesong'][i]);
          }
        });
      }
      }
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
    return "Successful";
  }

  favouritehandler(bool isfavourite, int id, context) async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "User.db");
    var database = await openDatabase(
      path,
    );
    List<Map> list = await database.rawQuery('SELECT * FROM userTable');
    if (isfavourite) {
      var url = 'https://raagmusic.herokuapp.com/removefavourite/' +
          list[0]['username'] +
          '/' +
          id.toString();
      var response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          favsongid.remove(id);
        });

        Toast.show("Removed from favourite", context,
            duration: Toast.LENGTH_SHORT,
            gravity: Toast.BOTTOM,
            backgroundColor: Colors.white70,
            textColor: Colors.black);
      } else {
        Toast.show("Try again later !", context,
            duration: Toast.LENGTH_SHORT,
            gravity: Toast.BOTTOM,
            backgroundColor: Colors.white70,
            textColor: Colors.black);
      }
    } else {
      var url = 'https://raagmusic.herokuapp.com/addfavourite/' +
          list[0]['username'] +
          '/' +
          id.toString();
      var response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          favsongid.add(id);
        });

        Toast.show("Added to favourite", context,
            duration: Toast.LENGTH_SHORT,
            gravity: Toast.BOTTOM,
            backgroundColor: Colors.white70,
            textColor: Colors.black);
      } else {
        Toast.show("Try again later !", context,
            duration: Toast.LENGTH_SHORT,
            gravity: Toast.BOTTOM,
            backgroundColor: Colors.white70,
            textColor: Colors.black);
      }
    }
  }

  Future<String> addtoRecent(int id) async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "User.db");
    var database = await openDatabase(
      path,
    );
    List<Map> list = await database.rawQuery('SELECT * FROM userTable');
    
    var url = 'https://raagmusic.herokuapp.com/addrecent/' +
        list[0]['username'] +
        '/' +
        id.toString();
    await http.get(url);
    return "Successful";
  }

 

  Future<void> play() async {
    setState(() {
      isplaying = true;
    });
    await trackPlayer.startPlayerFromTrack(
      track,
      onSkipBackward: () async {
        await trackPlayer.stopPlayer();
        play();
      },
      onSkipForward: () async {
        await trackPlayer.stopPlayer();
        play();
      },
      whenFinished: () async {
        if (isrepeat) {
          play();
          return;
        }
      },
    );
    setState(() {
      isloading = false;
      addtoRecent(widget.data.id);
    });

    _playerSubscription = trackPlayer.onPlayerStateChanged.listen((e) {
      if (e != null) {
        maxDuration = e.duration;
        if (maxDuration <= 0) maxDuration = 0.0;

        sliderCurrentPosition = min(e.currentPosition, maxDuration);
        if (sliderCurrentPosition < 0.0) {
          sliderCurrentPosition = 0.0;
        }
        initializeDateFormatting();
        DateTime date = new DateTime.fromMillisecondsSinceEpoch(
            e.currentPosition.toInt(),
            isUtc: true);
        String txt = DateFormat('mm:ss:SS', 'en_GB').format(date);
        this.setState(() {
          //this._isPlaying = true;
          this._playerTxt = txt.substring(0, 5);
        });
      }
    });
  }

  Future<void> resume() async {
    setState(() {
      isplaying = true;
    });
    await trackPlayer.resumePlayer();
  }

  Future<void> pause() async {
    setState(() {
      isplaying = false;
    });
    await trackPlayer.pausePlayer();
  }

  @override
  void initState() {
    super.initState();
    this.getJSONFavList();
    track = new Track(
      trackPath: widget.data.url, // An example audio file
      trackTitle: widget.data.name,
      trackAuthor: widget.data.artist,
      albumArtUrl: widget.data.cover, // An example image
    );
    play();
  }

  @override
  void dispose() {
    super.dispose();
    trackPlayer.stopPlayer();
    if (_playerSubscription != null) _playerSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: <Widget>[
      CachedNetworkImage(
        imageUrl: widget.data.cover,
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: imageProvider,
              fit: MediaQuery.of(context).size.height >
                      MediaQuery.of(context).size.width
                  ? BoxFit.cover
                  : BoxFit.fill,
            ),
          ),
        ),
        placeholder: (context, url) => Container(
          height: double.infinity,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 6.0),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
              color: Colors.black),
        ),
        errorWidget: (context, url, error) => Icon(Icons.error),
      ),
      Positioned.fill(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 200,
            sigmaY: 200,
          ),
          child: Container(
            color: Colors.black.withOpacity(0),
          ),
        ),
      ),
      Container(
        child: Column(children: <Widget>[
          SafeArea(
            child: Opacity(
              opacity: isloading ? 1.0 : 0.0,
              child: Container(
                height: 2.0,
                child: LinearProgressIndicator(
                    backgroundColor: Colors.transparent,
                    valueColor:
                        new AlwaysStoppedAnimation<Color>(Colors.white60)),
              ),
            ),
          ),
          Row(
            children: <Widget>[
              IconButton(
                  icon: Icon(Icons.arrow_back_ios),
                  color: Colors.white,
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              Expanded(
                  child: Text(widget.data.name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      ))),
              IconButton(
                  color: Colors.white,
                  icon: Icon(Icons.more_vert),
                  onPressed: () {}),
            ],
          ),
          MediaQuery.of(context).size.width < MediaQuery.of(context).size.height
              ? Expanded(
                  child: Center(
                    child: Container(
                      
                      //  height: 396,
                      //  width: 495,
                      padding: const EdgeInsets.only(
                          top: 12, left: 32, right: 32, bottom: 12),
                      child: Hero(
                        
                                   tag: widget.data.id.toString(),
                                  
                        child: CachedNetworkImage(
                            imageUrl: widget.data.cover,
                            imageBuilder: (context, imageProvider) => Container(
                              decoration: BoxDecoration(
                                //borderRadius:
                                //     BorderRadius.all(Radius.circular(8.0)),
                                // boxShadow: [
                                //   BoxShadow(
                                //     color: Colors.black.withOpacity(0.3),
                                //     spreadRadius: 5,
                                //     blurRadius: 7,
                                //     offset:
                                //         Offset(0, 3), // changes position of shadow
                                //   ),
                                // ],
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.contain,

                                  
                                ),
                              ),
                            ),
                            placeholder: (context, url) => Container(
                                height: double.infinity,
                                width: double.infinity,
                                margin: const EdgeInsets.symmetric(horizontal: 6.0),
                                decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8.0)),
                                    color: Colors.grey),
                                child: Icon(
                                  CupertinoIcons.double_music_note,
                                  color: Colors.white,
                                )),
                            errorWidget: (context, url, error) => Icon(Icons.error),
                          ),
                        ),
                    ),
                  ),
                )
              : Container(),
          Container(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Column(children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    MediaQuery.of(context).size.width >
                            MediaQuery.of(context).size.height
                        ? Container(
                            height: 140,
                            width: 140,
                            margin: const EdgeInsets.only(left: 32.0),
                            child: Hero( tag: widget.data.id.toString(),
                                                          child: CachedNetworkImage(
                                imageUrl: widget.data.cover,
                                imageBuilder: (context, imageProvider) =>
                                    Container(
                                  decoration: BoxDecoration(
                                    // borderRadius:
                                    //     BorderRadius.all(Radius.circular(8.0)),
                                    // boxShadow: [
                                    //   BoxShadow(
                                    //     color: Colors.black.withOpacity(0.3),
                                    //     spreadRadius: 5,
                                    //     blurRadius: 7,
                                    //     offset: Offset(
                                    //         0, 3), // changes position of shadow
                                    //   ),
                                    // ],
                                    image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                placeholder: (context, url) => Container(
                                    height: double.infinity,
                                    width: double.infinity,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 6.0),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8.0)),
                                        color: Colors.grey),
                                    child: Icon(
                                      CupertinoIcons.double_music_note,
                                      color: Colors.white,
                                    )),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                              ),
                            ),
                          )
                        : Container(),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            margin: const EdgeInsets.only(left: 32.0),
                            child: Text(widget.data.name,
                               overflow: TextOverflow.fade,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22.0,
                                    fontWeight: FontWeight.bold)),
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: 32.0),
                            child: Text(widget.data.artist,
                               overflow: TextOverflow.fade,
                                style: TextStyle(
                                    color: Colors.white54, fontSize: 12.0)),
                          ),
                        ]),
                    Expanded(
                      child: Text(''),
                    ),
                    Container(
                      margin: const EdgeInsets.only(right: 32.0),
                      child: 
                      //FavouriteButton(data: widget.data, ctx: context),

                            IconButton(
                            icon: favsongid.contains(widget.data.id)
                            ? Icon(
                                Icons.favorite,
                                color: Colors.red,
                                size: 30.0,
                              )
                            : Icon(
                                Icons.favorite_border,
                                color: Colors.white,
                                size: 30.0,
                              ),
                        onPressed: () {
                          favouritehandler(
                              favsongid.contains(widget.data.id),
                              widget.data.id,
                              context);
                        },
                        color: Colors.black,
                        hoverColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                      ),
                    ),
                  ],
                ),
                Slider(
                    value: min(sliderCurrentPosition, maxDuration),
                    activeColor: Colors.white,
                    inactiveColor: Colors.white10,
                    min: 0.0,
                    max: maxDuration,
                    onChanged: (double value) async {
                      await trackPlayer.seekToPlayer(value.toInt());
                    },
                    divisions: maxDuration == 0.0 ? 1 : maxDuration.toInt()),
                Row(children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(left: 32.0),
                    child: Text(_playerTxt,
                        style: TextStyle(color: Colors.white70, fontSize: 11)),
                  ),
                  Expanded(child: Text('')),
                  Container(
                      margin: const EdgeInsets.only(right: 32.0),
                      child: Text(widget.data.duration,
                          style:
                              TextStyle(color: Colors.white70, fontSize: 11))),
                ]),
                Row(children: <Widget>[
                  Expanded(
                    child: IconButton(
                      icon: Icon(Icons.shuffle),
                      onPressed: () {},
                      color: Colors.white24,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.skip_previous),
                    onPressed: () async {
                      await trackPlayer.stopPlayer();
                      play();
                    },
                    color: Colors.white,
                    iconSize: 42,
                  ),
                  IconButton(
                    icon: isplaying
                        ? Icon(Icons.pause_circle_filled)
                        : Icon(Icons.play_circle_filled),
                    onPressed: () {
                      if (isplaying)
                        pause();
                      else
                        resume();
                    },
                    color: Colors.white,
                    iconSize: 80,
                  ),
                  IconButton(
                    icon: Icon(Icons.skip_next),
                    onPressed: () async {
                      await trackPlayer.stopPlayer();
                      play();
                    },
                    color: Colors.white,
                    iconSize: 42,
                  ),
                  Expanded(
                    child: IconButton(
                      icon: Icon(Icons.repeat),
                      onPressed: () {
                        setState(() {
                          isrepeat = !isrepeat;
                        });
                      },
                      color: isrepeat ? Colors.white : Colors.white24,
                    ),
                  ),
                ]),
              ]))
        ]),
      ),
    ]));
  }
}




// class FavouriteButton extends StatefulWidget {
//   final Song data;
//   final BuildContext ctx;
//   FavouriteButton({
//     Key key,
//     @required this.data,
//     @required this.ctx,
//   }) : super(key: key);
//   @override
//   _FavouriteButtonState createState() => _FavouriteButtonState();
// }

// class _FavouriteButtonState extends State<FavouriteButton> {
//   List<int> favsongid = [];
//   void initState() {
//     super.initState();
//     this.getJSONFavList();
//   }

//   Future<String> getJSONFavList() async {
//     Directory documentsDirectory = await getApplicationDocumentsDirectory();
//     String path = join(documentsDirectory.path, "User.db");
//     var database = await openDatabase(
//       path,
//     );
//     List<Map> list = await database.rawQuery('SELECT * FROM userTable');
//     var url = 'https://raagmusic.herokuapp.com/favid?name=' + list[0]['username'];
//     var response = await http.get(url);
//     if (response.statusCode == 200) {
//       if (response.body != '[]') {
//         var jsonResponse = convert.jsonDecode(response.body);
//         setState(() {
//           for (int i = 0; i < jsonResponse[0]['favouritesong'].length; i++) {
//             favsongid.add(jsonResponse[0]['favouritesong'][i]);
//           }
//         });
//       }
//     } else {
//       print('Request failed with status: ${response.statusCode}.');
//     }
//     return "Successful";
//   }
//   Future<bool> onLikeButtonTapped(bool isLiked) async {
//     int id = widget.data.id;
//     bool isfavourite = favsongid.contains(widget.data.id);
//     //BuildContext context = _scaffoldKey.currentState.context;
//     Directory documentsDirectory = await getApplicationDocumentsDirectory();
//     String path = join(documentsDirectory.path, "User.db");
//     var database = await openDatabase(
//       path,
//     );
//     List<Map> list = await database.rawQuery('SELECT * FROM userTable');

//     var url = isfavourite
//         ? 'https://raagmusic.herokuapp.com/removefavourite/' +
//             list[0]['username'] +
//             '/' +
//             id.toString()
//         : 'https://raagmusic.herokuapp.com/addfavourite/' +
//             list[0]['username'] +
//             '/' +
//             id.toString();

//     var response = await http.get(url);
//     if (response.statusCode == 200) {
//       //setState(() {
//       if (isfavourite)
//         favsongid.remove(id);
//       else
//         favsongid.add(id);
//       //});

//       Toast.show(isfavourite ? "Removed from favourite" : "Added to favourite",
//           widget.ctx,
//           duration: Toast.LENGTH_SHORT,
//           gravity: Toast.BOTTOM,
//           backgroundColor: Colors.white70,
//           textColor: Colors.black);
//     } else {
//       Toast.show("Try again later !", widget.ctx,
//           duration: Toast.LENGTH_SHORT,
//           gravity: Toast.BOTTOM,
//           backgroundColor: Colors.white70,
//           textColor: Colors.black);
//     }
//     return !isLiked;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return LikeButton(
//       isLiked: favsongid.contains(widget.data.id),
//       circleColor: CircleColor(start: Colors.red, end: Colors.red),
//       bubblesColor: BubblesColor(
//           dotPrimaryColor: Colors.white, dotSecondaryColor: Colors.red),
//       likeBuilder: (bool isLiked) {
//         return Icon(
//           isLiked ? Icons.favorite : Icons.favorite_border,
//           color: isLiked ? Colors.red : Colors.white,
//         );
//       },
//       onTap: onLikeButtonTapped,
//     );
//   }
// }

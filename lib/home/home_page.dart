import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:like_button/like_button.dart';
import 'bottom_navy_bar.dart';
import 'playlist.dart';
import 'search.dart';
import 'route_generator.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_login/bloc/authentication_bloc.dart';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:toast/toast.dart';
import 'profile.dart';
import 'package:loading/loading.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';

class CircleTabIndicator extends Decoration {
  final BoxPainter _painter;

  CircleTabIndicator({@required Color color, @required double radius})
      : _painter = _CirclePainter(color, radius);

  @override
  BoxPainter createBoxPainter([onChanged]) => _painter;
}

class _CirclePainter extends BoxPainter {
  final Paint _paint;
  final double radius;

  _CirclePainter(Color color, this.radius)
      : _paint = Paint()
          ..color = color
          ..isAntiAlias = true;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration cfg) {
    final Offset circleOffset =
        offset + Offset(cfg.size.width / 2, cfg.size.height - radius);
    canvas.drawCircle(circleOffset, radius, _paint);
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Initially display FirstPage
      initialRoute: '/',
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}

class Song {
  int id;
  String name;
  String artist;
  int year;
  String url;
  String cover;
  String duration;
  Song(int id, String name, String artist, int year, String url, String cover,
      String duration) {
    this.id = id;
    this.name = name;
    this.artist = artist;
    this.year = year;
    this.url = url;
    this.cover = cover;
    this.duration = duration;
  }
}

class Album {
  int id;
  String albumname;
  String albumcover;
  List<Song> songlist;
  Album(int id, String albumname, String albumcover, List<Song> songlist) {
    this.id = id;
    this.albumname = albumname;
    this.albumcover = albumcover;
    this.songlist = songlist;
  }
}

class Artist {
  int id;
  String artistname;
  String artistcover;
  List<Song> songlist;
  Artist(int id, String artistname, String artistcover, List<Song> songlist) {
    this.id = id;
    this.artistname = artistname;
    this.artistcover = artistcover;
    this.songlist = songlist;
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Song> trendingsongs = [];

  List<Album> albums = [];
  List<Artist> artists = [];
  List<Album> playlist = [];
  String message = "";
  String username = "";
  int _currentIndex = 0;
  PageController _pageController;

  @override
  void initState() {
    super.initState();
    this.getJSONGreeting();
    this.getJSONtrendingSongs();
    this.getJSONUsername();
    this.getJSONalbums();
    this.getJSONartists();
    this.getJSONPlaylist();
    _pageController = PageController();
  }

  //   myuser() async{
  //   Directory documentsDirectory = await getApplicationDocumentsDirectory();
  //   String path = join(documentsDirectory.path, "User.db");
  //   var database = await openDatabase(path,);
  //   List<Map> list = await database.rawQuery('SELECT * FROM userTable');
  //   setState(() {
  //     username=list[0]['username'];
  //   });
  //   print(username);
  //  }

  Future<String> getJSONGreeting() async {
    var url = 'https://raagmusic.herokuapp.com/greeting?';
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      if (this.mounted) {
        setState(() {
          message = jsonResponse[0]['text'];
        });
      }
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
    return "Successful";
  }

  Future<String> getJSONtrendingSongs() async {
    var url = 'https://raagmusic.herokuapp.com/trending/';
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      for (int i = 0; i < jsonResponse[0]['songlist'].length; i++) {
        if (this.mounted) {
          setState(() {
            trendingsongs.add(
              Song(
                  (jsonResponse[0]['songlist'])[i]['id'],
                  (jsonResponse[0]['songlist'])[i]['name'],
                  (jsonResponse[0]['songlist'])[i]['artist'],
                  (jsonResponse[0]['songlist'])[i]['year'],
                  (jsonResponse[0]['songlist'])[i]['url'],
                  (jsonResponse[0]['songlist'])[i]['cover'],
                  (jsonResponse[0]['songlist'])[i]['duration']),
            );
          });
        }
      }
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
    return "Successful";
  }

  Future<String> getJSONUsername() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "User.db");
    var database = await openDatabase(
      path,
    );
    List<Map> list = await database.rawQuery('SELECT * FROM userTable');
    username = list[0]['username'];
    return "Successful";
  }

  Future<String> getJSONalbums() async {
    var url = 'https://raagmusic.herokuapp.com/trendingalbum/';
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      for (int i = 0;
          i <
              (jsonResponse[0]['albumlist'].length <= 8
                  ? jsonResponse[0]['albumlist'].length
                  : 8);
          i++) {
        List<Song> temp = [];

        ///

        for (int j = 0;
            j < jsonResponse[0]['albumlist'][i]['songlist'].length;
            j++) {
          temp.add(
            Song(
                (jsonResponse[0]['albumlist'][i]['songlist'])[j]['id'],
                (jsonResponse[0]['albumlist'][i]['songlist'])[j]['name'],
                (jsonResponse[0]['albumlist'][i]['songlist'])[j]['artist'],
                (jsonResponse[0]['albumlist'][i]['songlist'])[j]['year'],
                (jsonResponse[0]['albumlist'][i]['songlist'])[j]['url'],
                (jsonResponse[0]['albumlist'][i]['songlist'])[j]['cover'],
                (jsonResponse[0]['albumlist'][i]['songlist'])[j]['duration']),
          );
        }

        ///
        if (this.mounted) {
          setState(() {
            albums.add(Album(
              jsonResponse[0]['albumlist'][i]['id'],
              jsonResponse[0]['albumlist'][i]['albumname'],
              jsonResponse[0]['albumlist'][i]['albumcover'],
              temp,
            ));
          });
        }
      }
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }

    return "Successful";
  }

  Future<String> getJSONartists() async {
    var url = 'https://raagmusic.herokuapp.com/trendingartist/';
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      for (int i = 0;
          i <
              (jsonResponse[0]['artistlist'].length <= 8
                  ? jsonResponse[0]['artistlist'].length
                  : 8);
          i++) {
        List<Song> temp = [];

        ///

        for (int j = 0;
            j < jsonResponse[0]['artistlist'][i]['songlist'].length;
            j++) {
          temp.add(
            Song(
                (jsonResponse[0]['artistlist'][i]['songlist'])[j]['id'],
                (jsonResponse[0]['artistlist'][i]['songlist'])[j]['name'],
                (jsonResponse[0]['artistlist'][i]['songlist'])[j]['artist'],
                (jsonResponse[0]['artistlist'][i]['songlist'])[j]['year'],
                (jsonResponse[0]['artistlist'][i]['songlist'])[j]['url'],
                (jsonResponse[0]['artistlist'][i]['songlist'])[j]['cover'],
                (jsonResponse[0]['artistlist'][i]['songlist'])[j]['duration']),
          );
        }

        ///
        if (this.mounted) {
          setState(() {
            artists.add(Artist(
              jsonResponse[0]['artistlist'][i]['id'],
              jsonResponse[0]['artistlist'][i]['artistname'],
              jsonResponse[0]['artistlist'][i]['artistcover'],
              temp,
            ));
          });
        }
      }
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }

    return "Successful";
  }

  Future<String> getJSONPlaylist() async {
    var url = 'https://raagmusic.herokuapp.com/playlist/';
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      for (int i = 0; i < jsonResponse[0]['playlist'].length; i++) {
        List<Song> temp = [];
        for (int j = 0;
            j < jsonResponse[0]['playlist'][i]['songlist'].length;
            j++) {
          temp.add(
            Song(
                (jsonResponse[0]['playlist'][i]['songlist'])[j]['id'],
                (jsonResponse[0]['playlist'][i]['songlist'])[j]['name'],
                (jsonResponse[0]['playlist'][i]['songlist'])[j]['artist'],
                (jsonResponse[0]['playlist'][i]['songlist'])[j]['year'],
                (jsonResponse[0]['playlist'][i]['songlist'])[j]['url'],
                (jsonResponse[0]['playlist'][i]['songlist'])[j]['cover'],
                (jsonResponse[0]['playlist'][i]['songlist'])[j]['duration']),
          );
        }

        ///
        if (this.mounted) {
          setState(() {
            playlist.add(Album(
              jsonResponse[0]['playlist'][i]['id'],
              jsonResponse[0]['playlist'][i]['albumname'],
              jsonResponse[0]['playlist'][i]['albumcover'],
              temp,
            ));
          });
        }
      }
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }

    return "Successful";
  }

  @override
  void dispose() {
    _pageController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return message == ""
        ? Container(
            height: double.infinity,
            width: double.infinity,
            color: Color.fromRGBO(41, 43, 44, 0.5),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Icon(CupertinoIcons.double_music_note,color: Colors.white,size:64.0),
                  Loading(indicator: BallPulseIndicator()),
                ]))
        : Scaffold(
            key: _scaffoldKey,

            //Settingdrawer
            endDrawer: Drawer(
              child: Stack(children: <Widget>[
                Container(
                  height: double.infinity,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: new LinearGradient(
                        colors: [Colors.grey, Colors.black],
                        end: Alignment.topLeft,
                        begin: Alignment.bottomRight),
                  ),
                ),
                Container(
                  height: double.infinity,
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Transform.translate(
                        offset: Offset(40, 30),
                        child: Icon(CupertinoIcons.gear_solid,
                            size: 200.0, color: Colors.white10),
                      )
                    ],
                  ),
                ),
                SafeArea(
                  child: NotificationListener<OverscrollIndicatorNotification>(
                    onNotification: (overscroll) {
                      overscroll.disallowGlow();
                    },
                    child: ListView(
                      children: <Widget>[
                        Row(children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.arrow_back_ios),
                            color: Colors.white,
                            onPressed: () => Navigator.of(context).pop(),
                            hoverColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                          ),
                          Text(
                            ' Settings',
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ]),
                        Divider(
                          color: Colors.white,
                        ),
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext bc) => AlertDialog(
                                //backgroundColor: Colors.white12,

                                title: Text('Logout'),
                                content: Text('Are you sure?'),

                                actions: <Widget>[
                                  FlatButton(
                                    child: Text("LOGOUT"),
                                    onPressed: () {
                                      Navigator.of(bc).pop();
                                      BlocProvider.of<AuthenticationBloc>(
                                              context)
                                          .add(LoggedOut());
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  FlatButton(
                                    child: Text("CLOSE"),
                                    onPressed: () {
                                      Navigator.of(bc).pop();
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Container(
                              height: 55,
                              margin: const EdgeInsets.only(
                                  bottom: 12.0, left: 24.0, right: 24.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    spreadRadius: 1,
                                    blurRadius: 3,
                                    offset: Offset(
                                        0, 3), // changes position of shadow
                                  ),
                                ],
                              ),
                              child: Center(
                                  child: Wrap(
                                children: <Widget>[
                                  Transform.rotate(
                                      angle: 1.56,
                                      child: Icon(Icons.system_update_alt)),
                                  Text(
                                    'Logout',
                                    style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ))),
                        ),
                        GestureDetector(
                          onTap: () {
                            showAboutDialog(
                                context: context,
                                applicationName: 'Raag',
                                applicationVersion: '1.0.0',
                                applicationLegalese:
                                    'An elegant online music player',
                                applicationIcon: Icon(Icons.apps));
                          },
                          child: Container(
                              height: 55,
                              margin: const EdgeInsets.only(
                                  bottom: 12.0, left: 24.0, right: 24.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    spreadRadius: 1,
                                    blurRadius: 3,
                                    offset: Offset(
                                        0, 3), // changes position of shadow
                                  ),
                                ],
                              ),
                              child: Center(
                                  child: Wrap(
                                children: <Widget>[
                                  Icon(Icons.info_outline),
                                  Text(
                                    'About',
                                    style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ))),
                        ),
                      ],
                    ),
                  ),
                ),
              ]),
            ),
            endDrawerEnableOpenDragGesture: false,
            //
            backgroundColor: Color.fromRGBO(41, 43, 44, 0.5),
            body: NotificationListener<OverscrollIndicatorNotification>(
              onNotification: (overscroll) {
                overscroll.disallowGlow();
              },
              child: SizedBox.expand(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    if (this.mounted) {
                      setState(() => _currentIndex = index);
                    }
                  },
                  children: <Widget>[
                    Container(
                      child: (NotificationListener<
                              OverscrollIndicatorNotification>(
                          onNotification: (overscroll) {
                            overscroll.disallowGlow();
                          },
                          child: RefreshIndicator(
                              backgroundColor: Color.fromRGBO(41, 43, 44, 0.2),
                              color: Colors.white,
                              onRefresh: () async {
                                Navigator.pushReplacementNamed(context, '/');
                              },
                              child: Stack(
                                children: <Widget>[
                                  Container(
                                    height: double.infinity,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      gradient: new LinearGradient(
                                        colors: [
                                          message == 'Good evening'
                                              ? Colors.red[200]
                                              : message == 'Good afternoon'
                                                  ? Colors.orange[200]
                                                  : Colors.white70,
                                          Colors.transparent,
                                          Colors.transparent
                                        ],
                                        begin:
                                            MediaQuery.of(context).size.width >
                                                    MediaQuery.of(context)
                                                        .size
                                                        .height
                                                ? Alignment.topCenter
                                                : Alignment.topLeft,
                                        end: MediaQuery.of(context).size.width >
                                                MediaQuery.of(context)
                                                    .size
                                                    .height
                                            ? Alignment.bottomCenter
                                            : Alignment.center,
                                      ),
                                    ),
                                  ),
                                  ListView(
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      children: <Widget>[
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: <Widget>[
                                            IconButton(
                                              icon: Icon(CupertinoIcons.gear),
                                              iconSize: 25.0,
                                              color: Colors.white,
                                              onPressed: () {
                                                // Navigator.of(context).('/settings');

                                                _scaffoldKey.currentState
                                                    .openEndDrawer();
                                              },
                                              hoverColor: Colors.transparent,
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: <Widget>[
                                            Container(
                                              margin: const EdgeInsets.only(
                                                  left: 16.0),
                                              child: Text(message,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 25,
                                                  )),
                                            ),
                                          ],
                                        ),
                                        Container(
                                            margin: const EdgeInsets.only(
                                                left: 16.0,
                                                top: 16.0,
                                                right: 20.0),
                                            child: Row(
                                              children: <Widget>[
                                                Expanded(
                                                    child: Text("Trending ",
                                                        style: TextStyle(
                                                            color: Colors.grey,
                                                            fontSize: 20))),
                                                Icon(
                                                  Icons.whatshot,
                                                  color: Colors.orange,
                                                ),
                                              ],
                                            )),
                                        horizontalList(context, trendingsongs),
                                        RecentSong(),
                                        Container(
                                            margin: const EdgeInsets.only(
                                                left: 16.0,
                                                top: 20.0,
                                                right: 20.0),
                                            child: Row(
                                              children: <Widget>[
                                                Expanded(
                                                  child: Text("Artist",
                                                      style: TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 20)),
                                                ),
                                                Icon(
                                                  Icons.supervised_user_circle,
                                                  color:
                                                      Colors.lightGreenAccent,
                                                ),
                                              ],
                                            )),
                                        horizontalartistList(context, artists),
                                        Container(
                                            margin: const EdgeInsets.only(
                                                left: 16.0,
                                                top: 20.0,
                                                right: 20.0),
                                            child: Row(
                                              children: <Widget>[
                                                Expanded(
                                                  child: Text("Albums",
                                                      style: TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 20)),
                                                ),
                                                Icon(
                                                  Icons.album,
                                                  color: Colors.blue,
                                                ),
                                              ],
                                            )),
                                        horizontalalbumList(context, albums),
                                      ]),
                                ],
                              )))),
                    ),
                    Search(playlist: playlist),
                    Container(child: Myfavourite()),
                    Profile(username: username, scaffoldkey: _scaffoldKey),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: BottomNavyBar(
              backgroundColor: Colors.black45,
              selectedIndex: _currentIndex,
              onItemSelected: (index) {
                if (this.mounted) {
                  setState(() => _currentIndex = index);
                }
                _pageController.jumpToPage(index);
              },
              items: <BottomNavyBarItem>[
                BottomNavyBarItem(
                  icon: Icon(Icons.home),
                  title: Text('Home'),
                  inactiveColor: Colors.white54,
                  activeColor: message == 'Good evening'
                      ? Colors.red[200]
                      : message == 'Good afternoon'
                          ? Colors.orange[200]
                          : Colors.white70,
                  //activeColor: Colors.white,
                  textAlign: TextAlign.center,
                ),
                BottomNavyBarItem(
                  icon: Icon(CupertinoIcons.search),
                  title: Text('Search'),
                  inactiveColor: Colors.white54,
                  activeColor: Colors.greenAccent[100],
                  textAlign: TextAlign.center,
                ),
                BottomNavyBarItem(
                  icon: Icon(CupertinoIcons.double_music_note),
                  title: Text('My Liberary'),
                  inactiveColor: Colors.white54,
                  activeColor: Colors.deepPurpleAccent[100],
                  textAlign: TextAlign.center,
                ),
                BottomNavyBarItem(
                  icon: Icon(CupertinoIcons.person_solid),
                  title: Text('Profile'),
                  inactiveColor: Colors.white54,
                  activeColor: Colors.cyanAccent[100],
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
  }
}

class RecentSong extends StatefulWidget {
  @override
  _RecentSongState createState() => _RecentSongState();
}

class _RecentSongState extends State<RecentSong> {
  List<Song> recentsongs = [];
  Future<String> getJSONRecentSongs() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "User.db");
    var database = await openDatabase(
      path,
    );
    List<Map> list = await database.rawQuery('SELECT * FROM userTable');
    //username = list[0]['username'];
    var url =
        'https://raagmusic.herokuapp.com/recent?name=' + list[0]['username'];
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);

      if (response.body != '[]') {
        for (int i = 0;
            i <
                (jsonResponse[0]['songlist'].length <= 8
                    ? jsonResponse[0]['songlist'].length
                    : 8);
            i++) {
          if (this.mounted) {
            setState(() {
              recentsongs.add(
                Song(
                    (jsonResponse[0]['songlist'])[i]['id'],
                    (jsonResponse[0]['songlist'])[i]['name'],
                    (jsonResponse[0]['songlist'])[i]['artist'],
                    (jsonResponse[0]['songlist'])[i]['year'],
                    (jsonResponse[0]['songlist'])[i]['url'],
                    (jsonResponse[0]['songlist'])[i]['cover'],
                    (jsonResponse[0]['songlist'])[i]['duration']),
              );
            });
          }
        }
      }
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
    return "Successful";
  }

  @override
  void initState() {
    super.initState();
    getJSONRecentSongs();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      recentsongs.length > 0
          ? (Container(
              margin: const EdgeInsets.only(left: 16.0, top: 20.0, right: 20.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text("Recently played ",
                        style: TextStyle(color: Colors.grey, fontSize: 20)),
                  ),
                  Icon(
                    Icons.history,
                    color: Colors.pink,
                  ),
                ],
              )))
          : Container(),
      recentsongs.length > 0
          ? horizontalList(context, recentsongs)
          : Container(),
    ]);
  }
}

Widget horizontalList(context, trendingsongs) {
  return (Container(
    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    //height: MediaQuery.of(context).size.height * 0.18,
    height: 180,
    child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: (trendingsongs == null) ? 0 : trendingsongs.length,
        itemBuilder: (context, index) {
          return Container(
            //width: MediaQuery.of(context).size.width * 0.31,
            width: 140,
            child: Column(
              children: <Widget>[
                Expanded(
                  child: CachedNetworkImage(
                    imageUrl: trendingsongs[index].cover,
                    imageBuilder: (context, imageProvider) => GestureDetector(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          '/player',
                          arguments: trendingsongs[index],
                        );
                      },
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
                    errorWidget: (context, url, error) => Container(
                        height: double.infinity,
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 6.0),
                        decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(8.0)),
                            color: Colors.grey),
                        child: Icon(
                          Icons.error,
                          color: Colors.white,
                        )),
                  ),
                ),
                Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 5.0, horizontal: 7.0),
                    child: Row(children: <Widget>[
                      Expanded(
                        child: Text(
                          trendingsongs[index].name,
                          style: TextStyle(color: Colors.white),
                          overflow: TextOverflow.fade,
                          softWrap: false,
                        ),
                      ),
                    ])),
              ],
            ),
          );
        }),
  ));
}

Widget horizontalalbumList(context, albums) {
  return (Container(
    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    //height: MediaQuery.of(context).size.height * 0.18,
    height: 180,
    child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: (albums == null) ? 0 : albums.length,
        itemBuilder: (context, index) {
          return Container(
            //width: MediaQuery.of(context).size.width * 0.31,
            width: 140,
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Hero(
                    tag: 'album' + albums[index].id.toString(),
                    child: CachedNetworkImage(
                      imageUrl: albums[index].albumcover,
                      imageBuilder: (context, imageProvider) => GestureDetector(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 5.0),
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(8.0)),
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            '/playlist',
                            arguments: albums[index],
                          );
                        },
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
                            Icons.album,
                            color: Colors.white,
                          )),
                      errorWidget: (context, url, error) => Container(
                          height: double.infinity,
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(horizontal: 6.0),
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                              color: Colors.grey),
                          child: Icon(
                            Icons.error,
                            color: Colors.white,
                          )),
                    ),
                  ),
                ),
                Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 5.0, horizontal: 7.0),
                    child: Row(children: <Widget>[
                      Expanded(
                        child: Text(
                          albums[index].albumname,
                          style: TextStyle(color: Colors.white),
                          overflow: TextOverflow.fade,
                          softWrap: false,
                        ),
                      ),
                    ])),
              ],
            ),
          );
        }),
  ));
}

Widget horizontalartistList(context, artists) {
  return (Container(
    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    //height: MediaQuery.of(context).size.height * 0.18,
    height: 168,
    child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: (artists == null) ? 0 : artists.length,
        itemBuilder: (context, index) {
          return Container(
            //width: MediaQuery.of(context).size.width * 0.31,
            width: 137,
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Hero(
                    tag: 'artist' + artists[index].id.toString(),
                    child: CachedNetworkImage(
                      imageUrl: artists[index].artistcover,
                      imageBuilder: (context, imageProvider) => GestureDetector(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 5.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            '/artistplaylist',
                            arguments: artists[index],
                          );
                        },
                      ),
                      placeholder: (context, url) => Container(
                          height: double.infinity,
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(horizontal: 6.0),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: Colors.grey),
                          child: Icon(
                            Icons.supervised_user_circle,
                            color: Colors.white,
                          )),
                      errorWidget: (context, url, error) => Container(
                          height: double.infinity,
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(horizontal: 6.0),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: Colors.grey),
                          child: Icon(
                            Icons.error,
                            color: Colors.white,
                          )),
                    ),
                  ),
                ),
                Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 5.0, horizontal: 7.0),
                    child: Row(children: <Widget>[
                      Expanded(
                        child: Text(
                          artists[index].artistname,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.fade,
                          softWrap: false,
                        ),
                      ),
                    ])),
              ],
            ),
          );
        }),
  ));
}

class Myfavourite extends StatefulWidget {
  @override
  _MyfavouriteState createState() => _MyfavouriteState();
}

class _MyfavouriteState extends State<Myfavourite> {
  List<Song> songs = [];
  List<Album> albums = [];
  List<Artist> artists = [];

  @override
  void initState() {
    super.initState();
    this.getJSONsongs();
    this.getJSONalbums();
    this.getJSONartists();
  }

  Future<String> getJSONsongs() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "User.db");
    var database = await openDatabase(
      path,
    );
    List<Map> list = await database.rawQuery('SELECT * FROM userTable');
    var url =
        'https://raagmusic.herokuapp.com/favsong?name=' + list[0]['username'];
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);

      if (response.body != '[]') {
        for (int i = 0; i < jsonResponse[0]['favouritesong'].length; i++) {
          if (this.mounted) {
            setState(() {
              songs.add(
                Song(
                    (jsonResponse[0]['favouritesong'])[i]['id'],
                    (jsonResponse[0]['favouritesong'])[i]['name'],
                    (jsonResponse[0]['favouritesong'])[i]['artist'],
                    (jsonResponse[0]['favouritesong'])[i]['year'],
                    (jsonResponse[0]['favouritesong'])[i]['url'],
                    (jsonResponse[0]['favouritesong'])[i]['cover'],
                    (jsonResponse[0]['favouritesong'])[i]['duration']),
              );
            });
          }
        }
      }
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
    return "Successful";
  }

  Future<String> getJSONalbums() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "User.db");
    var database = await openDatabase(
      path,
    );
    List<Map> list = await database.rawQuery('SELECT * FROM userTable');
    var url =
        'https://raagmusic.herokuapp.com/favalbum?name=' + list[0]['username'];
    var response = await http.get(url);
    if (response.statusCode == 200) {
      if (response.body != '[]') {
        var jsonResponse = convert.jsonDecode(response.body);

        for (int i = 0; i < jsonResponse[0]['favouritealbum'].length; i++) {
          List<Song> temp = [];

          ///

          for (int j = 0;
              j < jsonResponse[0]['favouritealbum'][i]['songlist'].length;
              j++) {
            temp.add(
              Song(
                  (jsonResponse[0]['favouritealbum'][i]['songlist'])[j]['id'],
                  (jsonResponse[0]['favouritealbum'][i]['songlist'])[j]['name'],
                  (jsonResponse[0]['favouritealbum'][i]['songlist'])[j]
                      ['artist'],
                  (jsonResponse[0]['favouritealbum'][i]['songlist'])[j]['year'],
                  (jsonResponse[0]['favouritealbum'][i]['songlist'])[j]['url'],
                  (jsonResponse[0]['favouritealbum'][i]['songlist'])[j]
                      ['cover'],
                  (jsonResponse[0]['favouritealbum'][i]['songlist'])[j]
                      ['duration']),
            );
          }

          ///
          if (this.mounted) {
            setState(() {
              albums.add(Album(
                jsonResponse[0]['favouritealbum'][i]['id'],
                jsonResponse[0]['favouritealbum'][i]['albumname'],
                jsonResponse[0]['favouritealbum'][i]['albumcover'],
                temp,
              ));
            });
          }
        }
      }
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }

    return "Successful";
  }

  Future<String> getJSONartists() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "User.db");
    var database = await openDatabase(
      path,
    );
    List<Map> list = await database.rawQuery('SELECT * FROM userTable');
    var url =
        'https://raagmusic.herokuapp.com/favartist?name=' + list[0]['username'];
    var response = await http.get(url);

    if (response.statusCode == 200) {
      if (response.body != '[]') {
        var jsonResponse = convert.jsonDecode(response.body);

        for (int i = 0; i < jsonResponse[0]['favouriteartist'].length; i++) {
          List<Song> temp = [];

          ///

          for (int j = 0;
              j < jsonResponse[0]['favouriteartist'][i]['songlist'].length;
              j++) {
            temp.add(
              Song(
                  (jsonResponse[0]['favouriteartist'][i]['songlist'])[j]['id'],
                  (jsonResponse[0]['favouriteartist'][i]['songlist'])[j]
                      ['name'],
                  (jsonResponse[0]['favouriteartist'][i]['songlist'])[j]
                      ['artist'],
                  (jsonResponse[0]['favouriteartist'][i]['songlist'])[j]
                      ['year'],
                  (jsonResponse[0]['favouriteartist'][i]['songlist'])[j]['url'],
                  (jsonResponse[0]['favouriteartist'][i]['songlist'])[j]
                      ['cover'],
                  (jsonResponse[0]['favouriteartist'][i]['songlist'])[j]
                      ['duration']),
            );
          }

          ///
          if (this.mounted) {
            setState(() {
              artists.add(Artist(
                jsonResponse[0]['favouriteartist'][i]['id'],
                jsonResponse[0]['favouriteartist'][i]['artistname'],
                jsonResponse[0]['favouriteartist'][i]['artistcover'],
                temp,
              ));
            });
          }
        }
      }
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }

    return "Successful";
  }

  Widget build(BuildContext context) {
    return
        /////

        Stack(
      children: <Widget>[
        Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: new LinearGradient(
                colors: [Colors.deepPurpleAccent[100], Colors.transparent],
                begin: Alignment.topCenter,
                end: Alignment.center
                //begin: MediaQuery.of(context).size.width>MediaQuery.of(context).size.height? Alignment.topRight:Alignment.topLeft,
                //end:  MediaQuery.of(context).size.width>MediaQuery.of(context).size.height? Alignment.bottomLeft:Alignment.bottomRight,

                ),
          ),
        ),
        DefaultTabController(
            length: 3,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: SafeArea(
                child: NestedScrollView(
                  headerSliverBuilder:
                      (BuildContext context, bool innerBoxIsScrolled) {
                    return <Widget>[
                      SliverAppBar(
                        backgroundColor: Colors.transparent,
                        //expandedHeight: MediaQuery.of(context).size.height * 0.20,
                        expandedHeight: 180,
                        pinned: false,
                        flexibleSpace: FlexibleSpaceBar(
                          // Text('bunty',
                          //     style: TextStyle(
                          //       color: Colors.white,
                          //       fontSize: 16.0,
                          //     )),
                          background: Container(
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 32.0),
                                    child: Text(
                                      'favourites',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 42.0),
                                    ),
                                  ),
                                ]),
                          ),
                        ),
                      ),
                    ];
                  },
                  body: Column(
                    children: <Widget>[
                      Expanded(
                        child: TabBarView(children: [
                          FavouriteTile(
                            songlist: songs,
                          ),
                          albums.isEmpty
                              ? Container(
                                  child: Center(
                                      child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    LikeButton(
                                      circleColor: CircleColor(
                                          start: Colors.white70,
                                          end: Colors.white70),
                                      bubblesColor: BubblesColor(
                                          dotPrimaryColor: Colors.white70,
                                          dotSecondaryColor: Colors.white70),
                                      isLiked: false,
                                      likeBuilder: (bool isLiked) {
                                        return Icon(
                                          Icons.favorite_border,
                                          color: Colors.white70,
                                        );
                                      },
                                    ),
                                    Text('Your liked albums will appear here',
                                        style: TextStyle(
                                          color: Colors.white70,
                                        )),
                                  ],
                                )))
                              : GridView.count(
                                  // Create a grid with 2 columns. If you change the scrollDirection to
                                  // horizontal, this produces 2 rows.
                                  crossAxisCount:
                                      MediaQuery.of(context).size.width <
                                              MediaQuery.of(context).size.height
                                          ? 3
                                          : 6,

                                  // Generate 100 widgets that display their index in the List.
                                  children:
                                      List.generate(albums.length, (index) {
                                    return Container(
                                      margin: const EdgeInsets.only(
                                          left: 6.0, right: 6.0),
                                      child: Column(
                                        children: <Widget>[
                                          Expanded(
                                            child: Hero(
                                              tag: 'album' +
                                                  albums[index].id.toString(),
                                              child: CachedNetworkImage(
                                                imageUrl:
                                                    albums[index].albumcover,
                                                imageBuilder:
                                                    (context, imageProvider) =>
                                                        GestureDetector(
                                                  child: Container(
                                                    margin: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 5.0),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  8.0)),
                                                      image: DecorationImage(
                                                        image: imageProvider,
                                                        fit: BoxFit.fill,
                                                      ),
                                                    ),
                                                  ),
                                                  onTap: () {
                                                    Navigator.of(context)
                                                        .pushNamed(
                                                      '/playlist',
                                                      arguments: albums[index],
                                                    );
                                                  },
                                                ),
                                                placeholder: (context, url) =>
                                                    Container(
                                                        height: double.infinity,
                                                        width: double.infinity,
                                                        margin: const EdgeInsets
                                                                .symmetric(
                                                            horizontal: 6.0),
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            8.0)),
                                                            color: Colors.grey),
                                                        child: Icon(
                                                          CupertinoIcons
                                                              .double_music_note,
                                                          color: Colors.white,
                                                        )),
                                                errorWidget: (context, url,
                                                        error) =>
                                                    Container(
                                                        height: double.infinity,
                                                        width: double.infinity,
                                                        margin: const EdgeInsets
                                                                .symmetric(
                                                            horizontal: 6.0),
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            8.0)),
                                                            color: Colors.grey),
                                                        child: Icon(
                                                          Icons.error,
                                                          color: Colors.white,
                                                        )),
                                              ),
                                            ),
                                          ),
                                          Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 5.0,
                                                      horizontal: 7.0),
                                              child: Row(children: <Widget>[
                                                Expanded(
                                                  child: Text(
                                                    albums[index].albumname,
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                    overflow: TextOverflow.fade,
                                                    softWrap: false,
                                                  ),
                                                ),
                                              ])),
                                        ],
                                      ),
                                    );
                                  }),
                                ),
                          artists.isEmpty
                              ? Container(
                                  child: Center(
                                      child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    LikeButton(
                                      circleColor: CircleColor(
                                          start: Colors.white70,
                                          end: Colors.white70),
                                      bubblesColor: BubblesColor(
                                          dotPrimaryColor: Colors.white70,
                                          dotSecondaryColor: Colors.white70),
                                      isLiked: false,
                                      likeBuilder: (bool isLiked) {
                                        return Icon(
                                          Icons.favorite_border,
                                          color: Colors.white70,
                                        );
                                      },
                                    ),
                                    Text('Your liked artists will appear here',
                                        style: TextStyle(
                                          color: Colors.white70,
                                        )),
                                  ],
                                )))
                              : GridView.count(
                                  // Create a grid with 2 columns. If you change the scrollDirection to
                                  // horizontal, this produces 2 rows.
                                  crossAxisCount:
                                      MediaQuery.of(context).size.height >
                                              MediaQuery.of(context).size.width
                                          ? 3
                                          : 6,
                                  // Generate 100 widgets that display their index in the List.
                                  children:
                                      List.generate(artists.length, (index) {
                                    return Container(
                                      margin: const EdgeInsets.only(
                                          left: 6.0, right: 6.0),
                                      //width: MediaQuery.of(context).size.width * 0.29,

                                      child: Column(
                                        children: <Widget>[
                                          Expanded(
                                            child: Hero(
                                              tag: 'artist' +
                                                  artists[index].id.toString(),
                                              child: CachedNetworkImage(
                                                imageUrl:
                                                    artists[index].artistcover,
                                                imageBuilder:
                                                    (context, imageProvider) =>
                                                        GestureDetector(
                                                  child: Container(
                                                    margin: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 6.0),
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      image: DecorationImage(
                                                        image: imageProvider,
                                                        fit: BoxFit.fill,
                                                      ),
                                                    ),
                                                  ),
                                                  onTap: () {
                                                    Navigator.of(context)
                                                        .pushNamed(
                                                      '/artistplaylist',
                                                      arguments: artists[index],
                                                    );
                                                  },
                                                ),
                                                placeholder: (context, url) =>
                                                    Container(
                                                        height: double.infinity,
                                                        width: double.infinity,
                                                        margin: const EdgeInsets
                                                                .symmetric(
                                                            horizontal: 6.0),
                                                        decoration:
                                                            BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                color: Colors
                                                                    .grey),
                                                        child: Icon(
                                                          Icons
                                                              .supervised_user_circle,
                                                          color: Colors.white,
                                                        )),
                                                errorWidget: (context, url,
                                                        error) =>
                                                    Container(
                                                        height: double.infinity,
                                                        width: double.infinity,
                                                        margin: const EdgeInsets
                                                                .symmetric(
                                                            horizontal: 6.0),
                                                        decoration:
                                                            BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                color: Colors
                                                                    .grey),
                                                        child: Icon(
                                                          Icons.error,
                                                          color: Colors.white,
                                                        )),
                                              ),
                                            ),
                                          ),
                                          Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 5.0,
                                                      horizontal: 7.0),
                                              child: Row(children: <Widget>[
                                                Expanded(
                                                  child: Text(
                                                    artists[index].artistname,
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                    overflow: TextOverflow.fade,
                                                    softWrap: false,
                                                  ),
                                                ),
                                              ])),
                                        ],
                                      ),
                                    );
                                  }),
                                ),
                        ]),
                      ),
                      Container(
                        //padding: const EdgeInsets.only(left: 46.0, right: 46.0),
                        //width: MediaQuery.of(context).size.width*0.7,
                        //  decoration: BoxDecoration(

                        //    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30.0),bottomRight:Radius.circular(30.0),topRight:Radius.circular(30.0),topLeft:Radius.circular(30.0)),
                        //  ),
                        margin: const EdgeInsets.only(bottom: 5.0),

                        child: TabBar(
                            indicatorWeight: 0,
                            labelColor: Colors.white,
                            unselectedLabelColor: Colors.white30,
                            indicatorSize: TabBarIndicatorSize.tab,
                            indicator: CircleTabIndicator(
                                color: Colors.white, radius: 3),
                            tabs: [
                              Tab(
                                child: Text("Songs"),
                              ),
                              Tab(
                                child: Text("Album/Playlist"),
                              ),
                              Tab(
                                child: Text("Artist"),
                              ),
                            ]),
                      ),
                    ],
                  ),
                ),
              ),
            )),
      ],
    );

    ////
  }
}

class FavouriteTile extends StatefulWidget {
  final List<Song> songlist;

  FavouriteTile({
    Key key,
    @required this.songlist,
  }) : super(key: key);
  @override
  _FavouriteTileState createState() => _FavouriteTileState();
}

class _FavouriteTileState extends State<FavouriteTile> {
  favouriteHandler(int index, context) async {
    int id = widget.songlist[index].id;
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "User.db");
    var database = await openDatabase(
      path,
    );
    List<Map> list = await database.rawQuery('SELECT * FROM userTable');
    var url = 'https://raagmusic.herokuapp.com/removefavourite/' +
        list[0]['username'] +
        '/' +
        id.toString();
    var response = await http.get(url);
    if (response.statusCode == 200) {
      if (this.mounted) {
        setState(() {
          widget.songlist.remove(widget.songlist[index]);
        });
      }

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
  }

  @override
  Widget build(BuildContext context) {
    return widget.songlist.isEmpty
        ? Container(
            child: Center(
                child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              LikeButton(
                circleColor:
                    CircleColor(start: Colors.white70, end: Colors.white70),
                bubblesColor: BubblesColor(
                    dotPrimaryColor: Colors.white70,
                    dotSecondaryColor: Colors.white70),
                isLiked: false,
                likeBuilder: (bool isLiked) {
                  return Icon(
                    Icons.favorite_border,
                    color: Colors.white70,
                  );
                },
              ),
              Text('Your liked songs will appear here',
                  style: TextStyle(
                    color: Colors.white70,
                  )),
            ],
          )))
        : ListView.builder(
            itemCount: widget.songlist.length,
            itemBuilder: (context, index) {
              return Container(
                  margin:
                      const EdgeInsets.only(bottom: 6.0, left: 6.0, right: 6.0),
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(16.0)),
                    color: Colors.white70,
                  ),
                  child: ListTile(
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        '/player',
                        arguments: widget.songlist[index],
                      );
                    },
                    onLongPress: () {
                      popupDetail(context, widget.songlist[index]);
                    },
                    leading: Hero(
                      tag: widget.songlist[index].id.toString(),
                      child: CachedNetworkImage(
                        imageUrl: widget.songlist[index].cover,
                        placeholder: (context, url) =>
                            Icon(CupertinoIcons.double_music_note),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                    ),
                    title: Text(widget.songlist[index].name),
                    subtitle: Text(
                      widget.songlist[index].artist,
                      style: TextStyle(fontSize: 12, color: Colors.black38),
                    ),
                    trailing: Wrap(
                      // space between two icons
                      children: <Widget>[
                        IconButton(
                            icon: Icon(Icons.favorite),
                            color: Colors.red,
                            onPressed: () {
                              favouriteHandler(index, context);
                            }),
                        // IconButton(
                        //   icon: favsongid.contains(widget.data.songlist[index].id)
                        //       ? Icon(
                        //           Icons.favorite,
                        //           color: Colors.red,

                        //         )
                        //       : Icon(
                        //           Icons.favorite_border,
                        //           color: Colors.black38,
                        //         ),
                        //   onPressed: () {
                        //     favouritehandler(
                        //         favsongid.contains(widget.data.songlist[index].id),
                        //         widget.data.songlist[index].id,
                        //         context);
                        //   },
                        //   color: Colors.black,
                        //   hoverColor: Colors.transparent,
                        //   splashColor: Colors.transparent,
                        //   focusColor: Colors.transparent,
                        //   highlightColor: Colors.transparent,
                        // ), // icon-1
                        IconButton(
                          icon: Icon(Icons.more_vert),
                          onPressed: () {
                            popupDetail(context, widget.songlist[index]);
                          },
                          color: Colors.black,
                          hoverColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                        ),
                        // icon-2
                      ],
                    ),
                  ));
            },
          );
  }
}

import 'dart:ui';
import 'dart:math';
import 'package:bloc_login/home/playlist.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'home.dart';
import 'home_page.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

var random = new Random();

class Search extends StatefulWidget {
  final List<Album> playlist;
  Search({
    Key key,
    @required this.playlist,
  }) : super(key: key);
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  List<Song> songlist = [];
  List<Album> albums = [];
  List<Artist> artists = [];

  @override
  void initState() {
    super.initState();
    this.getJSONSongs();
    this.getJSONAlbums();
    this.getJSONArtists();
  
  }

  
  

  Future<String> getJSONSongs() async {
    var url = 'https://raagmusic.herokuapp.com/songs/';
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      for (int i = 0; i < jsonResponse.length; i++) {
        if (this.mounted){
        setState(() {
          songlist.add(
            Song(
                jsonResponse[i]['id'],
                jsonResponse[i]['name'],
                jsonResponse[i]['artist'],
                jsonResponse[i]['year'],
                jsonResponse[i]['url'],
                jsonResponse[i]['cover'],
                jsonResponse[i]['duration']),
          );
        });
      }
      }
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
    return "Successful";
  }

  Future<String> getJSONAlbums() async {
    var url = 'https://raagmusic.herokuapp.com/albums/';
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      for (int i = 0; i < jsonResponse.length; i++) {
        List<Song> temp = [];
        for (int j = 0; j < jsonResponse[i]['songlist'].length; j++) {
          temp.add(
            Song(
                (jsonResponse[i]['songlist'])[j]['id'],
                (jsonResponse[i]['songlist'])[j]['name'],
                (jsonResponse[i]['songlist'])[j]['artist'],
                (jsonResponse[i]['songlist'])[j]['year'],
                (jsonResponse[i]['songlist'])[j]['url'],
                (jsonResponse[i]['songlist'])[j]['cover'],
                (jsonResponse[i]['songlist'])[j]['duration']),
          );
        }

        ///
        if (this.mounted){
        setState(() {
          albums.add(Album(
            jsonResponse[i]['id'],
            jsonResponse[i]['albumname'],
            jsonResponse[i]['albumcover'],
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

  Future<String> getJSONArtists() async {
    var url = 'https://raagmusic.herokuapp.com/artist/';
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      for (int i = 0; i < jsonResponse.length; i++) {
        List<Song> temp = [];
        for (int j = 0; j < jsonResponse[i]['songlist'].length; j++) {
          temp.add(
            Song(
                (jsonResponse[i]['songlist'])[j]['id'],
                (jsonResponse[i]['songlist'])[j]['name'],
                (jsonResponse[i]['songlist'])[j]['artist'],
                (jsonResponse[i]['songlist'])[j]['year'],
                (jsonResponse[i]['songlist'])[j]['url'],
                (jsonResponse[i]['songlist'])[j]['cover'],
                (jsonResponse[i]['songlist'])[j]['duration']),
          );
        }

        ///
      if (this.mounted){
        setState(() {
          artists.add(Artist(
            jsonResponse[i]['id'],
            jsonResponse[i]['artistname'],
            jsonResponse[i]['artistcover'],
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,

      body: Stack(
        children: <Widget>[
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: new LinearGradient(
                  colors: [Colors.greenAccent[100], Colors.transparent],
                  begin: Alignment.topCenter,
                  end: Alignment.center
                  //begin: MediaQuery.of(context).size.width>MediaQuery.of(context).size.height? Alignment.topRight:Alignment.topLeft,
                  //end:  MediaQuery.of(context).size.width>MediaQuery.of(context).size.height? Alignment.bottomLeft:Alignment.bottomRight,

                  ),
            ),
          ),
          SafeArea(
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
                                padding: const EdgeInsets.only(bottom: 32.0),
                                child: Text(
                                  'Search',
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
                  Text(
                    '',
                    style: TextStyle(fontSize: 4.0),
                  ),
                  GestureDetector(
                      onTap: () {
                        showSearch(
                          context: context,
                          delegate: MySearch(songlist, albums, artists),
                        );
                      },
                      child: Container(
                          margin: const EdgeInsets.only(
                              bottom: 12.0, right: 12.0, left: 12.0),
                          //height: MediaQuery.of(context).size.height*0.057,
                          height: 46,
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(8.0),
                            ),
                            color: Colors.white,
                          ),
                          child: Row(children: <Widget>[
                            Expanded(child: Text('')),
                            Icon(CupertinoIcons.search),
                            Text(
                              '  Artists, songs, or albums',
                              style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54),
                            ),
                            Expanded(child: Text('')),
                          ]))),
                  Container(
                    alignment: Alignment.topLeft,
                    margin: const EdgeInsets.only(left: 12.0, top: 12.0),
                    child: Text(
                      'Browse all',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: GridView.count(
                        childAspectRatio: 1.7,
                        crossAxisCount: MediaQuery.of(context).size.width <
                                MediaQuery.of(context).size.height
                            ? 2
                            : 4,

                        // Generate 100 widgets that display their index in the List.
                        children: List.generate(widget.playlist.length, (index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                '/playlist',
                                arguments: widget.playlist[index],
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0)),
                                gradient: new LinearGradient(
                                    colors: [
                                      Color.fromRGBO(random.nextInt(255), 
                                         //random.nextInt(255),
                                         0,
                                          random.nextInt(255),
                                          1
                                          //(random.nextInt(10) + 1) / 10
                                          ),
                                      Colors.white
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight),
                              ),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Container(
                                        alignment: Alignment.topLeft,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 12.0, top: 16.0),
                                          child: Text(
                                            widget.playlist[index].albumname,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15.0),
                                          ),
                                        )),
                                  ),
                                  Expanded(
                                    child: Container(
                                      alignment: Alignment.bottomRight,
                                      child: Hero(tag: 'album'+widget.playlist[index].id.toString(),
                                               
                                                                              child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            child: Transform.rotate(
                                                angle: 22 / 50,
                                                child: Transform.translate(
                                                  offset: Offset(17, 7),
                                                  // child: Image.network(
                                                  //   'http://a10.gaanacdn.com/images/song/82/30410482/crop_480x480_1591270395.jpg',
                                                  //   height: 75,
                                                  //   fit: BoxFit.fitHeight,
                                                  // ),
                                                  child: CachedNetworkImage(
                                                      imageUrl:
                                                          widget.playlist[index].albumcover,
                                                      imageBuilder:
                                                          (context, imageProvider) =>
                                                              Container(
                                                        height: 75,
                                                        width: 75,
                                                        decoration: BoxDecoration(
                                                          image: DecorationImage(
                                                            image: imageProvider,
                                                            fit: BoxFit.contain,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                )),
                                          ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      // body: SafeArea(
      //     child: Column(children: <Widget>[
      //   Container(
      //     height: MediaQuery.of(context).size.height * 0.10,
      //   ),
      //   Container(
      //     child: Text(
      //       'Search',
      //       style: TextStyle(
      //           color: Colors.white,
      //           fontWeight: FontWeight.bold,
      //           fontSize: 42.0),
      //     ),
      //   ),
      //   GestureDetector(
      //       onTap: () {
      //         showSearch(
      //           context: context,
      //           delegate: MySearch(songlist, albums,artists),
      //         );
      //       },
      //       child: Container(
      //           margin: const EdgeInsets.only(
      //               top: 25.0, bottom: 12.0, right: 12.0, left: 12.0),
      //           height: MediaQuery.of(context).size.height * 0.057,
      //           padding: const EdgeInsets.all(12.0),
      //           decoration: BoxDecoration(
      //             borderRadius: BorderRadius.all(
      //               Radius.circular(8.0),
      //             ),
      //             color: Colors.white,
      //           ),
      //           child: Row(children: <Widget>[
      //             Expanded(child: Text('')),
      //             Icon(CupertinoIcons.search),
      //             Text(
      //               '  Artists, songs, or albums',
      //               style: TextStyle(
      //                   fontSize: 16.0,
      //                   fontWeight: FontWeight.bold,
      //                   color: Colors.black54),
      //             ),
      //             Expanded(child: Text('')),
      //           ]))),
      // ]))
    );
  }
}

class MySearch extends SearchDelegate {
  List<Song> songlist = [];
  List<Album> albums = [];
  List<Artist> artists = [];
  MySearch(songlist, albums, artists) {
    this.songlist = songlist;
    this.albums = albums;
    this.artists = artists;
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = ThemeData(
      primaryColor: Color.fromRGBO(0, 0, 0, 0.92),
      textTheme:
          TextTheme(headline6: TextStyle(color: Colors.white, fontSize: 20.0)),
    );
    return theme;
  }

  @override
  String get searchFieldLabel => '';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        focusColor: Colors.transparent,
        highlightColor: Colors.transparent,
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back_ios),
      onPressed: () {
        close(context, null);
      },
      hoverColor: Colors.transparent,
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      highlightColor: Colors.transparent,
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionSongList = songlist
        .where((p) => p.name
            .toLowerCase()
            .replaceAll(' ', '')
            .contains(query.toLowerCase().replaceAll(' ', '')))
        .toList();
    final suggestionAlbumList = albums
        .where((p) => p.albumname
            .toLowerCase()
            .replaceAll(' ', '')
            .contains(query.toLowerCase().replaceAll(' ', '')))
        .toList();
    final suggestionArtistList = artists
        .where((p) => p.artistname
            .toLowerCase()
            .replaceAll(' ', '')
            .contains(query.toLowerCase().replaceAll(' ', '')))
        .toList();
    return Container(
        padding: const EdgeInsets.only(top: 12.0),
        color: Color.fromRGBO(0, 0, 0, 0.92),
        child:
            // ListView(
            //   children:<Widget>[
            //     SongList(data: Album(0, '', '', suggestionSongList)),
            //     Text('nitin'),
            //   ]
            // )
            query.isNotEmpty && query.length >= 3
                ? suggestionSongList.isEmpty &&
                        suggestionAlbumList.isEmpty &&
                        suggestionArtistList.isEmpty
                    ? Container(
                        padding: const EdgeInsets.only(top: 20),
                        child: NotificationListener<
                                OverscrollIndicatorNotification>(
                            onNotification: (overscroll) {
                              overscroll.disallowGlow();
                            },
                            child: ListView(children: <Widget>[
                              Center(
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                    Icon(
                                      CupertinoIcons.flag,
                                      color: Colors.white70,
                                      size: 100,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 56.0, right: 56.0),
                                      child: Text(
                                        'No results found for ' +
                                            '"' +
                                            query +
                                            '"',
                                        style: TextStyle(
                                            fontSize: 20,
                                            color: Colors.white70),
                                      ),
                                    ),
                                    Text(
                                      '',
                                      style: TextStyle(fontSize: 8.0),
                                    ),
                                    Text(
                                      'Please check you have the right spaelling, or try',
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.white70),
                                    ),
                                    Text(
                                      'different keywords.',
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.white70),
                                    )
                                  ]))
                            ])))
                    : NotificationListener<OverscrollIndicatorNotification>(
                            onNotification: (overscroll) {
                              overscroll.disallowGlow();
                            },
                            child:ListView(children: <Widget>[
                        suggestionSongList.isNotEmpty
                            ? Row(children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(left: 12.0),
                                  child: Text(
                                    'SONG',
                                    style: TextStyle(color: Colors.white38),
                                  ),
                                ),
                              ])
                            : Container(),
                        suggestionSongList.isNotEmpty
                            ? Container(
                                child: BuildSonglist(
                                    suggestionSongList: suggestionSongList),
                              )
                            : Container(),
                        suggestionAlbumList.isNotEmpty
                            ? Row(children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 12.0, bottom: 8.0),
                                  child: Text(
                                    'ALBUM/PLAYLIST',
                                    style: TextStyle(color: Colors.white38),
                                  ),
                                ),
                              ])
                            : Container(),
                        suggestionAlbumList.isNotEmpty
                            ? Container(
                                child: GridView.count(
                                  // Create a grid with 2 columns. If you change the scrollDirection to
                                  // horizontal, this produces 2 rows.
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  crossAxisCount:
                                      MediaQuery.of(context).size.width <
                                              MediaQuery.of(context).size.height
                                          ? 3
                                          : 6,

                                  // Generate 100 widgets that display their index in the List.
                                  children: List.generate(
                                      suggestionAlbumList.length, (index) {
                                    return Container(
                                      margin: const EdgeInsets.only(
                                          left: 6.0, right: 6.0),
                                      child: Column(
                                        children: <Widget>[
                                          Expanded(
                                            child: Hero(  tag: 'album'+suggestionAlbumList[index].id.toString(),
                                                                                          child: CachedNetworkImage(
                                                imageUrl:
                                                    suggestionAlbumList[index]
                                                        .albumcover,
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
                                                      arguments:
                                                          suggestionAlbumList[
                                                              index],
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
                                                                BorderRadius.all(
                                                                    Radius
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
                                                                BorderRadius.all(
                                                                    Radius
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
                                                    suggestionAlbumList[index]
                                                        .albumname,
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
                              )
                            // Container(

                            //       child: horizontalalbumList(
                            //           context, suggestionAlbumList),
                            //     )

                            : Container(),
                        suggestionArtistList.isNotEmpty
                            ? Row(children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 12.0, bottom: 8.0),
                                  child: Text(
                                    'ARTIST',
                                    style: TextStyle(color: Colors.white38),
                                  ),
                                ),
                              ])
                            : Container(),
                        suggestionArtistList.isNotEmpty
                            ? Container(
                                child: GridView.count(
                                  // Create a grid with 2 columns. If you change the scrollDirection to
                                  // horizontal, this produces 2 rows.
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  crossAxisCount:
                                      MediaQuery.of(context).size.height >
                                              MediaQuery.of(context).size.width
                                          ? 3
                                          : 6,
                                  // Generate 100 widgets that display their index in the List.
                                  children: List.generate(
                                      suggestionArtistList.length, (index) {
                                    return Container(
                                      margin: const EdgeInsets.only(
                                          left: 6.0, right: 6.0),
                                      //width: MediaQuery.of(context).size.width * 0.29,

                                      child: Column(
                                        children: <Widget>[
                                          Expanded(
                                            child: Hero(   tag: 'artist'+suggestionArtistList[index].id.toString(),
                                                                                          child: CachedNetworkImage(
                                                imageUrl:
                                                    suggestionArtistList[index]
                                                        .artistcover,
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
                                                      arguments:
                                                          suggestionArtistList[
                                                              index],
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
                                                            shape:
                                                                BoxShape.circle,
                                                            color: Colors.grey),
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
                                                        decoration: BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
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
                                                    suggestionArtistList[index]
                                                        .artistname,
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
                              )
                            //    Container(
                            //           child: horizontalartistList(
                            //               context, suggestionArtistList),
                            //         )
                            : Container(),
                      ])
    )
                : Container(
                    padding: const EdgeInsets.only(top: 20),
                    child:
                        // (MediaQuery.of(context).size.height>MediaQuery.of(context).size.width)?
                        NotificationListener<OverscrollIndicatorNotification>(
                            onNotification: (overscroll) {
                              overscroll.disallowGlow();
                            },
                            child: ListView(children: <Widget>[
                              Center(
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                    Icon(
                                      CupertinoIcons.search,
                                      color: Colors.white70,
                                      size: 100,
                                    ),
                                    Text(
                                      'Find the music you love',
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.white70),
                                    ),
                                    Text(
                                      '',
                                      style: TextStyle(fontSize: 8.0),
                                    ),
                                    Text(
                                      'Search for artist, songs, albums, and more.',
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.white70),
                                    )
                                  ]))
                            ]))
                    // :Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children:<Widget>[Icon(CupertinoIcons.search,color: Colors.white54),Text('Search',style: TextStyle(color: Colors.white54),)]))
                    )

        // SongList(data: Album(0, '', '', suggestionSongList)),

        //horizontalalbumList(context, suggestionAlbumList),

        );
  }
}

class BuildSonglist extends StatefulWidget {
  final List<Song> suggestionSongList;
  BuildSonglist({
    Key key,
    @required this.suggestionSongList,
  }) : super(key: key);
  @override
  _BuildSonglistState createState() => _BuildSonglistState();
}

class _BuildSonglistState extends State<BuildSonglist> {
  List<int> favsongid = [];
  void initState() {
    super.initState();
    this.getJSONFavList();
  }

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
        if (this.mounted){
        setState(() {
          favsongid.remove(id);
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
    } else {
      var url = 'https://raagmusic.herokuapp.com/addfavourite/' +
          list[0]['username'] +
          '/' +
          id.toString();
      var response = await http.get(url);
      if (response.statusCode == 200) {
        if (this.mounted){
        setState(() {
          favsongid.add(id);
        });
        }

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

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(bottom: 6.0, left: 6.0, right: 6.0),
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: widget.suggestionSongList.length,
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
                      arguments: widget.suggestionSongList[index],
                    );
                  },
                  onLongPress: () {
                    popupDetail(context, widget.suggestionSongList[index]);
                  },
                  leading: Hero(   tag:widget.suggestionSongList[index].id.toString(),
                                      child: CachedNetworkImage(
                      imageUrl: widget.suggestionSongList[index].cover,
                      placeholder: (context, url) =>
                          Icon(CupertinoIcons.double_music_note),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  ),
                  title: Text(widget.suggestionSongList[index].name),
                  subtitle: Text(
                    widget.suggestionSongList[index].artist,
                    style: TextStyle(fontSize: 12, color: Colors.black38),
                  ),
                  trailing: Wrap(
                    // space between two icons
                    children: <Widget>[
                      IconButton(
                          icon: favsongid
                                  .contains(widget.suggestionSongList[index].id)
                              ? Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                )
                              : Icon(
                                  Icons.favorite_border,
                                  color: Colors.black38,
                                ),
                          color: Colors.red,
                          onPressed: () {
                            favouritehandler(
                                favsongid.contains(
                                    widget.suggestionSongList[index].id),
                                widget.suggestionSongList[index].id,
                                context);
                          }),
                      // icon-1
                      IconButton(
                        icon: Icon(Icons.more_vert),
                        onPressed: () {
                          popupDetail(
                              context, widget.suggestionSongList[index]);
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
        ));
    // SongList(
    //     data:
    //         Album(0, '', '', suggestionSongList)),
  }
}

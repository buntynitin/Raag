import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'home_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:ui';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:toast/toast.dart';
import 'package:like_button/like_button.dart';
final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
class PlayList extends StatelessWidget {
  
  final Album data;

  PlayList({
    Key key,
    @required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key : _scaffoldKey,

      body:
       NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              
              SliverAppBar(
                leading: IconButton(
                    icon: Icon(Icons.arrow_back_ios),
                    onPressed: () {
                      Navigator.of(context).pop();
                    }),
                actions: <Widget>[
                 FavouriteButton(data: data),
                ],
                backgroundColor: Color.fromRGBO(0, 0, 0, 1),
                //expandedHeight: MediaQuery.of(context).size.height * 0.4,
                  expandedHeight: 350,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                
                  
                  centerTitle: true,
                  title: Text(data.albumname,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      )),
                  background: Stack(children: <Widget>[
                    
                    CachedNetworkImage(
                      imageUrl: data.albumcover,
                      imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      placeholder: (context, url) =>
                          Icon(CupertinoIcons.double_music_note),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                    Positioned.fill(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: 100,
                          sigmaY: 100,
                        ),
                        child: Container(
                          color: Colors.black.withOpacity(0),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top:56.0),
                      child: Center(
                        child: Container( 
                          
                           height:180,
                           width: 180,
                          // padding: const EdgeInsets.only(
                          //     top: 150, bottom: 60, left: 120, right: 120),
                          child: Hero(  tag: 'album'+data.id.toString(),
                                                      child: CachedNetworkImage(
                              imageUrl: data.albumcover,
                              imageBuilder: (context, imageProvider) => Container(
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8.0)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      spreadRadius: 5,
                                      blurRadius: 7,
                                      offset:
                                          Offset(0, 3), // changes position of shadow
                                    ),
                                  ],
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                              placeholder: (context, url) =>
                                  Icon(CupertinoIcons.double_music_note),
                              errorWidget: (context, url, error) => Icon(Icons.error),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            ];
          },
          body: NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (overscroll) {
              overscroll.disallowGlow();
            },
            child: Container(
              color: Colors.black,
              child: SongList(data: data),
            ),
          )),
    );
  }
}


class FavouriteButton extends StatefulWidget {
  final Album data;
  FavouriteButton({
    Key key,
    @required this.data,
  }) : super(key: key);
  @override
  _FavouriteButtonState createState() => _FavouriteButtonState();
}

class _FavouriteButtonState extends State<FavouriteButton> {
  
  List<int> favalbumid = [];
  void initState() {
    super.initState();
    this.getJSONFavalbumList();
  }

  Future<String> getJSONFavalbumList() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "User.db");
    var database = await openDatabase(
      path,
    );
    List<Map> list = await database.rawQuery('SELECT * FROM userTable');
    var url = 'https://raagmusic.herokuapp.com/favalbumid?name=' + list[0]['username'];
    var response = await http.get(url);
    if (response.statusCode == 200) {
      if (response.body != '[]') {
        var jsonResponse = convert.jsonDecode(response.body);
        if (this.mounted){
        setState(() {
          for (int i = 0; i < jsonResponse[0]['favouritealbum'].length; i++) {
            favalbumid.add(jsonResponse[0]['favouritealbum'][i]);
          }
        });
        }
      }
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
    return "Successful";
  }

// favouritealbumhandler(bool isfavourite, int id, context) async {
//     Directory documentsDirectory = await getApplicationDocumentsDirectory();
//     String path = join(documentsDirectory.path, "User.db");
//     var database = await openDatabase(
//       path,
//     );
//     List<Map> list = await database.rawQuery('SELECT * FROM userTable');
//     if (isfavourite) {
//       var url = 'https://raagmusic.herokuapp.com/removefavouritealbum/' +
//           list[0]['username'] +
//           '/' +
//           id.toString();
//       var response = await http.get(url);
//       if (response.statusCode == 200) {
//         setState(() {
//           favalbumid.remove(id);
//         });

//         Toast.show("Removed from favourite", context,
//             duration: Toast.LENGTH_SHORT,
//             gravity: Toast.BOTTOM,
//             backgroundColor: Colors.white70,
//             textColor: Colors.black);
//       } else {
//         Toast.show("Try again later !", context,
//             duration: Toast.LENGTH_SHORT,
//             gravity: Toast.BOTTOM,
//             backgroundColor: Colors.white70,
//             textColor: Colors.black);
//       }
//     } else {
//       var url = 'https://raagmusic.herokuapp.com/addfavouritealbum/' +
//           list[0]['username'] +
//           '/' +
//           id.toString();
//       var response = await http.get(url);
//       if (response.statusCode == 200) {
//         setState(() {
//           favalbumid.add(id);
//         });

//         Toast.show("Added to favourite", context,
//             duration: Toast.LENGTH_SHORT,
//             gravity: Toast.BOTTOM,
//             backgroundColor: Colors.white70,
//             textColor: Colors.black);
     
//       } else {
//         Toast.show("Try again later !", context,
//             duration: Toast.LENGTH_SHORT,
//             gravity: Toast.BOTTOM,
//             backgroundColor: Colors.white70,
//             textColor: Colors.black);
//       }
//     }
   
//   }

   Future<bool> onLikeButtonTapped(bool isLiked) async{
     int id=widget.data.id;
     bool isfavourite = favalbumid.contains(widget.data.id);
     BuildContext context = _scaffoldKey.currentState.context;
     Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "User.db");
    var database = await openDatabase(
      path,
    );
    List<Map> list = await database.rawQuery('SELECT * FROM userTable');
  

    
      var url = isfavourite?'https://raagmusic.herokuapp.com/removefavouritealbum/' +
          list[0]['username'] +
          '/' +
          id.toString():
          'https://raagmusic.herokuapp.com/addfavouritealbum/' +
          list[0]['username'] +
          '/' +
          id.toString();

      var response = await http.get(url);
      if (response.statusCode == 200) {
        //setState(() {
          if(isfavourite)
          favalbumid.remove(id);
          else favalbumid.add(id);
        //});

        Toast.show(isfavourite?"Removed from favourite":"Added to favourite", context,
            duration: Toast.LENGTH_SHORT,
            gravity: Toast.BOTTOM,
            backgroundColor: Colors.white70,
            textColor: Colors.black);
      } else {
        Toast.show("Try again later !",context,
            duration: Toast.LENGTH_SHORT,
            gravity: Toast.BOTTOM,
            backgroundColor: Colors.white70,
            textColor: Colors.black);
       }



    
    // else {
    //   var url = 'https://raagmusic.herokuapp.com/addfavouritealbum/' +
    //       list[0]['username'] +
    //       '/' +
    //       id.toString();
    //   var response = await http.get(url);
    //   if (response.statusCode == 200) {
    //     setState(() {
    //       favalbumid.add(id);
    //     });

    //     Toast.show("Added to favourite", context,
    //         duration: Toast.LENGTH_SHORT,
    //         gravity: Toast.BOTTOM,
    //         backgroundColor: Colors.white70,
    //         textColor: Colors.black);
     
    //   }
    // else {
    //     Toast.show("Try again later !", context,
    //         duration: Toast.LENGTH_SHORT,
    //         gravity: Toast.BOTTOM,
    //         backgroundColor: Colors.white70,
    //         textColor: Colors.black);
    //   }
    // }
    return !isLiked;
  }

  @override
  Widget build(BuildContext context) {

   
    


    return LikeButton(
      isLiked: favalbumid.contains(widget.data.id),
      circleColor: CircleColor(start: Colors.red, end: Colors.red),
      bubblesColor: BubblesColor(
            dotPrimaryColor: Colors.white,
            dotSecondaryColor: Colors.red
          ),
       likeBuilder: (bool isLiked) {
            return Icon(
              isLiked?Icons.favorite:Icons.favorite_border,
              color: isLiked ? Colors.red : Colors.white,
            );
          },
      onTap: onLikeButtonTapped,
    );

     
    // IconButton(
    //                 icon: favalbumid.contains(widget.data.id)
    //                     ? Icon(
    //                         Icons.favorite,
    //                         color: Colors.red,
    //                       )
    //                     : Icon(
    //                         Icons.favorite_border,
    //                         color: Colors.white,
    //                       ),
    //                 onPressed: () {
    //                   favouritealbumhandler(
    //                       favalbumid.contains(widget.data.id),
    //                       widget.data.id,
    //                       context);
    //                 },
    //                 color: Colors.black,
    //                 hoverColor: Colors.transparent,
    //                 splashColor: Colors.transparent,
    //                 focusColor: Colors.transparent,
    //                 highlightColor: Colors.transparent,
    //               );
  }
}

class SongList extends StatefulWidget {
  final Album data;
  SongList({
    Key key,
    @required this.data,
  }) : super(key: key);
  @override
  _SongListState createState() => _SongListState();
}

class _SongListState extends State<SongList> {
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
    return ListView.builder(
      itemCount: widget.data.songlist.length,
      itemBuilder: (context, index) {
        return Container(
            margin: const EdgeInsets.only(bottom: 6.0, left: 6.0, right: 6.0),
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(16.0)),
              color: Colors.white70,
            ),
            child: ListTile(
              
                    
                      
              onTap: () {
                Navigator.of(context).pushNamed(
                  '/player',
                  arguments: widget.data.songlist[index],
                );
              },
              onLongPress: () {
                popupDetail(context, widget.data.songlist[index]);
              },
              leading: Hero(
                             tag:widget.data.songlist[index].id.toString(),
                              child: CachedNetworkImage(
                  imageUrl: widget.data.songlist[index].cover,
                  placeholder: (context, url) =>
                      Icon(CupertinoIcons.double_music_note),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
              title: Text(widget.data.songlist[index].name),
              subtitle: Text(
                widget.data.songlist[index].artist,
                style: TextStyle(fontSize: 12, color: Colors.black38),
              ),
              trailing: Wrap(
                // space between two icons
                children: <Widget>[
                 
                  IconButton(
                    icon: favsongid.contains(widget.data.songlist[index].id)
                        ? Icon(
                            Icons.favorite,
                            color: Colors.red,
                            
                          )
                        : Icon(
                            Icons.favorite_border,
                            color: Colors.black38,
                          ),
                    onPressed: () {
                      favouritehandler(
                          favsongid.contains(widget.data.songlist[index].id),
                          widget.data.songlist[index].id,
                          context);
                    },
                    color: Colors.black,
                   
                  ), // icon-1
                  IconButton(
                    icon: Icon(Icons.more_vert),
                    onPressed: () {
                      popupDetail(context, widget.data.songlist[index]);
                    },
                    color: Colors.black,
                    hoverColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                  ), // icon-2
                ],
              ),
            ));
      },
    );
  }
}

popupDetail(context, thissong) {
  showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      
      builder: (BuildContext bc) {
        return Container(
            padding: const EdgeInsets.only(top:12.0,left:12.0,right:12.0,bottom: 12.0),
            decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(topLeft:Radius.circular(24.0),topRight: Radius.circular(24.0))),
            child: Column(children: <Widget>[

             Row(
               mainAxisAlignment: MainAxisAlignment.end,
                 children: <Widget>[
                  
                   IconButton(icon: Icon(Icons.close),color: Colors.white,onPressed:(){
                     Navigator.of(context).pop();
                   })


                 ]
               ),
              
              
              Row(children: <Widget>[
                  Expanded(
                    child: Container(
               height: 150,
               child:Stack(
                 children: <Widget>[
                   CachedNetworkImage(
                 imageUrl: thissong.cover,
                 imageBuilder: (context, imageProvider) => Container(
                     decoration: BoxDecoration(
                       borderRadius: BorderRadius.all(Radius.circular(8.0)),
                       boxShadow: [
                         BoxShadow(
                           color: Colors.black.withOpacity(0.3),
                           spreadRadius: 5,
                           blurRadius: 7,
                           offset: Offset(0, 3), // changes position of shadow
                         ),
                       ],
                       image: DecorationImage(
                         image: imageProvider,
                         fit: BoxFit.contain,
                       ),
                     ),
                 ),
                 placeholder: (context, url) =>
                       Icon(CupertinoIcons.double_music_note),
                 errorWidget: (context, url, error) => Icon(Icons.error),
               ),

               Center(
                 child:
                 IconButton(icon: Icon(Icons.play_circle_filled),color: Colors.white,iconSize: 56.0, onPressed:  () {
               Navigator.of(context).pushNamed(
                   '/player',
                   arguments: thissong,
               );
                    },)
               )

                 ],

               )
                    ),
                  ),

                Expanded(
                  child: Column(children: <Widget>[
                  Text(''),
                  Text(
                    thissong.name,
                    style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold,color: Colors.white),
                    overflow: TextOverflow.fade,
                          softWrap: false,
                  ),
                  Text(
                    thissong.artist,
                    style: TextStyle(fontSize: 12.0,color: Colors.white70),
                    overflow: TextOverflow.fade,
                          softWrap: false,
                  ),
                 
                Divider(color: Colors.white38,),

                   Row(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: <Widget>[
               Icon(Icons.access_time,color: Colors.white,),
                    Text('   ' + thissong.duration, style: TextStyle(color: Colors.white),),
                    Expanded(child: Text('')),
                    Icon(
               Icons.calendar_today,
               size: 20.0,
               color: Colors.white,
                    ),
                    Text('   ' + thissong.year.toString(), style: TextStyle(color: Colors.white),),

                   
                   ],),
                   
               
                    

                   
                    
               
                  ],),
                ),

                ],),

              
              
            ]));
      });
}

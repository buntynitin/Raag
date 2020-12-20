import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_login/bloc/authentication_bloc.dart';
class Profile extends StatefulWidget {
  final username;
  final GlobalKey<ScaffoldState> scaffoldkey;
  Profile({
    Key key,
    @required this.username,
    @required this.scaffoldkey,
  }) : super(key: key);
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: new LinearGradient(
                  colors: [Colors.cyanAccent[100], Colors.transparent],
                  begin: Alignment.topCenter,
                  end: Alignment.center
                  //begin: MediaQuery.of(context).size.width>MediaQuery.of(context).size.height? Alignment.topRight:Alignment.topLeft,
                  //end:  MediaQuery.of(context).size.width>MediaQuery.of(context).size.height? Alignment.bottomLeft:Alignment.bottomRight,

                  ),
            ),
            
          ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body:
          SafeArea(
                      child: NestedScrollView(
                headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                  return <Widget>[
                    SliverAppBar(
                    
                      automaticallyImplyLeading: false,
                      
                      //backgroundColor: Colors.transparent,//Color.fromRGBO(0, 0, 0, 1),
                      //expandedHeight: MediaQuery.of(context).size.height * 0.4,
                      backgroundColor: Colors.transparent,
                      expandedHeight: 200,
                      //pinned: true,
                       floating: true,
                     
                      flexibleSpace: FlexibleSpaceBar(
                      
                      //   centerTitle: true,
                        
                      // title: Text(widget.username.toString()),
                        background: Center(
                          child: Container(
                                alignment: Alignment.bottomCenter,
                                 height: double.infinity,
                                 width: double.infinity,
                            child: Container(height: 150,width: 150,
                              child: CircleAvatar(backgroundColor: Colors.cyanAccent,child:Text(widget.username[0].toUpperCase(),style: TextStyle(fontSize:70.0,color: Colors.black),)))))
                      ),
                    ),
                  ];
                },
                body: ListView(
                  children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(widget.username.toString(),textAlign: TextAlign.center,style: TextStyle(fontSize:24.0,color: Colors.white),),

                      ),
                      GestureDetector(
                           onTap: (){
                          
                          showDialog(context: context,
                                    builder:(BuildContext bc)=>AlertDialog(
                                      //backgroundColor: Colors.white12,
                                      
                                      title: Text('Logout'),
                                      content: Text('Are you sure?'),

                                      actions: <Widget>[
                                      
                                         FlatButton(child: Text("LOGOUT"),
                                      onPressed: (){
                                        Navigator.of(bc).pop();
                                          BlocProvider.of<AuthenticationBloc>(context)
                                                        .add(LoggedOut());
                                                          Navigator.of(context).pop();
                                      },
                                       ),
                                         FlatButton(child: Text("CLOSE"),
                                      onPressed: (){
                                          Navigator.of(bc).pop();
                                      },
                                       ),
                                       
                                         ],
                                    ),
                          );
                           },
                                              child: Container(
                          height:55,
                          margin:const EdgeInsets.symmetric(vertical:24.0,horizontal: 56.0),
                          
                          decoration: BoxDecoration(
                            color:Colors.white,
                            borderRadius:
                                        BorderRadius.all(Radius.circular(8.0)),
                          boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        spreadRadius: 1,
                                        blurRadius: 3,
                                        offset:
                                            Offset(0, 3), // changes position of shadow
                                      ),
                                    ],
                 
                          ),
                          child: Center(child:Wrap(
                            children: <Widget>[
                              Transform.rotate( angle: 1.56,child: Icon(Icons.system_update_alt)),
                              Text('Logout',style: TextStyle(fontSize:20.0,fontWeight: FontWeight.bold),),
                            ],
                          ))
                        ),
                      )
                      
                      
                  ],
                )
            ),
          )
        ),

        SafeArea(child:
               Row(mainAxisAlignment: MainAxisAlignment.end,
                 children: <Widget>[
                    IconButton(
                                              icon: Icon(CupertinoIcons.gear),
                                              iconSize: 25.0,
                                              color: Colors.white,
                                              onPressed: () {
                                                // Navigator.of(context).('/settings');

                                                widget.scaffoldkey.currentState.openEndDrawer();
                                              },
                                              hoverColor: Colors.transparent,
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              highlightColor: Colors.transparent,
                                            ),


               ],)
            ),
      ],
    );
  }
}
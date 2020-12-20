import 'package:flutter/material.dart';
import 'home_page.dart';
import 'player.dart';
import 'playlist.dart';
import 'artistplaylist.dart';



class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Getting arguments passed in while calling Navigator.pushNamed
    final args = settings.arguments;
   
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => Home());
       case '/player':
           return MaterialPageRoute(builder: (_) => Player(data:args,) ,);
      case '/playlist':
           return MaterialPageRoute(builder: (_) => PlayList(data:args,) ,);
      case '/artistplaylist':
           return MaterialPageRoute(builder: (_) => ArtistPlayList(data:args,) ,);
      default:
        // If there is no such named route in the switch statement, e.g. /third
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Error'),
        ),
        body: Center(
          child: Text('ERROR'),
        ),
      );
    });
  }
}

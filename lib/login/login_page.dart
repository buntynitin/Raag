import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_login/repository/user_repository.dart';

import 'package:bloc_login/bloc/authentication_bloc.dart';
import 'package:bloc_login/login/bloc/login_bloc.dart';
import 'package:bloc_login/login/login_form.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

final Set<JavascriptChannel> jsChannels = [
  JavascriptChannel(
      name: 'Print',
      onMessageReceived: (JavascriptMessage message) {
        print(message.message);
      }),
].toSet();

class LoginPage extends StatelessWidget {
  final UserRepository userRepository;

  LoginPage({Key key, @required this.userRepository})
      : assert(userRepository != null),
        super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login | Home Hub'),
      ),
      body: Column(children: <Widget>[
        
        
        RaisedButton(onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SignUp()),
          );
        },
        child: Text("Sign up"),
        ),
        BlocProvider(
        create: (context) {
          return LoginBloc(
            authenticationBloc: BlocProvider.of<AuthenticationBloc>(context),
            userRepository: userRepository,
          );
        },
        child: LoginForm(),
      ),
      ],
    ),
    );
  }
}

class SignUp extends StatelessWidget {
  final flutterWebViewPlugin = FlutterWebviewPlugin();

  @override
  Widget build(BuildContext context) {
    
          return WebviewScaffold(
            url: 'https://raagmusic.herokuapp.com/register',
            javascriptChannels: jsChannels,
            mediaPlaybackRequiresUserGesture: false,
            appBar: AppBar(
              title: const Text('Sign up'),
              leading: IconButton(
                
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  hoverColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  ),
            ),
            withLocalStorage: true,
            hidden: true,
            initialChild: Container( 
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
            // bottomNavigationBar: BottomAppBar(
            //   child: Row(
            //     children: <Widget>[

            //       IconButton(
            //         icon: const Icon(Icons.arrow_back_ios),
            //         onPressed: () {
            //           flutterWebViewPlugin.goBack();
            //         },
            //       ),

            //       IconButton(
            //         icon: const Icon(Icons.arrow_forward_ios),
            //         onPressed: () {
            //           flutterWebViewPlugin.goForward();
            //         },
            //       ),
            //       IconButton(
            //         icon: const Icon(Icons.autorenew),
            //         onPressed: () {
            //           flutterWebViewPlugin.reload();
            //         },
            //       ),

            //     ],
            //   ),
            // ),
          );
  }
}
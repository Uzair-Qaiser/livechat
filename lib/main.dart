
import 'package:flutter/material.dart';
import 'package:livechat/models/FirebaseHelper.dart';
import 'package:livechat/models/UserModel.dart';
import 'package:livechat/pages/CompleteProfile.dart';
import 'package:livechat/pages/Login.dart';
import 'package:livechat/pages/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:livechat/pages/splashScreen.dart';
import 'package:uuid/uuid.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:overlay_support/overlay_support.dart';




var uuid = Uuid();
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {


  print("Handling a new background message: ${message.messageId}");
}



Future main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
 User? currentUser= FirebaseAuth.instance.currentUser;
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);



  // FlutterError.onError = (errorDetails) {
  //   FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  // };
  // // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  // PlatformDispatcher.instance.onError = (error, stack) {
  //   FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  //   return true;
  // };



  // for direct login etc
  if(currentUser!=null) {
    UserModel? thisUserModel= await FirebaseHelper.getUserModelById(currentUser!.uid);
    if(thisUserModel!=null){
    runApp(AppLoggedin(userModel: thisUserModel, firebaseUser: currentUser));}
    else{
      runApp(App());
    }
  }


  else{
    runApp(App());
  }

}
//Not Loggedin
class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: false
      ),

        debugShowCheckedModeBanner: false,
        home:Scaffold(
          // appBar: AppBar(
          //   backgroundColor: Colors.blue,
          //   title: Text("Live-Chat"),
          //   centerTitle: true,
          //   actions: [
          //     Icon(Icons.chat),
          //     SizedBox(width: 20,)
          //   ],
          // ),
          body: LoginScreen(),
          // Center(
          //   child: TextButton(
          //     onPressed: () => throw Exception(),
          //     child: const Text("Throw Test Exception"),
          //   ),
          // ),
        )
    );
  }
}


// Logged in
class AppLoggedin extends StatelessWidget {
 static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final UserModel userModel;
  final User firebaseUser;

AppLoggedin({required this.userModel,required this.firebaseUser});
  @override
  Widget build(BuildContext context) {
     final pushNotificationService = PushNotificationService(_firebaseMessaging);
    pushNotificationService.initialise();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(userModel: userModel, firebaseUser: firebaseUser),


    );
  }
}

//fcm


class PushNotificationService {
  final FirebaseMessaging _fcm;

  PushNotificationService(this._fcm);

  Future initialise() async {

    String? token = await _fcm.getToken();
    print("FirebaseMessaging token: $token");
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      if (message.notification != null) {

        print('Notification Title: ${message.notification!.title}');
        print('Notification Body: ${message.notification!.body}');
      }
    });


    /*_fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );*/
  }

}

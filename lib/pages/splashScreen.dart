import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../models/FirebaseHelper.dart';
import '../models/UserModel.dart';
import 'package:google_fonts/google_fonts.dart';



splash() async{
  User? currentUser= FirebaseAuth.instance.currentUser;
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

class SplashScreen extends StatefulWidget {
  @override

  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {

   super.initState();
     Timer(Duration(seconds: 5),(){
      splash();
     });

   }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(

        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            Container(padding: EdgeInsets.symmetric(horizontal: 50),
                child: Image.asset("images/chatting.png",width: 300,height: 200,)),
            SizedBox(height: 15,),
            Container(
                padding: EdgeInsets.symmetric(horizontal: 50),
                child: Text("Live Chat",style:GoogleFonts.acme(textStyle: TextStyle(fontSize: 28,),)))



          ],
        ) ,
      ),
    );
  }
}

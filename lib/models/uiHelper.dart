import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../pages/Login.dart';

class UiHelper{
  static void logOut(BuildContext context,String title){
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      actions: [
        TextButton(onPressed: () async {
        await FirebaseAuth.instance.signOut();
        Navigator.popUntil(context, (route) => route.isFirst);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginScreen()));

      }, child: Text("Yes")),
        TextButton(onPressed: ()  {
          Navigator.pop(context);

        }, child: Text("No"))],
    );

    showDialog(context: context,barrierDismissible: false,
        builder: (context){

          return alertDialog;
        });


  }

  static void showLoadingDialog(BuildContext context,String title){
    AlertDialog loadingDialog = AlertDialog(
      content: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 30,),
            Text(title),
          ],
        ),
      ),

    );
    showDialog(context: context,barrierDismissible: false,
        builder: (context){

      return loadingDialog;
    });
    

  }
  static void showAlertDialog(BuildContext context,String title,
      String content){
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [TextButton(onPressed: (){
        Navigator.pop(context);
      }, child: Text("OK"))],
    );
    showDialog(context: context, builder: (context){
      return alertDialog;
    });


  }
}
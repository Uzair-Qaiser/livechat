import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:livechat/components/Textfiled.dart';
import 'package:livechat/models/UserModel.dart';
import 'package:livechat/pages/home.dart';
import '../models/uiHelper.dart';
import 'Signup.dart';

class LoginScreen extends StatefulWidget {
   LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
 TextEditingController passcontroller=TextEditingController();

 TextEditingController Emailcontroller=TextEditingController();
 void checkvalues(){
   String email= Emailcontroller.text.trim();
   String password=passcontroller.text.trim();
   if(email==""|| password==""){
     UiHelper.showAlertDialog(context, "Incomplete data", "please fill all the feilds");
   }
   else{
     login(email, password);
   }
 }



 void login(String email,String password)async{

UserCredential? credential;
UiHelper.showLoadingDialog(context,"Logging in...");
try{
  credential= await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
}on FirebaseAuthException catch(ex){
  Navigator.pop(context);
  UiHelper.showAlertDialog(context, "An error ocurred", ex.message!);

}
if(credential!=null){
  String uid= credential.user!.uid;
DocumentSnapshot userData= await FirebaseFirestore.instance.collection("users").doc(uid).get();
UserModel userModel =UserModel.fromMap(userData.data() as Map<String,dynamic>);
print("Login Successful");
Navigator.popUntil(context, (route) => route.isFirst);
  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomePage(userModel: userModel, firebaseUser: credential!.user!)));
}


 }
 Future<UserCredential?> signInWithGoogle() async {
   await InternetAddress.lookup('google.com');

   try{
     // Trigger the authentication flow
     final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

     // Obtain the auth details from the request
     final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

     // Create a new credential
     final credential = GoogleAuthProvider.credential(
       accessToken: googleAuth?.accessToken,
       idToken: googleAuth?.idToken,
     );
    UserCredential? googleCredential =await FirebaseAuth.instance.signInWithCredential(credential);

     // Once signed in, return the UserCredential
     return googleCredential;
   }catch(e){
     log('signing with google $e');

     return null;

   }
 }
 handleGoogleButtonClick(){

   signInWithGoogle().then((user) async{
     UserCredential? credential;

     String uid="";
     if(user != null ){
       uid=user.user!.uid;

       UiHelper.showLoadingDialog(context,"Logging in...");
       DocumentSnapshot userData= await FirebaseFirestore.instance.collection("users").doc(uid).get();
       if(userData.data()!=null){

       UserModel userModel =UserModel.fromMap(userData.data() as Map<String,dynamic>);
       print("Login Successful");
       Navigator.popUntil(context, (route) => route.isFirst);
       Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomePage(userModel: userModel, firebaseUser: user!.user!)));

     }
       else{
         Navigator.pop(context);
         UiHelper.showAlertDialog(context, "Login Fail", " The email address is not registered");
       }
     }
     else{
       UiHelper.showAlertDialog(context, "No account Selected ","Please Select an account");
     }






   });
 }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(


          child: ListView(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(bottomLeft: Radius.elliptical(70, 70),bottomRight: Radius.elliptical(70, 70)),
                      color: Color.fromARGB(255, 32, 67, 170),
                    ),
                    child: Padding(padding: EdgeInsets.all(15),
                    child:Center(child: Text("Welcome",style: GoogleFonts.lora(textStyle: TextStyle(fontWeight: FontWeight.bold,fontSize: 30,color: Colors.white),))),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.only(left: 15,top: 15,bottom: 10),
                    child: Center(child: Text("Sign in to Continue",style: GoogleFonts.lora(textStyle: TextStyle(fontSize: 25,color: Colors.black),))),
                  ),
                  Center(child: Image.asset("images/user2.png",width: 120,height:120,)),

                  SizedBox(height: 40,),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 35),
                    child: MyTextField(
                      icon: Icon(CupertinoIcons.envelope),
                      Controller: Emailcontroller ,
                      labelText: 'Email',
                      hintText: 'Enter Email',
                      obsecureText: false,
                    )),
                  SizedBox(height: 20,),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 35),
                    child: MyTextField(
                      icon: Icon(CupertinoIcons.padlock_solid),
                      Controller: passcontroller ,
                      labelText: 'Password',
                      hintText: 'Enter Password',
                      obsecureText: true,
                    )),
                  SizedBox(height: 30,),
                  Center(child: SizedBox(width: 220,child: ElevatedButton(style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 33, 68, 171), // Background color
                  ),onPressed: (){checkvalues();}, child: Text("Login with Email & Password")))),
                  SizedBox(height: 10,),

                  Row(
                      children: [
                        Expanded(
                            child: Divider()
                        ),

                        Text("OR"),

                        Expanded(
                            child: Divider()
                        ),
                      ]
                  ),
                  SizedBox(height: 10,),


                  Center(child: SizedBox( width: 220,
                    child: ElevatedButton(style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 33, 68, 171), // Background color
                    ),onPressed: (){ handleGoogleButtonClick();}, child: Row( mainAxisSize: MainAxisSize.min,

                      children: [
                        Image.asset("images/pngegg.png",height: 30,width: 25,),
                        SizedBox(width: 10,),
                        Text("Login with Google"),
                      ],
                    )),
                  )),
                  SizedBox(height: 10,),
                  Row( mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(child: Divider()),
                      Text("Dont Have An Account?"),

                      TextButton(onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>Signup()));
                      }, child: Text("Create Account",style: TextStyle(color: Color.fromARGB(255, 33, 68, 171))),),
                      Expanded(child: Divider()),
                    ],
                  ),






                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

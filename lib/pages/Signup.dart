import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:livechat/models/UserModel.dart';
import 'package:livechat/pages/CompleteProfile.dart';
import 'package:livechat/pages/Login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:livechat/pages/home.dart';
import '../components/Textfiled.dart';
import '../models/uiHelper.dart';
class Signup extends StatefulWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  State<Signup> createState() => _SignupState();
}
class _SignupState extends State<Signup> {
  TextEditingController cpasscontroller=TextEditingController();
  TextEditingController passcontroller=TextEditingController();
  TextEditingController usercontroller=TextEditingController();
  TextEditingController Emailcontroller=TextEditingController();
  void checkvalues(){
    String email= Emailcontroller.text.trim();
    String fullname= usercontroller.text.trim();
    String password= passcontroller.text.trim();
    String cpass=cpasscontroller.text.trim();
    if(email==""||password==""||cpass==""||fullname==""){
      UiHelper.showAlertDialog(context, "Incomplete data", "please fill all the fields");
    }
    else if(password!=cpass){
      UiHelper.showAlertDialog(context, "Password Mismatch", "The password you entered do not match ");
    }
    else{
      signup(email, password,fullname);
    }
  }
  void signup(String email, String password,String fullname)async{
    UserCredential? credential;
    UiHelper.showLoadingDialog(context, "Creating Account..");
    try{
      credential= await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch(ex){
      Navigator.pop(context);
      UiHelper.showAlertDialog(context,"An error occured" , ex.message!);
      print(ex.code.toString());
    }
    if (credential!=null){
      String uid= credential.user!.uid;
      UserModel newuser =UserModel(
        uid: uid,
        email: email,
        fullname: fullname,
        profilepic: null,

      );
      await FirebaseFirestore.instance.collection("users").doc(uid).set(newuser.toMap());
      print("new user Created");
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>CompProfile(userModel: newuser, firebaseUser: credential!.user!)));

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

    signInWithGoogle().then((userCred) async{
      UserCredential? credential;


      if(userCred != null ){

        DocumentSnapshot userData= await FirebaseFirestore.instance.collection("users").doc(userCred.user!.uid!).get();
        if(userData.data()==null){
          UiHelper.showLoadingDialog(context, "Creating Account..");
       String uid=userCred.user!.uid;
       String email = userCred.user!.email!;
        String username= userCred.user!.displayName!;
        String profilepic= userCred.user!.photoURL!;
        UserModel newuser =UserModel(
          uid: uid,
          email: email,
          username:username,
          fullname: username,
          profilepic: profilepic,

        );
        await FirebaseFirestore.instance.collection("users").doc(uid).set(newuser.toMap());
        print("new user Created");
        Navigator.popUntil(context, (route) => route.isFirst);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomePage(userModel: newuser, firebaseUser: userCred!.user!)));


      }
      else{

        UiHelper.showAlertDialog(context, "Failed to create an account", "Account with this email address is already registered");

        }
      }
else
{
  UiHelper.showAlertDialog(context, "No account Selected ","Please Select an account");

}




    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
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
                  child: Center(child: Text("Create an Account",style: GoogleFonts.lora(textStyle: TextStyle(fontSize: 25,color: Colors.black),))),
                ),
                Center(child: Image.asset("images/user2.png",width: 120,height:120,)),




                SizedBox(height: 40,),
                Padding(
                  padding:EdgeInsets.symmetric(horizontal: 35),
                  child:  MyTextField(
                    icon: Icon(CupertinoIcons.person),
                    Controller: usercontroller,
                    labelText: 'Full Name',
                    hintText: 'Enter Name',
                    obsecureText: false,
                  ),),
                SizedBox(height: 20,),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 35),
                  child:  MyTextField(
                    icon: Icon(CupertinoIcons.envelope),
                    Controller: Emailcontroller,
                    labelText: 'Email',
                    hintText: 'Enter Email',
                    obsecureText: false,
                  ),),
                SizedBox(height: 20,),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 35),
                  child:  MyTextField(
                    icon: Icon(CupertinoIcons.padlock_solid),
                    Controller: passcontroller,
                    labelText: 'Password',
                    hintText: 'Enter Password',
                    obsecureText: true,
                  )),
                SizedBox(height: 20,),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 35),
                    child:  MyTextField(
                      icon: Icon(CupertinoIcons.padlock_solid),
                      Controller: cpasscontroller,
                      labelText: 'Confirm Password',
                      hintText: 'Enter Password',
                      obsecureText: true,
                    )),
                SizedBox(height: 20,),
                Center(child: SizedBox(width: 220,
                  child: ElevatedButton(style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 33, 68, 171), // Background color
                  ),onPressed: (){ checkvalues();}, child: Text("Create Account")),
                )),
                SizedBox(height: 20,),
                Center(child: SizedBox(width: 220,
                  child: ElevatedButton(style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 33, 68, 171), // Background color
                  ),onPressed: (){ handleGoogleButtonClick();}, child: Text("Create Account with Google")),
                )),
                SizedBox(height: 10,),
                Row( mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: Colors.grey[400],
                      ),
                    ),
                    Text("Already Have An Account?"),

                    TextButton(onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginScreen()));
                    }, child: Text("Login Here",style: TextStyle(color:Color.fromARGB(255, 33, 68, 171)),)),
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),






              ],
            ),
          ],
        ),
      ),
    );
  }
}
// google backup
// if(userCred != null ){
// String uid=userCred.user!.uid;
// String email = userCred.user!.email!;
// String username= userCred.user!.displayName!;
// String profilepic= userCred.user!.photoURL!;
// UserModel newuser =UserModel(
// uid: uid,
// email: email,
// username:username,
// fullname: username,
// profilepic: "",
//
// );
// await FirebaseFirestore.instance.collection("users").doc(uid).set(newuser.toMap());
// print("new user Created");
// Navigator.popUntil(context, (route) => route.isFirst);
// Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>CompProfile(userModel: newuser, firebaseUser: userCred!.user!)));
//
//
// }

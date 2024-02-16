import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:livechat/models/UserModel.dart';
import 'package:livechat/models/uiHelper.dart';
import 'package:livechat/pages/home.dart';
class UpProfile extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;
  const UpProfile({Key? key,  required this.userModel,required this.firebaseUser}) : super(key: key);

  @override
  State<UpProfile> createState() => _UpProfileState();
}

class _UpProfileState extends State<UpProfile> {
  File? imageFile;
  TextEditingController fname= TextEditingController();
  void selectImage(ImageSource source)async{
    XFile? pickedFile= await ImagePicker().pickImage(source: source);
    if(pickedFile!=null){
      cropImage(pickedFile);
    }
  }
  void cropImage(XFile file)async{
    File? croppedImage=await ImageCropper().cropImage(
      sourcePath: file.path,
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 20,
    );
    if(croppedImage!=null){
      setState(() {
        imageFile=croppedImage as File;
      });

    }

  }
  void showPhotoOptions(){
    showDialog(context: context, builder: (context){
      return AlertDialog(
        title: Text("Upload Profile Picture"),
        content: Column( mainAxisSize: MainAxisSize.min,
          children: [
            ListTile( onTap: (){
              selectImage(ImageSource.gallery);},
              leading: Icon(Icons.photo_album_outlined),
              title: Text("Select from Gallery"),),
            SizedBox(height: 12,),
            ListTile( onTap: (){

              selectImage(ImageSource.camera);
            },
              leading: Icon(Icons.camera_alt_outlined),
              title: Text("Take a photo"),),
            SizedBox(height: 10,),
            Row(
              children: [
                SizedBox(width: 30,),
                ElevatedButton(onPressed: (){
                  if(imageFile!=null){
                    Navigator.pop(context);
                    uploadData();
                    }
                  else{
                    UiHelper.showAlertDialog(context, "No Image Selected", "Please Select an Image");
                  }
                }, child: Text("Update")),
                SizedBox(width: 10,),
                ElevatedButton(onPressed: (){Navigator.pop(context);}, child: Text("Cancel")),
              ],
            ),


          ],
        ),

      );
    });
  }

  void uploadData()async{
    UiHelper.showLoadingDialog(context, "Uploading image...");
    UploadTask uploadTask= FirebaseStorage.instance.ref("profilepictures").child(widget.userModel.uid.toString()).putFile(imageFile!);
    TaskSnapshot snapshot= await uploadTask;
    String ?imageUrl= await snapshot.ref.getDownloadURL();
    widget.userModel.profilepic=imageUrl;
    await FirebaseFirestore.instance.collection("users").doc(widget.userModel.uid).set(widget.userModel.toMap()).then((value) {
      log("Data uploaded!");
      print("Data Uploaded");
      Navigator.pop(context);
      setState(() {

      });
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Update Profile"),centerTitle: true,automaticallyImplyLeading: true,backgroundColor: Color.fromARGB(255, 32, 67, 170),),
      body: SafeArea(
        child:Container(
          padding: EdgeInsets.symmetric(
            horizontal: 40,
          ),
          child: ListView(
            children: [
              SizedBox(height: 23,),
              CupertinoButton(onPressed:(){showPhotoOptions();},
                  child: CircleAvatar(radius:60,
                    backgroundImage: NetworkImage(widget.userModel.profilepic!))),

              SizedBox(height: 30,),
              CupertinoButton(child: Text("Submit"),color: Colors.black54, onPressed: (){
                Navigator.popUntil(context, (route) => route.isFirst);
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomePage(userModel: widget.userModel!, firebaseUser: widget.firebaseUser!)));

              }),


            ],
          ),
        ) ,
      ),
    );
  }
}

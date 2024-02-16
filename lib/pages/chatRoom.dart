import 'dart:io';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:livechat/models/MessageModel.dart';
import 'package:image_picker/image_picker.dart';
import 'package:livechat/pages/videoPage.dart';
import 'package:uuid/uuid.dart';
import '../main.dart';
import '../models/UserModel.dart';
import '../models/chatroomModel.dart';
import '../models/uiHelper.dart';
import 'package:video_player/video_player.dart';
class Chatroom extends StatefulWidget {
  const Chatroom({Key? key, required this.targetUser, required this.chatroom,  required this.userModel}) : super(key: key);
  final UserModel targetUser;
  final ChatroomModel chatroom;
  final UserModel userModel;



  @override
  State<Chatroom> createState() => _ChatroomState();
}

class _ChatroomState extends State<Chatroom> {
  String? msgId;

  TextEditingController messageController=  TextEditingController();
  void sendMessage()async{
    String msg= messageController.text.trim();


    messageController.clear();
    if(msg!=null){
      MessageModel newMessage= MessageModel( messageId: uuid.v1(),text: msg,reciever: widget.targetUser.uid!,
          con:1, sender: widget.userModel!.uid ,createdon: Timestamp.now(),seen: false);
      FirebaseFirestore.instance.collection("chatrooms").doc(widget.chatroom!.chatroomid).collection("messages").
      doc(newMessage.messageId).set(newMessage.toMap());
      widget.chatroom?.lastMessage = msg;
      msgId= newMessage.messageId;

      FirebaseFirestore.instance.collection("chatrooms").doc(widget.chatroom!.chatroomid).set(widget.chatroom!.toMap());
    }

  }
  File? videoFile;
  VideoPlayerController? videoController;
  Future getVideo()async{


    final pickedVideo = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if(pickedVideo!=null){
      videoFile= File(pickedVideo.path);
      VideoPlayerController.file(videoFile!)..initialize().then((_){
        uploadVideo();
      });
    }
  }
  Future uploadVideo()async{
    UiHelper.showLoadingDialog(context,"Sending Video...");
    String filename= uuid.v1();
    var ref = FirebaseStorage.instance.ref().child('videos').child("$filename.mp4");
    var uploadTask= await ref.putFile(videoFile as File);
    String videoUrl= await uploadTask.ref.getDownloadURL();
    print("videoUrl: ${videoUrl}");


    if(uploadTask!=null){

      Navigator.pop(context);
      MessageModel newMessage= MessageModel( messageId: uuid.v1(),text: "",
          video:videoUrl,con:3,sender: widget.userModel!.uid,createdon: Timestamp.now(),seen: false);
      FirebaseFirestore.instance.collection("chatrooms").doc(widget.chatroom!.chatroomid).collection("messages").
      doc(newMessage.messageId).set(newMessage.toMap());
      widget.chatroom?.lastMessage = "Video";
      FirebaseFirestore.instance.collection("chatrooms").doc(widget.chatroom!.chatroomid).set(widget.chatroom!.toMap());

    }
  }

  File? imageFile;
  Future getImage() async {
    ImagePicker _picker = ImagePicker();

    await _picker.pickImage(imageQuality: 20,source: ImageSource.gallery).then((xFile) {
      if (xFile != null) {
        imageFile = File(xFile.path);
        uploadImage();
      }
    });
  }

  Future uploadImage()async{
    UiHelper.showLoadingDialog(context,"Sending Image...");
    String filename= uuid.v1();
    var ref = FirebaseStorage.instance.ref().child('images').child("$filename.jpg");
    var uploadTask= await ref.putFile(imageFile as File);
    String imageUrl= await uploadTask.ref.getDownloadURL();
    print(imageUrl);
    if(uploadTask!=null){

      Navigator.pop(context);
      MessageModel newMessage= MessageModel( messageId: uuid.v1(),text: "",
          img: imageUrl, con:2,sender: widget.userModel!.uid,createdon: Timestamp.now(),seen: false);
      FirebaseFirestore.instance.collection("chatrooms").doc(widget.chatroom!.chatroomid).collection("messages").
      doc(newMessage.messageId).set(newMessage.toMap());
      widget.chatroom?.lastMessage = "Image ";
      FirebaseFirestore.instance.collection("chatrooms").doc(widget.chatroom!.chatroomid).set(widget.chatroom!.toMap());

    }}



  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: PreferredSize(
        preferredSize: Size.fromHeight(55),

        child: AppBar(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(40),bottomLeft: Radius.circular(40),
            ),
          ),
          backgroundColor: Color.fromARGB(255, 33, 68, 171),
          title: Row(mainAxisAlignment:MainAxisAlignment.start,children: [
            CircleAvatar(
              backgroundColor: Colors.grey[300],
              backgroundImage: NetworkImage(widget.targetUser.profilepic.toString()),
            ),
            SizedBox(width: 10,),
            Text(widget.targetUser.fullname.toString(),style: GoogleFonts.robotoSerif(),),
          ],),

        ),
      ),


      body: SafeArea(
        child: Container( margin: EdgeInsets.only(top: 20),
          child: Column(
            children: [
              Expanded(child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10,
                ),
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance.collection("chatrooms").
                  doc(widget.chatroom!.chatroomid).collection("messages").orderBy("createdon",descending: true).snapshots(),
                  builder: (context,snapshot){

                    if(snapshot.connectionState==ConnectionState.active){
                      if(snapshot.hasData){
                        QuerySnapshot dataSnapshot= snapshot.data as QuerySnapshot;

                        return ListView.builder( reverse: true,
                          itemCount: dataSnapshot.docs.length,
                          itemBuilder: (context,index){
                            MessageModel currentModel =MessageModel.fromMap(dataSnapshot.docs[index].data()as Map<String,dynamic>);
                            // if(widget.userModel.uid==currentModel.reciever){
                            //   FirebaseFirestore.instance.collection('chatrooms').doc(widget.chatroom.chatroomid).collection('messages')
                            //       .doc(msgId).update({
                            //     'seen': true,
                            //   });}
                            return Row(
                              mainAxisAlignment: (currentModel.sender== widget.userModel!.uid)? MainAxisAlignment.end: MainAxisAlignment.start,
                              children: [
                                //For Text Message
                                (currentModel.con==1)?Flexible(
                                  child: (currentModel.sender== widget.userModel!.uid)?Row(

                                    mainAxisAlignment: (currentModel.sender== widget.userModel!.uid)? MainAxisAlignment.end: MainAxisAlignment.start,

                                    children: [

                                      Icon((currentModel.seen==true )?Icons.done_all:Icons.done),
                                      Container(
                                          margin: EdgeInsets.symmetric(
                                            vertical: 2,
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 10,
                                          ),
                                          decoration: BoxDecoration(
                                              color: (currentModel.sender == widget.userModel!.uid)?Color.fromARGB(255, 33, 68, 171):Colors.green,
                                              borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20),bottomRight: Radius.circular(20)),
                                              border: Border.all(color: Colors.white)
                                          ),
                                          child: Text(currentModel.text.toString(),style: TextStyle(color: Colors.white,fontSize: 15),)),
                                    ],
                                  ):  Container(
                                      margin: EdgeInsets.symmetric(
                                        vertical: 2,
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                          color: (currentModel.sender == widget.userModel!.uid)?Color.fromARGB(255, 33, 68, 171):Colors.green,
                                          borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20),bottomRight: Radius.circular(20)),
                                          border: Border.all(color: Colors.white)
                                      ),
                                      child: Text(currentModel.text.toString(),style: TextStyle(color: Colors.white,fontSize: 15),)),
                                )
                                //For Image
                                    :(currentModel.con==2)?Container(
                                  margin: EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 10,
                                  ),
                                  height: 300,
                                  width: 200,
                                  child: Container(
                                    height: 300,
                                    width: 200,
                                    child: GestureDetector(onTap: (){showImageViewer(context, Image.network(currentModel.img!).image,
                                        swipeDismissible: false);},child: Image.network(currentModel.img!,fit: BoxFit.cover,)),
                                  ),

                                )
                                //For Video
                                    :(currentModel.con==3)?
                                Container(
                                  width: 240,
                                  height: 240,
                                  margin: EdgeInsets.symmetric(horizontal: 5,vertical: 10),
                                  color: Colors.black12,
                                  child:   IconButton(
                                      onPressed: (){
                                        Navigator.push(context, MaterialPageRoute(builder: (context)=>
                                            videoPage(videoUrl: currentModel.video!,)));}, icon: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.play_circle,color: Colors.grey,size:50,),
                                      SizedBox(height: 10,),
                                      Text('Tap to play video',style: TextStyle(color: Colors.black87),)
                                    ],
                                  )),
                                ) :Container()



                              ],
                            );

                          },);

                      }
                      else if(snapshot.hasError){
                        return Center(
                          child: Text("An error Occured! Please check your internet connection"),
                        );
                      }
                      else{
                        return Center(
                          child: Text("Say hi to your new friend"),
                        );

                      }

                    }
                    else{
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),

              )),
              Container(

                padding: EdgeInsets.symmetric(

                    vertical: 5

                ),
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 1,
                  child: Row(children: [



                    Flexible(child: Container(
                      padding:EdgeInsets.symmetric(horizontal: 10),
                      child: TextField(
                        controller: messageController,
                        maxLines: null,
                        decoration: InputDecoration(


                            suffixIcon: IconButton(onPressed: (){
                              getImage();
                            },icon: Icon(Icons.photo,color:  Color.fromARGB(255, 33, 68, 171),)),
                            hintText: "Type Something..",hintStyle: TextStyle(color: Color.fromARGB(255, 33, 68, 171),)
                        ),
                      ),
                    )),
                    IconButton(onPressed: (){
                      getVideo();
                    },icon: Icon(Icons.video_camera_back_outlined,)),
                    IconButton(onPressed: (){sendMessage();}, icon: Icon(Icons.send,color: Colors.green,)),

                  ]),
                ),
              ),
            ],
          ),

        ),
      ),

    );
  }

}






import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:livechat/models/MessageModel.dart';

import '../main.dart';
import '../models/UserModel.dart';
import '../models/chatroomModel.dart';
class ChatRoom extends StatefulWidget {
  const ChatRoom({Key? key, required this.targetUser, required this.chatroom, required this.userModel, required this.firebaseUser}) : super(key: key);
  final UserModel targetUser;
  final ChatroomModel chatroom;
  final UserModel userModel;
  final User firebaseUser;

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  String? val;
  TextEditingController messageController=  TextEditingController();

  void sendMessage()async{
    String msg= messageController.text.trim();
    messageController.clear();
    if(msg!=null){
      MessageModel newMessage= MessageModel( messageId: uuid.v1(),text: msg,
      sender: widget.userModel.uid,createdon: Timestamp.now(),seen: false);
      FirebaseFirestore.instance.collection("chatrooms").doc(widget.chatroom.chatroomid).collection("messages").
      doc(newMessage.messageId).set(newMessage.toMap());
      widget.chatroom.lastMessage = msg;
      val=newMessage.messageId;
      FirebaseFirestore.instance.collection("chatrooms").doc(widget.chatroom.chatroomid).set(widget.chatroom.toMap());
    }





  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          CircleAvatar(
            backgroundColor: Colors.grey[300],
            backgroundImage: NetworkImage(widget.targetUser.profilepic.toString()),
          ),
          SizedBox(width: 10,),
          Text(widget.targetUser.fullname.toString()),
        ],),
      ),
      body: SafeArea(
        child: Container(
          child: Column(
            children: [
              Expanded(child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10,
                ),
                child: StreamBuilder(

                  stream: FirebaseFirestore.instance.collection("chatrooms").
                  doc(widget.chatroom.chatroomid).collection("messages").orderBy("createdon",descending: true).snapshots(),
                  builder: (context,snapshot){
                    FirebaseFirestore.instance.collection('chatrooms').doc(widget.chatroom.chatroomid).collection('messages')
                        .doc(val).update({
                      'seen': true,
                    });
                    if(snapshot.connectionState==ConnectionState.active){
                      if(snapshot.hasData){

                        QuerySnapshot dataSnapshot= snapshot.data as QuerySnapshot;
                        return ListView.builder( reverse: true,
                          itemCount: dataSnapshot.docs.length,
                          itemBuilder: (context,index){
                          MessageModel currentModel =MessageModel.fromMap(dataSnapshot.docs[index].data()as Map<String,dynamic>);
                          return Row(
                            mainAxisAlignment: (currentModel.sender== widget.userModel.uid)? MainAxisAlignment.end: MainAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.symmetric(
                                  vertical: 2,
                                ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: (currentModel.sender == widget.userModel.uid)?Colors.grey:Theme.of(context).colorScheme.secondary,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(currentModel.text.toString(),style: TextStyle(color: Colors.white),)),
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
                color: Colors.grey[200],
                padding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Row(children: [
                  Flexible(child: TextField(
                    controller: messageController,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: "Enter message",
                    ),
                  )),
                  IconButton(onPressed: (){sendMessage();}, icon: Icon(Icons.send,color: Theme.of(context).colorScheme.secondary,)),

                ]),
              ),
            ],
          ),

        ),
      ),
    );
  }
}

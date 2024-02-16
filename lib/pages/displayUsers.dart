import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:livechat/models/UserModel.dart';

import '../components/ChatUsers.dart';
import '../main.dart';
import '../models/FirebaseHelper.dart';
import '../models/chatroomModel.dart';
import 'chatRoom.dart';
import 'chatroomPage.dart';

class DisplayUsers extends StatefulWidget {
  final UserModel? userModel;
  final User? firebaseUser;
  const DisplayUsers({super.key, required this.userModel, required this.firebaseUser});

  @override
  State<DisplayUsers> createState() => _DisplayUsersState();
}

class _DisplayUsersState extends State<DisplayUsers> {
  Future<ChatroomModel?> getChatroomModel(UserModel targetUser)async{
    ChatroomModel? chatroom;
    QuerySnapshot snapshot= await FirebaseFirestore.instance.collection("chatrooms")
        .where("participants.${widget.userModel!.uid}",isEqualTo: true)
        .where("participants.${targetUser!.uid}",isEqualTo: true).get();
    if(snapshot.docs.length>0){
      var docData=snapshot.docs[0].data();
      ChatroomModel existingChatroom= ChatroomModel.fromMap(docData as Map<String,dynamic>);
      chatroom =existingChatroom;
    }
    else{
      ChatroomModel newChatRoom= ChatroomModel(
          chatroomid: uuid.v1(),
          lastMessage: "",
          chatOrder: Timestamp.now(),
          participants: {
            widget.userModel!.uid.toString(): true,
            targetUser.uid!.toString():true,
          }
      );
      await FirebaseFirestore.instance.collection("chatrooms").doc(newChatRoom.chatroomid)
          .set(newChatRoom.toMap());
      chatroom= newChatRoom;


    }
    return chatroom;

  }
  List<UserModel?> list=[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 32, 67, 170),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 32, 67, 170),
        centerTitle: true,
        title: Text("Users"),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("users").where("uid",isNotEqualTo: widget.userModel!.uid).snapshots(),
        builder: (context,snapshot){

          switch(snapshot.connectionState){
          case ConnectionState.waiting:
          case ConnectionState.none:
            return Center(child: CircularProgressIndicator());
        // if data is loaded
          case ConnectionState.active:
          case ConnectionState.done:

            final data = snapshot.data?.docs;
            list=data?.map((e) => UserModel.fromMap(e.data())).toList()??[];


            if(list.isNotEmpty){


              return ListView.builder(itemCount: list.length ,itemBuilder: (context,index){
               // Map<String ,dynamic>  list2= UserModel.fromMap(list2 );
             UserModel searchedUser = list[index]!;

                return ChatUserCard(user: searchedUser, userModel: widget.userModel!, );
               });

            }
            else{
              return Center(child: Text("No Connections Found"));
            }

        }


        },
      ),
    );
  }
}
// return GestureDetector(
// onTap:(){
// var item = list[index];
// if(item !=null){
// Navigator.pop(context);
// Navigator.push(context, MaterialPageRoute(builder: (context)=>Chatroom(targetUser: item ,
// )));
// }
// },child: ChatUserCard(user: list[index]));
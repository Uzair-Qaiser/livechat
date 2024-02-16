import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:livechat/models/UserModel.dart';

import '../main.dart';
import '../models/chatroomModel.dart';
import '../pages/chatRoom.dart';

class ChatUserCard extends StatefulWidget {
  final UserModel? user;
  final UserModel userModel;
  const ChatUserCard({Key? key, required this.user, required this.userModel}) : super(key: key);

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
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

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(45)),
      color: Colors.white.withOpacity(0.8),
      elevation: 1,
      margin: EdgeInsets.symmetric(horizontal: 8,vertical: 8),
      child: InkWell(
        onTap: (){

        },

        child: ListTile(
          onTap: () async {

            if(widget.user !=null){

              ChatroomModel? chatroomModel= await getChatroomModel(widget.user!);

              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context)=>Chatroom(targetUser: widget.user!, chatroom: chatroomModel!, userModel: widget.userModel ,
              )));
            }
          },
          leading: CircleAvatar(backgroundImage: NetworkImage(widget.user!.profilepic!),),
          title: Text(widget.user!.fullname!,style: GoogleFonts.robotoSerif(),),
          subtitle:Text("Send a message to ${widget.user!.fullname!}") ,
          trailing: Icon(Icons.arrow_forward_ios),
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class ChatroomModel{
   String ? chatroomid;
   String? lastMessage;
   Timestamp? chatOrder;
   Map<String,dynamic>?participants;
   ChatroomModel({this.chatroomid,this.participants,this.lastMessage,required this.chatOrder});
   ChatroomModel.fromMap(Map<String,dynamic>map){
     chatroomid=map['chatroomid'];
     participants=map['participants'];
     lastMessage=map['lastMessage'];
     chatOrder=map['chatOrder'];

   }
   Map<String,dynamic> toMap(){
     return{
       "chatroomid":chatroomid,
       "participants":participants,
       "lastMessage":lastMessage,
       "chatOrder":chatOrder,
     };
   }

}
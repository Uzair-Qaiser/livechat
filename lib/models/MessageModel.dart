import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel{
  String? messageId;
  String? reciever;
  String? sender;
  String?text;
  String? img;
  String? sent;
  String? video;
  int?con;
  Timestamp? createdon;
  bool? seen;
  MessageModel({this.reciever,this.messageId,this.sender,this.seen,this.text,this.createdon,this.img,this.sent,this.video,this.con});
  MessageModel.fromMap(Map<String,dynamic>map){
    sender=map['sender'];
    reciever=map['reciever'];
    text=map['text'];
    seen=map['seen'];
    createdon=map['createdon'];
    messageId=map['messageId'];
    img=map['img'];
    sent=map['sent'];
    video=map['video'];
    con=map['con'];

  }
  Map<String,dynamic>toMap(){
    return{
      'reciever':reciever,
      'messageId':messageId,
      'sender':sender,
      'text':text,
      'seen':seen,
      'createdon':createdon,
      'img':img,
      'sent':sent,
      'video':video,
      'con':con


    };
}
}
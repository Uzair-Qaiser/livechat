import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:livechat/main.dart';
import 'package:livechat/models/UserModel.dart';
import '../models/chatroomModel.dart';
import 'chatRoom.dart';
import 'chatroomPage.dart';
class SearchPage extends StatefulWidget {

  final UserModel? userModel;
  final User? firebaseUser;
  const SearchPage({super.key, required this.userModel, required this.firebaseUser});
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController= TextEditingController();
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
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 33, 68, 171),
          title: Text("Search"),
        ),
        body: SafeArea(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 10,
            ),
            child: Column(
              children: [
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                      labelText: "Email Address"
                  ),
                ),
                SizedBox(height: 20,),
                CupertinoButton(child: Text("Search"), onPressed: (){
                  setState(() {

                  });
                },color: Color.fromARGB(255, 33, 68, 171),),
                SizedBox(height: 20,),
                StreamBuilder(
                    stream: FirebaseFirestore.instance.collection("users").where("email",isEqualTo: searchController.text)
                        .where("email",isNotEqualTo: widget.userModel!.email).snapshots(),
                    builder: ( context, snapshot) {
                      if(snapshot.connectionState== ConnectionState.active){
                        if(snapshot.hasData){
                          QuerySnapshot dataSnapshot= snapshot.data as QuerySnapshot;
                          if(dataSnapshot.docs.length>0){
                            Map<String ,dynamic> userMap= dataSnapshot.docs[0].data() as Map<String,dynamic>;
                            UserModel searchedUser =UserModel.fromMap(userMap);
                            return ListTile(
                              onTap: ()async{
                                ChatroomModel? chatroomModel= await getChatroomModel(searchedUser);
                                if(chatroomModel!=null){
                                  Navigator.pop(context);
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=>Chatroom(targetUser: searchedUser,
                                    userModel: widget.userModel!, chatroom: chatroomModel , )));
                                }

                              },

                              leading: CircleAvatar(
                                backgroundColor: Colors.grey[500],
                                backgroundImage: NetworkImage(searchedUser.profilepic!),
                              ),
                              title: Text(searchedUser.fullname.toString(),style: GoogleFonts.robotoSerif()),
                              subtitle: Text(searchedUser.email.toString()),
                              trailing: Icon(Icons.arrow_forward_ios),
                            );

                          }
                          else{
                            return Text("No results found");
                          }

                        }
                        else if(snapshot.hasError){
                          return Text("an error Occured");
                        }
                        else{
                          return Text("No results found");
                        }
                      }
                      else{
                        return CircularProgressIndicator();
                      }

                    }

                ),
              ],
            ),

          ),
        ));
  }
}
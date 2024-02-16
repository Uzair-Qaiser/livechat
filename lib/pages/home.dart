import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:livechat/models/FirebaseHelper.dart';
import 'package:livechat/models/UserModel.dart';
import 'package:livechat/models/chatroomModel.dart';
import 'package:livechat/models/uiHelper.dart';
import 'package:livechat/pages/CompleteProfile.dart';
import 'package:livechat/pages/Login.dart';
import 'package:livechat/pages/displayUsers.dart';
import 'package:livechat/pages/searchPage.dart';

import 'UpdateProfile.dart';
import 'chatRoom.dart';

class HomePage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;
  const HomePage({Key? key, required this.userModel, required this.firebaseUser}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 243, 243, 243),


      appBar: PreferredSize(preferredSize: Size.fromHeight(80),child:AppBar(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(70),
          ),
        ),
        backgroundColor: Color.fromARGB(255, 33, 68, 171),

        title: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Text("Live-Chat",style: GoogleFonts.bebasNeue(textStyle: TextStyle(fontSize: 30))),
        ),
        centerTitle: true,
        actions: [
          IconButton(onPressed: ()async{
            Navigator.push(context,
                MaterialPageRoute(builder: (context)=>SearchPage(userModel: widget.userModel, firebaseUser: widget.firebaseUser)));



          }, icon: Icon(Icons.search)),
          IconButton(onPressed: (){
            UiHelper.logOut(context,"Are you really want to logout?");
            // await FirebaseAuth.instance.signOut();
            // Navigator.popUntil(context, (route) => route.isFirst);
            // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginScreen()));
          }, icon: Icon(CupertinoIcons.power)),
        ],
      ), ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20,right: 10),
        child: FloatingActionButton(backgroundColor: Colors.white,
          child: Icon(CupertinoIcons.chat_bubble_text,color: Color.fromARGB(255, 32, 67, 170),),
          onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>DisplayUsers(userModel: widget.userModel, firebaseUser: widget.firebaseUser,)));


            },
        ),
      ),
      drawer: Drawer(

        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage("images/blocks.jpg"),fit: BoxFit.cover

            )
          ),
          child: ListView(
            children: [
              SizedBox(height: 40,),
              Center(child: CircleAvatar(radius:55,backgroundImage:NetworkImage(widget.userModel.profilepic!))),
              SizedBox(height: 10,),
              Center(child: Text(widget.userModel.fullname!,style: GoogleFonts.robotoSerif(textStyle:TextStyle(fontSize: 20,fontWeight: FontWeight.bold),))),
              SizedBox(height: 10,),
              Center(child: Text(widget.userModel.email!,style: TextStyle(color: Colors.black54),)),
              SizedBox(height: 10,),
              Divider(thickness: 2,),
              SizedBox(height: 10,),
              Container(color: Colors.white.withOpacity(0.5),

                child: ListTile(onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context)=>UpProfile(userModel: widget.userModel!, firebaseUser: widget.firebaseUser!)));},leading: Icon(Icons.person,size: 35,),title: Text("My Profile"),
                  subtitle: Text("Tap to edit profile"),iconColor: Color.fromARGB(255, 32, 67, 170),textColor: Color.fromARGB(255, 32, 67, 170),),
              ),
              SizedBox(height: 10,),
              Container(color: Colors.white.withOpacity(0.5),

                child: ListTile(onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context)=>SearchPage(userModel: widget.userModel, firebaseUser: widget.firebaseUser)));},leading: Icon(Icons.person_add,size: 35,),title: Text("Search"),
                subtitle: Text("Tap here to search"),iconColor: Color.fromARGB(255, 32, 67, 170),textColor: Color.fromARGB(255, 32, 67, 170),),
              ),
              SizedBox(height: 10,),
              Container(color: Colors.white.withOpacity(0.5),

                child: ListTile(onTap:(){
                  UiHelper.logOut(context,"Are you really want to logout?");
                },leading: Icon(Icons.logout,size: 40,),title: Text("Logout"),
                  subtitle: Text("Tap here to Logout"),iconColor:  Color.fromARGB(255, 32, 67, 170),textColor: Color.fromARGB(255, 32, 67, 170),),
              ),


            ],
          ),
        ),

      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(image: DecorationImage(image: AssetImage("images/blocks.jpg"),fit: BoxFit.cover) ),
          child: StreamBuilder(
            stream: FirebaseFirestore.instance.collection("chatrooms").where("participants.${widget.userModel.uid}",isEqualTo: true).snapshots(),
            builder: (context,snapshot){
            if(snapshot.connectionState ==ConnectionState.active){
              if(snapshot.hasData){
                QuerySnapshot chatRoomSnapshot = snapshot.data as QuerySnapshot;
                return ListView.builder(itemCount:chatRoomSnapshot.docs.length,
                    itemBuilder: (context, index){
                  ChatroomModel chatroomModel = ChatroomModel.fromMap(chatRoomSnapshot.docs[index].data()as Map<String,dynamic>);
                  Map<String,dynamic> participants =chatroomModel.participants!;
                  List<String> participantkeys = participants.keys.toList();
                  participantkeys.remove(widget.userModel.uid);
                  return FutureBuilder(
                    future: FirebaseHelper.getUserModelById(participantkeys[0]),
                    builder: (context,userData){
                      if(userData.connectionState ==ConnectionState.done){
                        if(userData.data!=null){
                          UserModel targetUser = userData.data as UserModel;
                          return Card(
                            margin: EdgeInsets.only(left: 0,top: 10,right: 10,bottom: 5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomRight: Radius.circular(45))),
                            color: Colors.white.withOpacity(0.8),
                            child: ListTile(
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>Chatroom(chatroom: chatroomModel,
                                  userModel: widget.userModel,targetUser: targetUser ,)));
                              },
                              title: Text(targetUser.fullname.toString(),style: GoogleFonts.robotoSerif(),),
                              trailing: Icon(CupertinoIcons.chat_bubble),
                              subtitle: (chatroomModel.lastMessage.toString()!="")?Text(chatroomModel.lastMessage.toString(),style: GoogleFonts.roboto(),):Text("Say hi to your new friend!",style :GoogleFonts.roboto(textStyle:TextStyle(color:Theme.of(context).colorScheme.secondary ),),),
                              leading: CircleAvatar( backgroundImage:(targetUser.profilepic!=null)? NetworkImage(targetUser.profilepic.toString()):null,child:(targetUser.profilepic==null)? Icon(Icons.person,size: 50,color: Colors.white,):null),
                            ),
                          );

                        }
                        else{
                          return Container();
                        }



                      }
                      else{
                        return Container();
                      }

                  },);

                });


              }
              else if(snapshot.hasError){
                return Center(
                  child: Text(snapshot.error.toString()),
                );
              }
              else{
                return Center(
                  child: Text("No Chat"),
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


        ),
      ),
    );
  }
}

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:livechat/models/FirebaseHelper.dart';
// import 'package:livechat/models/UserModel.dart';
// import 'package:livechat/models/chatroomModel.dart';
// import 'package:livechat/models/uiHelper.dart';
// import 'package:livechat/pages/Login.dart';
// import 'package:livechat/pages/chatroomPage.dart';
// import 'package:livechat/pages/displayUsers.dart';
// import 'package:livechat/pages/searchPage.dart';
//
// class HomePage extends StatefulWidget {
//   final UserModel userModel;
//   final User firebaseUser;
//   const HomePage({Key? key, required this.userModel, required this.firebaseUser}) : super(key: key);
//
//   @override
//   State<HomePage> createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//
//         title: Text("Live-Chat"),
//         centerTitle: true,
//         actions: [
//           IconButton(onPressed: ()async{
//             Navigator.push(context,
//                 MaterialPageRoute(builder: (context)=>SearchPage(userModel: widget.userModel, firebaseUser: widget.firebaseUser)));
//
//
//
//           }, icon: Icon(Icons.search)),
//           IconButton(onPressed: (){
//             UiHelper.logOut(context,"Are you really want to logout?");
//             // await FirebaseAuth.instance.signOut();
//             // Navigator.popUntil(context, (route) => route.isFirst);
//             // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginScreen()));
//           }, icon: Icon(CupertinoIcons.power)),
//         ],
//       ),
//       floatingActionButton: Padding(
//         padding: const EdgeInsets.only(bottom: 20,right: 10),
//         child: FloatingActionButton(
//           child: Icon(Icons.message),
//           onPressed: (){
//             Navigator.push(context, MaterialPageRoute(builder: (context)=>DisplayUsers(userModel: widget.userModel, firebaseUser: widget.firebaseUser,)));
//
//
//           },
//         ),
//       ),
//       body: SafeArea(
//         child: Container(
//           child: StreamBuilder(
//             stream: FirebaseFirestore.instance.collection("chatrooms").where("participants.${widget.userModel.uid}",isEqualTo: true).snapshots(),
//             builder: (context,snapshot){
//               if(snapshot.connectionState ==ConnectionState.active){
//                 if(snapshot.hasData){
//                   QuerySnapshot chatRoomSnapshot = snapshot.data as QuerySnapshot;
//                   return ListView.builder(itemCount:chatRoomSnapshot.docs.length,
//                       itemBuilder: (context, index){
//                         ChatroomModel chatroomModel = ChatroomModel.fromMap(chatRoomSnapshot.docs[index].data()as Map<String,dynamic>);
//                         Map<String,dynamic> participants =chatroomModel.participants!;
//                         List<String> participantkeys = participants.keys.toList();
//                         participantkeys.remove(widget.userModel.uid);
//                         return FutureBuilder(
//                           future: FirebaseHelper.getUserModelById(participantkeys[0]),
//                           builder: (context,userData){
//                             if(userData.connectionState ==ConnectionState.done){
//                               if(userData.data!=null){
//                                 UserModel targetUser = userData.data as UserModel;
//                                 return ListTile(
//                                   onTap: (){
//                                     Navigator.push(context, MaterialPageRoute(builder: (context)=>ChatRoom(chatroom: chatroomModel,firebaseUser: widget.firebaseUser,
//                                       userModel: widget.userModel,targetUser: targetUser ,)));
//                                   },
//                                   title: Text(targetUser.fullname.toString()),
//                                   subtitle: (chatroomModel.lastMessage.toString()!="")?Text(chatroomModel.lastMessage.toString()):Text("Say hi to your new friend!",style: TextStyle(color:Theme.of(context).colorScheme.secondary ),),
//                                   leading: CircleAvatar( backgroundImage: NetworkImage(targetUser.profilepic.toString()),),
//                                 );
//
//                               }
//                               else{
//                                 return Container();
//                               }
//
//
//
//                             }
//                             else{
//                               return Container();
//                             }
//
//                           },);
//
//                       });
//
//
//                 }
//                 else if(snapshot.hasError){
//                   return Center(
//                     child: Text(snapshot.error.toString()),
//                   );
//                 }
//                 else{
//                   return Center(
//                     child: Text("No Chat"),
//                   );
//                 }
//               }
//               else{
//                 return Center(
//                   child: CircularProgressIndicator(),
//                 );
//
//               }
//             },
//           ),
//
//
//         ),
//       ),
//     );
//   }
// }

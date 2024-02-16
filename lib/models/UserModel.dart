class UserModel{
  String? uid;
  String?fullname;
  String?email;
  String? profilepic;
  String?username;
  UserModel({this.uid,this.fullname,this.email,this.profilepic,this.username});
  UserModel.fromMap(Map<String,dynamic>map){
    uid=map['uid'];
    username=map['username'];
    fullname=map['fullname'];
    email=map['email'];
    profilepic=map['profilepic'];

  }
  Map<String,dynamic> toMap(){
    return{"uid":uid,
      "username":username,
      "fullname":fullname,
      "email":email,
      "profilepic":profilepic,

    };
  }
}
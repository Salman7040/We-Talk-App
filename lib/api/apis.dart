import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:we_talk/models/chat_user.dart';
import 'package:we_talk/models/message.dart';

class APIs {
  //for firebase authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  //for accessing cloud firestore
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  //for accessing Firebase Storage
  static FirebaseStorage storage = FirebaseStorage.instance;

  //for accessing firebase push notification
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;


  //for getting firebase messaging token
  static Future<void> getFirebaseMessagingToken()async {
     await fMessaging.requestPermission();
     await fMessaging.getToken().then((t){
       if(t != null){
            me.pushToken=t;
            print("push token: $t");
       }
     });

  }

  //for checking if user exists or not?
  static Future<bool> userExist() async {
    return (await firestore
            .collection('users')
            .doc(auth.currentUser!.uid)
            .get())
        .exists;
  }

  //for storing self info
  static late ChatUser me;

  //for getting current user info
  static Future<void> getSelfInfo() async {
    await firestore.collection('users').doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
        await getFirebaseMessagingToken();
        print("in APIS screen: ${APIs.me.name}");
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    });
  }

  static User get user => auth.currentUser!;

  //for creating new user
  static Future<void> createUser() async {
    final time = DateTime.now().microsecondsSinceEpoch.toString();
    final userDetail = ChatUser(
      id: user.uid,
      name: user.displayName.toString(),
      email: user.email.toString(),
      about: "Hey I'm Using We Talk ....!",
      image: user.photoURL.toString(),
      createdAt: time,
      isOnline: false,
      lastActive: time,
      pushToken: '',
    );

    return (await firestore
        .collection('users')
        .doc(user.uid)
        .set(userDetail.toJson()));
  }

  //for getting all user data form firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    return firestore
        .collection('users')
        .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  //for saving my data which is come from profile screen to the database
  static Future<void> updateProfileData() async {
    await firestore
        .collection('users')
        .doc(user.uid)
        .update({'name': me.name, 'about': me.about});
  }

  //for updating profile images of users
  static Future<void> updateProfilePicture(File file) async {
    final ext = file.path.split('.').last;
    final ref = storage.ref().child('profile_picture/${user.uid}.$ext');
    ref.putFile(file, SettableMetadata(contentType: 'image/$ext')).then((pO) {
      print('Data Transferd : ${pO.bytesTransferred / 1000} kb');
    });

    //TODO:for updating profile image in firestore
    me.image = await ref.getDownloadURL();
    await firestore
        .collection('users')
        .doc(user.uid)
        .update({'image': me.image});
  }

  //TODO: ******** Chat Screen Related APIs Logic **********

  //its use for getting conversation id
  static String getConversationId(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  // getting all msg from fire store database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(ChatUser user) {
    return firestore
        .collection('chats/${getConversationId(user.id)}/messages/')
        .orderBy('sent',descending: true)
        .snapshots();
  }

  //for sending msg
  static Future<void> sendMessage(ChatUser chatUser, String msg,Type type) async {
    //msg sending time (also used for as id)
    final time = DateTime.now().microsecondsSinceEpoch.toString();

    //msg to send
    final Message message = Message(
        msg: msg,
        fromId: user.uid,
        read: '',
        toId: chatUser.id,
        type: type,
        sent: time);

    final ref = firestore
        .collection('chats/${getConversationId(chatUser.id)}/messages/');
    await ref.doc(time).set(message.toJson());
  }

  //update read msg of status
  static Future<void> updateMessageReadStatus(Message message) async {
    firestore
        .collection('chats/${getConversationId(message.fromId)}/messages/')
        .doc(message.sent)
        .update({'read':DateTime.now().microsecondsSinceEpoch.toString()});
  }

  //get only last  message  of a  specific chat
  static Stream<QuerySnapshot<Map<String,dynamic>>> getLastMessage(ChatUser user){
    return firestore.collection('chats/${getConversationId(user.id)}/messages/')
        .orderBy('sent',descending: true)
        .limit(1)
        .snapshots();
  }


  //sending image in chat box
  static Future<void> sendChatImage(ChatUser chatUser,File file )async {
    final ext = file.path.split('.').last;
    final ref = storage.ref().child('images/${getConversationId(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');

     await ref.putFile(file, SettableMetadata(contentType: 'image/$ext')).then((pO) {
      print('Data Transferd : ${pO.bytesTransferred / 1000} kb');
    });

    //TODO:for updating profile image in firestore
    final imageUrl = await ref.getDownloadURL();

    await sendMessage(chatUser, imageUrl, Type.image);
  }


  //getting specific user info from fire store
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserinfo(ChatUser user) {
    return firestore
        .collection('users')
        .where('id',isEqualTo: user.id)
        .snapshots();
  }

  //update online and last user active
  static Future<void> updateActiveStaus(bool isOnline)async {
    firestore
        .collection('users')
        .doc(user.uid)
        .update({
      'is_online': isOnline,
      'last_active':DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token':me.pushToken,
        });

  }


  //for deleting chatting msg
  static Future<void>  deleteMessage(Message message) async {
    await firestore
        .collection('chats/${getConversationId(message.toId)}/messages/')
        .doc(message.sent)
        .delete();
    if(message.type==Type.image) {
      await storage.refFromURL(message.msg).delete();
    }

  }


  //for update chatting msg
  static Future<void>  updateMessage(Message message,String updatedMsg) async {
    await firestore
        .collection('chats/${getConversationId(message.toId)}/messages/')
        .doc(message.sent)
        .update({'msg': updatedMsg});


  }

}

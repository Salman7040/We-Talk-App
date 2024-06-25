import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:we_talk/Helper/my_date_util.dart';
import 'package:we_talk/Screen/chat_screen.dart';
import 'package:we_talk/api/apis.dart';
import 'package:we_talk/main.dart';
import 'package:we_talk/models/chat_user.dart';
import 'package:we_talk/models/message.dart';

import 'dialogs/profie_dialog.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser myChatUser;
  const ChatUserCard({super.key, required this.myChatUser});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  Message? _message;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: mq.width * .02, vertical: 2),
      elevation: 3,
      child: InkWell(
          onTap: () {
            //TODO:for navigating to the Chat screen
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ChatScreen(user: widget.myChatUser)));
          },
          child: StreamBuilder(
            stream: APIs.getLastMessage(widget.myChatUser),
            builder: (context, snapshot) {
              //TODO:For checking list empty if list empty then print about other wise print last msg
              final data = snapshot.data?.docs;
              final list =
                  data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
              if (list.isNotEmpty) {
                _message = list[0];
              }

              return ListTile(
                //user profile
                // leading: const CircleAvatar(child:Icon(CupertinoIcons.person_alt),),
                leading: InkWell(
                  onTap: (){
                    showDialog(context: context, builder: (_)=> ProfieDialog(user: widget.myChatUser) );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * .03),
                    child: CachedNetworkImage(
                      height: mq.height * .06,
                      width: mq.height * .06,
                      imageUrl: widget.myChatUser.image,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  ),
                ),

                //user name
                title: Text(widget.myChatUser.name),

                //last massage
                subtitle: Text(
                  _message != null
                      ? _message!.type == Type.image
                          ? 'image'
                          : _message!.msg
                      : widget.myChatUser.about,
                  maxLines: 1,
                ),

                trailing: _message == null
                    ? null
                    : _message!.read.isEmpty &&
                            _message!.fromId != APIs.user.uid
                        ? Container(
                            width: 15,
                            height: 15,
                            decoration: BoxDecoration(
                                color: Colors.greenAccent,
                                borderRadius: BorderRadius.circular(10)),
                          )
                        : Text(
                            MmyDateUtill.getLastMessageTime(
                                context: context, time: _message!.sent),
                            style: const TextStyle(
                                color: Colors.black45,
                                fontSize: 13,
                                fontWeight: FontWeight.w600),
                          ),
              );
            },
          )),
    );
  }
}

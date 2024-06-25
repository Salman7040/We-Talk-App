import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:we_talk/Helper/my_date_util.dart';
import 'package:we_talk/Screen/auth/view_profile_screen.dart';
import 'package:we_talk/custom_widgets/message_card.dart';
import 'package:we_talk/models/chat_user.dart';
import 'package:we_talk/models/message.dart';
import '../api/apis.dart';
import '../main.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Message> _list = [];

  //for handling text msg
  final _textEditController = TextEditingController();

  //for show and hiding emojis
  bool _showEmoji = false, _isUploading = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: WillPopScope(
        onWillPop: () {
          if (_showEmoji) {
            setState(() {
              _showEmoji = !_showEmoji;
            });

            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            automaticallyImplyLeading: false,
            flexibleSpace: _appBar(),
          ),
          backgroundColor: Colors.blue.shade50,
          body: Column(
            children: [
              _chattingData(),

              //uploading indicator
              if (_isUploading)
                Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: mq.width * .05, vertical: mq.width * .02),
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.lightBlue,
                      ),
                    )),

              _chatInput(),
              if (_showEmoji) _ShowEmojis()
            ],
          ),
        ),
      ),
    );
  }

  //for app bar design
  Widget _appBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: InkWell(
        onTap: () {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ViewProfileScreen(myChatUser: widget.user)));
        },
        child: StreamBuilder(
          stream: APIs.getUserinfo(widget.user),
          builder: (context, snapshot) {
            final data = snapshot.data?.docs;
            final list = data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];

            return Row(
              children: [
                IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.black54,
                    )),
                // for the user profile picture
                ClipRRect(
                  borderRadius: BorderRadius.circular(mq.height * .03),
                  child: CachedNetworkImage(
                    height: mq.height * .06,
                    width: mq.height * .06,
                    imageUrl: list.isNotEmpty ? list[0].image : widget.user.image,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),
                SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //user name
                    Text(
                      list.isNotEmpty ? list[0].name : widget.user.name,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    //last seen msg
                    Text(
                      list.isNotEmpty
                          ? list[0].isOnline
                              ? 'Online'
                              : MmyDateUtill.getLastActiveTime(context: context, lastActive: list[0].lastActive)
                          : MmyDateUtill.getLastActiveTime(context: context, lastActive: widget.user.lastActive),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                        fontWeight: FontWeight.w400,
                      ),
                    )
                  ],
                )
              ],
            );
          },
        ),
      ),
    );
  }

  //for chat input design
  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: _showEmoji ? mq.height * .00 : mq.height * .02,
          horizontal: mq.width * .010),
      child: Row(
        children: [
          //input fields and buttons
          Expanded(
            child: Card(
              child: Row(
                children: [
                  //emoji btn
                  IconButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      setState(() => _showEmoji = !_showEmoji);
                    },
                    icon: const Icon(Icons.emoji_emotions, size: 26),
                    color: Colors.lightBlue,
                  ),

                  //emoji container bar
                  Expanded(
                      child: TextField(
                    onTap: () {
                      if (_showEmoji) setState(() => _showEmoji = !_showEmoji);
                    },
                    controller: _textEditController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: const InputDecoration(
                        hintText: 'Type Something....',
                        hintStyle: TextStyle(color: Colors.lightBlue),
                        border: InputBorder.none),
                  )),

                  //pick image from gallery
                  IconButton(
                    onPressed: () async {
                      //TODO:taking multiple images from the gallery
                      final ImagePicker picker = ImagePicker();
                      final List<XFile> images =
                          await picker.pickMultiImage(imageQuality: 30);
                      if (images.isNotEmpty) {
                        for (var i in images) {
                          setState(() => _isUploading = true);
                          //uploaded and sending image one by one
                          await APIs.sendChatImage(widget.user, File(i.path));
                          setState(() => _isUploading = false);
                        }
                      }
                    },
                    icon: const Icon(Icons.image, size: 26),
                    color: Colors.lightBlue,
                  ),

                  //pick image from camera
                  IconButton(
                    onPressed: () async {
                      //TODO:for pickup image from the camera
                      final ImagePicker picker = ImagePicker();
                      final XFile? image = await picker.pickImage(
                          source: ImageSource.camera, imageQuality: 30);
                      //cropped and compressed image store in firebase store
                      if (image != null) {
                        setState(() => _isUploading = true);
                        await APIs.sendChatImage(widget.user, File(image.path));
                        setState(() => _isUploading = false);
                      }
                    },
                    icon: Icon(Icons.camera_alt_rounded, size: 26),
                    color: Colors.lightBlue,
                  ),
                ],
              ),
            ),
          ),

          //send msg Button
          MaterialButton(
            onPressed: () {
              if (_textEditController.text.isNotEmpty) {
                APIs.sendMessage(
                    widget.user, _textEditController.text, Type.text);
                _textEditController.text = '';
              }
            },
            minWidth: 0,
            shape: CircleBorder(),
            padding: EdgeInsets.only(top: 10, bottom: 10, right: 4, left: 10),
            color: Colors.lightGreen,
            child: const Icon(
              Icons.send,
              size: 28,
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }

  //for chatting data and design
  Widget _chattingData() {
    return Expanded(
      child: StreamBuilder(
        stream: APIs.getAllMessages(widget.user),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.none:
              //when msg get timing for loaded the data its show loading bar
              return const SizedBox();
            case ConnectionState.active:
            case ConnectionState.done:
              final data = snapshot.data?.docs;

              _list =
                  data?.map((e) => Message.fromJson(e.data())).toList() ?? [];

              if (_list.isNotEmpty) {
                return ListView.builder(
                    reverse: true,
                    padding: EdgeInsets.only(
                        top: mq.height * .01, bottom: mq.height * .01),
                    //its depend on searching btn
                    itemCount: _list.length,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      //for sending data except current user
                      return MessageCard(message: _list[index]);
                    });
              } else {
                return const Center(
                    child: Text(
                  "Say Hii! 👋",
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.black45,
                      fontWeight: FontWeight.bold),
                ));
              }
          }
        },
      ),
    );
  }

  //for showing emojis
  Widget _ShowEmojis() {
    return Padding(
      padding: EdgeInsets.only(bottom: mq.height * .020),
      child: EmojiPicker(
        textEditingController: _textEditController,
        config: Config(
          height: mq.height * .35,
          checkPlatformCompatibility: true,
          emojiViewConfig: EmojiViewConfig(
            columns: 8,
            emojiSizeMax: 28 * (Platform.isIOS ? 1.20 : 1.0),
          ),
        ),
      ),
    );
  }
}

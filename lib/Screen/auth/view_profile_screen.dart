import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:we_talk/Helper/my_date_util.dart';
import 'package:we_talk/main.dart';
import 'package:we_talk/models/chat_user.dart';

class ViewProfileScreen extends StatefulWidget {
  final ChatUser myChatUser;
  const ViewProfileScreen({
    super.key,
    required this.myChatUser,
  });
  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final isKeybord = MediaQuery.of(context).viewInsets.bottom != 0;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.myChatUser.name),
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            //its show about
            Text('Join On : ',style: const TextStyle(fontSize: 20,color: Colors.black87,fontWeight: FontWeight.w700)),
            Flexible(
              child: Text(MmyDateUtill.getLastMessageTime(context: context, time: widget.myChatUser.createdAt,shoYear: true),
                style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: mq.height * 0.03,
              ),
              if (!isKeybord)
                ClipRRect(
                  borderRadius: BorderRadius.circular(mq.height * 0.100),
                  child: CachedNetworkImage(
                    height: mq.height * 0.2,
                    width: mq.height * 0.2,
                    fit: BoxFit.cover,
                    imageUrl: widget.myChatUser.image,
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),

              SizedBox(
                height: mq.height * 0.02,
              ),
              //for showing email of the user
              Text(
                widget.myChatUser.email,
                style: const TextStyle(
                    fontSize: 20,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600),
              ),

              SizedBox(
                height: mq.height * 0.02,
              ),
              //for showing email of the user
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //its show about
                    Text('About: ',style: const TextStyle(fontSize: 20,color: Colors.black87,fontWeight: FontWeight.w700)),
                    Flexible(
                      child: Text(
                        widget.myChatUser.about,
                        style: const TextStyle(
                            fontSize: 20,
                            color: Colors.black54,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

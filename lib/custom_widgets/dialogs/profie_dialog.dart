import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:we_talk/Screen/auth/view_profile_screen.dart';
import 'package:we_talk/models/chat_user.dart';

import '../../main.dart';

class ProfieDialog extends StatelessWidget {
  final ChatUser user;
  const ProfieDialog({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(backgroundColor: Colors.white ,
      contentPadding: EdgeInsets.zero,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20),),
      content: SizedBox(width: mq.width*.6 ,height: mq.height*.35,child: Stack(

        children: [

          //user profile images
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: CachedNetworkImage(
                // width: mq.width*.3 ,
                height: mq.height*.35,
                fit: BoxFit.cover,
                imageUrl: user.image,
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
          ),


       Container(
         decoration: BoxDecoration(
           borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20)),
           color: Colors.black26,
         ),

         child: Padding(
           padding: const EdgeInsets. only(left: 10,top: 1),
           child: Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               //user name
               Expanded(child: Text(user.name,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500,color: Colors.white),)),

               //user info button
               MaterialButton(onPressed: (){
                 Navigator.pop(context);
                 Navigator.push(context, MaterialPageRoute(builder: (_)=> ViewProfileScreen(myChatUser: user)));
               },
                 minWidth: 0,
                 padding: EdgeInsets.all(0),
                 shape: CircleBorder(),
                 child: Icon(Icons.info_outline,color: Colors.white,size: 30,),),

             ],
           ),
         ),
       )

        ],
      ),),
    );
  }
}

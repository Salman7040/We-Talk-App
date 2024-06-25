import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver_updated/gallery_saver.dart';
import 'package:we_talk/Helper/my_date_util.dart';
import 'package:we_talk/api/apis.dart';
import 'package:we_talk/models/message.dart';
import '../main.dart';

class MessageCard extends StatefulWidget {
  final Message message;

  const MessageCard({super.key, required this.message});

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    bool isMe = APIs.user.uid == widget.message.fromId;
    return InkWell(
        onLongPress: () {
          _ShowBottomSheet(isMe);
        },
        child: isMe ? _greenMessage() : _blueMessage());
  }

  sendDataP(){
    print("hiii");
  }

//for sender msg
  Widget _blueMessage() {
    if (widget.message.read.isEmpty) {
      APIs.updateMessageReadStatus(widget.message);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            decoration: BoxDecoration(
                color: Colors.lightBlue.shade100,
                border: Border.all(color: Colors.lightBlue),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomRight: Radius.circular(30))),
            padding: EdgeInsets.all(widget.message.type == Type.image
                ? mq.width * .03
                : mq.width * .04),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * .03, vertical: mq.height * .01),
            child: widget.message.type == Type.text
                ?
                //if there is text
                Text(widget.message.msg)
                :
                //if there is image
                ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * .02),
                    child: CachedNetworkImage(
                      imageUrl: widget.message.msg,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                      errorWidget: (context, url, error) => Icon(
                        Icons.image,
                        size: 70,
                      ),
                    ),
                  ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: mq.width * .04),
          //msg receive timeing
          child: Text(MmyDateUtill.getFormattedTime(
              context: context, time: widget.message.sent)),
        )
      ],
    );
  }

  //for our or  user msg
  Widget _greenMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            //spacing
            SizedBox(
              width: mq.width * .04,
            ),

            //read icon
            widget.message.read.isNotEmpty
                ? Icon(
                    Icons.done_all_rounded,
                    color: Colors.lightBlue,
                    size: 20,
                  )
                : Icon(
                    Icons.done_all_rounded,
                    color: Colors.grey,
                    size: 20,
                  ),

            //spacing
            SizedBox(
              width: mq.width * .02,
            ),

            //read time
            Text(
              MmyDateUtill.getFormattedTime(
                  context: context, time: widget.message.sent),
              style: TextStyle(fontSize: 13, color: Colors.black45),
            ),
          ],
        ),
        Flexible(
          child: Container(
            decoration: BoxDecoration(
                color: Colors.lightGreen.shade100,
                border: Border.all(color: Colors.lightGreen),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30))),
            padding: EdgeInsets.all(widget.message.type == Type.image
                ? mq.width * .03
                : mq.width * .04),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * .03, vertical: mq.height * .01),

            //sending the msg here logic
            child: widget.message.type == Type.text
                ?
                //if there is text
                Text(widget.message.msg)
                :
                //if there is image
                ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * .02),
                    child: CachedNetworkImage(
                      imageUrl: widget.message.msg,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                      errorWidget: (context, url, error) => Icon(
                        Icons.image,
                        size: 70,
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  //bottom sheet for modifying msg detail
  void _ShowBottomSheet(isMe) {
    showModalBottomSheet(
        backgroundColor: Colors.white,
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        )),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            children: [
              // black divider
              Container(
                height: 4,
                margin: EdgeInsets.symmetric(
                    vertical: mq.height * .015, horizontal: mq.width * .4),
                decoration: BoxDecoration(
                    color: Colors.grey, borderRadius: BorderRadius.circular(8)),
              ),

              //if selected item is text then do other wise its show ave image
              widget.message.type==Type.image ?
              //save option
              _OptionItem(icon: Icon(Icons.download_rounded ,color: Colors.lightBlue,), name: "Save Image", myOnTap: () async {
                try{
                  await GallerySaver.saveImage(widget.message.msg,albumName: 'We Talk').then((_)=>Navigator.pop(context));
                }
                catch(e){
                  print('ErrorWhileSavingImage $e');
                }
              }):
              //copy text option
              _OptionItem(icon: Icon(Icons.copy_all_outlined,color: Colors.lightBlue,), name: "Copy Text", myOnTap:() async {
                await Clipboard.setData(ClipboardData(text: widget.message.msg)).then((value){
                  Navigator.pop(context);
                });
              }),



              if(widget.message.type==Type.text || widget.message.type==Type.image  && isMe )
              //divider border
                  Divider(color: Colors.black26, endIndent: mq.width*.04, indent:  mq.width*.04,),

              //edit text option
              if(widget.message.type==Type.text  && isMe)
              _OptionItem(icon: Icon(Icons.edit,color: Colors.blueAccent,), name: "Edit Message", myOnTap: (){
                // for hiding current bottom sheet
                Navigator.pop(context);
                _showMessageUpdateDialog();
              }),

              if(widget.message.type==Type.text  || widget.message.type==Type.image && isMe )
              //delete text option
              _OptionItem(icon: Icon(Icons.delete_forever,color: Colors.redAccent,), name: "Delete Message", myOnTap: () async {
                await APIs.deleteMessage(widget.message).then((_)=>Navigator.pop(context));
              },),

              //divider border
              Divider(color: Colors.black26, endIndent: mq.width*.04, indent:  mq.width*.04,),

              //sent time
              _OptionItem(icon: Icon(Icons.remove_red_eye,color: Colors.blue,), name: "Sent at:  ${MmyDateUtill.getMessageTime(context: context, time: widget.message.sent)}", myOnTap: (){}),

              //Read time
              _OptionItem(icon: Icon(Icons.remove_red_eye,color: Colors.green,),
                  name:widget.message.read.isEmpty?
                  'Read at:  Not seen yet':
                  "Read at:  ${MmyDateUtill.getMessageTime(context: context, time: widget.message.read)}",
                  myOnTap: (){}),
            ],
          );
        });
  }


//dialog for updating message content
  void _showMessageUpdateDialog(){
    String updatedMsg=widget.message.msg;
    showDialog(context: context, builder: (_)=> AlertDialog(
      contentPadding: EdgeInsets.only(left: 24,right: 24,top: 20,bottom: 10),
      //title
      title: const Row(

        children: [
        Icon(Icons.message,color:Colors.lightBlueAccent,),
        Text("Update Message")
      ],),

      content: TextFormField(initialValue:updatedMsg ,
      maxLines: null,
      onChanged: (value)=>updatedMsg=value,
      decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),

      ),
      actions: [

        MaterialButton(onPressed: (){
          Navigator.pop(context);
        },child: Text("Cancel"),),
        MaterialButton(onPressed: () async {
          Navigator.pop(context);
           await APIs.updateMessage(widget.message, updatedMsg).then((onValue)=>Navigator.pop(context));
        },child: Text("Update"),),
      ],

    ));


  }

}

class _OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final  VoidCallback myOnTap;
  const _OptionItem({required this.icon, required this.name, required this.myOnTap});



  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => myOnTap() ,
      child: Padding(
        padding: EdgeInsets.only(left: mq.width*.05,bottom: mq.height*.015,top:mq.height*.015 ),
        child: Row(
          children: [
            icon,
            Flexible(child: Text('    $name',style: TextStyle(fontSize: 14,color: Colors.grey),)),

          ],
        ),
      ),
    );
  }



}

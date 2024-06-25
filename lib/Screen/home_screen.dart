import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:we_talk/Screen/auth/login_screen.dart';
import 'package:we_talk/Screen/auth/profile_screen.dart';
import 'package:we_talk/api/apis.dart';
import 'package:we_talk/custom_widgets/chat_user_card.dart';
import 'package:we_talk/main.dart';
import 'package:we_talk/models/chat_user.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUser> _list = [];

  final List<ChatUser> _searchList = [];
  bool _isSearching=false;

  @override
  void initState() {
    super.initState();
    APIs.updateActiveStaus(true);
    SystemChannels.lifecycle.setMessageHandler((massage){
      if(APIs.auth.currentUser!=null) {
        if (massage.toString().contains('resume')) APIs.updateActiveStaus(true);
        if (massage.toString().contains('pause')) APIs.updateActiveStaus(false);
      }
      return Future.value();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ()=>FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: (){
          if(_isSearching){
            setState(() {
              _isSearching=!_isSearching;
            });
            return Future.value(false);
          }
          else{
            return Future.value(true);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            leading: Icon(Icons.home),
            title: _isSearching?
                TextField(
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Name, Email, .....'),
                  autofocus: true,
                  style: TextStyle(fontSize: 17,letterSpacing: 0.5),
                  //all searching logic
                 onChanged:(val){
                    _searchList.clear();

                    for(var i in _list){
                      if(i.name.toLowerCase().contains(val.toLowerCase()) || i.email.toLowerCase().contains(val.toLowerCase()) ){
                        _searchList.add(i);
                      }

                      setState(() {
                        _searchList;
                      });
                    }
                 },
                )
                :Text("We Talk"),
            actions: [
              //for searching Icon
              IconButton(onPressed: () {
                setState(() {
                  _isSearching=!_isSearching;
                });
              }, icon: Icon(_isSearching ? CupertinoIcons.clear_circled_solid :Icons.search)),
              IconButton(
                  onPressed: () {
                    //sending current user data for profile creating
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ProfileScreen(myChatUser: APIs.me)));
                  },
                  icon: Icon(Icons.more_vert)),
            ],
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: FloatingActionButton(
              onPressed: () async {},
              child: Icon(Icons.add_comment_rounded),
            ),
          ),
          body: StreamBuilder(
            stream: APIs.getAllUsers(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                case ConnectionState.active:
                case ConnectionState.done:
                  final data = snapshot.data?.docs;
                  _list =
                      data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];
                  if (_list.isNotEmpty) {
                    return ListView.builder(
                        padding: EdgeInsets.only(
                            top: mq.height * .01, bottom: mq.height * .01),

                        //its depend on searching btn
                        itemCount: _isSearching?  _searchList.length:_list.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          //for sending data except current user
                          return ChatUserCard(myChatUser:_isSearching?_searchList[index]: _list[index]);
                        });
                  } else {
                    return const Center(
                        child: Text(
                      "No Connection Found",
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.black45,
                          fontWeight: FontWeight.bold),
                    ));
                  }
              }
            },
          ),
        ),
      ),
    );
  }
}

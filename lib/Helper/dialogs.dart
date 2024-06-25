import 'package:flutter/material.dart';

class Dialogs {
  static void showSnackBar(BuildContext context,String msg,color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: const Duration(milliseconds: 300),
      content: Text(msg,style: TextStyle(color: Colors.black,fontWeight: FontWeight.w600),),
      // backgroundColor: Colors.red.withOpacity(.9),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
    ));
  }

  static void showProgressBar(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) => Center(child: CircularProgressIndicator()));
  }
}

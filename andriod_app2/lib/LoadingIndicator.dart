import 'package:flutter/material.dart';

class Dialogs {
  static Future<void> showLoadingDialog(
      BuildContext context, GlobalKey key) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
              onWillPop: () async => false,
              child: SimpleDialog(
                shape: CircleBorder(),
                elevation: 0.0,
                key: key,
                backgroundColor: Colors.transparent,
                children: <Widget>[
                  Center(
                    child: CircularProgressIndicator(),
                  )]
              )
          );
        });
  }
}
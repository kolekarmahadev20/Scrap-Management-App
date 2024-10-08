import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      backgroundColor:Color(0xFF6482AD),
      title: Text(
        "Scrap Management",
        style: TextStyle(color: Colors.white),
      ),
      elevation: 2,
      shadowColor: Colors.black,
      shape: OutlineInputBorder(

        borderSide: BorderSide(style: BorderStyle.solid ,color: Colors.white60)
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.notifications, color: Colors.white,),
          onPressed: () {
            // Handle notification icon press here
            showDialog(context: context, builder: (BuildContext context){
              return AlertDialog(
                title: Text("Notification"),
                content: Text('You have new notifications!'),
                actions: <Widget>[
                  TextButton(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                  ),
                ],
              );
            });
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

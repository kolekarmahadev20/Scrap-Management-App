import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.indigo[800],
      title: Center(
          child: Text(
        "Scrap Management       ",
        style: TextStyle(color: Colors.white),
      )),
      elevation: 10,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

import 'package:flutter/material.dart';

import 'materialColor.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String appBarText;

  CustomAppBar(this.appBarText);

  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.grey[50],
      elevation: 0,

      title: Text(
        appBarText,
        style: TextStyle(
          color: materialColor(RosePink.primary),
          fontSize: 18,
        ),
      ),
      leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: materialColor(RosePink.primary),
          ),
          onPressed: () => Navigator.pop(context)),
    );
  }
}

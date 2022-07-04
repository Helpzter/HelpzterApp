import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

import '../materialColor.dart';

showContactInfoDialog(context) async {
  await showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      String title = "Contact Info";
      return new AlertDialog(
          title: Text(
            title,
            style: TextStyle(fontSize: 22),
          ),
          content: SingleChildScrollView(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text('Phone Number:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 17)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: SelectableText(
                      '(347) 201 3613',
                      style: TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text('Email:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 17)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: SelectableText(
                      'Raizel@helpzter.com ',
                      style: TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      children: [
                        SvgPicture.asset("assets/icons/InstagramLogo.svg", width: 20, height: 20),
                        Text(' Follow us on Instagram:',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: SelectableText(
                      'Helpzter@gmail.com',
                      style: TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                  ),
                ]),
          ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'OK'),
            child: const Text('OK'),
          ),
        ],
      );

    },
  );
}
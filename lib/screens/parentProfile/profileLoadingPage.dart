import 'package:flutter/material.dart';
import 'package:skeletons/skeletons.dart';

import '../../materialColor.dart';

class ProfileLoadingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title: Text(
          'Profile',
          style: TextStyle(color: materialColor(RosePink.primary)),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Center(
                child: Container(
                  margin: EdgeInsets.only(top: 10, bottom: 25),
                  child: SkeletonAvatar(
                    style: SkeletonAvatarStyle(
                        shape: BoxShape.circle, width: 120, height: 120),
                  ),
                ),
              ),
              SkeletonLine(
                style: SkeletonLineStyle(
                  height: 30,
                  width: 180,
                  borderRadius: BorderRadius.circular(20),
                  alignment: AlignmentDirectional.center,
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 60),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Email",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    SkeletonLine(
                      style: SkeletonLineStyle(
                        height: 16,
                        width: 170,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 20,
                thickness: 2,
              ),
              Container(
                margin: EdgeInsets.only(top: 4, bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Address",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    SkeletonLine(
                      style: SkeletonLineStyle(
                        height: 16,
                        width: 100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 20,
                thickness: 2,
              ),
              Container(
                margin: EdgeInsets.only(top: 4, bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Phone Number",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    SkeletonLine(
                      style: SkeletonLineStyle(
                        height: 16,
                        width: 120,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 20,
                thickness: 2,
              ),
              Container(
                margin: EdgeInsets.only(top: 4, bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Kids",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    SkeletonLine(
                      style: SkeletonLineStyle(
                        height: 16,
                        width: 30,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 20,
                thickness: 2,
              ),
              Container(
                margin: EdgeInsets.only(top: 4, bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Emergency Name",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    SkeletonLine(
                      style: SkeletonLineStyle(
                        height: 16,
                        width: 110,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 20,
                thickness: 2,
              ),
              Container(
                margin: EdgeInsets.only(top: 4, bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Emergency Number",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    SkeletonLine(
                      style: SkeletonLineStyle(
                        height: 16,
                        width: 120,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 20,
                thickness: 2,
              ),
              Container(
                margin: EdgeInsets.only(top: 4, bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Change Password",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                      icon: Icon(Icons.edit),
                      onPressed: () {
                      },
                      color: materialColor(RosePink.primary),
                      splashRadius: 25,
                    )
                  ],
                ),
              ),
              Divider(
                height: 20,
                thickness: 2,
              ),
            ],
          ),
        ),
      ),
    );
    ;
  }
}

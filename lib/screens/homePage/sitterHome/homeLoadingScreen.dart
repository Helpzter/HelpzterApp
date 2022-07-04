import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:skeletons/skeletons.dart';

import '../../../globals.dart';
import '../../../materialColor.dart';
import '../../../size_config.dart';

class HomeLoadingScreen extends StatelessWidget {
  final FirebaseAuth auth = FirebaseAuth.instance;
  User user;

  Widget build(BuildContext context) {
    SizeConfig().init(context);
    user = auth.currentUser;
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 5, bottom: 15),
                child: ValueListenableBuilder<Map>(
                  valueListenable: userInfo,
                  builder: (context, value, child) {
                    return Text(
                      'Welcome, ${value['name']}',
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.w200),
                    );
                  },
                ),
              ),
              Text(
                'Today\'s Bookings',
                style: TextStyle(fontSize: 17),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 7, top: 6),
                child: Container(
                  height: 3,
                  width: 50,
                  color: materialColor(RosePink.primary),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 2, vertical: 15),
                        child: ListTile(
                          title: Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: SkeletonLine(
                              style: SkeletonLineStyle(
                                height: 18,
                                width: 155,
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Wrap(
                              direction: Axis.vertical,
                              spacing: 6,
                              children: [
                                SkeletonLine(
                                  style: SkeletonLineStyle(
                                    height: 13,
                                    width: 130,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                Wrap(
                                  spacing: 8,
                                  children: [
                                    SkeletonLine(
                                      style: SkeletonLineStyle(
                                        height: 13,
                                        width: 90,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    SkeletonLine(
                                      style: SkeletonLineStyle(
                                        height: 13,
                                        width: 115,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          trailing: Icon(Icons.arrow_forward),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  'Future Bookings',
                  style: TextStyle(fontSize: 17),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 7, top: 6),
                child: Container(
                  height: 3,
                  width: 50,
                  color: materialColor(RosePink.primary),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 2, vertical: 15),
                        child: ListTile(
                          title: Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: SkeletonLine(
                              style: SkeletonLineStyle(
                                height: 18,
                                width: 155,
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Wrap(
                              direction: Axis.vertical,
                              spacing: 6,
                              children: [
                                SkeletonLine(
                                  style: SkeletonLineStyle(
                                    height: 13,
                                    width: 130,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                Wrap(
                                  spacing: 8,
                                  children: [
                                    SkeletonLine(
                                      style: SkeletonLineStyle(
                                        height: 13,
                                        width: 90,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    SkeletonLine(
                                      style: SkeletonLineStyle(
                                        height: 13,
                                        width: 115,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          trailing: Icon(Icons.arrow_forward),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  'Previous Bookings',
                  style: TextStyle(fontSize: 17),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 7, top: 6),
                child: Container(
                  height: 3,
                  width: 50,
                  color: materialColor(RosePink.primary),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 2, vertical: 15),
                        child: ListTile(
                          title: Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: SkeletonLine(
                              style: SkeletonLineStyle(
                                height: 18,
                                width: 155,
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Wrap(
                              direction: Axis.vertical,
                              spacing: 6,
                              children: [
                                SkeletonLine(
                                  style: SkeletonLineStyle(
                                    height: 13,
                                    width: 130,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                Wrap(
                                  spacing: 8,
                                  children: [
                                    SkeletonLine(
                                      style: SkeletonLineStyle(
                                        height: 13,
                                        width: 90,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    SkeletonLine(
                                      style: SkeletonLineStyle(
                                        height: 13,
                                        width: 115,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          trailing: Icon(Icons.arrow_forward),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

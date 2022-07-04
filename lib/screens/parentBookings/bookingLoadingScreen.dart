import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:skeletons/skeletons.dart';

import '../../../globals.dart';
import '../../../materialColor.dart';
import '../../../size_config.dart';

class BookingLoadingScreen extends StatelessWidget {

  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pending',
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
                  'Booked',
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
                  'Completed Jobs',
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

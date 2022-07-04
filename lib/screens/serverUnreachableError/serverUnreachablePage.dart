import 'package:flutter/material.dart';

import '../homePage/homePageWrapper.dart';

class ServerUnreachableErrorPage extends StatelessWidget {
  final returnToWrapper;

  ServerUnreachableErrorPage({Key key, this.returnToWrapper: false}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Something went wrong', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),),
              Padding(
                padding: const EdgeInsets.only(top: 5, bottom: 15),
                child: Text('Try checking your wifi connection', style: TextStyle(fontSize: 15,color: Colors.grey),),
              ),
              ElevatedButton(
                onPressed: () {
                  if(returnToWrapper) {
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) => HomePageWrapper()),
                            (route) => false);
                  } else {
                    Navigator.pop(context);
                  }

                },
                child: Text('Try again'),
                style: ElevatedButton.styleFrom(shape: StadiumBorder()),
              )
            ],
          ),
        ),
      ),
    );
  }
}

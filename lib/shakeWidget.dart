import 'package:flutter/material.dart';

class ShakeX extends StatefulWidget {
  final Widget child;
  final double horizontalPadding;
  final double animationRange;
  final ShakeXController controller;
  final Duration animationDuration;

  const ShakeX(
      {Key key,
        @required this.child,
        this.horizontalPadding = 30,
        this.animationRange = 24,
        this.controller,
        this.animationDuration = const Duration(milliseconds: 500)})
      : super(key: key);

  @override
  _ShakeXState createState() => _ShakeXState();
}

class _ShakeXState extends State<ShakeX> with SingleTickerProviderStateMixin {
  AnimationController animationController;

  @override
  void initState() {
    animationController =
        AnimationController(duration: widget.animationDuration, vsync: this);

    if (widget.controller != null) {
      widget.controller.setState(this);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Animation<double> offsetAnimation =
    Tween(begin: 0.0, end: widget.animationRange)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(animationController)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          animationController.reverse();
        }
      });

    return AnimatedBuilder(
      animation: offsetAnimation,
      builder: (context, child) {
        return Center(
          child: Container(
           // margin: EdgeInsets.symmetric(horizontal: widget.animationRange),
            padding: EdgeInsets.only(
                left: offsetAnimation.value + widget.horizontalPadding,
                right: widget.horizontalPadding - offsetAnimation.value),
            child: widget.child,
          ),
        );
      },
    );
  }
}

class ShakeXController {
  _ShakeXState _state;
  void setState(_ShakeXState state) {
    _state = state;
  }

  Future<void> shake() {
    return _state.animationController.forward(from: 0.0);
  }
}
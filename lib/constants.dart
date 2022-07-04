import 'package:flutter/material.dart';
import './materialColor.dart';

final Shader linearGradient = LinearGradient(
  colors: <Color>[
    materialColor(RosePink.primary),
    materialColor(RosePink.primary)[200]
  ],
).createShader(new Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));
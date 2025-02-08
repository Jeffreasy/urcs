import 'package:flutter/material.dart';

class StateProperties {
  static MaterialStateProperty<Color?> color(Color color) {
    return MaterialStateProperty.all(color);
  }
}

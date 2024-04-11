import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Test extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<Test> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Listener(
          onPointerSignal: (pointerSignal) {
            if (pointerSignal is PointerScrollEvent) {
              final ctrlHeld = pointerSignal.buttons == kSecondaryMouseButton;
              // Ctrl 키가 눌려있는지 확인합니다.
              if (ctrlHeld) {
                setState(() {
                  // 마우스 휠을 위로 움직이면 줌 인, 아래로 움직이면 줌 아웃합니다.
                  _scale += pointerSignal.scrollDelta.dy * -0.01;
                  // 스케일 값을 적절한 범위 내로 제한합니다.
                  _scale = _scale.clamp(0.5, 5.0);
                });
              }
            }
          },
          child: Transform.scale(
            scale: _scale,
            child: Center(
              child: Text('Ctrl + Scroll to zoom in/out'),
            ),
          ),
        ),
      ),
    );
  }
}

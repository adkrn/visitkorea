import 'package:flutter/material.dart';
import 'package:visitkorea/common_widgets.dart';

class IntroPage extends StatefulWidget {
  @override
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  bool isHoverd = false;
  void onHoverdCallBack() {
    setState(() {
      isHoverd = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    //4821, bot 48, left,right 51
    //4613, 792, 240

    bool isMobile = screenWidth < 1000;

    double imageWidth = isMobile ? 390 : 1920;
    double imageHeight = isMobile ? 4972 : 4835;
    double buttonWidth = isMobile ? 288 : 336;
    double buttonHeight = isMobile ? 70 : 81;

    double maxTopPos = isMobile ? 4821 : 4613;
    double maxBottomPos = isMobile ? 48 : 105;
    double maxHorizPos = isMobile ? 51 : 792;

    double containerWidth = screenWidth * (buttonWidth / imageWidth);
    double containerHeight = containerWidth * (buttonHeight / buttonWidth);

    double topPosition = screenWidth * (maxTopPos / imageWidth);
    if (topPosition > maxTopPos) topPosition = maxTopPos;
    double bottomPosition = screenWidth * (maxBottomPos / imageWidth);
    if (bottomPosition > maxBottomPos) bottomPosition = maxBottomPos;
    double leftPosition = screenWidth * (maxHorizPos / imageWidth);
    if (leftPosition > maxHorizPos) leftPosition = maxHorizPos;
    double rightPosition = screenWidth * (maxHorizPos / imageWidth);
    if (rightPosition > maxHorizPos) rightPosition = maxHorizPos;

    return Scaffold(
        appBar: CustomAppBar(
            appBarHeight: isMobile ? 98 : 90, onHoverd: onHoverdCallBack),
        body: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Stack(children: [
                  Image.asset(
                    isMobile
                        ? 'assets/introPage_Mobile.png'
                        : 'assets/introPage_PC.png',
                    fit: BoxFit.fill,
                  ),
                  Positioned(
                      bottom: bottomPosition,
                      left: leftPosition,
                      right: rightPosition,
                      child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: SizedBox(
                            width: containerWidth,
                            height: containerHeight,
                          )))
                ]),
              ),
            ),
            if (isHoverd) ...[
              MouseRegion(
                onEnter: (event) {
                  setState(() {
                    isHoverd = false;
                  });
                },
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
              CustomLnb(),
            ]
          ],
        ));
  }
}

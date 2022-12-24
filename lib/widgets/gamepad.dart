import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:jumpy/helper/enums.dart';
import 'package:jumpy/helper/game_controller.dart';
import 'package:jumpy/widgets/responsive/responsive.dart';

class GamePad extends StatelessWidget {
  const GamePad({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.h,
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          GestureDetector(
            onTapUp: ((details) {
              GetIt.instance<GameController>().releaseControl();
            }),
            onTapDown: (details) {
              GetIt.instance<GameController>().setAction(GameAction.moveLeft);
            },
            child: Image.asset(
              "assets/images/left.png",
              width: 20.w,
              height: 20.w,
            ),
          ),
          const SizedBox(width: 20),
          Listener(
            child: GestureDetector(
              onTapUp: ((details) {
                GetIt.instance<GameController>().releaseControl();
              }),
              onTapDown: (details) {
                GetIt.instance<GameController>()
                    .setAction(GameAction.moveRight);
              },
              child: Image.asset(
                "assets/images/right.png",
                width: 20.w,
                height: 20.w,
              ),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: (() {
              GetIt.instance<GameController>().isJumping = true;
            }),
            child: Image.asset(
              "assets/images/circle.png",
              width: 22.w,
              height: 22.w,
            ),
          )
        ],
      ),
    );
  }
}

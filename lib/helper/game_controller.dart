import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'enums.dart';

class GameController {
  int score = 0;
  FlameGame? currentGameRef;
  GameAction action = GameAction.idle;
  bool isJumping = false;
  ValueNotifier<GameStatus> gameStatus =
      ValueNotifier<GameStatus>(GameStatus.pause);
  ValueNotifier<int> coinsCollected = ValueNotifier<int>(0);
  increaseScore() {
    score += 1;
  }

  resetScore() {
    score = 0;
  }

  releaseControl() {
    action = GameAction.idle;
  }

  setAction(GameAction updatedAction) {
    action = updatedAction;
  }

  setGameState(GameStatus updatedState) {
    gameStatus.value = updatedState;
  }
}

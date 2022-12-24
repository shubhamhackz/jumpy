enum GameAction { moveRight, moveLeft, idle }

enum GameStatus { pause, start, over, restart }

extension GameActionX on GameAction {
  bool get isMovingRight => this == GameAction.moveRight;
  bool get isMovingLeft => this == GameAction.moveLeft;
  bool get isIdle => this == GameAction.idle;
}

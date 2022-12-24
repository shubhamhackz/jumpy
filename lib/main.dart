import 'dart:math';
import 'dart:ui' as ui show Gradient, lerpDouble;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/experimental.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/parallax.dart';
import 'package:flame/sprite.dart';
import 'package:flame_audio/audio_pool.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:jumpy/helper/enums.dart';
import 'package:jumpy/helper/game_controller.dart';
import 'package:jumpy/helper/preference_helper.dart';
import 'package:jumpy/widgets/player.dart';
import 'package:jumpy/widgets/responsive/responsive.dart';
import 'package:uuid/uuid.dart';

void main() {
  setUp();
  runApp(const MyGame());
}

setUp() {
  GetIt getIt = GetIt.instance;
  getIt.registerLazySingleton<GameController>(() => GameController());
}

class MyGame extends StatefulWidget {
  const MyGame({super.key});

  @override
  State<MyGame> createState() => _MyGameState();
}

class _MyGameState extends State<MyGame> {
  @override
  void initState() {
    PreferenceHelper.init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveWidget(
      pixelDensity: false,
      designUISize: const Size(800, 300),
      builder: (context, orientation, deviceType) => MaterialApp(
        home: Stack(
          children: [
            GameWidget(
              game: RunGame(),
            ),
            // Positioned(
            //   left: 0,
            //   bottom: 4.w,
            //   child: const GamePad(),
            // ),
            Positioned(
              child: ValueListenableBuilder(
                valueListenable:
                    GetIt.instance<GameController>().coinsCollected,
                builder: ((context, value, child) {
                  return Material(
                    color: Colors.transparent,
                    child: Padding(
                      padding: EdgeInsets.only(left: 2.w, top: 2.w),
                      child: Text(
                        "Score: $value",
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: "Bungee",
                          fontSize: 26,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            ValueListenableBuilder(
              valueListenable: GetIt.instance<GameController>().gameStatus,
              builder: (context, gameStatus, __) {
                if (gameStatus == GameStatus.over) {
                  return Material(
                    color: Colors.transparent,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: double.infinity,
                        ),
                        const Text(
                          "Game Over",
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: "BungeeInline",
                            fontSize: 32,
                          ),
                        ),
                        Text(
                          "Score: ${GetIt.instance<GameController>().coinsCollected.value}",
                          style: const TextStyle(
                            color: Colors.black,
                            fontFamily: "Bungee",
                            fontSize: 24,
                          ),
                        ), //
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.black87,
                            backgroundColor: Colors.white38,
                            // padding: const EdgeInsets.all(16.0),
                            textStyle: const TextStyle(
                              fontSize: 20,
                              fontFamily: "Bungee",
                            ),
                          ),
                          icon: const Icon(Icons.refresh),
                          onPressed: () {
                            GetIt.instance<GameController>()
                                .coinsCollected
                                .value = 0;
                            GetIt.instance<GameController>()
                                .setGameState(GameStatus.restart);

                            GetIt.instance<GameController>()
                                .currentGameRef
                                ?.resumeEngine();
                          },
                          label: const Text('Play Again'),
                        ),
                      ],
                    ),
                  );
                } else {
                  return const SizedBox();
                }
              },
            )
          ],
        ),
      ),
    );
  }
}

class RunGame extends FlameGame
    with HasDraggables, HasCollisionDetection, TapDetector {
  ParallaxComponent? _parallaxComponent;
  Player? _player;
  World? _world;
  CameraComponent? _cameraComponent;
  CutterManager? _cutterManager;
  CoinManager? _coinManager;

  @override
  bool get debugMode => false;

  @override
  void onTap() {
    GameController gameController = GetIt.instance<GameController>();
    if (gameController.gameStatus.value == GameStatus.pause) {
      gameController.gameStatus.value = GameStatus.start;
    } else if (gameController.gameStatus.value == GameStatus.start) {
      gameController.isJumping = true;
    }

    super.onTap();
  }

  loadWorld() async {
    _world = World()..addToParent(this);

    _cameraComponent = CameraComponent(world: _world!);

    final skyLayer = await loadParallaxLayer(
      ParallaxImageData("sky.png"),
      fill: LayerFill.width,
    );
    final mountainLayer = await loadParallaxLayer(
      ParallaxImageData("mountains.png"),
      velocityMultiplier: Vector2(1.8, 0),
      fill: LayerFill.width,
    );
    final hillsLayer = await loadParallaxLayer(
      ParallaxImageData("hills.png"),
      velocityMultiplier: Vector2(2.6, 0),
      fill: LayerFill.width,
    );

    final treesLayer = await loadParallaxLayer(
      ParallaxImageData("trees.png"),
      velocityMultiplier: Vector2(3.8, 0),
      fill: LayerFill.width,
    );
    final grassLayer = await loadParallaxLayer(
      ParallaxImageData("grass.png"),
      velocityMultiplier: Vector2(4.0, 0),
      fill: LayerFill.width,
    );
    final landLayer = await loadParallaxLayer(
      ParallaxImageData("land.png"),
      velocityMultiplier: Vector2(4.6, 0),
      fill: LayerFill.width,
    );

    final cloudsLayer = await loadParallaxLayer(
      ParallaxImageData(
        'clouds.png',
      ),
      velocityMultiplier: Vector2(0.3, 0),
    );
    final Parallax parallax = Parallax(
      [
        skyLayer,
        cloudsLayer,
        mountainLayer,
        hillsLayer,
        treesLayer,
        grassLayer,
        landLayer,
      ],
      size: Vector2(100.h, 100.w),
      // baseVelocity: Vector2(20, 0),
    );
    _parallaxComponent = ParallaxComponent(parallax: parallax)
      ..anchor = Anchor.center;
    _player = Player(parallax);

    add(_cameraComponent!);
    _cutterManager = CutterManager(parallax, _world!);
    _coinManager = CoinManager(parallax, _world!);
    _world?.add(_parallaxComponent!);
    _world?.add(_player!);
    _world?.add(_cutterManager!);
    _world?.add(_coinManager!);
  }

  resetWorld() {
    _world?.remove(_parallaxComponent!);
    _world?.remove(_player!);
    _world?.remove(_cutterManager!);
    _world?.remove(_coinManager!);
    remove(_cameraComponent!);
    remove(_world!);
  }

  @override
  Future<void>? onLoad() async {
    Flame.device
      ..setLandscape()
      ..fullScreen();
    await FlameAudio.audioCache.load('coin.mp3');
    loadWorld();
    GetIt.instance<GameController>().gameStatus.addListener(() {
      if (GetIt.instance<GameController>().gameStatus.value ==
          GameStatus.restart) {
        resetWorld();
        loadWorld();
        GetIt.instance<GameController>().gameStatus.value = GameStatus.start;
      }
    });
    return super.onLoad();
  }
}

class CutterManager extends Component {
  CutterManager(this.parallax, this.world);
  final Parallax parallax;
  final World world;
  bool isAdded = false;
  late CutterSpriteComponent lastCutterSpriteCOmponent;
  @override
  Future<void>? onLoad() {
    lastCutterSpriteCOmponent = CutterSpriteComponent(parallax, world);
    world.add(lastCutterSpriteCOmponent);
    return super.onLoad();
  }

  @override
  void update(double dt) {
    GameAction action = GetIt.instance<GameController>().action;
    int rand = Random().nextInt(6);

    if (lastCutterSpriteCOmponent.position.x <= -200 &&
        lastCutterSpriteCOmponent.topLeftPosition.x <= -300) {
      world.remove(lastCutterSpriteCOmponent);
      lastCutterSpriteCOmponent = CutterSpriteComponent(parallax, world);
      world.add(lastCutterSpriteCOmponent);
    }
    // if (parallax.currentOffset().x <= 0.15 &&
    //     !isAdded &&
    //     action.isMovingRight) {
    //   isAdded = true;
    //   world.add(CutterSpriteComponent(parallax, world));
    // }
    super.update(dt);
  }
}

class CutterSpriteComponent extends SpriteAnimationComponent
    with CollisionCallbacks, HasGameRef {
  CutterSpriteComponent(this.parallax, this.world,
      {this.initPosition, this.midWayCallback})
      : velocity = Vector2.zero(),
        super(size: Vector2(23.w, 18.w));
  final Parallax parallax;
  final Vector2? initPosition;
  final World world;
  final Vector2 velocity;
  final double runSpeed = 200.0;
  final ValueChanged? midWayCallback;
  late AudioPool collisionSound;
  @override
  Future<void>? onLoad() async {
    collisionSound = await AudioPool.create('audio/hit.mp3', maxPlayers: 1);
    priority = 10;
    x = 35.h;
    y = 18.w;
    final sprites =
        [1, 2, 3, 4, 5, 6].map((i) => Sprite.load('rotating_saw_0$i.png'));
    final spriteAnimation = SpriteAnimation.spriteList(
      await Future.wait(sprites),
      stepTime: 0.08,
    );
    animation = spriteAnimation;

    // final hitboxPaint = BasicPalette.white.paint()
    //   ..style = PaintingStyle.stroke;
    // add(
    //   PolygonHitbox.relative(
    //     [
    //       Vector2(0.0, -1.0),
    //       Vector2(-1.0, -0.1),
    //       Vector2(-0.2, 0.4),
    //       Vector2(0.2, 0.4),
    //       Vector2(1.0, -0.1),
    //     ],
    //     parentSize: size,
    //   )
    //     ..paint = hitboxPaint
    //     ..renderShape = true,
    // );
    add(CircleHitbox());
    return super.onLoad();
  }

  @override
  void update(double dt) {
    GameController gameController = GetIt.instance<GameController>();
    GameAction action = gameController.action;
    bool isJumping = gameController.isJumping;
    // x += parallax.currentOffset().x;
    // if (action.isMovingRight) {
    //   x -= parallax.currentOffset().x + 4;
    // } else if (action.isMovingLeft) {
    //   x -= parallax.currentOffset().x + 4;
    // }
    if (gameController.gameStatus.value == GameStatus.start) {
      x -= parallax.currentOffset().x + 4;
    }

    if (x <= 240 && midWayCallback != null) {
      midWayCallback!(true);
    }
    super.update(dt);
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    // velocity.negate();
    // flipVertically();
    collisionSound.start();
    if (other is Player) {
      GetIt.instance<GameController>().setGameState(GameStatus.over);
      GetIt.instance<GameController>().currentGameRef = gameRef;
      gameRef.paused = true;
      PreferenceHelper.setHighscore = GetIt.instance<GameController>().score;
    }
    // print('COLLISION');
  }
}

class CoinManager extends Component {
  CoinManager(this.parallax, this.world);
  final Parallax parallax;
  final World world;
  bool isAdded = false;
  late Map<String, CoinSpriteComponent> lastCoinSpriteComponents = {};
  late AudioPool coinSound;
  @override
  Future<void>? onLoad() {
    String coinId = const Uuid().v1();
    lastCoinSpriteComponents[coinId] = CoinSpriteComponent(
      parallax,
      world,
      coinId: coinId,
      onRemoved: ((id) {
        lastCoinSpriteComponents.remove(id);
      }),
    );
    world.addAll(lastCoinSpriteComponents.values.toList());

    return super.onLoad();
  }

  @override
  void update(double dt) {
    GameAction action = GetIt.instance<GameController>().action;

    int noOfCoins = Random().nextInt(4) + 1;
    if (lastCoinSpriteComponents.isEmpty ||
        (lastCoinSpriteComponents.values.toList().last.position.x <= -300 &&
            lastCoinSpriteComponents.values.toList().last.topLeftPosition.x <=
                -300)) {
      if (lastCoinSpriteComponents.isNotEmpty) {
        world.removeAll(lastCoinSpriteComponents.values.toList());
        lastCoinSpriteComponents.clear();
      }
      // world.remove(lastCutterSpriteCOmponent);
      for (int i = 0; i <= noOfCoins; i++) {
        // lastCoinSpriteComponents.add(CoinSpriteComponent(parallax, world));
        String coinId = const Uuid().v1();
        lastCoinSpriteComponents[coinId] = CoinSpriteComponent(
          parallax,
          world,
          coinId: coinId,
          onRemoved: ((id) {
            lastCoinSpriteComponents.remove(id);
          }),
        );
      }
      world.addAll(lastCoinSpriteComponents.values.toList());
    }
    // if (parallax.currentOffset().x <= 0.15 &&
    //     !isAdded &&
    //     action.isMovingRight) {
    //   isAdded = true;
    //   world.add(CutterSpriteComponent(parallax, world));
    // }
    super.update(dt);
  }
}

class CoinSpriteComponent extends SpriteAnimationComponent
    with CollisionCallbacks, HasGameRef {
  CoinSpriteComponent(this.parallax, this.world,
      {this.initPosition,
      this.midWayCallback,
      this.onRemoved,
      required this.coinId})
      : velocity = Vector2.zero(),
        super(size: Vector2(7.w, 7.w));
  final Parallax parallax;
  final Vector2? initPosition;
  final World world;
  final Vector2 velocity;
  final double runSpeed = 200.0;
  final ValueChanged? midWayCallback;
  final ValueChanged? onRemoved;
  final String coinId;
  late AudioPool coinSound;
  @override
  Future<void>? onLoad() async {
    coinSound = await AudioPool.create('audio/coin.mp3', maxPlayers: 1);
    int xOffset = Random().nextInt(30) + 20;
    bool shouldFloat = Random().nextBool();
    int yOffset =
        shouldFloat ? Random().nextInt(10) + -3 : Random().nextInt(20) + 15;

    priority = 5;
    x = xOffset.h;
    y = yOffset.w;
    final spriteSheet = SpriteSheet(
        image: await gameRef.images.load('coin.png'), srcSize: Vector2(20, 20));
    // final sprites =
    //     [1, 2, 3, 4, 5, 6].map((i) => Sprite.load('rotating_saw_0$i.png'));
    // final spriteAnimation = SpriteAnimation.spriteList(
    //   await Future.wait(sprites),
    //   stepTime: 0.08,
    // );
    animation = spriteSheet.createAnimation(row: 0, stepTime: 0.1);
    add(CircleHitbox());
    return super.onLoad();
  }

  @override
  void onRemove() {
    if (onRemoved != null) {
      onRemoved!(coinId);
    }
    super.onRemove();
  }

  @override
  void update(double dt) {
    GameController gameController = GetIt.instance<GameController>();
    GameAction action = gameController.action;
    bool isJumping = gameController.isJumping;
    // x += parallax.currentOffset().x;
    // if (action.isMovingRight) {
    //   // x -= parallax.currentOffset().x * parallax.baseVelocity.x / 5;
    //   x -= parallax.currentOffset().x + 4;
    // } else if (action.isMovingLeft) {
    //   // x -= parallax.currentOffset().x * parallax.baseVelocity.x / 2;
    //   x += parallax.currentOffset().x + 4;
    // }
    if (gameController.gameStatus.value == GameStatus.start) {
      x -= parallax.currentOffset().x + 4;
    }

    if (x <= 240 && midWayCallback != null) {
      midWayCallback!(true);
    }
    // print('Parallex Offset : ${parallax.currentOffset()}');

    super.update(dt);
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    // velocity.negate();
    // // flipVertically();
    // print('COLLISION COIN');
    // FlameAudio.play('coin.mp3');
    if (other is Player) {
      coinSound.start();
      GetIt.instance<GameController>().coinsCollected.value += 10;
      add(RemoveEffect(delay: 0.1));
    }
  }
}

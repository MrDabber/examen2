import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame_audio/flame_audio.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.setPortrait();
  final shapeGame = GameTemplate();
  runApp(GameWidget(game: shapeGame));
}

class GameTemplate extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  late Ship shipPlayer;
  int totalAttempts = 30;
  bool gameOver = false;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    add(HeaderTitle());
    shipPlayer = Ship(await loadSprite('triangle.png'));
    add(shipPlayer);
    final random = Random();
    for (int i = 0; i < 3; i++) {
      add(Square(
        await loadSprite('square.png'),
        initialPosition: Vector2(random.nextDouble() * size.x, 0),
      ));
    }

    await FlameAudio.audioCache.load('ball.wav');
    await FlameAudio.audioCache.load('explosion.wav');
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (shipPlayer.points <= 0 || totalAttempts <= 0) {
      if (!gameOver) {
        gameOver = true;
        pauseEngine();
        add(GameOverScreen());
      }
    }
  }
}

// Add a ship to the game, using triangle.png
class Ship extends SpriteComponent
    with HasGameReference<GameTemplate>, CollisionCallbacks {
  final spriteVelocity = 500;
  double screenPosition = 0.0;
  bool leftPressed = false;
  bool rightPressed = false;
  bool isCollision = false;
  bool upPressed = false;
  bool downPressed = false;
  int points = 100;

  Ship(Sprite sprite) {
    debugMode = true;
    this.sprite = sprite;
    size = Vector2(50.0, 50.0);
    anchor = Anchor.center;
    position = Vector2(200.0, 200.0);
    add(RectangleHitbox());

    //here is for movility
    add(
      KeyboardListenerComponent(
        keyDown: {
          LogicalKeyboardKey.keyA: (keys) {
            leftPressed = true;
            return true;
          },
          LogicalKeyboardKey.keyD: (keys) {
            rightPressed = true;
            return true;
          },
          LogicalKeyboardKey.keyW: (keys) {
            upPressed = true;
            return true;
          },
          LogicalKeyboardKey.keyS: (keys) {
            downPressed = true;
            return true;
          },
        },
        keyUp: {
          LogicalKeyboardKey.keyA: (keys) {
            leftPressed = false;
            return true;
          },
          LogicalKeyboardKey.keyD: (keys) {
            rightPressed = false;
            return true;
          },
          LogicalKeyboardKey.keyW: (keys) {
            upPressed = false;
            return true;
          },
          LogicalKeyboardKey.keyS: (keys) {
            downPressed = false;
            return true;
          },
        },
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (leftPressed && position.x > width / 2) {
      position.x -= spriteVelocity * dt;
      FlameAudio.play('ball.wav');
    }
    if (rightPressed && position.x < game.size.x - width / 2) {
      position.x += spriteVelocity * dt;
      FlameAudio.play('ball.wav');
    }
    if (upPressed && position.y > height / 2) {
      position.y -= spriteVelocity * dt;
      FlameAudio.play('ball.wav');
    }
    if (downPressed && position.y < game.size.y - height / 2) {
      position.y += spriteVelocity * dt;
      FlameAudio.play('ball.wav');
    }
  }
}

class Square extends SpriteComponent
    with HasGameReference<GameTemplate>, CollisionCallbacks {
  double spriteVelocity = 100;
  double screenPosition = 0.0;
  bool isCollision = false;

  Square(Sprite sprite, {required Vector2 initialPosition}) {
    debugMode = false;
    this.sprite = sprite;
    size = Vector2(50.0, 50.0);
    position = initialPosition;
    add(RectangleHitbox());
    final Random random = Random();
    spriteVelocity = 50 + random.nextDouble() * 150; // Entre 50 y 200
  }


  
}

class Square extends SpriteComponent
    with HasGameReference<GameTemplate>, CollisionCallbacks {
  final Random random = Random();
  double spriteVelocity = 0;
  double screenPosition = 0.0;

  Square(Sprite sprite, {required Vector2 initialPosition}) {
    debugMode = false;
    this.sprite = sprite;
    size = Vector2(50.0, 50.0);
    position = initialPosition;
    spriteVelocity = 50 + random.nextDouble() * 150;
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    screenPosition = position.y + spriteVelocity * dt;
    if (screenPosition < game.size.y - height / 2) {
      position.y = screenPosition;
    } else {
      position = Vector2(random.nextDouble() * game.size.x, 0);
      spriteVelocity = 50 + random.nextDouble() * 150;
      game.totalAttempts--;
    }
  }
}

class HeaderTitle extends TextComponent {
  HeaderTitle()
      : super(
          text: "Super Square Attack",
          textRenderer: TextPaint(
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22.0,
            ),
          ),
          position: Vector2(100, 20),
        );
}

class GameOverScreen extends TextComponent with HasGameReference<GameTemplate> {
  GameOverScreen() {
    textRenderer = TextPaint(
      style: const TextStyle(color: Colors.white, fontSize: 20),
    );
    position = Vector2(game.size.x / 2, game.size.y / 2);
    anchor = Anchor.center;
  }

  @override
  void render(Canvas canvas) {
    final hits = (100 - game.shipPlayer.points) ~/ 20;
    final points = game.shipPlayer.points;
    final status = points > 80
        ? "Excelente"
        : points > 50
            ? "Bueno"
            : points > 20
                ? "Regular"
                : "Pobre";
    text = "Game Over\nHits: $hits\nPoints: $points\nStatus: $status";
    super.render(canvas);
  }
}
import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flame/anchor.dart';
import 'package:flame/components/animation_component.dart';
import 'package:flame/components/mixins/resizable.dart';
import 'package:flame/flame.dart';
import 'package:flame/game/base_game.dart';
import 'package:flutter/material.dart';
import 'package:flame/components/component.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flame/gestures.dart';
import 'game_over.dart';
import 'highscore.dart';
import 'mode.dart';
import 'score.dart';
import 'package:shared_preferences/shared_preferences.dart';

const gravity = 200.0;
const boost = -600.0;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final size = await Flame.util.initialDimensions();

  Flame.util.setOrientation(DeviceOrientation.landscapeLeft);

  SharedPreferences storage = await SharedPreferences.getInstance();
  final game = MyGame(size, storage);

  runApp(game.widget);
}

class Bg extends Component with Resizable {
  // ignore: non_constant_identifier_names
  static final Paint paint_l1 = Paint()..color = Color(0xFF55E6C1);
  // ignore: non_constant_identifier_names
  static final Paint paint_l2 = Paint()..color = Color(0xFF2C3A47);
  @override
  void render(Canvas c) {
    c.drawRect(Rect.fromLTWH(0.0, 0.0, size.width, size.height), paint_l2);
    c.drawRect(
        Rect.fromLTWH(0.0, 0.0, size.width, 2 * size.height / 3), paint_l1);
  }

  @override
  void update(double t) {}
}

class Player extends AnimationComponent with Resizable {
  double speedY = 0.0;
  bool frozen = true;
  var rectX, rectY;
  Player()
      : super.sequenced(150, 50, 'raceFuture.png', 1,
            textureWidth: 193, textureHeight: 57) {
    this.anchor = Anchor.center;
  }

  @override
  void resize(Size size) {
    super.resize(size);
    reset();
  }

  void reset() {
    this.x = 100.0;
    this.y = (2 * size.height / 3) - 25.0;
    this.speedY = 0.0;
    this.frozen = true;
  }

  void updt() {
    rectX = this.x - 75;
    rectY = this.y - 25;
  }

  @override
  void render(Canvas canvas) {
    Paint paint = Paint()..color = Color(0x00FFFFFF);
    updt();
    canvas.drawRect(Rect.fromLTWH(rectX, rectY, 150, 50), paint);
    super.render(canvas);
  }

  @override
  void update(double t) {
    super.update(t);

    if (!frozen && y > 175) {
      this.y -= speedY * t + gravity * t * t / 2;
      this.speedY += gravity;
    }
    if (this.y <= 175) {
      Timer(Duration(milliseconds: 450), () {
        reset();
      });
    }
    updt();
  }

  void onTap() {
    if (frozen) frozen = false;
    speedY = boost;
  }
}

class Enemy extends AnimationComponent with Resizable {
  Random rnd;
  var rectX, rectY;
  Enemy()
      : super.sequenced(30, 30, "enemy_blue.png", 1,
            textureHeight: 16, textureWidth: 22) {
    this.x = 700;
    this.y = 220;
    rnd = Random();
  }

  void reset() {
    this.x = 600 + rnd.nextDouble() * (size.width);
    this.y = (2 * size.height / 3) - 75.0 + rnd.nextDouble() * 30;
  }

  @override
  void resize(Size size) {
    super.resize(size);
  }

  void pos() {
    rectX = this.x;
    rectY = this.y;
  }

  @override
  void render(Canvas canvas) {
    Paint paint = Paint()..color = Color(0x00000000);
    pos();
    canvas.drawRect(Rect.fromLTWH(rectX, rectY, 30, 30), paint);
    super.render(canvas);
  }

  @override
  void update(double t) {
    super.update(t);

    this.x -= (400 + rnd.nextDouble() * 200) * t;

    if (x < -10) {
      reset();
    }
    pos();
  }
}

class MyGame extends BaseGame with TapDetector {
  SharedPreferences storage;
  Enemy emy = Enemy();
  ScoreText scoreText;
  int score;
  bool collied = false;
  Player ply = Player();
  GameOver gameOver;
  Mode mode;
  HighScoreText highScoreText;
  Size size;
  MyGame(Size size, storage) {
    this.size = size;
    this.storage = storage;

    initialize();
  }

  void initialize() {
    score = 0;
    mode = Mode.playing;
    add(Bg());
    add(ply);
    add(emy);
    emy.pos();
    ply.updt();
    //Flame.bgm.play('bg_music.wav');
    print(size.width);
    scoreText = ScoreText(this);
    highScoreText = HighScoreText(this);
    gameOver = GameOver(this);
  }

  void collision() {
    //AABB Algorthm implemented
    if (ply.rectX < emy.rectX + 30 &&
        ply.rectX + 150 > emy.rectX &&
        ply.rectY < emy.rectY + 30 &&
        ply.rectY + 50 > emy.rectY) {
      mode = Mode.game_over;
      collied = true;
      score = 0;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (mode == Mode.playing) {
      scoreText.render(canvas);
      highScoreText.render(canvas);
    } else if (mode == Mode.game_over) {
      gameOver.render(canvas);
    }
  }

  @override
  void update(double t) {
    if (mode == Mode.playing) {
      if (emy.x < 0) {
        score += 1;
        if (score > (storage.getInt('highscore') ?? 0)) {
          storage.setInt('highscore', score);
        }
      }
      collision();
      scoreText.update(t);
      highScoreText.update(t);
    }
    if (mode == Mode.game_over) {
      gameOver.update(t);
    }
    super.update(t);
  }

  @override
  void onTap() {
    ply.onTap();
  }
}

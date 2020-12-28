import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:train/main.dart';

class HighScoreText {
  MyGame game;
  TextPainter painter;
  Offset position;
  int highscore;
  HighScoreText(game) {
    this.game = game;
    painter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    position = Offset.zero;
  }

  void render(Canvas canvas) {
    painter.paint(canvas, position);
  }

  void update(double t) {
    //print("--getint" + game.storage.getInt(highscore.toString()).toString());
    highscore = game.storage.getInt(highscore.toString()) ?? 0;

    painter.text = TextSpan(
        text: "HighScore: $highscore",
        style: GoogleFonts.pressStart2p(
          textStyle: TextStyle(
            color: Colors.white,
            fontSize: 24.0,
          ),
        ));
    painter.layout();
    position = Offset(100, ((2 * game.size.height / 3) + 45));
  }
}

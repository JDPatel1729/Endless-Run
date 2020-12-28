import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:train/main.dart';

class ScoreText {
  final MyGame game;
  TextPainter painter;
  Offset position;

  ScoreText(this.game) {
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
    if ((painter.text ?? '') != game.score.toString()) {
      painter.text = TextSpan(
          text: "Score: " + game.score.toString(),
          style: GoogleFonts.pressStart2p(
            textStyle: TextStyle(
              color: Colors.white,
              fontSize: 24.0,
            ),
          ));
      painter.layout();

      position = Offset(game.size.width / 3, ((2 * game.size.height / 3) + 45));
    }
  }
}

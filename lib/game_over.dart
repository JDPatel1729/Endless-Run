import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:train/main.dart';

class GameOver {
  MyGame game;
  TextPainter painter;
  Offset position;

  GameOver(MyGame game) {
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
    painter.text = TextSpan(
        text: "Game\nOver",
        style: GoogleFonts.pressStart2p(
          textStyle: TextStyle(
            color: Colors.white,
            fontSize: 70.0,
          ),
        ));
    painter.layout();

    position = Offset(game.size.width / 2, game.size.height / 2);
  }
}

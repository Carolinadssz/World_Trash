import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:worldtrash/game/my_game.dart';
import 'package:worldtrash/ui/game_hud.dart';
import 'package:worldtrash/ui/main_menu.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(const MyGameApp());
}

class MyGameApp extends StatelessWidget {
  const MyGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Trash World',

      home: GameWidget<MyGame>.controlled(
        gameFactory: MyGame.new,
        overlayBuilderMap: {
          'MainMenu': (context, game) => MainMenu(game: game),

          'GameHud': (context, game) => GameHud(game: game),
        },
        initialActiveOverlays: const ['MainMenu'],
      ),
    );
  }
}
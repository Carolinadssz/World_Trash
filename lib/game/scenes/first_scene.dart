import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/parallax.dart';
import 'package:worldtrash/game/enemies/lixoso_spawner_first.dart';
import 'package:worldtrash/game/player/playerMain.dart';
import 'package:flame/experimental.dart';
import 'package:flutter/painting.dart';


class FirstScene extends Component with HasGameRef<FlameGame> {
  late PlayerMain player;
  late double levelWidth;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    levelWidth = gameRef.size.x * 3;

    final background = await gameRef.loadParallaxComponent(
      [
        ParallaxImageData('background_first.png'),
      ],

      baseVelocity: Vector2(0, 0),


      velocityMultiplierDelta: Vector2(1.0, 0),

      repeat: ImageRepeat.repeat,
      fill: LayerFill.height,
    );
    add(background);

    player = PlayerMain();
    player.position = Vector2(400, gameRef.size.y - 15);
    add(player);
    gameRef.camera.follow(player);
    gameRef.camera.setBounds(
      Rectangle.fromLTRB(0, 0, levelWidth, gameRef.size.y),
    );

    add(LixosoSpawnerFirst());
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (player.position.x > levelWidth - 150) {

    }
  }
}
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/parallax.dart';
import 'package:flame/experimental.dart'; // IMPORTANTE: Traz o 'Rectangle'
import 'package:flutter/painting.dart';   // IMPORTANTE: Traz o 'ImageRepeat'
import 'package:worldtrash/game/enemies/lixoso_spawner_final.dart';
import 'package:worldtrash/game/enemies/lixoso_spawner_second.dart';
import 'package:worldtrash/game/player/playerMain.dart';
// import 'package:worldtrash/game/enemies/lixoso_spawner_second.dart'; // Futuro Spawner

class FinalScene extends Component with HasGameRef<FlameGame> {
  late PlayerMain player;
  late double levelWidth;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Define a largura da fase 2 (3 telas de largura, igual a fase 1)
    levelWidth = gameRef.size.x * 3;

    // 1. BACKGROUND (Parallax)
    final background = await gameRef.loadParallaxComponent(
      [
        ParallaxImageData('background_beach.png'), // TODO: Trocar para background_second.png
      ],
      baseVelocity: Vector2(0, 0),
      velocityMultiplierDelta: Vector2(1.0, 0),
      repeat: ImageRepeat.repeat,
      fill: LayerFill.height,
    );
    add(background);

    // 2. PLAYER
    player = PlayerMain();
    player.position = Vector2(100, gameRef.size.y - 30);
    add(player);

    // 3. CÂMERA (Seguir Player e Limites)
    gameRef.camera.follow(player);

    gameRef.camera.setBounds(
      Rectangle.fromLTRB(0, 0, levelWidth, gameRef.size.y),
    );

    // 4. INIMIGOS
    add(LixosoSpawnerFinal());

    print("Fase final Carregada com Sucesso!");
  }

  @override
  void update(double dt) {
    super.update(dt);
  }
}
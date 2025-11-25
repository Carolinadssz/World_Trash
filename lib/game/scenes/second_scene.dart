import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/parallax.dart';
import 'package:flame/experimental.dart';
import 'package:flutter/painting.dart';
import 'package:worldtrash/game/enemies/lixoso_spawner_second.dart';
import 'package:worldtrash/game/player/playerMain.dart';

class SecondScene extends Component with HasGameRef<FlameGame> {
  late PlayerMain player;
  late double levelWidth;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    levelWidth = gameRef.size.x * 3;

    final background = await gameRef.loadParallaxComponent(
      [
        ParallaxImageData('background_second.png'), // TODO: Trocar para background_second.png
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

    // 3. CÂMERA
    gameRef.camera.follow(player);

    // Define o limite da câmera para não mostrar o "preto" além da fase
    gameRef.camera.setBounds(
      Rectangle.fromLTRB(0, 0, levelWidth, gameRef.size.y),
    );

    // 4. INIMIGOS
    add(LixosoSpawnerSecond());

    print("Fase 2 Carregada com Sucesso!");
  }

  @override
  void update(double dt) {
    super.update(dt);
  }
}
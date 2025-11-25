import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';
import 'package:worldtrash/game/enemies/lixosoMain.dart';
import 'package:worldtrash/game/my_game.dart';

class LixosoSpawnerFinal extends Component with HasGameRef<MyGame> {
  int roundsSpawned = 0;
  final int maxRounds = 3; // Total de rounds

  // Um pequeno delay entre matar o último inimigo e nascer a próxima onda
  double waveCooldown = 2.0;
  bool waitingForNextWave = false;

  bool isLevelFinished = false;

  @override
  void update(double dt) {
    super.update(dt);

    if (isLevelFinished) return;

    // Verifica quantos inimigos estão vivos AGORA
    final lixososVivos = parent?.children.whereType<Lixoso>().toList() ?? [];

    // Se não tem inimigos vivos, precisamos decidir o que fazer
    if (lixososVivos.isEmpty) {

      if (roundsSpawned < maxRounds) {

        // Lógica de delay (Cooldown)
        if (!waitingForNextWave) {
          waitingForNextWave = true;
          waveCooldown = 2.0; // Reseta o tempo de espera (ex: 2 segundos)
        } else {
          waveCooldown -= dt;
          // Se o tempo de espera acabou, SPAWNA!
          if (waveCooldown <= 0) {
            _spawnRoundDe3();
            roundsSpawned++;
            waitingForNextWave = false; // Para de esperar
          }
        }

        // CASO 2: Já spawnamos todos os rounds e todos morreram? VITÓRIA!
      } else {
        _winLevel();
      }
    }
  }

  void _spawnRoundDe3() {
    print("Iniciando Round ${roundsSpawned + 1} de $maxRounds");

    double groundY = gameRef.size.y - -20;

    // --- 1. INIMIGO DA DIREITA ---
    final inimigoDir = Lixoso(
      position: Vector2(gameRef.size.x - 100, groundY),
      behavior: LixosoBehavior.patroller,
    );
    inimigoDir.direction = -1; // Anda p/ Esquerda
    inimigoDir.flipHorizontallyAroundCenter();
    parent?.add(inimigoDir);

    // --- 2. INIMIGO DA ESQUERDA ---
    final inimigoEsq = Lixoso(
      position: Vector2(100, groundY),
      behavior: LixosoBehavior.patroller,
    );
    inimigoEsq.direction = 1; // Anda p/ Direita
    parent?.add(inimigoEsq);

    // --- 3. INIMIGO DO MEIO ---
    final inimigoMeio = Lixoso(
      position: Vector2(gameRef.size.x / 2, groundY),
      behavior: LixosoBehavior.patroller,
    );

    inimigoMeio.direction = -1;
    inimigoMeio.flipHorizontallyAroundCenter();
    parent?.add(inimigoMeio);
  }

  void _winLevel() {
    isLevelFinished = true;
    print("TODOS OS ROUNDS FINALIZADOS!");

    final textPaint = TextPaint(
      style: const TextStyle(
        fontSize: 48.0,
        fontWeight: FontWeight.bold,
        color: Colors.greenAccent,
        shadows: [
          Shadow(blurRadius: 10, color: Colors.black, offset: Offset(3, 3)),
        ],
      ),
    );

    gameRef.add(
      TextComponent(
        text: 'JOGO COMPLETO!',
        textRenderer: textPaint,
        anchor: Anchor.center,
        position: gameRef.size / 2,
        priority: 100,
      ),
    );

    Future.delayed(const Duration(seconds: 3), () {
      _goToMainMenu();
    });
  }

  void _goToMainMenu() {
    bool overlayAdded = gameRef.overlays.add('MainMenu');

    gameRef.children.whereType<TextComponent>().forEach((t) => t.removeFromParent());

    parent?.removeFromParent();
  }
}
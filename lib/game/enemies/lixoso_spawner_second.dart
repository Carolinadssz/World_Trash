import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';
import 'package:worldtrash/game/enemies/lixosoMain.dart';
import 'package:worldtrash/game/my_game.dart';
import 'package:worldtrash/game/scenes/final_scene.dart';

class LixosoSpawnerSecond extends Component with HasGameRef<MyGame> {
  double timer = 0.0;
  int roundsSpawned = 0;
  double penaltyTimer = 0.0;

  // Controles para saber se já spawnamos para não repetir
  bool spawn1 = false;
  bool spawn2 = false;
  bool spawn3 = false;
  bool spawn4 = false;
  bool spawn5 = false;

  bool isLevelFinished = false;

  @override
  void update(double dt) {
    super.update(dt);

    if (isLevelFinished) return;

    timer += dt;

    if (timer >= 0 && roundsSpawned == 0) {
      _spawnLixoso();
      roundsSpawned++;
    }

    if (timer >= 15.0 && roundsSpawned == 1) {
      _spawnLixoso();
      roundsSpawned++;
    }

    if (timer >= 30.0 && roundsSpawned == 2) {
      _spawnLixoso();
      roundsSpawned++;
    }

    if (timer >= 45.0 && roundsSpawned == 3) {
      _spawnLixoso();
      roundsSpawned++;

      penaltyTimer = 0;
    }

    if (roundsSpawned >= 4) {
      penaltyTimer += dt;

      if (penaltyTimer >= 15.0) {
        _spawnLixoso(); // SPAWN EXTRA (Punição)
        penaltyTimer = 0; // Reinicia a contagem de 15s
      }
    }

    // --- VERIFICAÇÃO DE VITÓRIA ---
    if (roundsSpawned >= 4) {
      final lixosos = parent?.children.whereType<Lixoso>().toList() ?? [];

      if (lixosos.isEmpty) {
        _winLevel();
      }
    }
  }

  void _spawnLixoso() {
    // Posição Y do chão (comum para os dois)
    double groundY = gameRef.size.y - -20;

    // --- INIMIGO 1: VEM DA DIREITA (Lado original) ---
    double spawnXRight = gameRef.size.x - 100;
    final inimigoDireita = Lixoso(
      position: Vector2(spawnXRight, groundY),
      behavior: LixosoBehavior.patroller,
    );

    inimigoDireita.direction = -1;
    inimigoDireita.flipHorizontallyAroundCenter();
    parent?.add(inimigoDireita);


    // --- INIMIGO 2: VEM DA ESQUERDA (Novo) ---
    double spawnXLeft = 100;

    final inimigoEsquerda = Lixoso(
      position: Vector2(spawnXLeft, groundY),
      behavior: LixosoBehavior.patroller,
    );

    inimigoEsquerda.direction = 1; // Anda para a direita
    parent?.add(inimigoEsquerda);
  }

  void _winLevel() {
    // ATIVA A TRAVA: Isso garante que este código só rode UMA VEZ
    isLevelFinished = true;

    print("FASE CONCLUÍDA!");

    // 1. Mensagem de Sucesso
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
        text: 'SUCESSO!\nÁrea Limpa',
        textRenderer: textPaint,
        anchor: Anchor.center,
        position: gameRef.size / 2, // Meio da tela
        priority: 100, // Garante que fique na frente
      ),
    );

    // 2. Redirecionamento após 3 segundos
    Future.delayed(const Duration(seconds: 3), () {
      _goToNextLevel();
    });
  }

  void _goToNextLevel() {

    parent?.removeFromParent();
    gameRef.children.whereType<TextComponent>().forEach((t) => t.removeFromParent());
    gameRef.add(FinalScene());
  }
}
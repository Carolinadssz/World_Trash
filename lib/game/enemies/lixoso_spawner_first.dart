import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';
import 'package:worldtrash/game/enemies/lixosoMain.dart';
import 'package:worldtrash/game/my_game.dart';

import '../scenes/second_scene.dart';

class LixosoSpawnerFirst extends Component with HasGameRef<MyGame> {
  double timer = 0.0;

  // Controles para saber se já spawnamos para não repetir
  bool spawn1 = false;
  bool spawn2 = false;
  bool spawn3 = false;
  bool spawn4 = false;
  bool spawn5 = false;

  // TRAVA DE SEGURANÇA: Impede que a vitória rode mais de uma vez
  bool isLevelFinished = false;

  @override
  void update(double dt) {
    super.update(dt);

    // Se a fase já acabou, paramos tudo aqui para não repetir mensagem
    if (isLevelFinished) return;

    // Aumenta o tempo
    timer += dt;

    // --- ONDA 1: Tempo 0 (Imediato) ---
    if (!spawn1) {
      _spawnLixoso();
      spawn1 = true;
    }

    // --- ONDA 2: Intervalos de 5 segundos ---
    if (timer >= 5.0 && !spawn2) {
      _spawnLixoso();
      spawn2 = true;
    }
    if (timer >= 10.0 && !spawn3) {
      _spawnLixoso();
      spawn3 = true;
    }
    if (timer >= 15.0 && !spawn4) {
      _spawnLixoso();
      spawn4 = true;
    }

    // --- ONDA 3: Tempo 20 segundos ---
    if (timer >= 20.0 && !spawn5) {
      _spawnLixoso();
      spawn5 = true;
    }

    // --- VERIFICAÇÃO DE VITÓRIA ---
    // Só verificamos se o ÚLTIMO inimigo já nasceu (spawn5 == true)
    if (spawn5) {
      // Procura se ainda tem algum Lixoso no jogo (na mesma camada pai)
      final lixosos = parent?.children.whereType<Lixoso>().toList() ?? [];

      // Se a lista estiver vazia, significa que o player matou e COLETOU todos
      if (lixosos.isEmpty) {
        _winLevel();
      }
    }
  }

  void _spawnLixoso() {
    double groundY = gameRef.size.y - -30;

    double spawnX = gameRef.size.x - 100;

    final inimigo = Lixoso(
      position: Vector2(spawnX, groundY),
      behavior: LixosoBehavior.patroller, // Ou 'chaser' se quiser que persiga
    );

    // Força ele a começar andando para a esquerda
    inimigo.direction = -1;
    inimigo.flipHorizontallyAroundCenter(); // Vira o sprite para a esquerda

    // Adiciona o inimigo na cena (parent do spawner)
    parent?.add(inimigo);
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
        position: gameRef.size / 2,
        priority: 100,
      ),
    );

    Future.delayed(const Duration(seconds: 3), () {
      _goToNextLevel();
    });
  }

  void _goToNextLevel() {
    parent?.removeFromParent();
    gameRef.children.whereType<TextComponent>().forEach((t) => t.removeFromParent());
    gameRef.add(SecondScene());
  }
}
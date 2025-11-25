import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:worldtrash/game/my_game.dart'; // <--- 1. Importe o MyGame
import 'package:worldtrash/game/player/playerMain.dart';

// 2. Adicione HasGameRef<MyGame> para acessar o virtualJump
class PlayerJump extends Component with KeyboardHandler, HasGameRef<MyGame> {
  double vSpeed = 0;
  final double gravity = 1000.0;
  final double jumpForce = -700.0;
  double? groundY;

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keys) {
    return true;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (parent is! PlayerMain) return;
    final p = parent as PlayerMain;

    groundY ??= p.position.y;

    // --- 3. Lógica de Input Unificada (Teclado + HUD) ---

    // Verifica teclas físicas
    final keysPressed = HardwareKeyboard.instance.logicalKeysPressed;
    final isKeyboardJump = keysPressed.contains(LogicalKeyboardKey.space) ||
        keysPressed.contains(LogicalKeyboardKey.arrowUp);

    // O pulo acontece se: (Teclado OU Botão Virtual) E (Estiver no chão)
    final wantToJump = isKeyboardJump || gameRef.virtualJump;

    if (wantToJump && p.position.y >= groundY!) {
      vSpeed = jumpForce;
    }
    // ----------------------------------------------------

    // Física
    vSpeed += gravity * dt;
    p.position.y += vSpeed * dt;

    // --- Lógica de Colisão com o Chão ---
    if (p.position.y >= groundY!) {
      p.position.y = groundY!;
      vSpeed = 0;

      // Destrava a animação quando toca o chão
      if (p.current == PlayerState.jump) {
        p.current = PlayerState.idle;
      }

    } else if (p.position.y < groundY! - 5) {
      // Se está no ar (acima de 5px), força animação de pulo
      p.current = PlayerState.jump;
    }
  }
}
import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:worldtrash/game/my_game.dart'; // <--- 1. Importe o MyGame
import 'playerMain.dart';

// 2. Mude para HasGameRef<MyGame> para acessar as variáveis virtuais
class PlayerMovement extends Component with KeyboardHandler, HasGameRef<MyGame> {
  final double speed = 150.0;
  int _horizontalDirection = 0;

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keys) {
    return true;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (parent is! PlayerMain) return;

    final player = parent as PlayerMain;
    final screenWidth = gameRef.size.x;

    _horizontalDirection = 0;

    // Verifica quais teclas estão apertadas agora
    final keysPressed = HardwareKeyboard.instance.logicalKeysPressed;

    // ESQUERDA: Teclado (Seta ou A) OU Botão Virtual
    final moveLeft = keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
        keysPressed.contains(LogicalKeyboardKey.keyA) ||
        gameRef.virtualLeft;

    // DIREITA: Teclado (Seta ou D) OU Botão Virtual
    final moveRight = keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
        keysPressed.contains(LogicalKeyboardKey.keyD) ||
        gameRef.virtualRight;

    if (moveLeft) _horizontalDirection -= 1;
    if (moveRight) _horizontalDirection += 1;

    // Movimenta e mantém dentro dos limites (15% a 85% da tela)
    player.position.x = (player.position.x + _horizontalDirection * speed * dt)
        .clamp(screenWidth * 0.15, screenWidth * 0.85);

    // Só altera animação de andar/parar se NÃO estiver pulando
    if (player.current != PlayerState.jump) {
      player.current = _horizontalDirection != 0 ? PlayerState.run : PlayerState.idle;
    }

    // Vira o personagem (Flip) baseado na direção
    if ((_horizontalDirection < 0 && player.scale.x > 0) ||
        (_horizontalDirection > 0 && player.scale.x < 0)) {
      player.flipHorizontallyAroundCenter();
    }
  }
}
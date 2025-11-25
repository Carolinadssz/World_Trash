import 'package:flutter/material.dart';
import 'package:worldtrash/game/my_game.dart';

class GameHud extends StatelessWidget {
  final MyGame game;

  const GameHud({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // --- LADO ESQUERDO (Movimento)
          Positioned(
            bottom: 30,
            left: 30,
            child: Row(
              children: [
                // Botão Esquerda
                ControlButton(
                  icon: Icons.arrow_back,
                  onDown: () => game.virtualLeft = true,
                  onUp: () => game.virtualLeft = false,
                ),
                const SizedBox(width: 48),
                // Botão Direita
                ControlButton(
                  icon: Icons.arrow_forward,
                  onDown: () => game.virtualRight = true,
                  onUp: () => game.virtualRight = false,
                ),
              ],
            ),
          ),

          // --- LADO DIREITO (Ações) ---
          Positioned(
            bottom: 30,
            right: 30,
            child: Row(
              children: [
                // Botão Ataque
                ControlButton(
                  icon: Icons.shower_outlined,
                  color: Colors.redAccent,
                  onDown: () => game.virtualAttack = true,
                  onUp: () => game.virtualAttack = false,
                ),
                const SizedBox(width: 10),
                // Botão Pulo
                ControlButton(
                  icon: Icons.arrow_upward,
                  onDown: () => game.virtualJump = true,
                  onUp: () => game.virtualJump = false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Um Widget customizado para evitar repetição de código
class ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onDown;
  final VoidCallback onUp;
  final Color color;

  const ControlButton({
    super.key,
    required this.icon,
    required this.onDown,
    required this.onUp,
    this.color = Colors.white54, // Branco meio transparente
  });

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => onDown(),
      onPointerUp: (_) => onUp(),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black45, // Fundo escuro transparente
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white30, width: 2),
        ),
        child: Icon(
          icon,
          size: 36,
          color: color,
        ),
      ),
    );
  }
}
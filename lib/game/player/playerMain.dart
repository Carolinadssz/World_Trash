import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/collisions.dart'; // Necessário para colisão
import 'package:flutter/material.dart'; // Necessário para Cores
import 'package:flutter/scheduler.dart';
import 'package:worldtrash/game/my_game.dart';
import 'package:worldtrash/game/player/playerCombat.dart';
import 'package:worldtrash/game/player/playerJump.dart';
import 'package:worldtrash/game/player/playerMovement.dart';
// IMPORTANTE: Ajuste este import para onde seu arquivo Lixoso.dart está
import 'package:worldtrash/game/enemies/lixosoMain.dart';

enum PlayerState { idle, run, jump, hit }

class PlayerMain extends SpriteAnimationGroupComponent<PlayerState>
    with HasGameRef<MyGame>, CollisionCallbacks {

  final double characterSize = 200.0;

  // --- Configurações de Vida ---
  final double maxHealth = 500.0;
  // CORREÇÃO 1: Inicializa direto para evitar erro de "Null check operator used on a null value"
  double currentHealth = 500.0;

  // --- Configurações de Dano e Invencibilidade ---
  bool isInvincible = false;

  // CORREÇÃO 2 (Trava de Morte): Impede que o jogo tente matar o player 60 vezes por segundo
  bool isDead = false;

  double damageTimer = 0.0;
  final double invincibilityDuration = 1.5;

  PlayerMain() : super(
      size: Vector2.all(200.0),
      anchor: Anchor.bottomCenter
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // --- IDLE ---
    final idleImages = await Future.wait([
      Flame.images.load('idle_01.png'),
      Flame.images.load('idle_02.png'),
      Flame.images.load('idle_03.png'),
      Flame.images.load('idle_04.png'),
      Flame.images.load('idle_05.png'),
    ]);
    final idleAnimation = SpriteAnimation.spriteList(
      idleImages.map((img) => Sprite(img)).toList(),
      stepTime: 0.25,
      loop: true,
    );

    // --- RUN ---
    final runImages = await Future.wait([
      Flame.images.load('walk_01.png'),
      Flame.images.load('walk_02.png'),
      Flame.images.load('walk_03.png'),
    ]);
    final runAnimation = SpriteAnimation.spriteList(
      runImages.map((img) => Sprite(img)).toList(),
      stepTime: 0.15,
      loop: true,
    );

    // --- JUMP ---
    final jumpSprite = await Flame.images.load('jump_02.png');
    final jumpAnimation = SpriteAnimation.spriteList(
      [Sprite(jumpSprite)],
      stepTime: 1.0,
      loop: true,
    );

    // --- HIT (Opcional) ---
    final hitAnimation = idleAnimation;

    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.run: runAnimation,
      PlayerState.jump: jumpAnimation,
      PlayerState.hit: hitAnimation,
    };

    current = PlayerState.idle;

    // --- COMPONENTES LÓGICOS ---
    add(PlayerMovement());
    add(PlayerJump());
    add(PlayerCombat());

    // --- HITBOX ---
    add(RectangleHitbox(
      position: Vector2(70, 20),
      size: Vector2(60, 140),
    ));


    // --- BARRA DE VIDA ---
    add(PlayerHealthBar(
      maxHealth: maxHealth,
      getCurrentHealth: () => currentHealth,
      position: Vector2(size.x / 2, -20),
      size: Vector2(100, 12),
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isInvincible) {
      damageTimer += dt;
      opacity = (damageTimer * 10).toInt() % 2 == 0 ? 0.2 : 1.0;

      if (damageTimer >= invincibilityDuration) {
        isInvincible = false;
        damageTimer = 0.0;
        opacity = 1.0;
      }
    }
  }

  // --- CORREÇÃO 3: LÓGICA DE COLETA NO ONCOLLISION ---
  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    if (other is Lixoso) {
      if (other.isDead) {
        other.collect();

      }
      // CENÁRIO 2: O inimigo está vivo -> O player TOMA DANO
      else if (!isInvincible) {
        takeDamage(100);
      }
    }
  }

  void takeDamage(double amount) {
    // Se já estiver morto, não faz nada
    if (isDead) return;
    if (currentHealth <= 0) return;

    currentHealth -= amount;
    isInvincible = true;

    // Efeito de Knockback (Empurrão)
    if (scale.x > 0) position.x -= 50;
    else position.x += 50;

    if (currentHealth <= 0) {
      die();
    }
  }

  void die() {
    // TRAVA DE SEGURANÇA: Se já morreu, sai da função imediatamente.
    // Isso evita o bug de criar clones infinitos.
    if (isDead) return;

    isDead = true;
      currentHealth = maxHealth;
      position = Vector2(100, 0);
      isInvincible = false;
      opacity = 1.0;
      isDead = false;
  }
}

// --- CLASSE DA BARRA DE VIDA DO PLAYER ---
class PlayerHealthBar extends PositionComponent {
  final double maxHealth;
  final double Function() getCurrentHealth;

  PlayerHealthBar({
    required this.maxHealth,
    required this.getCurrentHealth,
    required super.position,
    required super.size,
  }) : super(anchor: Anchor.center);

  final _bgPaint = Paint()..color = Colors.black.withOpacity(0.7);
  final _borderPaint = Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2;
  final _healthPaint = Paint()..color = Colors.green;

  @override
  void render(Canvas canvas) {
    canvas.drawRect(size.toRect(), _bgPaint);
    canvas.drawRect(size.toRect(), _borderPaint);

    final healthPercentage = (getCurrentHealth() / maxHealth).clamp(0.0, 1.0);

    if (healthPercentage < 0.3) {
      _healthPaint.color = Colors.red;
    } else {
      _healthPaint.color = Colors.green;
    }

    canvas.drawRect(
      Rect.fromLTWH(2, 2, (size.x - 4) * healthPercentage, size.y - 4),
      _healthPaint,
    );
  }
}
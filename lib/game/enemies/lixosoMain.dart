import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:worldtrash/game/my_game.dart';
import 'package:worldtrash/game/player/playerMain.dart';

enum LixosoState { walk, dead, damage }
enum LixosoBehavior { patroller, chaser }

class Lixoso extends SpriteAnimationGroupComponent<LixosoState>
    with HasGameRef<MyGame>, CollisionCallbacks {

  final double speed = 80.0;
  final double maxHealth = 100.0;
  double currentHealth = 100.0;
  final LixosoBehavior behavior;

  bool isDead = false;
  double deadTimer = 0.0;
  final double timeToRevive = 10.0;

  bool isTakingDamage = false;
  double damageTimer = 0.0;
  final double damageDuration = 0.5;

  int direction = 1;

  Lixoso({
    required Vector2 position,
    this.behavior = LixosoBehavior.patroller,
  }) : super(
    position: position,
    size: Vector2.all(245.0),
    anchor: Anchor.bottomCenter,
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final walkImages = await Future.wait([
      Flame.images.load('lixosoWalk_01.png'),
      Flame.images.load('lixosoWalk_02.png'),
    ]);
    final walkAnim = SpriteAnimation.spriteList(
      walkImages.map((img) => Sprite(img)).toList(),
      stepTime: 0.2,
      loop: true,
    );

    final deadSprite = await Flame.images.load('lixosoDeath_01.png');
    final deadAnim = SpriteAnimation.spriteList(
      [Sprite(deadSprite)],
      stepTime: 1.0,
      loop: true,
    );


    final damageSprite = await Flame.images.load('lixosoDammage_01.png');
    final damageAnim = SpriteAnimation.spriteList(
      [Sprite(damageSprite)],
      stepTime: damageDuration,
      loop: false,
    );

    animations = {
      LixosoState.walk: walkAnim,
      LixosoState.dead: deadAnim,
      LixosoState.damage: damageAnim,
    };

    current = LixosoState.walk;

    // --- HITBOX DO INIMIGO ---
    add(RectangleHitbox(
      size: Vector2(50, 50),
      position: Vector2(95, 100),
    ));

    // Barra de Vida
    final barWidth = size.x * 0.4;
    final barHeight = 8.0;
    final barPosition = Vector2(size.x / 2, 70);

    add(HealthBar(
      maxHealth: maxHealth,
      getCurrentHealth: () => currentHealth,
      position: barPosition,
      size: Vector2(barWidth, barHeight),
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isDead) {
      deadTimer += dt;
      if (deadTimer >= timeToRevive) revive();
      return;
    }

    if (isTakingDamage) {
      damageTimer += dt;
      if (damageTimer >= damageDuration) {
        isTakingDamage = false;
        current = LixosoState.walk;
      }
    }

    if (behavior == LixosoBehavior.patroller) {
      _updatePatrol(dt);
    } else if (behavior == LixosoBehavior.chaser) {
      _updateChase(dt);
    }
  }

  // --- DETECÇÃO DE COLISÃO ---
  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    // Se o inimigo estiver morto, ele ignora colisões de ataque.
    if (isDead) return;

    // Se estiver vivo e tocar no player, causa dano
    if (other is PlayerMain) {
      other.takeDamage(100);
    }
  }

  void _updatePatrol(double dt) {
    _move(direction.toDouble(), dt);
    double screenWidth = gameRef.size.x;
    double halfWidth = size.x / 2;

    if (position.x - halfWidth <= 0) {
      direction = 1;
    }
    else if (position.x + halfWidth >= screenWidth) {
      direction = -1;
    }
  }

  void _updateChase(double dt) {
    final player = gameRef.children.query<PlayerMain>().firstOrNull;
    if (player != null) {
      if (player.currentHealth > 0) {
        double dir = player.position.x < position.x ? -1 : 1;
        _move(dir, dt);
      }
    }
  }

  void _move(double dir, double dt) {
    position.x += dir * speed * dt;
    if (dir < 0 && scale.x > 0) flipHorizontallyAroundCenter();
    if (dir > 0 && scale.x < 0) flipHorizontallyAroundCenter();
  }

  void takeDamage(double damage) {
    if (isDead) return;
    currentHealth -= damage;
    if (currentHealth <= 0) {
      die();
    } else {
      isTakingDamage = true;
      damageTimer = 0.0;
      current = LixosoState.damage;
      animationTicker?.reset();
    }
  }

  void die() {
    isDead = true;
    currentHealth = 0;
    deadTimer = 0.0;
    isTakingDamage = false;
    current = LixosoState.dead;
  }

  void revive() {
    isDead = false;
    currentHealth = maxHealth;
    current = LixosoState.walk;
  }
  void collect() {
    if (isDead) {
      removeFromParent();
      print("LIXO RECICLADO COM SUCESSO!");
    }
  }
}

class HealthBar extends PositionComponent {
  final double maxHealth;
  final double Function() getCurrentHealth;

  HealthBar({
    required this.maxHealth,
    required this.getCurrentHealth,
    required super.position,
    required super.size,
  }) : super(anchor: Anchor.center);

  final _bgPaint = Paint()..color = Colors.red.withOpacity(0.8);
  final _fgPaint = Paint()..color = Colors.green;

  @override
  void render(Canvas canvas) {
    canvas.drawRect(size.toRect(), _bgPaint);
    final healthPercentage = (getCurrentHealth() / maxHealth).clamp(0.0, 1.0);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x * healthPercentage, size.y),
      _fgPaint,
    );
  }
}
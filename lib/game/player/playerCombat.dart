import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/flame.dart';
import 'package:flutter/services.dart';
import 'package:worldtrash/game/my_game.dart';
import 'package:worldtrash/game/enemies/lixosoMain.dart';
import 'package:worldtrash/game/player/playerMain.dart';

// --- 1. COMPONENTE CONTROLADOR (Lógica de Input e Cooldown) ---
class PlayerCombat extends Component with HasGameRef<MyGame> {
  double attackCooldownTimer = 0.0;
  final double attackCooldown = 2.0;
  bool canShoot = true;

  @override
  void update(double dt) {
    super.update(dt);
    // Garante que o pai é o PlayerMain para pegar a direção (scale.x)
    if (parent is! PlayerMain) return;
    final p = parent as PlayerMain;

    // --- Lógica do Cooldown ---
    if (!canShoot) {
      attackCooldownTimer += dt;
      if (attackCooldownTimer >= attackCooldown) {
        canShoot = true;
        attackCooldownTimer = 0.0;
      }
    }

    // --- Lógica de Input Unificada (Igual ao PlayerJump) ---
    final keysPressed = HardwareKeyboard.instance.logicalKeysPressed;

    // Verifica se apertou ENTER no teclado
    final isKeyboardAttack = keysPressed.contains(LogicalKeyboardKey.enter);

    // O ataque acontece se: (Teclado OU Botão Virtual HUD) E (Pode Atirar)
    final wantToAttack = isKeyboardAttack || gameRef.virtualAttack;

    if (wantToAttack && canShoot) {
      shoot(p);
    }
  }

  void shoot(PlayerMain p) {
    canShoot = false; // Inicia o cooldown

    // Direção baseada no scale.x do PlayerMain
    double dir = p.scale.x > 0 ? 1 : -1;

    // Posição de saída: Um pouco à frente do player e na altura do peito (-100 no Y)
    Vector2 spawnPos = p.position.clone()..add(Vector2(dir * 20, -100));

    // IMPORTANTE: Adiciona o poder no MUNDO (gameRef), não dentro do player
    gameRef.add(AirHadouken(
      position: spawnPos,
      direction: dir,
    ));
  }
}

// --- 2. COMPONENTE VISUAL (O Projetil) ---
class AirHadouken extends SpriteAnimationComponent
    with HasGameRef<MyGame>, CollisionCallbacks {

  final double direction;
  final double speed = 400.0;
  final double damage = 50.0;
  final double maxDistance = 600.0;
  double distanceTraveled = 0.0;

  AirHadouken({
    required Vector2 position,
    required this.direction,
  }) : super(
    position: position,
    size: Vector2(64, 64), // Tamanho do poder
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Tenta carregar a imagem do poder
    try {
      final images = await Future.wait([
        Flame.images.load('air_power.png'),
      ]);
      animation = SpriteAnimation.spriteList(
        images.map((img) => Sprite(img)).toList(),
        stepTime: 0.1,
        loop: true,
      );
    } catch (e) {
      print("Imagem air_power.png não encontrada. Usando placeholder.");
    }

    // Adiciona Hitbox ao poder para colidir com o Lixoso
    add(RectangleHitbox(isSolid: true));

    // Vira o sprite se estiver indo para a esquerda
    if (direction < 0) {
      flipHorizontallyAroundCenter();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Move o poder
    position.x += speed * direction * dt;
    distanceTraveled += speed * dt;

    // Remove se for muito longe
    if (distanceTraveled >= maxDistance) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    // Se bater no Lixoso
    if (other is Lixoso) {
      other.takeDamage(damage);
      removeFromParent();
    }
  }
}
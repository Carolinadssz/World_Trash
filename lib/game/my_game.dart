import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:worldtrash/game/scenes/first_scene.dart';


class MyGame extends FlameGame with HasKeyboardHandlerComponents, HasCollisionDetection{
  bool virtualLeft = false;
  bool virtualRight = false;
  bool virtualJump = false;
  bool virtualAttack = false;

  @override
  Future<void> onLoad() async{
    pauseEngine();
    overlays.add("MainMenu");
  }

  void startGame(){
    overlays.remove("MainMenu");

    overlays.add('GameHud');

    add(FirstScene());

    resumeEngine();
  }

  @override
  void onDetach(){
    pauseEngine();
    super.onDetach();
  }
}
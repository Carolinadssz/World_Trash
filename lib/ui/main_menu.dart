import 'package:flutter/material.dart';
import 'package:worldtrash/game/my_game.dart';

class MainMenu extends StatelessWidget {
  final MyGame game;

  const MainMenu({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        image: DecorationImage(
          image: AssetImage("assets/visual_identity/background_image.png"),
          fit: BoxFit.cover,
        ),
      ),

      child: Center(
        child: Column(
          spacing: 48,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Image(
              image: AssetImage("assets/visual_identity/worldTrash_logo.png"),
            ),
            SizedBox(
              width: 250,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  game.startGame();
                },
                child: Text("Iniciar Jogo", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  side: const BorderSide(
                    color: Color(0xffFFBD97),
                    width: 6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(0),
                  ),
                  backgroundColor: Color(0xff1E1E1E),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            SizedBox(
              width: size.width,
              height: 56,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 48.0,
                  vertical: 0.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "RA - R572BI9",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                    Text(
                      "Desenvolvido por - Ana Carolina",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                    Text(
                      "Turma - SI2P06",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

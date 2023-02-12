import 'dart:async';

import 'package:bubble_trouble/ball.dart';
import 'package:bubble_trouble/button.dart';
import 'package:bubble_trouble/counter.dart';
import 'package:bubble_trouble/missile.dart';
import 'package:bubble_trouble/player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

enum direction {LEFT,RIGHT}

class _HomePageState extends State<HomePage> {
  //player variables
  double playerX = 0;

  //missile variables
  double missileX = 0;
  double missileHeight = 1;
  bool midShot = false;

  //ball variables
  double ballX = 0.5;
  double ballY = 1;
  var ballDirection = direction.LEFT;

  double time = 0;
  double height = 0;
  double velocity = 80; //speed of the bounce
  bool gameStarted = false;
  _HomePageState(){
    startGame();
  }

  int counter = 0;

  void refreshPage(){
    Navigator.of(context).pop();
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => HomePage(),
    ));
  }
  void startGame(){
    if(gameStarted == false)
      {
        gameStarted = true;
        Timer.periodic(Duration(milliseconds: 10), (timer) {
          //quadratic equation that models a bounce (upside down parabola)
          height = -5 * time * time + velocity * time;

          if(height < 0){
            time = 0;
          }

          //update the new ball position
          setState(() {
            ballY = heightToPosition(height);
          });

          //if the ball hits the left wall change direction to RIGHT
          if(ballX - 0.02 <= -1) {
            ballDirection = direction.RIGHT;
          }
          //if the ball hits the right wall change direction to LEFT
          else if(ballX + 0.02 >= 1){
            ballDirection = direction.LEFT;
          }

          //Move the ball in the correct direction
          if(ballDirection == direction.LEFT){
            setState(() {
              ballX -= 0.02;
            });
          }

          if(ballDirection == direction.RIGHT){
            setState(() {
              ballX += 0.02;
            });
          }

          //keep the time going!
          time +=0.1;

          //check if the ball hits the player
          if(playerDies()){
            timer.cancel();
            _showDialog();
            print('game over');
          }

        });

      }


  }
  void _showDialog(){
    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            backgroundColor: Colors.green,
            title: Text("Game Over",style: TextStyle(color: Colors.white)),
            actions: <Widget> [Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MyButton(
                  icon: Icons.refresh,
                  function: refreshPage,
                ),
              ],
            )],
          );
        });
  }

  void moveLeft(){
    setState(() {
      if(!(playerX - 0.1 < -1)){
        playerX -= 0.1;
      }
      if(!midShot){
        missileX = playerX;
      }
    });
  }

  void moveRight(){
    setState(() {
      if(!(playerX + 0.1 > 1)){
        playerX += 0.1;
      }
      if(!midShot){
        missileX = playerX;
      }

    });
  }

  void fireMissile(){
    if(midShot == false){
      Timer.periodic(Duration(milliseconds: 20), (timer) {

        //shots fired
        midShot = true;

        //missile grows till hitting the top of screen
        setState(() {
          missileHeight += 10;
        });

        //stop missile when it reaches the top of the screen
        if(missileHeight > MediaQuery.of(context).size.height * 3/4) {

          resetMissile();
          timer.cancel();
        }

        //check if missile has hit the ball
        if(ballY > heightToPosition(missileHeight)
            && (ballX - missileX).abs() < 0.03){

          setState(() {
            counter++;
          });
          resetMissile();
          ballX=5;
          timer.cancel();
        }

      });
    }
  }


  bool playerDies(){
    //if the ball position and the player position of the same then the player dies
    if((ballX-playerX).abs() < 0.05 && ballY > 0.95){
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: (event){
        if(event.isKeyPressed(LogicalKeyboardKey.arrowLeft)){
          moveLeft();
        } else if(event.isKeyPressed(LogicalKeyboardKey.arrowRight)){
          moveRight();
        }

        if(event.isKeyPressed(LogicalKeyboardKey.space)){
          fireMissile();
        }

      },
      child: Column(
        children: [
        Expanded(
          flex:3,
          child: Container(
            color: Colors.pink[100],
            child: Center(
              child: Stack(
                children: [
                  MyBall(ballX: ballX, ballY: ballY),
                  MyMissile(
                    height: missileHeight,
                    missileX: missileX),
                  MyPlayer(
                    playerX: playerX,
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            color: Colors.grey,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Counter(counter: counter),
                // MyButton(
                //   icon: Icons.play_arrow,
                //   function: startGame,
                // ),
                MyButton(
                  icon: Icons.arrow_back,
                  function: moveLeft,
                ),
                MyButton(
                  icon: Icons.fireplace,
                  function: fireMissile,
                ),
                MyButton(
                  icon: Icons.arrow_forward,
                  function: moveRight,
                ),
                ],
            ),
          ),
        ),
      ],
      ),
    );
  }

  double heightToPosition(double height) {
    double totalHeight = MediaQuery.of(context).size.height * 3 / 4;
    double position = 1 - 2 * height/totalHeight;

    return position;

  }

  void resetMissile() {
    missileX = playerX;
    missileHeight = 10;
    midShot = false;
  }
}

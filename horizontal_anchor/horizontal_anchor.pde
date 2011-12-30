import com.shigeodayo.ardrone.manager.*;
import com.shigeodayo.ardrone.navdata.*;
import com.shigeodayo.ardrone.utils.*;
import com.shigeodayo.ardrone.processing.*;
import com.shigeodayo.ardrone.command.*;
import com.shigeodayo.ardrone.*;

ARDroneForP5 drone;

final int TURN_SPEED = 30;
color red_tracking_color = -9174516;
boolean is_flying = false;
PImage video;
boolean is_tracking = true;
int timer = 0;
String last_seen_direction = "right";

void setup() {
  size(320, 240);

  drone = new ARDroneForP5("192.168.1.1");
  drone.connect();
  drone.connectNav();
  drone.connectVideo();
  drone.start();
}

void draw() {
  timer += 1;

  background(204);

  video = drone.getVideoImage(false);
  if(video == null){
    return;
  };
  image(video, 0, 0);

  track_red_color();
}

void track_red_color() {
  float red_world_record = 500;

  int red_closest_x = 0;
  int red_closest_y = 0;

  int x;
  int xl = video.width;
  int y;
  int yl = video.height;
  int loc;
  for(x = 0; x < xl; x += 1){
    for(y = 0; y < yl; y += 1){
      loc = x + y * xl;
      color current_color = video.pixels[loc];
      float r1 = red(current_color);
      float g1 = green(current_color);
      float b1 = blue(current_color);
      float r2 = red(red_tracking_color);
      float g2 = green(red_tracking_color);
      float b2 = blue(red_tracking_color);

      float d1 = dist(r1,g1,b1,r2,g2,b2);

      if(d1 < red_world_record){
        red_world_record = d1;
        red_closest_x = x;
        red_closest_y = y;
      };
    };
  };

  if(red_world_record < 30){
    fill(red_tracking_color);
    strokeWeight(4.0);
    stroke(0);
    ellipse(red_closest_x,red_closest_y,16,16);

    int center_x = width / 2;
    if(is_flying == true && timer % 5 == 0){
      if(red_closest_x < center_x - 10){
        println("target is to left");
        drone.spinLeft(TURN_SPEED);
        last_seen_direction = "left";
      } else if(red_closest_x > center_x + 10){
        println("target is to right");
        drone.spinRight(TURN_SPEED);
        last_seen_direction = "right";
      } else{
        hover_drone();
        println("target is front");
      }
    }
  } else{
    if(is_flying == true && timer % 5 == 0){
      if(last_seen_direction == "left"){
        drone.spinLeft(TURN_SPEED);
      } else{
        drone.spinRight(TURN_SPEED);
      };
    };
  };
}

void keyPressed() {
  if(key == 'e'){
    if(is_flying){
      drone.landing();
      is_flying = false;
    } else{
      drone.takeOff();
      is_flying = true;
    };
  };
}

void mousePressed() {
  // use this to figure out what value to give red_tracking_color
  if(video == null){
    return;
  };
  int loc = mouseX + mouseY * video.width;
  println(video.pixels[loc]);
}

void hover_drone() {
  if(is_flying == true){
    drone.setSpeed(0);
    drone.goRight(0);
    drone.up(0);
    drone.spinRight(0);
    drone.forward(0);
  };
}

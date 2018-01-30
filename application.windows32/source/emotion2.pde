import emotionprocessing.*;
import processing.video.*;
import de.looksgood.ani.*;
import gab.opencv.*;
import java.awt.*; 
import java.awt.Font;

Capture cam;
OpenCV opencv;

EmotionProcessing emo_recog;

int api_debug_counter = 0;

// image to display
PImage output;

// array of bounding boxes for face
Rectangle[] faces;

// scale factor to downsample frame for processing 
float scale = 0.5;

float slider = 0;

enum State {
  WELCOME_PAGE, 
  INSTRUCTION,
    READY,
    INSTR,
    GAMING, 
    OVER;
}

public interface Button
{
  public void draw();
  public boolean mouseOver();
}

public class Instr_button implements Button
{
  Instr_button() {
  }
  public float btwidth = 800;
  public float btheight = 400;
  public float x = width*(4/5.0)+5+slider;
  public float y = height*(4/7.0)-60;
  
  public void draw() {
    x = width*(4/5.0)+5+slider;
    noFill();
    strokeWeight(10);
    stroke(255);
    rect(x, y, btwidth, btheight);
    PFont f = createFont("BebasNeue Regular.otf",32);
    
    textFont(f);
    textSize(90);
    text("INSTRUCTION", x+30, y+100);
    text("BACK", x+635, y+100);
    mouseOver();
  }

  public boolean mouseOver() {
    boolean b = mouseX >= x && mouseX <= x + btwidth &&
      mouseY >= y && mouseY <= y + btheight;
    if (b) {
      noFill();
      strokeWeight(7);
      stroke(255);
      rect(x+15, y+15, btwidth-30, btheight-30);
    }
    return b;
  }
}

public class Start_button implements Button
{
  Start_button() {
  }
  int mode = 0;
  public float btwidth = 800;
  public float btheight = 400;
  public float x = width*(4/5.0)+5+slider;
  public float y = height*(1/7.0)-60;
  public void draw() {
    x = width*(4/5.0)+5+slider;
    noFill();
    strokeWeight(10);
    stroke(255);
    rect(x, y, btwidth, btheight);
    PFont f = createFont("BebasNeue Regular.otf",32);
    textFont(f);
    textSize(95);
    text("START", x+30, y+100);
    text("START", x+600, y+100);
    textSize(80);
    text("SINGLE",x+180, y+210);
    text("SINGLE",x+433, y+210);
    textSize(80);
    text("DUAL",x+200, y+330);
    text("DUAL",x+455, y+330);
    mouseOver();
  }

  public boolean mouseOver() {
    if(mouseX >= x && mouseX <= x + btwidth &&
      mouseY >= y+120 && mouseY <= y + 220){  
      mode = 1;
    } else if(mouseX >= x && mouseX <= x + btwidth &&
      mouseY >= y+215 && mouseY <= y + 325){ 
      mode = 2;
    } else {
      mode = 0;
    }
    if (mode == 1) {
      noFill();
      strokeWeight(6);
      stroke(255);
      rect(x+35, y+130, btwidth-60, 98);
    }
    if(mode == 2){
      noFill();
      strokeWeight(6);
      stroke(255);
      rect(x+35, y+255, btwidth-60, 98);
    }
    return mode!=0?true:false;
  }
}

public class GameStart_button implements Button
{
  GameStart_button(){}
  public float btwidth = 100;
  public float btheight = 100;
  public float x = width*(4/5.0)+5+slider;
  public float y = height*(6/7.0)-50;
  public void draw() {
    x = width*(4/5.0)+5+slider;
    noFill();
    strokeWeight(12);
    stroke(255);
    rect(x, y, btwidth-20, btheight-20);
    mouseOver();
    PFont f = createFont("BebasNeue Regular.otf",32);
    textFont(f);
    textSize(115);
    fill(255, 96, 89);
    if(current == State.READY){
      text("START", x+25, y+105);
    } else {
      text("AGAIN", x+25, y+105);
    }

  }

  public boolean mouseOver() {
    boolean b = mouseX >= x && mouseX <= x + btwidth*2.3 &&
      mouseY >= y && mouseY <= y + btheight*1.2;
    if (b) {
      noFill();
      strokeWeight(8);
      stroke(255);
      rect(x+50, y-20, btwidth*1.3, btheight+60);
    }
    return b;
  }
}


public class Back_button implements Button
{
  Back_button(){}
  public float btwidth = 100;
  public float btheight = 100;
  public float x = width*(4/5.0)-300+slider;
  public float y = height*(6/7.0)-50;
  public void draw() {
    x = width*(4/5.0)-300+slider;
    noFill();
    strokeWeight(12);
    stroke(255);
    rect(x, y, btwidth-20, btheight-20);
    mouseOver();
    PFont f = createFont("BebasNeue Regular.otf",32);
    textFont(f);
    textSize(115);
    fill(255, 96, 89);
    text("BACK", x+25, y+105);
  }

  public boolean mouseOver() {
    boolean b = mouseX >= x && mouseX <= x + btwidth*2.3 &&
      mouseY >= y && mouseY <= y + btheight*1.2;
    if (b) {
      noFill();
      strokeWeight(8);
      stroke(255);
      rect(x+50, y-20, btwidth*1.3, btheight+60);
    }
    return b;
  }
}

public class Start_title
{
  Start_title() {
  }
  float x = slider;
  void draw() {
    x = slider;
    fill(255);
    PFont f = createFont("BebasNeue Regular.otf",32);
    textFont(f);
    textSize(500);
    text("TRY", x, 400);
    textSize(300);
    text("NOT TO", x, height/2+110);
    textSize(500);
    text("LAUGH", x, height/2+500);
    
    textSize(190);
    text("WATCH A FUNNY VIDEO", width+x+640, 140);
    textSize(180);
    text("OR COMPETE WITH", width+x+945, 290);
    textSize(180);
    text("YOUR FRIEND", width+x+1235, 430);
    textSize(250);
    text("IF YOU LAUGH", width+x+940, 620);
    textSize(250);
    text("YOU TAKE DAMAGE", width+x+540, 820);
    textSize(290);
    text("TRY TO SURVIVE", width+x+550, 1070);
  }
}

public class Healthbar
{
  Healthbar() {
  }
  
  float health = 100;
  int len = 300;
  int hgt = 100;
  
  boolean dead = false;
  
  void draw() {
    if (faces.length > 0) {
      
      noFill();
      strokeWeight(8);
      stroke(255);
      beginShape();
      vertex(40,0);
      vertex(0,40);
      vertex(460,40);
      vertex(500,0);
      vertex(40,0);
      endShape();
      
      PFont f = createFont("Segoe UI Italic",32);
      textFont(f);
      if(health == 100){
        textSize(140);
        fill(125);
        text((int)health, -65, 60);
        fill(255);
        text((int)health, -85, 27);
      } else {
        if(health >= 10){
          textSize(140);
          fill(125);
          text((int)health/10, -55, 53);
          fill(255);
          text((int)health/10, -75, 26);
          textSize(95);
          fill(125);
          text((int)health%10, 25, 39);
          fill(255);
          text((int)health%10, 5, 26);
        } else {
          textSize(140);
          fill(125);
          text((int)health, -55, 53);
          fill(204, 33, 19);
          text((int)health, -75, 26);
        }
      }
      
      fill(155);
      strokeWeight(0);
      pushMatrix();
      translate(67,26);
      beginShape();
      vertex(45,0);
      vertex(0,45);
      vertex(745,45);
      vertex(790,0);
      vertex(45,0);
      endShape();
      popMatrix();
      
      String Color = "Green";
      if(health<=70 && health > 30) Color = "Yellow";
      else if(health <= 30) Color = "Red";
      
      if(Color == "Green") fill(47,255,101);//fill(85, 255, 82);
      else if(Color=="Yellow") fill(255, 203, 33);
      else if(Color=="Red") fill(255, 71, 61);
      
      float ratio = health/100.0;
      strokeWeight(0);
      pushMatrix();
      translate(30,14);
      beginShape();
      vertex(40,0);
      vertex(0,40);
      vertex(730*ratio,40);
      vertex(730*ratio+40,0);
      vertex(40,0);
      endShape();
      popMatrix();
      
      if(dead){
        fill(204, 33, 19);
        PFont df = createFont("BebasNeue Regular.otf",32);
        textFont(df);
        textSize(130);
        text("YOU ARE DEAD!", 200, 45);
      }
    }
  }
  void reset() {
    health = 100;
    dead = false;
  }
  void receive_damage(float dmg) {
    if(dmg < 0.05) return;
    if(health != 0) {
      float rng = random(100)%30/100+1; 
      println(rng);
      health -= dmg*dmg*10*rng;
    }
    if(health < 1) {
      health = 0;
      dead = true;
      if(bt.mode==1) current = State.OVER;
      if(bt.mode==2){
        if(hb.dead && hb2.dead) current = State.OVER;
      }
    }
  }
}

State current = State.WELCOME_PAGE;

Start_title title;
Start_button bt;
Instr_button it;
GameStart_button gst;
Back_button bbt;
Healthbar hb;
Healthbar hb2;

void setup() {
  Ani.init(this);
  Ani.setDefaultEasing(Ani.CUBIC_IN_OUT);
  fullScreen();
  title = new Start_title();
  bt = new Start_button();
  it = new Instr_button();
  bbt = new Back_button();
  hb = new Healthbar();
  hb2 = new Healthbar();
  gst = new GameStart_button();
  scale = width*2 / float(640);
  emo_recog= new EmotionProcessing("94bb6a66756a4645a80e5441b6f886bd");
}

int frames = 0;

void draw() {

  switch(current) {
  case WELCOME_PAGE:
  case INSTRUCTION:
    fill(255, 96, 89);
    strokeWeight(0);
    rect(0, 0, width, height);
    title.draw();
    bt.draw();
    it.draw();
    return;
  case READY:
    slider = 0;
    if(cam == null){
      cam = new Capture(this, int(640)/2, int(480)/2);
      opencv = new OpenCV(this, cam.width, cam.height);
      opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE); 
      cam.start();
      output = new PImage(cam.width, cam.height);
    }
    if (cam.available() == true) {
      cam.read();
      opencv.loadImage(cam);
      opencv.flip(1);
      faces = opencv.detect();
      opencv.useColor(RGB);
      output = cam.copy();
      pushMatrix();
      translate(width, -240);
      scale(-scale,scale);
      image(output, 0, 0);
      popMatrix();
      drawHealthBar();
      gst.draw();
      bbt.draw();
    }
    return;
  case GAMING:
    if (cam.available() == true) {
      cam.read();
      opencv.loadImage(cam);
      opencv.flip(1);
      faces = opencv.detect();
      opencv.useColor(RGB);
      output = cam.copy();
      pushMatrix();
      translate(width, -240);
      scale(-scale,scale);
      image(output, 0, 0);
      popMatrix();
      drawHealthBar();

      int upper=0;
      if(bt.mode == 1) upper = 12;
      if(bt.mode == 2) upper = 24;
      frames++;
      if (frames>upper) frames = 0;
    
      if (cam.available() == true) {
        cam.read();
        try {
          if (frames==6) {
            if(faces.length>0){
              PImage crop = get(int(faces[0].x*scale),int(faces[0].y*scale-240),
                  int(faces[0].width*scale),int(faces[0].height*scale));
              FloatDict emotions = emo_recog.recognizeFromCamera(crop);
              float happiness = emotions.get("happiness");
              api_debug_counter ++;
              println("\n[DEBUG]------INDEX: "+api_debug_counter+"-----"+millis()/1000.0+"s------Happiness: "+happiness+"------------");
              hb.receive_damage(happiness);
            }
          }
          if(frames == 11){
            if(bt.mode == 2 && faces.length>1){
              PImage crop = get(int(faces[1].x*scale),int(faces[1].y*scale-240),
                  int(faces[1].width*scale),int(faces[1].height*scale));
              FloatDict emotions = emo_recog.recognizeFromCamera(crop);
              float happiness = emotions.get("happiness");
              api_debug_counter ++;
              println("\n[DEBUG]------INDEX: "+api_debug_counter+"-----"+millis()/1000.0+"s------Happiness: "+happiness+"------------");
              hb2.receive_damage(happiness);
            }
          }
        }
        catch(Exception ex) {
        }
      }
    }
    return;
  case OVER:
    if (cam.available() == true) {
      cam.read();
      opencv.loadImage(cam);
      opencv.flip(1);
      faces = opencv.detect();
      opencv.useColor(RGB);
      output = cam.copy();
      pushMatrix();
      translate(width, -240);
      scale(-scale,scale);
      image(output, 0, 0);
      popMatrix();
      drawHealthBar();
      gst.draw();
      bbt.draw();
    }
    return;
  }
}

void mousePressed() {
  switch(current) {
  case WELCOME_PAGE:
    if(bt.mouseOver()){
      current = State.READY;
    }
    if(it.mouseOver()){
      current = State.INSTRUCTION;
      Ani.to(this, 3, "slider", -width);
    }
    break;
  case INSTRUCTION:
    if (bt.mouseOver()) {
      current = State.READY;
    }
    if(it.mouseOver()){
      current = State.WELCOME_PAGE;
      Ani.to(this, 3, "slider", 0);
    }
    break;
  case READY:
    if (gst.mouseOver()){
      current = State.GAMING;
    }
    if(bbt.mouseOver()){
      hb.reset();
      hb2.reset();
      current = State.WELCOME_PAGE;
    }
    break;
  case OVER:
    if(gst.mouseOver()){
      hb.reset();
      hb2.reset();
      current = State.GAMING;
    }
    if(bbt.mouseOver()){
      hb.reset();
      hb2.reset();
      current = State.WELCOME_PAGE;
    }
  }  
}

void drawHealthBar(){
  if(faces.length > 0){
        pushMatrix();
        float ratio = faces[0].width*scale;
        translate(-90,-50);
        translate(faces[0].x*scale, faces[0].y*scale-ratio);
        scale(faces[0].width*scale/500);
        hb.draw();
        popMatrix();
        if(bt.mode==2){
          if(faces.length>1){
            pushMatrix();
            float ratio2 = faces[1].width*scale;
            translate(-90,-50);
            translate(faces[1].x*scale, faces[1].y*scale-ratio2);
            scale(faces[1].width*scale/500);
            hb2.draw();
            popMatrix();
          }
        }
  }
}
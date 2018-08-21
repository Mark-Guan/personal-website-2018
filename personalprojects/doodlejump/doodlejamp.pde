int screen = 1;
boolean isSpinning = false;
PImage guy;
float rot = 0;
int playerX = 150;
int playerY = 350;
float velocityY = 0;
int bounceHeight = -15;
ArrayList<Platform> platforms = new ArrayList<Platform>();
int platformHeight = 10;
int platformWidth = 40;
PImage bckground;
PImage platform;
PImage broken;
PImage spring;
PImage brokenbroken;
PImage moving;
int xSpeed = 1;
int springReoccurenceCounter = 0;
boolean hasShiftedOnce = false;
int score = 0;

void setup() {
  noCursor();
  imageMode(CENTER);
  rectMode(CENTER);
  size(350, 500);
  bckground = loadImage("https://i.imgur.com/omcJr8G.png");
  platform = loadImage("https://i.imgur.com/N9t2j8w.png");
  spring = loadImage("https://i.imgur.com/nunX6FA.png");
  broken = loadImage("https://i.imgur.com/Q9Hoge9.png");
  brokenbroken = loadImage("https://i.imgur.com/8VZid0f.png");
  guy = loadImage("http://img1.wikia.nocookie.net/__cb20130403202424/doodle-jump/images/5/5c/Doodler.png");
  moving = loadImage("https://i.imgur.com/Rgp9RzM.png");

  //generates the starting couple of platforms
  for (int i = 0; i<2; i ++)
    platforms.add(new Platform((int)random(0, width), (int)random(height/2, height), platformWidth, platformHeight, 1));
  for (int i = 0; i<3; i ++) {
    platforms.add(new Platform((int)random(0, width), (int)random(0, height/2), platformWidth, platformHeight, 1));
    //generates 1 starting SpringPlatform
  }
  platforms.add(new PlatformSpring((int)random(0, width), (int)random(height/2, height), platformWidth, platformHeight, 2));

  //generates 3 brokenplatforms at start
  for (int i = 0; i<3; i ++)
    platforms.add(new BrokenPlatform((int)random(0, width), (int)random(0, height), platformWidth, platformHeight, 4, broken, brokenbroken));

  //generates two moving platforms at start
  platforms.add(new MovingPlatform((int)random(26, width-26), (int)random(height/2, height), platformWidth, platformHeight, 5));
  platforms.add(new MovingPlatform((int)random(26, width-26), (int)random(0, height/2), platformWidth, platformHeight, 5));
}

void draw() {
  pushMatrix();
  //start  screen
  if (screen == 1) {
    image(bckground, width/2, height/2, width, height);
    fill(0);
    text("PRESS P TO PLAY", 123, 100);
    text("USE YOUR MOUSE TO MOVE DOODLEBOB AROUND", 23, 167);
  }

  //play screen
  if (screen ==2) {
    image(bckground, width/2, height/2, width, height);
    fill(0);
    text("Score: " + (int)score, width-100, height-50);
    playerX = mouseX;  // follows mouse
    pushMatrix();
    if (isSpinning)rot+=2*PI/60;
    if (rot>=2*PI) {
      isSpinning=false;
      rot=0;
    }

    translate(playerX, playerY);
    rotate(rot);
    image(guy, 0, 0, 30, 30); // displays the player's image

    popMatrix();
    //clear offscreen platforms
    clear();

    //display platforms and constantly shift them down
    for (Platform plat : platforms) {
      plat.display();

      //bounce if the guy touches a platform
      if (dist(playerX, 0, plat.x, 0) <=75 && dist( 0, playerY, 0, plat.y) <=75) {
        if (dist(playerX, 0, plat.x, 0) <=30  && dist( 0, playerY, 0, plat.y) <=20 && velocityY > 0) {
          if (plat.type != 4)
            jump();
          if (plat.type == 2) {
            //jump 3x 
            velocityY = -30;
            isSpinning = true;
          }
          // broken platforms switching
          if (plat.type == 4 && velocityY > 0) {
            ((BrokenPlatform)plat).switchDisplay();
          }
        }
      }
      //moving platform speed
      if (plat.type == 5) {
        if (plat.x <= 25 || plat.x >=width-25)
          xSpeed = -xSpeed;
        plat.x += xSpeed;
      }
      if (plat.type == 4) {
        if (((BrokenPlatform)plat).hasSwitched) {
          plat.y ++;
        }
      }
    }

    if (playerY <= height/2 && velocityY<0) {
      for (int i = 0; i < platforms.size (); i++) {
        Platform p = platforms.get(i);
        p.shift(-velocityY);
        hasShiftedOnce = true;
      }
    } else {
      playerY += velocityY;
    }
    velocityY+=0.5; // Gravity

    //    test code so that the guy will bounce off the bottom
    if (playerY >= height - 15 && !hasShiftedOnce) {
      jump();
    }
    // having the spring platform reoccur every 500 points
    if (score - springReoccurenceCounter > 500) {
      generateNewSpringPlatform();
      springReoccurenceCounter = score;
    }
  }
  // if the player falls off the screen, then text appears saying "press r to play again"
  if (playerY>height+100 && screen  == 2) {
    text("PRESS R TO PLAY AGAIN", width/2-70, height/4);
  }
  popMatrix();
}

//key listeners
void keyPressed() {
  //starts game
  if (screen == 1)
    if (key == 'p')
      screen = 2;
  //restarts game 
  if (key == 'r') {
    screen = 2;
    playerX = 150;
    playerY = 350;
    velocityY = 0;
    bounceHeight = -15;
    platforms.clear();
    springReoccurenceCounter = 0;
    hasShiftedOnce = false;
    score = 0;
    setup();
  }
}

// makes the player jump
void jump() {
  velocityY = bounceHeight;
}

// clears off screen platforms from arraylist
void clear() {
  for (int i = 0; i < platforms.size (); i++) {
    Platform platform = platforms.get(i);
    if (platform.y >= height+20) {
      if (platform.type == 2) {
        platforms.remove(i);
      } 
      if (platform.type == 1) {
        platforms.remove(i);
        generateNewPlatform();
      }
      if (platform.type == 3) {
        platforms.remove(i);
      }
      if (platform.type == 4) {
        platforms.remove(i);
        generateBrokenPlatform();
      }
      if (platform.type == 5) {
        platforms.remove(i);
        generateMovingPlatform();
      }
    }
  }
}

//these methods generate a new platform in the top half of the screen after one is cleared
void generateNewPlatform() {
  platforms.add(new Platform((int)random(0, width), 0, platformWidth, platformHeight, 1));
}
void generateNewSpringPlatform() {
  platforms.add(new PlatformSpring((int)random(0, width), 0, platformWidth, platformHeight, 2));
}
void generateBrokenPlatform() {
  platforms.add(new BrokenPlatform((int)random(0, width), 0, platformWidth, platformHeight, 4, broken, brokenbroken));
}
void generateMovingPlatform() {
  platforms.add(new MovingPlatform((int)random(30, width-30), 0, platformWidth, platformHeight, 5));
}

//regular platform
class Platform {
  int x;
  int y;
  int width;
  int height;
  int type;
  Platform(int x, int y, int width, int height, int type) {
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
    this.type = type;
  }
  void display() {
    image(platform, x, y, width, height);
  }
  void shift(float speed) {
    y += speed;
    score += (0.1*speed);
  }
}

//spring platform
class PlatformSpring extends Platform {
  PlatformSpring(int x, int y, int width, int height, int type) {
    super(x, y, width, height+5, type);
  }
  void display() {
    image(spring, x, y, width, height);
  }
}

//broken platform
class BrokenPlatform extends Platform {
  PImage current;
  PImage otherstate;
  boolean hasSwitched = false;
  BrokenPlatform(int x, int y, int width, int height, int type, PImage one, PImage two) {
    super(x, y, width, height, type);
    current = one;
    otherstate = two;
  }
  // blueprint for changing the broken platform from solid to broken
  void display() {
    image(current, x, y, width, height);
  }
  void switchDisplay() {
    if (!hasSwitched) {
      PImage temp = current;
      current = otherstate;
      otherstate = temp;
      hasSwitched = true;
    }
  }
}

//moving platform
class MovingPlatform extends Platform {
  MovingPlatform(int x, int y, int width, int height, int type) {
    super(x, y, width, height, type);
  }
  void display() {
    image(moving, x, y, width, height);
  }
}

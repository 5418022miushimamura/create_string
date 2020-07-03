boolean easy = true;
String theme;
int index = 0;
int t = 0;


State state;
void setup() {
  size(800, 800);
  textAlign(CENTER);
  PFont font = createFont("MS Gothic", 50);
  textFont (font);
}

void draw() {
  background(255);
  fill(0);
  textSize(100);
  text("Create letters", 50, 100);
  state = new Title();
}

abstract class State {
  long t_start;
  float t;

  State() {
    t_start = millis();
  }

  State doState() {
    drawState();
    return decideState();
  }

  abstract void drawState();    // 状態に応じた描画を行う
  abstract State decideState(); // 次の状態を返す
}

class Title extends State {
  void drawState() {
    text("Create letters", width * 0.5, height * 0.3);
    text("Press 'F' key to start easy, 'J' key to start hard", width * 0.5, height * 0.7);
  }

  State decideState() {
    if (keyPressed && key == 'f') { // if 'f' key is pressed
      return new Game(); // start game
    }
    if (keyPressed && key == 'j') {
      easy = false;
      return new Game(); // start game
    }
    return this;
  }
}

class Game extends State {
  void drawState() {
    text("Game (for 5 seconds)", width * 0.5, height * 0.5);
  }

  State decideState() {
    if (t == 0 || 文字の長さ == index) { // if ellapsed time is larger than
      return new End(); // go to ending
    }
    return this;
  }
}

class Letter {
  float lx, ly;
  char c;
  boolean judge(float px, float py, float lx, float ly) {
  }
  void move(float dx, float dy, float lx, float ly) {
    lx += dx;
    ly += dy;
  }
}

void player(float px, float py) {
  //移動に関すること
}

class Theme {
  String makeTcheme() {
    return 文字列;
  }
  int word() {
    return word_index;
  }
}

void timer(int tm, int t) {
  tm++;//時間設定
  if (tm==60) {
    t--;
    tm=0;
  }
}

class End extends State {
  void drawState() {
    text("Result", width * 0.5, height * 0.5);
    if (t == 0) {
      text("not clear a stage", width * 0.5, height * 0.7);
    } else {
      text("clear a stage", width * 0.5, height * 0.7);
    }
    text("to title (press some key).", width * 0.5, height * 0.7);
  }

  State decideState() {
    if (keyPressed) {
      return new End();
    }
    return this;
  }
}

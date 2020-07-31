boolean easy;
String theme;
int index;  // 0文字目を取得した状態で，index = 0
int t, tm;
int side = 80;  // マス1つ分の辺の長さ
float px, py;

State state;
Letter[] letters = new Letter[60];

void setup() { 
  size(800, 800); 
  textAlign(CENTER);
  PFont font = createFont("MS Gothic", 50);
  textFont (font);

  state = new Title();
}

void draw() {
  background(255);
  state = state.doState();
}

abstract class State {
  State doState() {
    drawState();
    if (state instanceof Game) {
      timer();
    }
    return decideState();
  }

  abstract void drawState();    // 状態に応じた描画を行う
  abstract State decideState(); // 次の状態を返す
}

class Title extends State {
  Title() {  // 初期化
    t = 60;
    tm = 0;
    index = -1;
    px = 800/2;
    py = 800/1.75;
  }

  void drawState() {
    fill(0);
    textSize(70);
    text("Create letters", width * 0.5, height * 0.3);
    textSize(30);
    text("Press 'F' key to start easy, 'J' key to start hard", width * 0.5, height * 0.7);
  }

  State decideState() {
    if (keyPressed && key == 'f') {  // if 'f' key is pressed
      easy = true;
      makeTheme();
      return new Game(); // start game
    }
    if (keyPressed && key == 'j') {  // if 'j' key is pressed
      easy = false;
      makeTheme();
      return new Game(); // start game
    }
    return this;
  }
}

class Game extends State {
  int time, n = 0;
  void drawState() {
    background(255);
    for (int i=1; i<=4; i++) {
      line(width/4, height/1.75/1.75+i*side, width/4*3, height/1.75/1.75+i*side);
      line(width/4+i*side, height/1.75/1.75, width/4+i*side, height/1.75/1.75+side*5);
    }

    fill(255, 0, 0);
    textSize(side/4);
    textAlign(LEFT);
    text("お題："+theme, 0, height/10);
    text("残り時間：" + t + "seconds", 0, height/10+side/2);
    text("今まで取得した文字列："+theme.substring(0, index+1), 0, height/10+side);
    textAlign(CENTER);
    textSize(side);

    if (tm == 0) {
      time++;
      if (time >= 1) {
        int isVer = int(random(2)), isTopOrLelf = int(random(2));
        if (isVer == 0)
          letters[n] = new MoveVertical(n, isTopOrLelf);
        else
          letters[n] = new MoveHorizontal(n, isTopOrLelf);

        n++;
        time = 0;
      }
    }
    for (int i = 0; i < n; i++) {
      if (!(letters[i].isHit)) {
        if (index+2 <= theme.length())
          letters[i].collision();
        letters[i].display();
        letters[i].move();
      }
    }
    if (index+2 <= theme.length()) {
      fill(0, 0, 255);
      text(theme.substring(index+1, index+2), 700, height/10); // 次に取得する文字
    }
    fill(255);
    ellipse(px, py, side/2, side/2);
  }

  State decideState() {
    if (t <= 0 || theme.length()-1 == index) { // if ellapsed time is larger than
      return new End(); // go to ending
    }
    return this;
  }
}

abstract class Letter {
  float min_px = width/2 - side * 2;  // 0列目
  float min_py = height/1.75 - side * 1.5;  // 0行目
  int id = int(random(5));
  float lx, ly;
  String c;

  Letter(int i) {
    if (i % 3 == 0) {
      c = theme.substring(index +1, index +2);
    } else {
      int idOfChar = int(random(26));
      char cc = (char)(idOfChar + 'A');
      c = String.valueOf(cc);
    }
  }

  int dx = 1, dy = 1; // 文字の速度
  boolean isHit = false;

  void collision() {
    String next_c = theme.substring(index+1, index+2);
    if (dist(px, py, lx, ly - side/2) < side/2) {  // 文字とぶつかった
      isHit = true;
      if (c.equals(next_c)) {  // 正解
        index++;
      } else {  // 不正解
        t -= 3;
      }
    }
  }
  void display() {
    fill(0);
    text(c, lx, ly);
  }
  abstract void move();
}

class MoveVertical extends Letter {
  int isTopOrLelf;
  MoveVertical(int i, int isTopOrLelf0) {
    super(i);
    isTopOrLelf = isTopOrLelf0;
    lx = min_px + float(side * id);
    if (isTopOrLelf == 0)
      ly = 0;
    else
      ly = height;
  }
  void move() {  // 縦
    if (isTopOrLelf == 0)
      ly += dy;
    else
      ly -= dy;
  }
}

class MoveHorizontal extends Letter {
  int isTopOrLelf;
  MoveHorizontal(int i, int isTopOrLelf0) {
    super(i);
    isTopOrLelf = isTopOrLelf0;
    if (isTopOrLelf == 0)
      lx = 0;
    else
      lx = width;
    ly = min_py + float(side * id);
  }
  void move() {  // 横
    if (isTopOrLelf == 0)
      lx += dx;
    else
      lx -= dx;
  }
}

void keyPressed() {
  if (key == CODED)  // コード化されているキーが押された
    player();
}

void player() {
  /* px, pyはplayerのいるマスの右下の座標を指す.
   - (px, pyはグローバル)*/
  float min_px = width/2 - side * 2;
  float max_px = width/2 + side * 2;
  float min_py = height/1.75 - side * 2;
  float max_py = height/1.75 + side * 2;

  if (keyCode == RIGHT && px < max_px)
    px += side;
  else if (keyCode == LEFT && px > min_px)
    px -= side;
  else if (keyCode == UP && py > min_py)
    py -= side;
  else if (keyCode == DOWN && py < max_py)
    py += side;
}

void makeTheme() {
  String[] makeThemes = new String[200];
  if (easy) {
    String[] makeEasy = {"HEAP", "SORT", "PDE", "SOFT", "JAVA", "RUBY", "QUE"};
    makeThemes = makeEasy;
  } else {
    String[] makeHard = {"QUERY", "SERVER", "NETWORK", "OBJECT", "STACK", "PROGRAM", "PYTHON"};
    makeThemes = makeHard;
  }
  theme = makeThemes[int(random(makeThemes.length))];
}

void timer() {
  tm++;  //時間設定
  if (tm == 60) {
    t--;
    tm = 0;
  }
}

class End extends State {
  void drawState() {
    fill(0);
    text("Result", width * 0.5, height * 0.5);
    textSize(30);
    if (t <= 0)
      text("not clear a stage", width * 0.5, height * 0.7);
    else
      text("clear a stage", width * 0.5, height * 0.7);
    text("to title (press enter key).", width * 0.5, height * 0.9);
  }

  State decideState() {
    if (keyPressed && key == ENTER) {
      return new Title();
    }
    return this;
  }
}

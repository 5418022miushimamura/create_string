boolean easy = true;
String theme;
int index = -1;  // 0文字目を取得した状態で，index = 0
int t = 60, tm = 0;
int side = 80;
float px, py;

State state;
Letter[] letters = new Letter[30];

void setup() { 
  size(800, 800); 
  textAlign(CENTER);
  PFont font = createFont("MS Gothic", 50);
  textFont (font);

  px = 800/2;
  py = 800/1.75;

  theme = "EE";
  //makeTheme();
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
  void drawState() {
    fill(0);
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
  int time, n = 0;
  void drawState() {
    for (int i=1; i<=4; i++) {
      line(width/4, height/1.75/1.75+i*side, width/4*3, height/1.75/1.75+i*side);
      line(width/4+i*side, height/1.75/1.75, width/4+i*side, height/1.75/1.75+side*5);
    }

    fill(255, 0, 0);
    textSize(side/4);
    textAlign(LEFT);
    text("お題："+theme, 0, height/10);
    text("残り時間："+t+"seconds", 0, height/10+side/2);
    text("今まで取得した文字列："+theme.substring(0, index+1), 0, height/10+side);
    textAlign(CENTER);
    textSize(side);

    if (tm == 0) {
      time++;
      if (time >= 2) {
        letters[n] = new Letter();
        letters[n].decideY();
        n++;
        time = 0;
      }
    }
    for (int i = 0; i < n; i++) {
      if (!(letters[i].isHit)) {
        if (index+2 <= theme.length())
          letters[i].collision();
        letters[i].display();
        //letters[i].moveVertical();
        letters[i].moveHorizontal();
      }
    }
    if (index+2 <= theme.length())
      text(theme.substring(index+1, index+2), 700, height/10); // 次に取得する文字
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

class Letter {
  float min_px = width/2 - side * 2;  // 0列目
  float min_py = height/1.75 - side * 1.5;  // 0行目
  int id = int(random(5));
  float lx, ly;

  /* 以下decideは1回のみ呼び出す */
  void decideX() {  // 何列目か位置を確定する
    lx = min_px + float(side * id);
    //ly = 0;
    ly = height;
  }
  void decideY() {  // 何行目か位置を確定する
    lx = 0;
    //lx = width;
    ly = min_py + float(side * id);
    println("ly:" + ly);
  }
  int dx = 1, dy = 1;
  String c = "E";  //後でランダムにする
  String next_c = theme.substring(index+1, index+2);
  boolean isHit = false;

  void collision() {
    if (dist(px, py, lx, ly - side/2) < side/2) {  // 文字とぶつかった
      println("c:" + next_c);
      isHit = true;
      if (c.equals(next_c)) { // 正解
        index++;
      } else { // 不正解
        t -= 3;
      }
    }
  }
  void display() {
    fill(0);
    text(c, lx, ly);
  }
  void moveVertical() {  // 縦
    ly -= dy;
  }
  void moveHorizontal() {  // 横
    lx += dx;
  }
}

/* (void playerの代わり - px, pyはグローバル)
 px, pyはplayerのいるマスの右下の座標を指す. */
void keyPressed() {
  if (key == CODED) {// コード化されているキーが押された

    float min_px = width/2 - side * 2;
    float max_px = width/2 + side * 2;
    float min_py = height/1.75 - side * 2;
    float max_py = height/1.75 + side * 2;

    if (keyCode == RIGHT && px < max_px) {
      px += side;
    } else if (keyCode == LEFT && px > min_px) {
      px -= side;
    } else if (keyCode == UP && py > min_py) {
      py -= side;
    } else if (keyCode == DOWN && py < max_py) {
      py += side;
    }
  }
}

void makeTheme() {
  String[] makethemes= {"AAA", "BBB", "CCC", "DDD", "EEEEE", "FFFFF", "GGGGG", "HHHHH", "IIIII", "JJJJJJJJ", "KKKKK", "LLLLLLL", "MMMMMMM", "NNNNNN", "OOO", "PPP", "QQQ", "RRR", "SSS", "TTTTT", "UUUUU"};
  theme = makethemes[int(random(makethemes.length))];
}

void timer() {
  tm++;//時間設定
  if (tm == 60) {
    t--;
    tm = 0;
  }
}

class End extends State {
  void drawState() {
    fill(0);
    text("Result", width * 0.5, height * 0.5);
    if (t <= 0) {
      text("not clear a stage", width * 0.5, height * 0.7);
    } else {
      text("clear a stage", width * 0.5, height * 0.7);
    }
    text("to title (press some key).", width * 0.5, height * 0.7);
  }

  State decideState() {
    t = 60;
    if (keyPressed && key == ENTER) {
      return new Title();
    }
    return this;
  }
}

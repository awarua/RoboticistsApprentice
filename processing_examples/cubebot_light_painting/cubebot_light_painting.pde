CubeBot[] cbs = new CubeBot[9];
PImage mona;

PGraphics botField;
PGraphics lightPainting;

void setup() {
  size(1200, 596);
  rectMode(CENTER);
  ellipseMode(CENTER);

  mona = loadImage("mona-lisa.jpg");  
  botField = createGraphics(width / 3, height);
  lightPainting = createGraphics(width / 3, height);
  
  for(int i = 0; i < cbs.length; i++){
    cbs[i] = new CubeBot();
  }

  background(0);
}

void draw() {
  drawField();
  
  botField.beginDraw();
  lightPainting.beginDraw();
  
  botField.background(0);
  
  for(int i = 0; i < cbs.length; i++){
    cbs[i].update();
    cbs[i].draw();
  }

  botField.endDraw();
  lightPainting.endDraw();
  
  image(botField, width / 3, 0);
  image(lightPainting, 2 * width / 3, 0);
}

void drawField() {
  background(0);
  image(mona, 0, 0);
}
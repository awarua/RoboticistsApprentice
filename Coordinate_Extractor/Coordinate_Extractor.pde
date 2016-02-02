PImage image;
PFont f;

void settings() {
  image  = loadImage("test1.png");
  size(image.width, image.height);
}

void setup() {
  f = createFont("Arial", 16, true);
}


void draw() {

  image(image, 0, 0);
  noCursor();
  stroke(255, 50);
  line(mouseX, 0, mouseX, height);
  line(0, mouseY, width, mouseY);

  if (mousePressed) {
    println("x coordinate   "+"   "+mouseX); 
    println("y coordinate   "+"   "+mouseY);
    textFont(f, 16);
    fill(255);
    text("x coordinate   "+"   "+mouseX, 10, 70);
    text("y coordinate   "+"   "+mouseY, 10, 100);
  }
}
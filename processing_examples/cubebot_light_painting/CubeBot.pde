class CubeBot{  
  float x;
  float y;
  float vx;
  float vy;
  
  color c = color(255);
  
  float h; 
  
  float te;
  float be;
  float le;
  float re;
  
  float w = 20;
  
  float maxV = 1;
  
  float noiseInc = 0.007;
  float vxSamp = 1000;
  float vySamp = 0;
  
  float lightIntensity = 5;
  
  CubeBot(){  
    x = random(w / 2.0, botField.width - w / 2.0);
    y = random(h / 2.0, botField.height - w / 2.0);

    vxSamp = random(10000);
    vySamp = random(10000);
    
    te = 0;
    be = botField.height;
    le = 0;
    re = botField.width;
    
    vx = 0;
    vy = 0;
  }
  
  void update(){
    vxSamp += noiseInc;
    vySamp += noiseInc;
    
    vx += 0.1 * (noise(vxSamp) - 0.5);
    vy += 0.1 * (noise(vySamp) - 0.5);
  
    vx = min(max(-maxV, vx), maxV);
    vy = min(max(-maxV, vy), maxV);
 
    x += vx;
    y += vy;
 
    // Constrain to bounds. 
    if(x - w / 2.0 <= le){
      x = le + w / 2.0;
      vx = -vx;
    }
    else if(x + w / 2.0 >= re){
      x = re - w / 2.0;
      vx = -vx;
    }
    if(y - w / 2.0 <= te){
      y = te + w / 2.0;
      vy = -vy;
    }
    else if(y + w / 2.0 >= be){
      y = be - w / 2.0;
      vy = -vy;
    }
    
    getHeading();
    getColour();
  }
  
  void draw(){
    drawBotField();
    drawLightPainting();
  }
  
  void drawBotField(){
    botField.pushMatrix();

    botField.rectMode(CENTER);
    botField.ellipseMode(CENTER);
    
    botField.translate(x, y);
    botField.rotate(h);
            
    botField.noStroke();
    botField.fill(c, 50);
    botField.ellipse(0, 0, w * 3, w * 3);

    botField.stroke(0);
    botField.fill(c);
    botField.rect(0, 0, w, w);

    botField.popMatrix();
  }
  
  void drawLightPainting(){
    lightPainting.pushMatrix();

    lightPainting.rectMode(CENTER);
    lightPainting.blendMode(SCREEN);
    
    lightPainting.translate(x, y);
    lightPainting.rotate(h);
    
    lightPainting.noStroke();
    lightPainting.fill(c, lightIntensity);
    
    lightPainting.rect(0, 0, w, w);
    
    lightPainting.popMatrix();
  }
  
  void getColour(){
    c = mona.get(int(x), int(y));
  }
  
  void getHeading(){
    h = new PVector(vx, vy).heading(); 
  }
}
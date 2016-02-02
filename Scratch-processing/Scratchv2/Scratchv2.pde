import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.ServletException;
import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import gab.opencv.*;
import org.opencv.imgproc.Imgproc;
import org.opencv.core.MatOfPoint2f;
import org.opencv.core.Point;
import processing.video.*;
import org.opencv.core.Size;
import processing.serial.*;
import org.opencv.core.Mat;
import org.opencv.core.CvType;
import blobDetection.*;
import java.awt.*;


Capture video;
Serial serial;
BlobDetection theBlobDetection;
XBee xbeeExplorer;
OpenCV opencv;

float scratchX;
float scratchY;
float scratchR;
float scratchC;
float scratchstart;
float botstart;
float scratchready;
float botX, botY, botR, newscratchR, botT, targetx, targety;
int videowidth = 640;
int videoheight = 480;

float frontblobarea = 0;
float backblobarea = 0;
int xbeeExplorerPort = 1;
int baudRate = 57600;
boolean forward = false;
byte[] msg = new byte[10];
PImage birdseye; 
int floorWidth = 578;
int floorHeight = 580;
float turnfactor = 0;
float  diffR, lastx1, lasty1, lastx2, lasty2, lastx3, lasty3, lastx4, lastscratchC, lastscratchX, lastscratchY, distx, disty, startx, starty;
int[] tile1 = {107, 159, 0};
int[] tile2 = {285, 263, 0};
int[] tile3 = {469, 178, 0};
int[] tile4 = {280, 81, 0};
int[][] tilepoints = {tile1, tile2, tile3, tile4}; 
int[] frontblob ={0, 0};
int[] backblob = {0, 0};
float[] fullblob = {0, 0};
float simh = -90;
float[] sim = {578/2, 580/2};
float heading = 0;
PVector dir = new PVector(0, 0);
float stepsizex, stepsizey;
float newscratchX = sim[0];
float newscratchY = sim[1];
float loop = 0;

int movetime=0;
float desiredheading = 0;
boolean turn = false;
int colornum = 4;
boolean colorchange = false;
Point[] points;
color c;

boolean sayHello = false;

void settings() {
  size(floorWidth, floorHeight);
}
void setup() {
  try {
    startServer();
  } 
  catch (Exception e) {
    println("Exception starting server");
  }
  //loads original video into opencv
  video = new Capture(this, videowidth, videoheight);
  //THIS HAS TO BE ADJUSTED TO VIDEO WIDTH
  opencv = new OpenCV(this, videowidth, videoheight);
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);  

  //create the image to store thresholded and birdseye images into
  birdseye = createImage(578, 580, ARGB); 

  //open xbeeExplorer
  xbeeExplorer = new XBee(xbeeExplorerPort, baudRate, this);

  /*-----------------Xbee variables to be set------------------------------------*/
  msg[0] = -86; //[0] 0xAA
  msg[1] = 85;  //[1] 0x55
  msg[2] = -6;  //[2] rId byte(-6) == all robots.
  msg[3] = 1;  // [3] type: 1 = manual control, 2 = auto control (for spins etc.)
  msg[4] = 100; // [4] d1:     (velocity of left wheel. 100 = still, < 100 = forward)
  msg[5] = 100;  // [5] d2:     (velocity of right wheel. 100 = still, < 100 = forward)
  msg[6] = 3;  // [6] d3: NO FUNCTION
  msg[7] = 0;  // [7] d4:     (includes ID of button pushed. From L-R these are 1,2,4,8(L-shoulder),16,32,64,-128(R-shoulder)
  //[8] and [9] are set in Xbee class
  // [8] seqno:  (just checks that this seqno != seqno of previous).
  // [9] crc: Global variable sent & incremeneted with each xBee message.

  botT = 0;

  video.start();

  //initialize variables for scratch
  scratchX = 0;
  scratchY = 0;
  scratchR = 0;
  scratchC = 0;
  botstart = 0;
  scratchstart = 0;
  scratchready = 0;

  noStroke();
  background(255);
  xbeeExplorer.lightson(msg);
}

void draw() {

  botX = fullblob[0];
  botY = fullblob[1];
  botR = heading;
  float oldscratchX = newscratchX;
  float oldscratchY = newscratchY;
  newscratchX = (scratchX+(480/2))+50;
  newscratchY = ((scratchY-(360/2))*-1)+110;

  if ((scratchR >=-90)&&(scratchR<=180)) {
    newscratchR = scratchR-90;
  } else {
    newscratchR = scratchR+270;
  }
  if (scratchC == 1) {
    c = color(255, 0, 0);
  }
  if (scratchC == 2) {
    c = color(255, 255, 0);
  }
  if (scratchC == 3) {
    c = color(0, 255, 0);
  }
  if (scratchC == 4) {
    c = color(0, 0, 255);
  }
  if (scratchC == 5) {
    c = color(255, 0, 255);
  }
  if (scratchC == 6) {
    c = color(255);
  }

  if ((scratchC != 6)&&(scratchstart == 1)) {
    if ((newscratchX!=oldscratchX)||(newscratchY!=oldscratchY)) {
      stepsizex = sim[0];
      stepsizey = sim[1];
      botT = 0;
      println("x " + stepsizex+ " y "+ stepsizey);
      println("sx " + newscratchX + " sy "+ newscratchY);
      forward = true;
    }

    if (forward == true){
      sim[0]  = lerp(stepsizex, newscratchX, loop/10.0);
        sim[1] = lerp(stepsizey, newscratchY, loop/10.0);
        fill(c);
        rectMode(CENTER);
        pushMatrix();
        translate(sim[0], sim[1]);
        rotate(radians(newscratchR));
        rect(0, 0, 20, 20);
        popMatrix();
        loop++;
        if (loop == 10){
          loop = 0;
          forward = false;
          botT = 1;
        }
    }
  }
  if (botstart == 1) {
    /*-----------------Perspective Transformation------------------------------------*/
    //opencv = new OpenCV(this, videowidth, videoheight);
    opencv.loadImage(video);
    opencv.toPImage(warpPerspective(tilepoints, floorWidth, floorHeight), birdseye);

    /*-----------------Blob detection------------------------------------*/
    noFill(); 
    theBlobDetection = new BlobDetection(birdseye.width, birdseye.height);
    //theBlobDetection.setPosDiscrimination(true);
    //this needs to be adjusted depending on brightness present in video feed
    theBlobDetection.setThreshold(0.65f);
    theBlobDetection.computeBlobs(birdseye.pixels);
    drawBlobs(true);
    rectMode(CENTER);
    fill(0, 0, 255);
    rect(targetx, targety, 20, 20);
    /*----------------Direction and heading code------------------------------------*/

    //heading is calculated using the front blob and back blob - remember processing has a coordinate system with topright corner x=0, y=0
    heading = degrees(atan2(frontblob[1]-backblob[1], frontblob[0]-backblob[0]));
    /*-------------------------Movement code---------------------------------------------*/
    if (scratchC!=lastscratchC) {
      if (scratchC == 1) {
        msg [4] = byte(2); //colour
        xbeeExplorer.lightson(msg);
      }
      if (scratchC == 2) {
        msg[4] = byte(5);
        xbeeExplorer.lightson(msg);
      }
      if (scratchC == 3) {
        msg [4] = byte(3); //colour
        xbeeExplorer.lightson(msg);
      }
      if (scratchC == 4) {
        msg [4] = byte(4); //colour
        xbeeExplorer.lightson(msg);
      }
      if (scratchC == 5) {
        msg [4] = byte(6); //colour
        xbeeExplorer.lightson(msg);
      }
      if (scratchC == 6) {
        xbeeExplorer.lightsoff(msg);
      }
    }
    if ((((heading-newscratchR)<-5)||((heading-newscratchR)>5))&&(forward == false)) {
      turn = true;
      botT = 0;
      println("turn triggered");
    }

    if (turn) {
      desiredheading = newscratchR;
      float turnvar = (newscratchR-heading);
      if (((turnvar >= -180)&& (turnvar<=0))||(turnvar>=180)) {
        xbeeExplorer.turnleft(msg);
      } else {
        xbeeExplorer.turnright(msg);
      }
      //allows for below or above 5 degrees from desired heading
      if ((heading >= (desiredheading-3))&&(heading <= (desiredheading+3))) {
        //reset turn
        turn = false;
        xbeeExplorer.still(msg);
        botT = 1;
        println("turn off");
      }
    }
    float xdistance = targetx - fullblob[0];
    float ydistance = targety - fullblob[1];
    if ((forward == false)&&(turn == false)&&((xdistance<-5)||(xdistance>5)||(ydistance<-5)||(ydistance>5))) {
      forward = true;
      startx = fullblob[0];
      starty = fullblob[1];
      botT = 0;
      println("forward triggered");
    }
    if (forward) {
      println("moving forward");
      xbeeExplorer.forward(msg);
      if (((fullblob[0]-startx)>=xdistance)&&((fullblob[1]-starty)>=ydistance)) {
        println("forward off");
        forward = false;
        xbeeExplorer.still(msg);
        botT = 1;
      }
    }

    //allows messages to be sent continously
    xbeeExplorer.relayMsg(msg);

    if ((fullblob[0]==0)&&(fullblob[1]==0)) {
      xbeeExplorer.still(msg);
      botT = 0;
    }

    /*---------------------------------Drawing Code--------------------------------------------------------------*/
    if ((fullblob[0] != 0)||(fullblob[1] != 0)) {
      stroke(c);
      fill(c);
      ellipse(fullblob[0], fullblob[1], 40, 40);
    }

    fullblob[0]  = 0;
    fullblob[1] = 0;
    lastscratchC = scratchC;
    if (forward==false) {
      lastscratchX = newscratchX;
      lastscratchY = newscratchY;
    }
  }
}

void startServer() throws Exception
{
  Server server = new Server(20807);

  ServletContextHandler context = new ServletContextHandler(ServletContextHandler.SESSIONS);
  context.setContextPath("/"); 
  context.addServlet(new ServletHolder(new PollResponse()), "/poll"); 

  context.addServlet(new ServletHolder(new ScratchPositionResponse()), "/scratchPosition/*"); 
  context.addServlet(new ServletHolder(new ScratchXResponse()), "/scratchX/*"); 
  context.addServlet(new ServletHolder(new ScratchYResponse()), "/scratchY/*"); 
  context.addServlet(new ServletHolder(new ScratchRResponse()), "/scratchR/*"); 
  context.addServlet(new ServletHolder(new ScratchCResponse()), "/scratchC/*"); 
  context.addServlet(new ServletHolder(new ScratchstartResponse()), "/scratchstart/*");
  context.addServlet(new ServletHolder(new ScratchreadyResponse()), "/scratchready/*");
  context.addServlet(new ServletHolder(new botstartResponse()), "/botstart/*");
  ResourceHandler resource_handler = new ResourceHandler();
  resource_handler.setDirectoriesListed(false); 
  resource_handler.setWelcomeFiles(new String[]{ "newhtml.html" }); 
  resource_handler.setResourceBase(sketchPath(".")); 

  HandlerList handlers = new HandlerList();
  handlers.setHandlers(new Handler[] {resource_handler, context, new DefaultHandler() }); 
  server.setHandler(handlers); 

  server.start();
}
/*------------------------------Functions for Warping and transforming perspective(taken from opencv library)-----------------------------------*/
Mat getPerspectiveTransformation(int[][] inputPoints, int w, int h) {
  Point[] canonicalPoints = new Point[4];
  canonicalPoints[0] = new Point(22, 535);
  canonicalPoints[1] = new Point(489, 473);
  canonicalPoints[2] = new Point(578, 45);
  canonicalPoints[3] = new Point(21, 45);

  MatOfPoint2f canonicalMarker = new MatOfPoint2f();
  canonicalMarker.fromArray(canonicalPoints);

  Point[] points = new Point[4];
  for (int i = 0; i < 4; i++) {
    points[i] = new Point(inputPoints[i][0], inputPoints[i][1]);
  }
  MatOfPoint2f marker = new MatOfPoint2f(points);
  return Imgproc.getPerspectiveTransform(marker, canonicalMarker);
}

Mat warpPerspective(int[][] inputPoints, int w, int h) {
  Mat transform = getPerspectiveTransformation(inputPoints, w, h);
  Mat unWarpedMarker = new Mat(w, h, CvType.CV_8UC1);  
  Imgproc.warpPerspective(opencv.getColor(), unWarpedMarker, transform, new Size(w, h));
  return unWarpedMarker;
}


//------------------------------------Function to read camera----------------------------------
void captureEvent(Capture c) {
  c.read();
}
//------------------------------------Function to find centroidx and centroid y and draw blob----------------------------------
void drawBlobs(boolean drawBlobs)
{  

  noFill();
  Blob b;
  int backblobnum = 0;
  frontblobarea = 0;
  backblobarea = 0;
  for (int n=0; n<theBlobDetection.getBlobNb (); n++)
  {

    b=theBlobDetection.getBlob(n);
    fill(0, 255, 0);
    rectMode(CORNER);
    rect(b.xMin*floorWidth, b.yMin*floorHeight, b.w*floorWidth, b.h*floorHeight);
    float barea= b.w*floorWidth*b.h*floorHeight;
    fill(255, 0, 0);
    //ellipse(b.xMin*floorWidth, b.yMin*floorHeight, 5, 5);
    if (b!=null)
    {  
      //goes through the loop and finds the largest blob- this is the back blob
      if (barea>backblobarea) {
        backblobarea = barea;
        //finds x and y coords
        backblob[0] = round(((b.xMin*floorWidth)+(b.w*floorWidth*0.5)));
        backblob[1] = round(((b.yMin*floorHeight)+(b.h*floorHeight*0.5)));
        backblobnum = n;
      }
    }
  }

  //goes through loop and finds second biggest blob - this is front blob
  for (int n=0; n<theBlobDetection.getBlobNb (); n++)
  {
    b=theBlobDetection.getBlob(n);
    if (n!=backblobnum) {

      float farea= b.w*floorWidth*b.h*floorHeight;
      if (b!=null)
      {  //this condition means that the next biggest blob within a 40 pixel radius of the back blob is recorded as the front blob
        if (((round(((b.xMin*floorWidth)+(b.w*floorWidth*0.5)))-backblob[0])<40)&&((round(((b.xMin*floorWidth)+(b.w*floorWidth*0.5)))-backblob[0])>-40)) {
          if (((round(((b.yMin*floorHeight)+(b.h*floorHeight*0.5)))-backblob[1])<40)&&((round(((b.yMin*floorHeight)+(b.h*floorHeight*0.5)))-backblob[1])>-40)) {
            if (farea>frontblobarea) {
              frontblobarea = farea;
              ///finds x and y cooreds
              frontblob[0] = round(((b.xMin*floorWidth)+(b.w*floorWidth*0.5)));
              frontblob[1] = round(((b.yMin*floorHeight)+(b.h*floorHeight*0.5)));
            }
          }
        }
      }
    }
  }
  if ((backblobarea>100)&&(frontblobarea>100)) {

    fullblob[0] = (backblob[0]+frontblob[0])/2;
    fullblob[1] = (backblob[1]+backblob[1])/2;
  } else {
    println("warning, the two blobs are not being detected");
  }
  //uncomment this code to check the front and back blob are being detected correctly - it will draw a green square around the blobs
  rectMode(CENTER);
  stroke(0);
  //fill(255, 0, 0);
  //rect(frontblob[0], frontblob[1], 20, 20);
  //fill(0, 0, 255);
  //rect(backblob[0], backblob[1], 20, 20);
}

//------------------------------------Funtion to refresh screen when mouse pressed----------------------------------
void mousePressed() {
  targetx = mouseX;
  targety = mouseY;
}

//------------------------------------Controls for the cube triggered by keypresses----------------------------------
void keyPressed() { 

  if (keyCode == UP) {
    xbeeExplorer.forward(msg);
  }
  if (keyCode == DOWN) {
    xbeeExplorer.backward(msg);
  }
  if (keyCode == RIGHT) {
    xbeeExplorer.turnright(msg);
  }
  if (keyCode == LEFT) {
    xbeeExplorer.turnleft(msg);
  }
  if (keyCode == SHIFT) {
    xbeeExplorer.still(msg);
  }
  if (key == 'l') {
    xbeeExplorer.lightsoff(msg);
  }
}
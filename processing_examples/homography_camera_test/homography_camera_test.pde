import processing.video.*;
Capture cam;
PImage axes;

void setup() {  
  size(640, 360, P3D);

  ellipseMode(CENTER);
  
  axes = loadImage("axes.png");

  String[] cameras = Capture.list();

  if (cameras == null) {
    println("Failed to retrieve the list of available cameras, will try the default...");
    cam = new Capture(this, 640, 480);
  } 
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println(cameras[i]);
    }

    // The camera can be initialized directly using an element
    // from the array returned by list():
    println("Starting camera 0");
    cam = new Capture(this, cameras[0]);
    // Or, the settings can be defined based on the text in the list
    //cam = new Capture(this, 640, 480, "Built-in iSight", 30);
  }

  // Start capturing the images from the camera
  cam.start();
}

void draw() {
  background(255);
  
  if (cam.available()) {
    cam.read();
  }
  // Check https://processing.org/reference/ in the 'Transform' section for available affine transforms.

  pushMatrix();

  /** /

  resetMatrix();
  
  // apply transforms from the centre of the canvas.
  translate(width * 0.7, height * -0.3);
  
  // Flip the image and scale up
  scale(-1.2, 1.2);
  
  // Rotate in x, y, z.
  rotateX(radians(20));
  rotateY(radians(45));
  rotateZ(radians(5));

  printMatrix();
  /**/  
  
  // I *think* that the above transofrms can also be loaded through the following matrix
  // but if you've already calculated your own homography matrix through matlab then you can 
  // probably load that directly?
  applyMatrix(
    -000.8453,  000.0740, -000.8485,  448.0000,
     000.3874,  001.0980, -000.2902, -108.0000,
    -000.6321,  000.3986,  000.6645,  000.0000,
     000.0000,  000.0000,  000.0000,  001.0000  
  );
  /**/
   
  // Draw the image in the transormed drawing space
  image(cam, 0, 0, width, height);
//  ellipse(0, 0, 100, 100);

  popMatrix();
  
  image(axes, width - axes.width, height - axes.height); 

}
// ==========================================================
// STATIC VARIABLES

int canvasWidth = 1920;
int canvasHeight = 1080;

PImage bgImg;
PImage figureImg;
String figureImgFile;

int figureWidth;
int figureHeight;

int positionX;
int positionY;
float rotation;

// counter vars
int frameCounter = 1;
int thisShape = 1;
int thisIntroStep = 0;
int thisRhythmStep = 0;
int thisBg;

// array for shape list (to enable shuffling)
IntList shapeList;
int shapeListItem;
String introStepsItem;






// ==========================================================
// SETTINGS

// adjusts the size to test at reasonable speeds
boolean isHD = true;

// saves each frame as a PNG image
boolean isRendering = true;

// determines the function of the application
// "shapes" renders flickering shapes
// "intro" renders intro screens (label, title, etc)
String mode = "shapes";

// IMPORTANT number of files in the /bg folder
int bgCount = 14;

// IMPORTANT number of files in the /shape folder
int shapeCount = 35;

// determines the flickering/jittering amount
int positionVariance = 2; // even number!
float rotationVariance = 1; // even number!

// number of frames per shape
int framesPerShape = 6;
int framesPerBeat = 3;

//int fps = 9;
int[] rhythmSteps = {1,1,1,2,1,2,1,2};
int[] rhythmFrames = rhythmSteps;


// intro step durations in seconds
//int[] introDurations = {
//  1,
//  1,
//  1,
//  1,
//  1,
//  1,
//  1,
//  1
//};

String[] introSteps = {
  "blank",
  "label-logo",
  "blank",
  "artist",
  "album-title",
  "release-date",
  "blank",
  "title--cracker",
  "blank"
};



// ==========================================================
// SETTINGS & SETUP

void settings(){
  if (isHD == false) {
    canvasWidth = canvasWidth / 2;
    canvasHeight = canvasHeight / 2;
    positionVariance = positionVariance / 2;
    rotationVariance = rotationVariance / 2;    
  }
  
  size(canvasWidth, canvasHeight);
}




void setup(){
  background(#000000);
 
  // determine the runtime frame rate depending on settings...
  if (isRendering == true) { // slow down for rendering
    if (isHD == true) {
      frameRate(.2); // very slow for big images
    } else {
      frameRate(.5); // moderate for draft images
    }
  } else {
    frameRate(4); // sketching
  }

  // setup actions for "shapes" mode
  if (mode == "shapes") {
    // build shape list based on shape count
    shapeList = new IntList();
    for (int i = 0; i < shapeCount; i++){
      shapeList.append(i+1);
    }
    
    // shuffle the list
    shapeList.shuffle();
    
    // convert rhythmSteps array (beats) into frame counts
    for(int i = 0; i < rhythmSteps.length; i++) {
      int frames = rhythmSteps[i] * framesPerBeat;
      rhythmFrames[i] = frames;
    }
  }
  
  println("rhythmSteps");
  printArray(rhythmSteps);
  println("rhythmFrames");
  printArray(rhythmFrames);
  
  // setup actions for "intro" mode
  if (mode == "intro") {
    println("intro mode");
    
    // convert intro durations array (seconds) into frame counts
    //for(int i = 0; i < introDurations.length; i++) {
    //  int frames = introDurations[i] * fps;
    //  introDurations[i] = frames;
    //}
    
  }
}



// ==========================================================
// Generic functions

// get a background image
void getBg() {
  // choose a random background
  thisBg = randomInteger(1, bgCount);

  // build the file path
  String bgImgFile = "_source/bg/"+nf(thisBg, 2)+".png";
  
  // load the image
  bgImg = loadImage(bgImgFile);
}

void getFigure() {

  // if "shapes" mode, use the shapes list to find the right image
  if (mode == "shapes") {
    // get respective item from list (shuffled)
    shapeListItem = shapeList.get(thisShape - 1); // -1 because it's a 0-based array list
    
    // build the image path
    figureImgFile = "_source/shape/"+nf(shapeListItem, 2)+".png";
  }
  
  // if "intro" mode...
  if (mode == "intro") {
    introStepsItem = introSteps[thisIntroStep];
    figureImgFile = "_source/intro/"+introStepsItem+".png";
  }

  // load the images file
  figureImg = loadImage(figureImgFile);
 
  // get width and height of loaded image
  figureWidth = figureImg.width;
  figureHeight = figureImg.height;
  
  // adjust size based on settings
  if (isHD == false) {
    figureWidth = figureWidth / 2;
    figureHeight = figureHeight / 2;
  }
}

// set initial position and rotation of image
void setFigureParams() { 
  positionX = (canvasWidth / 2) - (figureWidth / 2);
  positionY = (canvasHeight / 2) - (figureHeight / 2);
  
  rotation = randomFloat(0, 1);
}

// adjust position and rotation of current image
void adjustFigureParams() {
  int adjustX = randomInteger(0 - positionVariance - 1, positionVariance);
  int adjustY = randomInteger(0 - positionVariance - 1, positionVariance);
  // the -1 corrects a positive weighting i don't understand (-variance never occurs)
  
  positionX = positionX + adjustX;
  positionY = positionY + adjustY;
  
  float adjustRotation = randomFloat(0 - rotationVariance, rotationVariance);
  // -1 same
  
  rotation = rotation + adjustRotation;
}



// ==========================================================
// Functions for SHAPES mode

// This function mimics the default draw() function, for the "shapes" mode
void drawShapeFrame(){  
  // get a background image
  getBg();
  image(bgImg, 0, 0, canvasWidth, canvasHeight);
  
  // get a shape
  getFigure();
  
  println(
    "index:", thisShape,
    "  shape:", shapeListItem,
    "  frame", frameCounter,
    " thisRhythmStep", thisRhythmStep,
    " rhythmFrames", rhythmFrames[thisRhythmStep]);
  
  if (frameCounter == 1) {
    setFigureParams();
  } else {
    adjustFigureParams();
  }
  
  rotate(radians(rotation));  
  image(figureImg, positionX, positionY, figureWidth, figureHeight);
  
  if (isRendering == true) {
    saveFrame("_render/"+nf(thisShape, 2)+"-"+nf(frameCounter, 2)+".png");
  }
  
  // update counters
  if (frameCounter == rhythmFrames[thisRhythmStep]) {
    thisShape++;
    frameCounter = 1;
    
    // check for last rhythm step
    if (thisRhythmStep == rhythmFrames.length - 1) {
      thisRhythmStep = 0;
    } else {
      thisRhythmStep++;
    }
    
  } else {
    frameCounter ++;
  }
  
  // exit if at end of list
  if (thisShape > shapeCount) {
    println("exit");
    exit();
  }
}




// ==========================================================
// Functions for INTRO mode

// This function mimics the default draw() function, for the "intro" mode
void drawIntroFrame(){
  
  // get a background image
  getBg();
  image(bgImg, 0, 0, canvasWidth, canvasHeight);
  
  // get an intro step
  getFigure();
  
  println("thisIntroStep:", thisIntroStep, "  item:", introStepsItem, "  frame", frameCounter);
  
  if (frameCounter == 1) {
    setFigureParams();
  } else {
    adjustFigureParams();
  }
  
  rotate(radians(rotation));  
  image(figureImg, positionX, positionY, figureWidth, figureHeight);
  
  if (isRendering == true) {
    saveFrame("_render/"+nf(thisIntroStep, 2)+"-"+nf(frameCounter, 2)+".png");
  }
  
  // update counters
  if (frameCounter == framesPerShape) {
    thisIntroStep++;
    frameCounter = 1;
  } else {
    frameCounter ++;
  }
  
  // exit if at end of intro steps
  if (thisIntroStep == introSteps.length) {
    println("exit");
    exit();
  }
}





// ==========================================================
// Draw functions
void draw() {
  if (mode == "shapes") {
    drawShapeFrame();
  }
  
  if (mode == "intro") {
    drawIntroFrame();
  }
}






// ==========================================================
// handle key press events
void keyPressed() {
  // println(keyCode);
  
  // space bar : reset position and rotation
  if (keyCode == 32) {
    redraw();
  }
  
  // p : export image
  if (keyCode == 80) {    
    saveFrame(getTimestamp()+".png");
  }
}







// ==========================================================
// UTILITIES

// function: generates a random integer
int randomInteger(int min, int max){
  int ri = int(random(min, max+1));
  return ri;
}

// function: generates a random float number
float randomFloat(float min, float max){
  float rf = random(min, max);
  return rf;
}

// function: generates a random boolean
boolean randomBoolean(){
  int ri = int(random(2));
  if (ri == 1) {
    return true;
  }
  return false;
}

// function: generates a random positive|negative multiplier
int randomPlusOrMinus(){
  int rm = int(random(2))*2-1;
  return rm;
}

// function: generates a timestamp string
String getTimestamp(){
  String y = nf(year(), 4);
  String m = nf(month(), 2);
  String d = nf(day(), 2);
  String h = nf(hour(), 2);
  String mm = nf(minute(), 2);
  String s = nf(second(), 2);
  
  String timestamp = y+m+d+h+mm+s;
  return timestamp;
}

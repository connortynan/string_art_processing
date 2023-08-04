
static int nodes = 240;
static float stringWeight = 0.05;
static int max_strings = 2000;

PGraphics model, drawing;
IntList[] strings = new IntList[nodes];
IntList order = new IntList();
double current_difference = Double.POSITIVE_INFINITY;

void setup() {
  size(800, 400);
  frameRate(120);
  model = createGraphics(height, height);
  drawing = createGraphics(height, height);

  colorMode(RGB, 1.0);

  int first_node = int(random(nodes)); //randomly pick the starting node
  order.append(first_node);

  for (int i = 0; i < nodes; i++) {
    strings[i] = new IntList();
  }

  PImage img, circle_mask;

  img = loadImage("eye.png");
  //img = loadImage("among_us.png");



  circle_mask = loadImage("circle_mask.png");
  circle_mask.resize(img.width, img.height);
  img.mask(circle_mask);
  model.beginDraw();
  model.colorMode(RGB, 1.0);
  model.background(1);
  model.image(img, 0, 0, model.width, model.height);
  model.filter(GRAY);
  model.endDraw();

  drawing.beginDraw();
  drawing.colorMode(RGB, 1.0);
  drawing.endDraw();
}

void draw() {
  background(1);
  image(model, 0, 0, model.width, model.height);
  image(drawing, width*0.5, 0, drawing.width, drawing.height);
  
  int next_node = getNextString();
  if (next_node != -1 && order.size() < max_strings) {
    addNode(next_node);
  } else {
    noLoop();
    println("DONE!");
    println(order);
    save("output.png");
  }
  drawModel();
}

void drawModel() {
  drawing.beginDraw();
  drawing.background(1);
  drawing.stroke(0);
  drawing.strokeWeight(5);
  for (int i = 0; i < nodes; i++) {
    PVector node_point = nodeToVect(i);
    drawing.point(node_point.x, node_point.y);
  }

  for (int i = 0; i < order.size()-1; i++) {
    drawString(order.get(i), order.get(i+1));
  }
  drawing.endDraw();
}

int getNextString() {

  int last_node = order.get(order.size()-1);
  double min_difference = current_difference;
  int best_node = -1;

  PGraphics current_drawing = createGraphics(drawing.width, drawing.height);
  drawModel();
  current_drawing.beginDraw();
  current_drawing.image(drawing, 0, 0);
  current_drawing.endDraw();

  for (int i = 0; i < nodes; i++) {
    if (i != last_node && !strings[last_node].hasValue(i)) {
      drawing.beginDraw();
      drawing.image(current_drawing, 0, 0);
      drawString(last_node, i);
      drawing.endDraw();

      double difference = colorDifference();
      if (difference < min_difference) {
        min_difference = difference;
        best_node = i;
      }
    }
  }

  current_difference = min_difference;
  return best_node;
}

double colorDifference() {
  model.loadPixels();
  drawing.loadPixels();

  double difference = 0;
  for (int i = 0; i < model.width*model.height; i++) {
    //println((brightness(model.pixels[i]) - brightness(drawing.pixels[i]))*(brightness(model.pixels[i]) - brightness(drawing.pixels[i])));
    difference += (brightness(model.pixels[i]) - brightness(drawing.pixels[i]))*(brightness(model.pixels[i]) - brightness(drawing.pixels[i]));
  }

  return difference;
}

void drawString(int n1, int n2) {
  drawing.strokeWeight(stringWeight);
  PVector n1_point = nodeToVect(n1);
  PVector n2_point = nodeToVect(n2);
  drawing.line(n1_point.x, n1_point.y, n2_point.x, n2_point.y);
}

PVector nodeToVect(int n) {
  return new PVector(drawing.width*0.5 + drawing.width*0.5*cos(2*PI*n/nodes), drawing.height*0.5 + drawing.width*0.5*sin(2*PI*n/nodes));
}

void addNode(int n) {
  int last_node = order.get(order.size()-1);

  strings[last_node].append(n);
  strings[n].append(last_node);

  order.append(n);
}

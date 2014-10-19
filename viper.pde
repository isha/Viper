import java.util.Map;
import java.util.Hashtable;

// Note the HashMap's "key" is a String and "value" is an Integer
HashMap<String,String> instr = new HashMap<String,String>();

// Image list
Hashtable<Integer, PImage> images = new Hashtable<Integer, PImage>();
Integer imagesCount;

void setup() {
  size(1000, 600);
  imagesCount = 0;

  // Putting key-value pairs in the HashMap
  instr.put("Method", "create");
  instr.put("Image", "snowball.jpg");
  instr.put("PositionX", "35");
  instr.put("PositionY", "36");
}

void draw() {
  if (instr.get("Method") == "create") {
    PImage img = loadImage(instr.get("Image"));

    images.put(imagesCount, img);
    imagesCount++;

    image(img, Integer.parseInt(instr.get("PositionX")), Integer.parseInt(instr.get("PositionY")), img.width, img.height);
  }
  else if (instr.get("Method") == "update") {

  }
  else if (instr.get("Method") == "delete") {

  }
}

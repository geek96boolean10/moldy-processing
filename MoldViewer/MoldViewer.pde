import java.util.*;
import java.math.*;
import java.text.*;
import java.io.*;

boolean LOAD_LOCAL = true; // true if file is in sketch directory; otherwise reads as absolute
String LOAD_FILE = "autosave.mold";
boolean ALLOW_GREEN = false;
int Scale = 20;
float Inflate = 1.2; // ratio of rendered size to actual size of cells (may overlap!)

Hashtable<String, Cell> Cells = new Hashtable();
int[] BOUNDS = {-5,-5,5,5};
float GlobalKnownMax = 0; 

PGraphics render;

int[] StrArr(String str)
{
  if (str.endsWith(",")) str = str.substring(0, str.length() - 1);
  String[] s = str.split(",");
  int[] a = new int[s.length];
  for (int i = 0; i < a.length; i++)
  {
    a[i] = Integer.parseInt(s[i]);
  }
  return a;
}

String ArrStr(int[] arr)
{
  String s = "";
  for (int i : arr) s += i + ",";
  return s;
}

void importFile(String fromFile)
{
  Cells.clear();
  try
  {
    FileReader fileReader = 
                new FileReader(fromFile);

    // Always wrap FileReader in BufferedReader.
    BufferedReader bufferedReader = 
        new BufferedReader(fileReader);
    String line = null;
    while((line = bufferedReader.readLine()) != null) {
        // each line indicates a cell
        String[] split = line.split(",");
        Cell n = new Cell(true);
        
        n.Position = StrArr(split[1] + "," + split[2]);
        n.Energy = parseFloat(split[3]);
        n.Excitability = parseFloat(split[4]);
        n.Excitement = parseFloat(split[5]);
        n.Insulation = parseFloat(split[6]);
        n.dist = parseFloat(split[7]);
        n.isChosen = parseBoolean(split[8]);
        n.isNew = parseBoolean(split[9]);
        n.ticker = parseInt(split[10]);
        
        if (split[0].equals("c"))
        {
          Cells.put(ArrStr(n.Position), n);
        }
        else if (split[0].equals("q"))
        {
          // skip Qd cells
        }
        else
        {
          println("Bad key [" + split[0] + "]; Unrecognized line: " + line);
        }
    }   
    bufferedReader.close();     
    println("File successfully loaded: " + fromFile);    
  } catch (Exception ex)
  {
    println("[ ! ] Couldn't load file: " + fromFile);
  }
}

void setup()
{
  //println("...");
  size(200, 200);
  
  if (LOAD_LOCAL) LOAD_FILE = sketchPath() + "\\" + LOAD_FILE;
  
  calculate();
  
  //println("Generating canvas...");
  render = createGraphics(int(1.1 * Scale * (2*Math.max(BOUNDS[2], abs(BOUNDS[0])))), //<>//
                          int(1.1 * Scale * (2*Math.max(BOUNDS[3], abs(BOUNDS[1])))));
  
}

void calculate()
{
  importFile(LOAD_FILE);
  println("Calculating bounds over " + Cells.size() + " cells...");
  
  for (Cell c : Cells.values())
  {
    int[] atPos = c.Position;
    if (atPos[0] < BOUNDS[0]) BOUNDS[0] = atPos[0];
    if (atPos[1] < BOUNDS[1]) BOUNDS[1] = atPos[1];
    if (atPos[0] > BOUNDS[2]) BOUNDS[2] = atPos[0];
    if (atPos[1] > BOUNDS[3]) BOUNDS[3] = atPos[1];
    GlobalKnownMax = c.Energy > GlobalKnownMax ? c.Energy : GlobalKnownMax;
  }
  println("Bounds: " + ArrStr(BOUNDS));   
}

void start()
{
  
}

void draw()
{
  noLoop();
  render.rectMode(CORNER);
  render.ellipseMode(RADIUS);
  println("Painting...");    
  render.beginDraw();
  render.background(0);
  noStroke();
  for (Cell c : Cells.values())
  {
    int x = c.Position[0], y = c.Position[1];
    int R,G,B;
    G = (int)(50 * (c.Energy / GlobalKnownMax));
    R = 50 + (int)(map(c.Excitability, Cell.OFF_EXCITE, Cell.OFF_EXCITE + Cell.MAX_EXCITE, 0, 50)) + G;
    B = 50 + (int)(map(c.Insulation, Cell.OFF_INSULA, Cell.OFF_INSULA + Cell.MAX_INSULA, 0, 50)) + G;
    G = ALLOW_GREEN ? 50 + (int)(154 * (c.Energy / GlobalKnownMax)) : 50;
    render.fill(R, G, B);
    //float o = c.isChosen ? .01 * Scale : (.37 * Scale)*pow(1 - c.Energy / GlobalKnownMax, 10); // this enables chosens to remain large
    float o = 0.05 * Scale + (.37 * Scale)*pow(1 - c.Energy / GlobalKnownMax, 5); // make all pulse with energy
    render.rect((x-.5* Inflate) * Scale + render.width/2 + o, (y-.5 * Inflate ) * Scale + render.height/2 + o, Inflate * Scale-2*o, Inflate * Scale-2*o);
  }
  render.endDraw();
  println("... done!");
  println("Saving...");
  render.save(LOAD_FILE + ".render.png");
  println("... done!");
}

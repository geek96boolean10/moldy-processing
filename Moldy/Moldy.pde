import java.util.*;
import java.math.*;
import java.text.*;
import java.io.*;

Hashtable<String, Cell> Cells = new Hashtable();
ArrayList<Cell> Q = new ArrayList();
int[] BOUNDS = {-5,-5,5,5};
Random R = new Random();

boolean force_crash = false;

float LIVING_TOL = .00000001;           // Minimum amount of energy to remain alive
int FRAME_SKIP = 5;                     // number of loops to skip before drawing
boolean ALLOW_GREEN = true;             // use green to indicate energy, not just size (disable for better view of cell properties)

boolean LOAD = true;                    // determines whether to start this from a loaded file; if true, file will also be saved to the loaded location. if not found, starts a new file with this name.
String LOAD_FILE = "moldy01.mold";      // if LOAD is true, loads this file at startup instead of starting anew. resetting will reload the file.

boolean HEADLESS = false;               // headless-mode disables rendering altogether; useful for running at max speed. cannot be toggled.
String HEADLESS_ARGS = "10000,false,autorun";   // arguments that describe how the mode runs. { [int] RunsBetweenSaves , [bool] IncrementSaveFile , [str] BaseFileName }

Cell ORIGIN;

final int FPS = 60;
String timeStamp = new SimpleDateFormat("yyyyMMdd-HHmmss").format(Calendar.getInstance().getTime());

void setup()
{
  size(800, 600, P2D);
  frameRate(FPS);
}

void start()
{
  if (LOAD)
  {
    println("Load enabled!");
    File f = new File(LOAD_FILE);
    if(!f.exists())
    {
      println("File not found to be loaded;  creating one.");
      resetORIGIN();
      exportFile(LOAD_FILE); // creates a file to write to
    }
    else
    {
      importFile(LOAD_FILE); // loads a preexisting file
    }
    f = new File(LOAD_FILE);
    println("Home file: " + f.getAbsolutePath());
  } 
  else
  {
    resetORIGIN();
  }
}

void resetORIGIN()
{
  Spawn(new int[]{0,0}, 0);
  Cell i = Q.get(0);
  i.Insulation = 1;
  i.Energy = 10;
  i.Excitability = 1;
  i.isChosen = true;
  ORIGIN = i;
}

float GlobalKnownMax = 0.0000000001;
float GlobalEnergy = 0;
int loop = 0;
float Scale = 1;
void draw()
{
  noStroke();
  rectMode(CORNER);
  ellipseMode(CORNER);
  fill(0,0,0,10);
  rect(0,0,width,height);
  Scale = .9 * Math.min((int)(width / (2*Math.max(BOUNDS[2], BOUNDS[0]))), (int)(height / (2*Math.max(BOUNDS[3], BOUNDS[1]))));
  
  runBatch(); // runs as many frameskips between draws
  
  // allow draw
  // Third round, draw all Cells
  for (int x = BOUNDS[0]; x <= BOUNDS[2]; x++)
  {
    for (int y = BOUNDS[1]; y <= BOUNDS[3]; y++)
    {
      if (Cells.containsKey(ArrStr((new int[]{x, y}))))
      {
        Cell c = Cells.get(ArrStr(new int[]{x, y}));
        int R,G,B;
        G = (int)(50 * (c.Energy / GlobalKnownMax));
        R = 50 + (int)(map(c.Excitability, Cell.OFF_EXCITE, Cell.OFF_EXCITE + Cell.MAX_EXCITE, 0, 50)) + G;
        B = 50 + (int)(map(c.Insulation, Cell.OFF_INSULA, Cell.OFF_INSULA + Cell.MAX_INSULA, 0, 50)) + G;
        G = ALLOW_GREEN ? 50 + (int)(154 * (c.Energy / GlobalKnownMax)) : 50;
        fill(R, G, B);
        //float o = c.isChosen ? .01 * Scale : (.37 * Scale)*pow(1 - c.Energy / GlobalKnownMax, 10); // this enables chosens to remain large
        float o = 0.05 * Scale + (.37 * Scale)*pow(1 - c.Energy / GlobalKnownMax, 5); // make all pulse with energy
        if (!c.isChosen) rect((x-.5) * Scale + width/2 + o, (y-.5) * Scale + height/2 + o, Scale-2*o, Scale-2*o);
        else          ellipse((x-.5) * Scale + width/2 + o, (y-.5) * Scale + height/2 + o, Scale-2*o, Scale-2*o);
      } else {
        
      }
    }
  }
}

void runBatch()
{
  for (int i = 0; i < FRAME_SKIP; i++)
  {
    try
    {
      execute();
    }
    catch (Exception e)
    {
      // if something bad happens, dump the data
      timeStamp = new SimpleDateFormat("yyyyMMdd-HHmmss").format(Calendar.getInstance().getTime());
      exportFile("crashdump-" + timeStamp + ".mold");
      println("CRASHED! " + timeStamp);
      fill(100,0,0,255);
      if (!HEADLESS) rect(0,0,width,height);
      i = FRAME_SKIP;
      noLoop();
    }
  }
}

void execute() throws Exception
{
  //println(Cells.size());
  //
  //clear();
  //background(0);
  float KnownMax = .0000001;
  GlobalKnownMax -= .0000001;
  
  if (force_crash) throw new Exception("Forcing crash...");
  
  // First round, let all Cells radiate and know their new energy without affecting their actual energy
  for (Cell c : Cells.values())
  {
    //println("foundkey:" + (ArrStr(new int[]{x, y})));
    Tick(c);
    KnownMax = c.Energy > KnownMax ? c.Energy : KnownMax;
  }
  
  GlobalKnownMax = KnownMax > GlobalKnownMax ? KnownMax : GlobalKnownMax;
  
  // Second round, let all Cells update their actual energy to their new energy
  for (Cell c : Cells.values())
  {
    c.Progress(R);
    GlobalEnergy += c.Energy;
    if (c.Energy < LIVING_TOL && !c.isChosen)
    {
      c.Energy = 0;
      Q.add(c);
    }
  }
  
  for (Cell q : Q)
  {
    if (q.Energy <= LIVING_TOL && !q.isNew) // essentially dead
    {
      if (Cells.containsKey(ArrStr(q.Position))) Cells.remove(ArrStr(q.Position));
    }
    else // they are new spawn
    {
      Cells.put(ArrStr(q.Position), q);
    }
  }
  
  Q.clear();
  //println("max energy: " + KnownMax);
  if (++loop >= FPS * FRAME_SKIP)
  { 
    loop = 0;
    println("Global Energy: " + GlobalEnergy + ";  Density: " + GlobalEnergy / Cells.size());
  }
  GlobalEnergy = 0;
}

void keyPressed()
{
  switch (key)
  {
    case ('r'):
      Cells.clear();
      Q.clear();
      if (LOAD)
      {
        importFile(LOAD_FILE);
      }
      else
      {
        resetORIGIN();
      }
      BOUNDS = new int[]{-5,-5,5,5};
      break;
    case ('b'):
      for (Cell c : Cells.values())
      {
        int[] atPos = c.Position;
        if (atPos[0] < BOUNDS[0]) BOUNDS[0] = atPos[0];
        if (atPos[1] < BOUNDS[1]) BOUNDS[1] = atPos[1];
        if (atPos[0] > BOUNDS[2]) BOUNDS[2] = atPos[0];
        if (atPos[1] > BOUNDS[3]) BOUNDS[3] = atPos[1];
      }
      break;
    case ('g'):
      ALLOW_GREEN = !ALLOW_GREEN;
      break;
    case ('s'):
      // saves the file
      if (LOAD)
      {
        exportFile(LOAD_FILE);
      }
      else
      {
        exportFile("moldy-" + timeStamp + ".moldy");
      }
      break;
    case ('!'):
      force_crash = true;
      break;
  }
  if (isNumber(key))
  {
    FRAME_SKIP = Integer.parseInt(""+key);
  }
}

void Spawn(int[] atPos, float grant)
{
  Cell c = new Cell(R, atPos);
  c.Excite(grant);
  if (atPos[0] < BOUNDS[0]) BOUNDS[0] = atPos[0];
  if (atPos[1] < BOUNDS[1]) BOUNDS[1] = atPos[1];
  if (atPos[0] > BOUNDS[2]) BOUNDS[2] = atPos[0];
  if (atPos[1] > BOUNDS[3]) BOUNDS[3] = atPos[1];
  //Cells.put(ArrStr(atPos), c);
  Q.add(c);
  //println("newcell @ " + ArrStr(atPos) + " : " + ArrStr(c.Position));
}

void Tick(Cell c)
{
  if (c.isNew) return; // new cells should not radiate.
  
  float EnergyPer = c.Radiate();
  int[][] poss = {
                  {c.Position[0]+1, c.Position[1]},
                  {c.Position[0]-1, c.Position[1]},
                  {c.Position[0], c.Position[1]+1},
                  {c.Position[0], c.Position[1]-1}
                };
  for (int i = 0; i < 4; i++)
  {
    if (!Cells.containsKey(ArrStr(poss[i])))
    {
      Spawn(poss[i], EnergyPer / 3); // lose energy during creation
    } else {
      Cell d = Cells.get(ArrStr(poss[i]));
      d.Excite(EnergyPer);
    }
  }
  
}

String ArrStr(int[] arr)
{
  String s = "";
  for (int i : arr) s += i + ",";
  return s;
}

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

final char[] ints = {'1','2','3','4','5','6','7','8','9','0'};
boolean isNumber(char c)
{
  return (new String(ints)).contains(""+c);
}

void exportFile(String toFile)
{
  try
  {
    PrintWriter writer = new PrintWriter(toFile, "utf-8");
    for (Cell c : Cells.values())
    {
      writer.println("c," + ArrStr(c.Position) + c.Energy + "," + c.Excitability + "," + c.Excitement + "," + c.Insulation + "," + c.dist + "," + c.isChosen + "," + c.isNew + "," + c.ticker);
    }
    for (Cell c : Q)
    {
      //              0             1, 2           3                4                      5                    6                    7              8                  9               10
      writer.println("q," + ArrStr(c.Position) + c.Energy + "," + c.Excitability + "," + c.Excitement + "," + c.Insulation + "," + c.dist + "," + c.isChosen + "," + c.isNew + "," + c.ticker);
    }
    writer.close();
    println("File successfully saved: " + toFile);
  } catch (Exception ex)
  {
    println("[ ! ] Couldn't save file: " + toFile);
  }
}

void importFile(String fromFile)
{
  Cells.clear();
  Q.clear();
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
          if (ArrStr(n.Position) == ArrStr(new int[]{0,0})) ORIGIN = n;
          Cells.put(ArrStr(n.Position), n);
        }
        else if (split[0].equals("q"))
        {
          Q.add(n);
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

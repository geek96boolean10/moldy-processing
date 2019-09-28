class Cell
{
  public static final float MAX_EXCITE = 1;    // Maximum range of Excitability
  public static final float OFF_EXCITE = 0.1;  // Excitability offset from 0
  public static final float MAX_INSULA = 1;    // Maximum range of Insulation
  public static final float OFF_INSULA = 1;  // Insulation offset from 0
  public static final float MAX_RADIAT = 0.6;  // Maximum percent of energy allowed to Radiate
  public static final float MIN_RADIAT = .4;    // Minimum ratio of energy per allowed Radiation
  public float Energy = 0;
  public int[] Position = {0,0};
  public boolean isNew = true;
  public boolean isChosen = false;
  float dist;
  public PVector PV()
  {
    return new PVector(Position[0], Position[1]);
  }
  
  public Cell(boolean eh)
  {
    // non-standard constructor used to intialize an empty cell; used when loading.
  }
  
  public Cell(Random r, int[] pos)
  {
    Excitability = MAX_EXCITE - MAX_EXCITE * sqrt(r.nextFloat()) + OFF_EXCITE;
    Insulation = r.nextFloat() * MAX_INSULA + OFF_INSULA;
    Position = pos;
    dist = 2* PVector.dist(PV(), new PVector(0,0)) + 1;
    if (r.nextInt(1000000) == 0)
    {
      isChosen = true;
      Energy = 10;
      isNew = false;
    }
  }
  
  public float Excitability = 1;
  public float Excitement = 0;
  public void Excite(float energy) // Lets the cell know they will have more energy
  {
    if (isChosen)   Excitement += energy * 0 * Excitability;
    else    Excitement += energy * Excitability;
  }
  
  public float Insulation = 1;
  public float Radiate() // Determines the amount of energy neighboring cells will get and decreases this cell's energy
  {
    float Rad = Energy * MAX_RADIAT / Insulation ;
    // no or little radiation means no new cells; cells store up
    if (!isChosen && Rad < pow(dist,4) * MIN_RADIAT) Rad = 0;
    else if (isChosen && Rad < MIN_RADIAT) Rad = 0;
    Energy -= Rad;
    return Rad / 4;
  }
  
  int ticker = 0;
  
  public void Progress(Random r) // Allows the cell to absorb the new energy
  {
    Energy += Excitement;
    Excitement = 0;
    isNew = false; // this is no longer a new cell by this point.
    
    if (isChosen && ++ticker >= FPS) { ticker = 0; Energy += 50; } // if isChosen, this can generate pulses
    
    Energy -= 0.00001 * Energy * pow(dist,1.2) ; // living tax; the further from home, the more expensive
    Energy -= 0.00005 * Excitability;            // living tax; the more excitable, the more expensive
    if (Energy < 0) Energy = 0; // no negatives.
    
    // use distance and excitability to determine if they can initiate a pulse
    if (!isChosen)
    {
      float joy = r.nextFloat() * Excitability * 10000;
      if (joy <= Excitability) Energy += r.nextFloat() * Excitability * 10;
    }
  }
}

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
  public float Excitability = 1;
  public float Excitement = 0;
  public float Insulation = 1;
  int ticker = 0;
  
  public Cell(boolean eh)
  {
    // non-standard constructor used to intialize an empty cell; used when loading.
  }
  
}

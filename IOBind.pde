class InputOutputBind implements AudioSignal, AudioListener
{
  float[] leftChannel ;
  private float[] rightChannel;
  private int count, old, now;
  
 InputOutputBind(int sample)
  {
    leftChannel = new float[sample];
    rightChannel= new float[sample];
  }
  
  // This part is implementing AudioSignal interface, see Minim reference
  void generate(float[] samp)
  {
     if(old == now) {
         for(int i = 0; i < samp.length; i++) {
             samp[i] = 0;
         }
     } else {
         for(int i = 0; i < samp.length; i++) {
             samp[i] = leftChannel[i];
         }
     }
  }
  void generate(float[] left, float[] right)
  {
      
     //arraycopy(leftChannel,left);
     old = now;
  }
  
 // This part is implementing AudioListener interface, see Minim reference
  void samples(float[] samp)
  {
     leftChannel[0] = samp[0];
         for(int i = 1; i < samp.length-1; i++) {
             leftChannel[i] = samp[i]*4; //(samp[i-1]+samp[i]+samp[i+1])/3*4;
         }
     now = ++count;
  }
  void samples(float[] sampL, float[] sampR)
  {
  }  
} 

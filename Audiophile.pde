import ddf.minim.spi.*;
import ddf.minim.signals.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;
import java.util.ArrayList;

TweenManager tm;
AudioInput in;
Minim minim;
InputOutputBind iobuf;
FFT fft;
SmartColor warm = new SmartColor(255,0,0); //the warm color starts as pure red
SmartColor cold = new SmartColor(0,0,255); //the cold color starts as pure blue
SmartColor background;
BeatDetect beats;

SmartColor rgb(int r, int g, int b) {
    return new SmartColor(r,g,b);
}

//Special thanks to the XKCD color survey
//for providing the really nice pleasing colors
SmartColor[] warmColors = {
    rgb(254, 66, 15),
<<<<<<< HEAD
    rgb(175, 47, 13),
    rgb(169, 3, 8)
=======
    rgb(255,0,0)
>>>>>>> 23265a4a8414e6fb9133053bdfedeb282d35006e
};

SmartColor[] coldColors = {
    rgb(177, 209, 252),
    rgb(62, 130, 252),
    rgb(61, 122, 253),
    rgb(115, 133, 149)
};

ArrayList<Float> immediatePower;
ArrayList<Float> powerFrame;
ArrayList<Float> immediateMood;
ArrayList<Float> moodFrame;
ArrayList<ComplexBubble> bigbubbles;
ArrayList<SimpleBubble> regbubbles;
float cbg = 255/2;
float cwt = 0;
float[] lastF;
boolean kick,snare,hat;
final int IMMEDIATE_SIZE = 8;
final int FRAME_SIZE = 8;
final int MAX_CBUBBLES = 25;
final int MAX_SBUBBLES = 150;

void setup() {
    size(800,700);
    tm = new TweenManager();
    minim = new Minim(this);
    int size = 1024*2; //size picked based on the highly scientific efforts of GUESS and CHECK.
    in = minim.getLineIn(Minim.MONO, size);
    iobuf = new InputOutputBind(size);
    in.addListener(iobuf);
    fft = new FFT(size, 44100);
    fft.noAverages();
    
    //set up all the historical data tracking structures
    immediatePower = new ArrayList<Float>(IMMEDIATE_SIZE);
    immediateMood = new ArrayList<Float>(IMMEDIATE_SIZE);
    moodFrame = new ArrayList<Float>(FRAME_SIZE);
    powerFrame = new ArrayList<Float>(FRAME_SIZE);
    //and one drawing structure
    bigbubbles = new ArrayList<ComplexBubble>(MAX_CBUBBLES);
    regbubbles = new ArrayList<SimpleBubble>(MAX_SBUBBLES);
    beats = new BeatDetect(size, 44100);
    textAlign(LEFT, CENTER);
}

void draw() {
    tm.update(.003);
    //grab the current sound buffer out of the left [mono] channel
    float[] left = iobuf.leftChannel;
    beats.detect(left);
    kick = beats.isKick();
    snare = beats.isSnare();
    hat = beats.isHat();
    //compute an FFT on that buffer
    fft.forward(left);
    stroke(255,0,0);
    //don't store spec bigger than we have screen space
    float[] spec = new float[min(width,fft.specSize())];
    float[] wspec = new float[spec.length];
    float avg = 0; //avg: the average power of the whole FFT
    float max = 0; //max; the max power of the whole FFT
    for(int i = 0; i < 3; i++) {
        spec[i] = fft.getBand(i);
        //wspec is a weighted version, which is more visually appealing because
        //it filters the lower end of the spectrum. In addition to being more appealing,
        //though, it also seems to be easier to take Yellow values from.
        wspec[i] = (spec[i]*31)*(constrain((float)Math.sqrt(i/40.)/4, 0, .5));
    }
    for(int i = 3; i < spec.length-3; i++) {
        //pre-smoothing.
        spec[i]= fft.getBand(i-1) + fft.getBand(i-2) + fft.getBand(i-3) + fft.getBand(i) + fft.getBand(i+1) + fft.getBand(i+2) + fft.getBand(i+3);
        spec[i] /= 7; //take the average of five neighbors.
        avg += spec[i]; //track max, avg
        max = (max > spec[i]) ? max : spec[i];
        wspec[i] = (spec[i]*31)*(constrain((float)Math.sqrt(i/90.)/4, 0, .5));
    }
    for(int i = spec.length-3; i < spec.length; i++) {
        spec[i] = fft.getBand(i);
        wspec[i] = (spec[i]*11)*(constrain((float)Math.sqrt(i/40.)/4, 0, .5));
    }
    
    avg /= spec.length;//divide the average by the counted values
    
    //begin dealing with the power history and trends.
    //
    //power is related to the brightness of this sketch, as we can
    //use sound power as a (slightly) relevant measure of sound intensity.
    if(immediatePower.size() < IMMEDIATE_SIZE) {
        //is the immediate frame full?
        //if not, add to it.
        immediatePower.add(avg);
    } else {
        //The immediate frame is full,
        //so now we can take its average and store it in the
        //powerFrame, to analyze for trends.
        float powavg = 0;
        for(float f : immediatePower) {
            powavg += f;
        }
        powavg /= immediatePower.size();
        //if the PowerFrame(which is intended to be a circular buffer)
        //is also full, empty from the FRONT until it is not full,
        //then add to the END.
        while(powerFrame.size() > FRAME_SIZE) powerFrame.remove(0);
        powerFrame.add(powavg);
        //clear the immediate frame.
        immediatePower.clear();
        //and don't drop the element we were trying to add in the first place.
        immediatePower.add(avg);
    }
    
    float imp = 0; //now we do some things with the impulse.
    //which is the power.
    //I'm not sure why I named it differently this time.
    for(float f : immediatePower) {
        imp += f;
    }
    
    //do nothing with impulse if there are not enough powers stored in the immediate frame.
    //also, we can't compare the currently read impulse to the impulse history unless there
    //IS at least one history.
    if(immediatePower.size() >  IMMEDIATE_SIZE/2 && powerFrame.size() > 0) {
        imp /= immediatePower.size(); //take the average
        //(but don't do it outside this if statement, because of accidental divide-by-zero,
        //which is prevented by the if)
        
        float avp = 0; //average power in the entire history frame
        for(float f : powerFrame) {
            avp += f;
        }
        avp /= powerFrame.size(); //calculate average
        
        //direction that the average and our current impulse frame is headed.
        float direction = powerFrame.get(powerFrame.size() - 1) - imp;
        //however, we only want the sign from this value.
        direction = (direction < 0)? -1 : 1;
        //the trend value starts with the sign of this direction.
        float trend = direction;
        if(powerFrame.size() > 1) {
                //now we calculate trend, by getting the direction all through the history.
                direction = powerFrame.get(powerFrame.size()-2) - powerFrame.get(powerFrame.size()-1);
                direction = (direction < 0)? -1:1;
                if(trend == direction) trend += direction;
                for(int i = powerFrame.size()-2; i > 1; i--) {
                    float p = powerFrame.get(i-1) - powerFrame.get(i);
                    p = (p < 0)? -1 : 1;
                    if(p == direction) {
                        trend += p;
                    } else {
                        //the trend count stops as soon as we encounter a direction that
                        //isn't headed the same way as we started.
                        break;
                    }
                }
        }
        //for whatever reason, Trend has the expected result
        //when its sign is flipped. Should probably investigate
        //why this is.
        
        //also, the multiplier values were once again chosen by the highly
        //scientific method of "guess and check"
        trend *= (trend < 0)? -.5 : -.5;
        println(cbg);
        if(abs(avp-imp)/avp > .2) {
            cbg = constrain(cbg+trend, 0, 255);
            float magnet = (cbg > 255/4.*3)? -2 : 2;
            //magnetize towards the center; helps prevent skew
            cbg += magnet;
        }
    }
    
    /* Compute average, max of wspec */
    avg = 0;
    max = -1;
    for(float f : wspec) {
        if(f > max) max = f;
        avg += f;
    }
    avg /= wspec.length; 
    float target = avg + (max-avg)*0.15;
    //this array list is called yellow for historical reasons. They used to be values I was
    //drawing as actually yellow. They are local maximums (within 3 of their neighbors)
    //which are greater than the target value (which is currently average power + 3/4 average)
    ArrayList<Integer> yellows = new ArrayList<Integer>();
    //put a zero in it so it's not empty in case of accidents.
    yellows.add(0);
    //if the values are maximums of their neighbors and also greater than the target, collect their indices.
    for(int i = 2; i < wspec.length-2; i++) {
        if(wspec[i] > wspec[i-1] && wspec[i] > wspec[i+1] && wspec[i] > wspec[i-2] && wspec[i] > wspec[i+2] && wspec[i] > target) {
            yellows.add(i);
        }
    }
    
    int mid = 150; //values (again) chosen by the highly scientific blah blah blah....
    ///              yeah, you get it. I messed with the code until it was pretty.
    ///              The measurements produced by this program have almost 0 scientific
    ///              value, only artistic value.
    int top = 250;
    float range = top-mid;
    int low = mid - (int)range;
    int brightness = 0;
    //clip yellow values outside of the bounds;
    //I found out that this prevents a lot of false blue
    //AND allows us a better read on classical music.
    for(int i = yellows.size() - 1; i >= 0; i--) {
        brightness = yellows.get(i);
        if(brightness <= top+50) break;
    }
    
    //the mood frame, which has an immediate for collection and a frame for averages
    //is handled much the same as the power frame and immediate. Except here, we're looking
    //for the "brightest" (highest) yellow frequency. We use this as a (albeit terrible)
    //measure of song tone in terms of brightness. (gives us our blue/red axis)
    if(immediateMood.size() < IMMEDIATE_SIZE) {
        immediateMood.add((float)brightness);
    } else {
        avg = 0; //we reuse avg a lot for these average calculations....
        for(float f : immediateMood) {
            avg += f;
        }
        avg /= immediateMood.size();
        immediateMood.clear();
        immediateMood.add((float)brightness);
        while(moodFrame.size() >= FRAME_SIZE) moodFrame.remove(0);
        moodFrame.add(avg);
    }
    avg = 0; //more average calculations.
    if(immediateMood.size() > 0) {
        for(float f : immediateMood) {
            avg += f;
        }
        avg /= immediateMood.size();
        avg /= 4;
    }
    for(float f : moodFrame) {
        avg += f;
    }
    if(moodFrame.size() > 0) {
        avg /= moodFrame.size() + .4;
    }
    
    //the weight ratio along our red-blue axis. Used for weighting the colors together
    //to get the correct one.
    float realwt = constrain((avg-low)/(range*2),0,1);
    
    //the current weight is actually glided though; using the past
    //weight as a starting point and only moving *towards* the real weight
    //pumped out of the averaging functions. This smooths out the visual
    //transitions when there are really big sudden changes in the weight,
    //keeping the transitions from looking sudden and jerky
    cwt += (realwt-cwt)/16;
    float wt = cwt;
    background = getBackgroundFor(wt);
    SmartColor ibackground = warm.weight(cold,wt).intensity(cbg);
    
    //better, subtly gradiented background.
    //originally was just background(bg color) but now it has a
    //fun gradient taken from slightly around where the background is.
    //
    //this gives it the feeling of blue-red as intended, but also isn't quite as boring.
    for(int i = 0; i < height; i++) {
        /*SmartColor p =*/ background.weight(ibackground,.9 + ((float)(i))/height*.9).rstroke();
        //p.weight(warm.intensity(190),.70+((float)(height-i))/height*.3).rstroke();
        line(0,i,width,i);
    }
    
    //do the spec freq again, but instead actually draw to the screen instead
    //of locating yellow values. Notice here that the color we do it is picked in somewhat
    //nifty fashion: We rotate approximately 20% along the blue/red axis from where the weight
    //currently is set for the background. This draws a contrasting color almost all the time.
    SmartColor spectrograph = cold.weight(warm,1-wt);
    SmartColor ispectrograph = cold.weight(warm,((((int)((wt)*100)+80)%100)/100.));
    for(int i = 0; i < spec.length; i++) {
        //stroke(255);
        spectrograph.intensity(400).rstroke();
        float ft = wspec[i]*2+2;
        line(i,height/2-ft,i,height/2+ft);
        ft -= 2;
        ft = constrain(ft,0,height);
        
        int intense = constrain((int)abs(constrain((255/((float)Math.sqrt(dist(i, 0, int(wt*width), 0)/(width/50)))), 0,9001)-250)+150, 150, 600);
        spectrograph.intensity(intense).rstroke();
        line(i,height/2-ft,i,height/2+ft);
    }
    //stroke(255);
    //line(wt*width,0,wt*width,height);
    
    //bubbles
    if(bigbubbles.size() < MAX_CBUBBLES) {
        bigbubbles.add(new ComplexBubble(random(0,width),height+45, random(200,400)));
    } else if(regbubbles.size() < MAX_SBUBBLES) {
        regbubbles.add(new SimpleBubble(random(0,width), height+45, random(200,400)));
    }
    
    ArrayList dead = new ArrayList();
    for(ComplexBubble b : bigbubbles) {
        b.draw();
        if(b.dead()) dead.add(b);
    }
    for(SimpleBubble b : regbubbles) {
        b.draw();
        if(b.dead()) dead.add(b);
    }
    
    //kill the dead ones.
    for(Object o : dead) {
        if(o instanceof ComplexBubble) bigbubbles.remove(o);
        if(o instanceof SimpleBubble) regbubbles.remove(o);
    }
}

SmartColor getBackgroundFor(float wt) {
    return cold.weight(warm,wt).intensity(cbg);
}

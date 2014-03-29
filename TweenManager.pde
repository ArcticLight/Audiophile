class TweenManager {
    float glide = 1f;
    int pwarm = 0;
    int pcold = 0;
    float now = 0;
    int nextWarm = 0;
    int nextCold = 0;
    
    public TweenManager() {
    }
    
    void update(float step) {
        now = now + step;
        if(now > glide) {
            //time for a new color; snap the old one and start over
            now = 0;
            warm = new SmartColor(warmColors[nextWarm]);
            cold = new SmartColor(coldColors[nextCold]);
            pwarm = nextWarm;
            pcold = nextCold;
            nextWarm = (nextWarm+1) % warmColors.length;
            nextCold = (nextCold+1) % coldColors.length;
        } else {
            warm = warmColors[pwarm].weight(warmColors[nextWarm], 1-(now/glide));
            cold = coldColors[pcold].weight(coldColors[nextCold], 1-(now/glide));
        }
    }
    
}

class SmartColor {
    private float r, g, b;
    
    public final int C_RGB = 0;
    
    SmartColor(float r, float g, float b) {
        this.r = r;
        this.g = g;
        this.b = b;
    }
    
    SmartColor(SmartColor clone) {
        this.r = clone.r;
        this.g = clone.g;
        this.b = clone.b;
    }
    
    SmartColor weight(SmartColor o, float amount) {
        float newr = this.r * amount + (o.r*(1-amount));
        float newg = this.g * amount + (o.g*(1-amount));
        float newb = this.b * amount + (o.b*(1-amount));
        return new SmartColor(newr, newg, newb); 
    }
    
    SmartColor intensity(float amount) {
        float newr = this.r*(amount/255);
        float newg = this.g*(amount/255);
        float newb = this.b*(amount/255);
        return new SmartColor(newr, newg, newb); 
    }
    
    float getR() {
        return r;
    }
    
    float getG() {
        return g;
    }
    
    float getB() {
        return b;
    }
    
    void rstroke() {
        stroke(r,g,b);
    }
    
    void rstrokea(float alpha) {
        stroke(r,g,b, alpha);
    }
    
    void rfill() {
        fill(r,g,b);
    }
    
    void rfilla(float alpha) {
        fill(r,g,b,alpha);
    }
    
    void setr(float r) {
        this.r = r;
    }
    
    void setg(float g) {
        this.g = g;
    }
    
    void setb(float b) {
        this.b = b;
    }
}

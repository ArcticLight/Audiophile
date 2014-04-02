class ColdBubble {
    PVector position,go;
    PGraphics buf,mask,bmask;
    int radius;
    float rot, rotv;
    float lifespan, lived;
    SmartColor c;
    
    int sr;
    
    ColdBubble(float x, float y, float lifespan) {
        this.lived = 0;
        this.lifespan = lifespan;
        this.position = new PVector(x,y);
        this.radius = (int)random(55, 110);
        this.go = new PVector(0,random(-4,-1));
        this.c = new SmartColor(background);
        this.rot = random(1,31);
        this.rotv = random(-.1,.1);
        this.sr = (int)random(0,400);
        this.buf = createGraphics(radius+2,radius+2);
        this.mask = createGraphics(radius+2,radius+2);
        this.bmask = createGraphics(radius+2,radius+2);
        bmask.beginDraw();
        bmask.background(0);
        bmask.ellipseMode(CENTER);
        bmask.noFill();
        for(float z = 1; z >= 0; z -= .01) {
            bmask.stroke((255-(lived/lifespan)*255)*(1-z));
            bmask.ellipse(radius/2,radius/2,radius/2*z,radius/2*z);
        }
        bmask.endDraw();
    }
    
    void draw() {
        position.add(go);
        lived++;
        sr+=8;
        rot += rotv;
        c.intensity(150).rstrokea(100-((lived/lifespan)*100));
        ellipseMode(CENTER);
        //ellipse(position.x, position.y, radius, radius);
        buf.beginDraw();
        buf.background(0,0,0,0);
        SmartColor q = c.intensity(150);
        buf.ellipseMode(CORNERS);
        buf.stroke(q.getR(),q.getG(),q.getB());
        buf.fill(c.getR(),c.getG(),c.getB());
        buf.ellipse(0, 0, radius, radius);
        buf.stroke(255,255,255, (position.y/height)*255);
        float py = radius/2;
        buf.translate(radius/2, radius/2);
        buf.rotate(rot);
        buf.translate(-radius/2,-radius/2);
        for(int i = 0; i < (int)radius-1; i++) {
            float y = iobuf.leftChannel[i*8+sr];
            y *= sin((i/(float)radius)*PI)*60;
            y += radius/2;
            buf.line(i, py, i+1, y);
            py = y;
        }
        buf.endDraw();
        PImage ubuf = createImage(buf.width, buf.height, RGB);
        ubuf.set(0,0,buf);
        mask.beginDraw();
        mask.set(0,0,bmask);
        mask.noStroke();
        mask.fill(0,0,0,lived/lifespan*255);
        mask.rect(0,0,radius,radius);
        mask.endDraw();
        ubuf.mask(mask);
        image(ubuf,position.x,position.y);
    }
    
    boolean dead() {
        return lived > lifespan;
    }
}

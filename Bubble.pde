abstract class Bubble {
    abstract void draw();
    abstract boolean dead();
}

class ComplexBubble extends Bubble {
    PVector position,go;
    PGraphics buf,mask,bmask;
    int radius;
    float rot, rotv;
    float lifespan, lived;
    float mywt;
    
    int sr;
    
    ComplexBubble(float x, float y, float lifespan) {
        this.lived = 0;
        this.lifespan = lifespan;
        this.position = new PVector(x,y);
        this.radius = (int)random(55, 110);
        this.go = new PVector(0,random(-4,-1));
        this.mywt = cwt;
        this.rot = random(1,31);
        this.rotv = random(-.1,.1);
        this.sr = (int)random(0,100);
        this.buf = createGraphics(radius+2,radius+2);
        this.mask = createGraphics(radius+2,radius+2);
        this.bmask = createGraphics(radius+2,radius+2);
        bmask.beginDraw();
        bmask.background(0);
        bmask.ellipseMode(CORNERS);
        bmask.fill(255);
        bmask.ellipse(0,0,radius,radius);
        bmask.endDraw();
    }
    
    void draw() {
        SmartColor c = getBackgroundFor(mywt).intensity(150);
        position.add(go);
        lived++;
        sr+=2;
        rot += rotv;
        c.rstrokea(100-((lived/lifespan)*100));
        ellipseMode(CENTER);
        //ellipse(position.x, position.y, radius, radius);
        buf.beginDraw();
        buf.background(0,0,0,0);
        SmartColor q = c.intensity(300);
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

class SimpleBubble extends Bubble {
    PVector position,go;
    int radius;
    float rot, rotv;
    float lifespan, lived;
    float mywt;
    
    
    //target whiteout value
    boolean whiteQueued;
    int waitct;
    float target;
    float cwa;
    int reactsTo;
    int unchanged;
    boolean shine;
    int damp;
    
    SimpleBubble(float x, float y, float lifespan) {
        this.lived = 0;
        this.lifespan = lifespan;
        this.position = new PVector(x,y);
        this.radius = (int)random(28, 70);
        this.go = new PVector(0,random(-4,-1));
        this.mywt = cwt;
        this.rot = random(1,31);
        this.rotv = random(-.1,.1);
        this.target = 0;
        this.cwa = 0;
        this.unchanged = 0;
        this.reactsTo = (int)random(1,3);
        this.shine = (random(0,1) < 0.5);
        this.damp = 0;
    }
    
    void draw() {
        unchanged++;
        if(unchanged > 60 && cwa < 0.05) {
            reactsTo = (int)random(1,3);
            unchanged = 0;
        }
        boolean nowBeat = (reactsTo == 1)? kick : hat;
        if(target == 1 && cwa > 0.94) {
            target = 0;
            whiteQueued = false;
        }
        if(whiteQueued && waitct > 0) {
            waitct--;
        } else if(whiteQueued) {
            cwa += (target-cwa)/1.4;
        } else if(cwa >= 0.05) {
            cwa += (target-cwa)/5;
            if(cwa < 0.05) {
                reactsTo = (int)random(1,3);
                unchanged = 0;
                damp = 5;
                cwa = 0;
                target = 0;
                waitct = 0;
            }
        }
        if(target == 0 && cwa < 0.05 && nowBeat && damp <= 0) {
            target = 1;
            whiteQueued = true;
            waitct = (int)random(0,1);
        } else {
            damp--;
        }
        SmartColor c;
        if(reactsTo == 1) {
            c = getBackgroundFor(mywt).intensity(100);
        } else if(reactsTo == 2) {
            c = getBackgroundFor(mywt).intensity(600);
        } else {
            c = getBackgroundFor(mywt).intensity(800);
        }
        go.add(new PVector(random(-.1,.1), 0));
        this.position.add(go);
        lived++;
        rot += rotv;
        c.rstrokea((100-((lived/lifespan)*100))*cwa);
        c.rfilla((100-((lived/lifespan)*100))*cwa);
        ellipseMode(CENTER);
        ellipse(position.x, position.y, radius, radius);
    }
    
    boolean dead() {
        return lived > lifespan;
    }
}

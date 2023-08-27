ArrayList<OrderedDynamicLine> lines = new ArrayList<OrderedDynamicLine>();

int speed = 1000;
int WIDTH = 400;

void setup() {
    size(400, 400);
    
    OrderedDynamicLine[] step5 = generateDiagonalStep(2);
    OrderedDynamicLine[] step6 = generateOrthogonalStep(4);
    OrderedDynamicLine[] step7 = generateDiagonalStep(4);
    OrderedDynamicLine[] step8 = generateOrthogonalStep(8);
    OrderedDynamicLine[] step9 = generateDiagonalStep(8);
    OrderedDynamicLine[] step10 = generateOrthogonalStep(16);
    OrderedDynamicLine[] step11 = generateDiagonalStep(16);
    
    OrderedDynamicLine[][] steps = {
        step1, 
        step2,
        step3,
        step5,
        step6,
        step7,
        step8,
        step9,
        step10,
        step11
    };

    int stepNum = 0;
    for (OrderedDynamicLine[] step : steps) {
        for (OrderedDynamicLine line : step) {
            line.ordering = stepNum;
            lines.add(line);
        }
        stepNum++;
    }
}

void draw() {
    background(0);
    
    for (OrderedDynamicLine line : lines) {
        line.update();
        line.display();
    }
}

class DynamicLine {
    PVector startPos, endPos, currentPos;
    color lineColor;
    int duration;
    int thickness;
    int startTime, endTime;
    boolean active = false; 
    
    DynamicLine(PVector startPos, PVector endPos, color lineColor, int duration, int thickness) {
        this.startPos = startPos.copy();
        this.endPos = endPos.copy();
        this.lineColor = lineColor;
        this.duration = duration;
        this.thickness = thickness;
        
        this.startTime = millis();
        this.endTime = this.startTime + this.duration;
        this.currentPos = this.startPos.copy();
    }
    
    void update() {
        int currentTime = millis();
        float progress = active ? constrain((float)(currentTime - startTime) / duration, 0, 1) : 0;
        currentPos.x = lerp(startPos.x, endPos.x, progress);
        currentPos.y = lerp(startPos.y, endPos.y, progress);
    }
    
    void display() {
        stroke(lineColor);
        strokeWeight(thickness);
        strokeCap(SQUARE);
        line(startPos.x, startPos.y, currentPos.x, currentPos.y);
    }
    
    boolean hasFinished() {
        float currentTime = millis();
        return constrain((float)(currentTime - startTime) / duration, 0, 1)  < 1.0;
    }
    
    void resetClock() {
        this.startTime = millis();
        this.endTime = this.startTime + this.duration;
    }
}

class OrderedDynamicLine extends DynamicLine {
    int ordering;
    
    OrderedDynamicLine(PVector startPos, PVector endPos, color lineColor, int duration, int thickness) {
        super(startPos, endPos, lineColor, duration, thickness);
        this.ordering = 0;
    }

    OrderedDynamicLine(PVector startPos, PVector endPos, color lineColor, int duration, int thickness, int ordering) {
        super(startPos, endPos, lineColor, duration, thickness);
        this.ordering = ordering;
    }
    
    boolean canDisplay() {
        for (OrderedDynamicLine line : lines) {
            if (line.ordering < this.ordering && line.hasFinished()) {
                return false;
            }
        }
        return true;
    }
    
    void display() {
        if (canDisplay()) {
            if (super.active == false) {
                super.resetClock();
                super.active = true;
            }

            super.display();
        }
    }
}

// OrderedDynamicLine horiz1 = ;

OrderedDynamicLine[] step1 = {
    new OrderedDynamicLine(
        new PVector(0, 200), 
        new PVector(WIDTH, 200), 
        color(255, 255, 255), 
        speed, 
        4
    )
};


OrderedDynamicLine[] step2 = {
    new OrderedDynamicLine(
        new PVector(200, 0), 
        new PVector(200, WIDTH), 
        color(255, 255, 255), 
        speed, 
        4
    )
};

OrderedDynamicLine[] step3 = {
    new OrderedDynamicLine(
        new PVector(0, 0), 
        new PVector(WIDTH, WIDTH), 
        color(255, 255, 255), 
        speed, 
        4
    ),
    new OrderedDynamicLine(
        new PVector(0, WIDTH), 
        new PVector(WIDTH, 0), 
        color(255, 255, 255), 
        speed, 
        4
    )
};

OrderedDynamicLine[] generateOrthogonalStep(int divisions) {
    OrderedDynamicLine[] lines = new OrderedDynamicLine[divisions];
    
    for (int i = 0; i < divisions / 2; i++) {
        int direction = i % 2 == 0 ? 1 : 0;
        int startPos = WIDTH * ((direction + 1) % 2);
        int endPos = WIDTH * (direction);

        // horizontal
        int spacing = WIDTH / divisions;
        int pos = spacing + 2 * spacing * i;
        lines[i*2] = new OrderedDynamicLine(
            new PVector(startPos, pos), 
            new PVector(endPos, pos), 
            color(255, 255, 255), 
            speed, 
            4
        );

        // vertical
        lines[2*i+1] = new OrderedDynamicLine(
            new PVector(pos, startPos), 
            new PVector(pos, endPos), 
            color(255, 255, 255), 
            speed, 
            4
        );
    }

    return lines;
}

OrderedDynamicLine[] generateDiagonalStep(int divisions) {
    int numOfLines = (divisions * divisions) * 2;
    OrderedDynamicLine[] lines = new OrderedDynamicLine[numOfLines];
    int windowSize = WIDTH / divisions;

    for (int i = 0; i < divisions; i++) {
        for (int j = 0; j < divisions; j++) {
            PVector topRight = new PVector(windowSize + windowSize * i, windowSize + windowSize * j);
            PVector bottomLeft = new PVector(windowSize * i, windowSize + windowSize * j);
            PVector topLeft = new PVector(windowSize + windowSize * i, windowSize * j);
            PVector bottomRight = new PVector(windowSize * i, windowSize * j);

            if ((i + j) % 4 == 0) {
                PVector temp = topRight.copy();
                topRight = bottomRight.copy();
                bottomRight = temp.copy();

                PVector temp2 = topLeft.copy();
                topLeft = bottomLeft.copy();
                bottomLeft = temp2.copy();
            }
            lines[divisions*2*i + 2*j] = new OrderedDynamicLine(
                topRight, 
                bottomRight, 
                color(255, 255, 255), 
                speed, 
                4
            );

            lines[divisions*2*i + 2*j + 1] = new OrderedDynamicLine(
                topLeft, 
                bottomLeft, 
                color(255, 255, 255), 
                speed, 
                4
            );
        }
    }

    return lines;
}

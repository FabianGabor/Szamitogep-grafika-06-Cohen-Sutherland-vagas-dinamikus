Table table;

boolean elsoPont = true;
boolean vag = true;

int bgColor = 204;
int xMin, yMin, xMax, yMax;

int rectW = 50;
int rectH = 50;

int x1, y1, x2, y2;

final int BENT = 0;    // 0000
final int BAL  = 1;    // 0001
final int JOBB = 2;    // 0010
final int LENT = 4;    // 0100
final int FENT = 8;    // 1000

void setup() {
    size(640, 480);
    
    table = loadTable("../modell.csv", "header");

    for (TableRow row : table.rows()) {
        int x1 = row.getInt("x1");    
        int y1 = row.getInt("x2");
        int x2 = row.getInt("y1");
        int y2 = row.getInt("y2");
        println("(" + x1 + "," + y1 + "), (" + x2 + "," + y2 + ")");
    }
}


void draw() {
    background(bgColor);
    
    xMin = mouseX - rectW/2;
    yMin = mouseY - rectH/2;
    xMax = mouseX + rectW/2;
    yMax = mouseY + rectH/2;
    
   
    if (vag)
        rect(mouseX - rectW/2, mouseY - rectH/2, rectW, rectH);
     

    if (table.getRowCount() > 0) {
        for (TableRow row : table.rows()) {
            x1 = row.getInt("x1");
            y1 = row.getInt("y1");
            x2 = row.getInt("x2");
            y2 = row.getInt("y2");
            
            CohenSutherlandSzakaszvago(x1, y1, x2, y2);
        }
    }
}

int Zona(double x, double y) {
    int zona = BENT;    

    if (x < xMin) zona |= BAL;
    else if (x > xMax) zona |= JOBB;
    if (y < yMin) zona |= LENT;
    else if (y > yMax) zona |= FENT;

    return zona;
}

void CohenSutherlandSzakaszvago(float x0, float y0, float x1, float y1)
{
    int pont1Zona = Zona(x0, y0);
    int pont2Zona = Zona(x1, y1);
    boolean elfogad = false;
    boolean vege = false;
    
    do {
        if ((pont1Zona | pont2Zona) == 0) {            
            // mindket pont bent van            
            elfogad = true;
            vege = true;            
        } else {
            if ((pont1Zona & pont2Zona) != 0) {
                // mindket pont kozos kulso zonaban van (BAL, JOBB, FENT, LENT)
                // nem fogadjuk el, vege
                vege = true;
            } else {
                float x = 0, y = 0;
                
                // egy pont biztosan kint van
                int pontKint = pont2Zona > pont1Zona ? pont2Zona : pont1Zona;
    
                // Metszespontok:                
                // m = (y1 - y0) / (x1 - x0)
                // x = x0 + (1 / m) * (y[Min/Max] - y0)
                // y = y0 + m * (x[Min/Max] - x0)
                if ((pontKint & FENT) != 0) {
                    x = x0 + (x1 - x0) * (yMax - y0) / (y1 - y0);
                    y = yMax;
                } else if ((pontKint & LENT) != 0) {
                    x = x0 + (x1 - x0) * (yMin - y0) / (y1 - y0);
                    y = yMin;
                } else if ((pontKint & JOBB) != 0) {
                    y = y0 + (y1 - y0) * (xMax - x0) / (x1 - x0);
                    x = xMax;
                } else if ((pontKint & BAL) != 0) {
                    y = y0 + (y1 - y0) * (xMin - x0) / (x1 - x0);
                    x = xMin;
                }
    
                if (pontKint == pont1Zona) {
                    x0 = x;
                    y0 = y;
                    pont1Zona = Zona(x, y);
                } else {
                    x1 = x;
                    y1 = y;
                    pont2Zona = Zona(x, y);
                }            
            }
        }
    }
    while (!vege);
    
    if (elfogad)
        drawLine(x0, y0, x1, y1);
}

void drawLine(float x, float y, float x0, float y0) {
    float m;
    float i, j;

    if (x0 != x) { // nem függőleges
        m = (y0 - y) / (x0 - x);

        if (abs(m) <= 1) {
            j = (x < x0) ? y : y0;
            for (i = (x < x0) ? x : x0; i < ((x > x0) ? x : x0); i++) {
                point(i, j);
                j += m;
            }
        } else {
            i = (y < y0) ? x : x0;
            for (j = (y < y0) ? y : y0; j < ((y > y0) ? y : y0); j++) {
                point(i, j);
                i += 1/m;
            }
        }
    } else {    // függőleges
        for (j = (y < y0) ? y : y0; j < ((y > y0) ? y : y0); j++) {
            point(x, j);
        }
    }
}

void keyPressed() {
    if (key == 'v') {
        vag = !vag;        
    }
    
    switch (keyCode) {
        case UP: rectH += 10; break;
        case DOWN: rectH -= 10; break;
        case LEFT: rectW -=10; break;
        case RIGHT: rectW +=10; break;
    }
}

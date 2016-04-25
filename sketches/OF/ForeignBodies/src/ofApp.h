#pragma once

#include "ofMain.h"
#include "ofxOsc.h"
#define PORTIN 8000
#define PORTOUT 57120
#define HOST "localhost"

struct solenoidElement{
    ofPoint pos;
    float timeStamp;
    bool isActive;
};

struct blobElement{
    vector<ofPoint> pos;
    vector<float> size;
    int numCircles;
    int index;
};

class ofApp : public ofBaseApp{

	public:
		void setup();
		void update();
		void draw();
    
    void drawWaves();
    void drawBlobs();
    void addBlob();
    void clearBlobs();
    void resetAllSolenoids();
    
        int setSolenoidsPosition(int numRows);
        void drawCircle(int index);
    
		void keyPressed(int key);
		void keyReleased(int key);
		void mouseMoved(int x, int y );
		void mouseDragged(int x, int y, int button);
		void mousePressed(int x, int y, int button);
		void mouseReleased(int x, int y, int button);
		void mouseEntered(int x, int y);
		void mouseExited(int x, int y);
		void windowResized(int w, int h);
		void dragEvent(ofDragInfo dragInfo);
		void gotMessage(ofMessage msg);

    ofxOscReceiver receiver;
				ofxOscSender sender;
    ofFbo fbo;
};

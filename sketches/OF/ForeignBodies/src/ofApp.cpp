#include "ofApp.h"

vector<solenoidElement> solenoidArray;
vector<blobElement> blobArray;
vector<Boolean> activeSolenoid;
int totalSpeakers;
int blobCount;
ofPixels pix;
int playMode; // play mode
int nodeID; //for example blob index
float tStampTime;
float wTimeStamp;
//--------------------------------------------------------------
void ofApp::setup(){
    blobCount =0;
    wTimeStamp=0.0;
    playMode = -1;
    cout << "listening for osc messages on port " << PORTIN << "\n";
    receiver.setup(PORTIN);
    sender.setup(HOST,PORTOUT);
    
    int totalRows = 10;
    totalSpeakers = setSolenoidsPosition(totalRows);
    fbo.allocate(ofGetWidth(),ofGetHeight(), GL_RGB);
}

//--------------------------------------------------------------
void ofApp::update(){
    
    // check for waiting messages
    while(receiver.hasWaitingMessages()){
        // get the next message
        ofxOscMessage m;
        receiver.getNextMessage(m);
        if(m.getAddress() == "/oscID"){
            cout<<"ok"<<endl;
            int msg = m.getArgAsInt(0) ;
            if(msg<totalSpeakers){
                solenoidArray[msg].timeStamp = ofGetElapsedTimeMillis();
            }
        }
    }
    //turn off solenoid after duration
    for (int i=0; i<totalSpeakers; i++) {
        if(playMode==0 && ofGetElapsedTimeMillis()-solenoidArray[i].timeStamp>tStampTime){
            solenoidArray[i].isActive=false;
        }
    }
    //    if(ofGetKeyPressed()){
    //        ofxOscMessage n;
    //        n.setAddress("/OF");
    //        n.addFloatArg(int(ofRandom(0,100)));
    //        sender.sendMessage(n);
    //}
    //    for (int i=0; i<totalSpeakers; i++) {
    //
    //    if ((ofGetElapsedTimeMillis()-solenoidArray[i].timeStamp)<1000) {
    //        solenoidArray[i].isActive=false;
    //    }
    //    }
}

//--------------------------------------------------------------
void ofApp::draw(){
    ofBackground(0, 0, 0);
    fbo.begin();
    ofClear(0.,0.,0., 0.);
    if(playMode==0){drawWaves();}
    else if (playMode==1){drawBlobs();}
    
    fbo.end();
    fbo.readToPixels(pix);
    pix.getData();
    
    for(int i=0; i<totalSpeakers;i++){
        if(pix.getColor(solenoidArray[i].pos.x, solenoidArray[i].pos.y).r>0 && solenoidArray[i].isActive==false){
            solenoidArray[i].isActive=true;
            solenoidArray[i].timeStamp=ofGetElapsedTimeMillis();
        }
        
        if(solenoidArray[i].isActive != activeSolenoid[i]){
            ofxOscMessage n;
            n.setAddress("/OF");
            n.addFloatArg(i);
            n.addIntArg(playMode); // playMode
            n.addIntArg(solenoidArray[i].isActive); //is active?
            n.addIntArg(nodeID); //index
            sender.sendMessage(n);
            activeSolenoid[i] = solenoidArray[i].isActive;// update our reference node
            cout << "OSC: Noid "<< i << " is " << solenoidArray[i].isActive << " -- nodeID: " << nodeID << endl;
        }
    }
    
    //    fbo.draw(0,0);
    
    //    ofDrawBitmapString(msg, ofGetWidth()/2, ofGetHeight()/2);
    for (int i=0; i<totalSpeakers; i++) {
        drawCircle(i);
    }
    
}

//--------------------------------------------------------------
void ofApp::addBlob(){
    blobArray.push_back(blobElement()); //our good friend blobby
    blobArray[blobCount].index=blobCount;
    blobArray[blobCount].numCircles = ofRandom(2,15);
    ofPoint areaSize = ofPoint(ofRandom(ofGetWidth()/10, ofGetWidth()/4),ofRandom(ofGetHeight()/10, ofGetHeight()/4));
    ofPoint minBounds = ofPoint(ofRandom(0,ofGetWidth()-areaSize.x),ofRandom(0,ofGetHeight()-areaSize.y));
    ofPoint maxBounds = ofPoint(minBounds.x+areaSize.x,minBounds.y+areaSize.y);
    for (int i=0; i<blobArray[blobCount].numCircles; i++) {
        blobArray[blobCount].pos.push_back(ofPoint(ofRandom(minBounds.x,maxBounds.x),ofRandom(minBounds.y,maxBounds.y)));
        blobArray[blobCount].size.push_back(ofRandom(MIN(areaSize.x,areaSize.y)/4,MIN(areaSize.x,areaSize.y)));
    }
    blobCount++;
    nodeID=blobCount;
}
//--------------------------------------------------------------

void ofApp::clearBlobs(){
    // turn all the blobs off
    for(int i=0; i<totalSpeakers;i++){
        if(pix.getColor(solenoidArray[i].pos.x, solenoidArray[i].pos.y).r>0){
            solenoidArray[i].isActive=false;
            ofxOscMessage n;
            n.setAddress("/OF");
            n.addFloatArg(i);
            n.addIntArg(solenoidArray[i].isActive);
            n.addIntArg(playMode);
            sender.sendMessage(n);
        }
    }
    
    blobArray.clear();
    blobCount=0;
    nodeID=blobCount;
}

//--------------------------------------------------------------
void ofApp::drawBlobs(){
    ofSetColor(255, 255, 255);
    for (int i=0; i<blobArray.size(); i++) {
        for (int j=0; j<blobArray[i].numCircles; j++) {
            ofDrawCircle(blobArray[i].pos[j].x, blobArray[i].pos[j].y, blobArray[i].size[j]);
        }
    }
}
//--------------------------------------------------------------
void ofApp::drawWaves(){
    float rad = 0.0;
    rad=ofLerp(0.0, ofGetHeight(), (ofGetElapsedTimef()-wTimeStamp)/5);
    ofSetColor(255);
    ofDrawCircle(ofGetWidth()/2, ofGetHeight()/2, rad);
    ofSetColor(0);
    ofDrawCircle(ofGetWidth()/2, ofGetHeight()/2, CLAMP(rad-10,0,rad));
    if(rad>ofGetHeight())
        playMode=-1; // turn off after 10 seconds
}
//--------------------------------------------------------------
int ofApp::setSolenoidsPosition(int numRows){
    float xmul = ofGetWidth()/numRows;
    float ymul = ofGetHeight()/numRows;
    float xoffset = xmul/2;
    float yoffset = ymul/2;
    int count=0;
    for (int y=0; y<numRows; y++) {
        for (int x=0; x<numRows; x++) {
            solenoidArray.push_back(solenoidElement());
            activeSolenoid.push_back(false); // don't forget to add activeSolenoid placeholder array
            solenoidArray[count].pos.set(xmul*x+xoffset, ymul*y+yoffset);
            solenoidArray[count].timeStamp = ofGetElapsedTimeMillis();
            solenoidArray[count].isActive = false;
            count++;
        }
    }
    return count;
}
//--------------------------------------------------------------
void ofApp::drawCircle(int index){
    ofPushMatrix();
    ofTranslate(solenoidArray[index].pos.x, solenoidArray[index].pos.y);
    ofFill();
    if (solenoidArray[index].isActive) {
        ofSetColor(ofColor::lightYellow);
    }else{
        ofSetColor(ofColor::darkMagenta);
    }
    ofDrawCircle(0,0, 10);
    ofPopMatrix();
}
//--------------------------------------------------------------
void ofApp::resetAllSolenoids(){
    for(int i=0; i<totalSpeakers;i++){
        solenoidArray[i].isActive=0;
    }
}
//--------------------------------------------------------------
void ofApp::keyPressed(int key){
    if (key==' ') {
        playMode = 0;
        tStampTime = 1*1000; //1 sec
        wTimeStamp = ofGetElapsedTimef();
    }
    if(key=='q')
        clearBlobs();
    
    if (key=='b') {
        if(playMode==1)
            resetAllSolenoids();
        
        tStampTime = 60*1000; //60 seconds
        addBlob();
        playMode=1;
    }
}

//--------------------------------------------------------------
void ofApp::keyReleased(int key){
    
}

//--------------------------------------------------------------
void ofApp::mouseMoved(int x, int y ){
    
}

//--------------------------------------------------------------
void ofApp::mouseDragged(int x, int y, int button){
    
}

//--------------------------------------------------------------
void ofApp::mousePressed(int x, int y, int button){
    
}

//--------------------------------------------------------------
void ofApp::mouseReleased(int x, int y, int button){
    
}

//--------------------------------------------------------------
void ofApp::mouseEntered(int x, int y){
    
}

//--------------------------------------------------------------
void ofApp::mouseExited(int x, int y){
    
}

//--------------------------------------------------------------
void ofApp::windowResized(int w, int h){
    
}

//--------------------------------------------------------------
void ofApp::gotMessage(ofMessage msg){
    
}

//--------------------------------------------------------------
void ofApp::dragEvent(ofDragInfo dragInfo){ 
    
}

JSONObject json;
JSONArray values;
int numElements;
int textsize;

void setup() {
size(1024,768);
 textsize = 16;
background(150);
  json = loadJSONObject("/Users/erikparr/Documents/_Projects/Landscapes/sketches/python/Drift/metadata.json");
  //JSONObject soundgroup = json.getJSONObject("Tibetan Bell");
  JSONArray values = json.getJSONArray("Tibetan Bell");

  numElements = values.size();
  print("numelements:"+numElements);
  for (int i = 1; i < values.size(); i++) {
        JSONObject soundEntry = values.getJSONObject(i);
        int id = soundEntry.getInt("id");
        String filename = soundEntry.getString("filename");
      JSONArray tags = soundEntry.getJSONArray("tags");
      println("-");
      println("filename: "+filename);
  for (int j = 0; j < tags.size(); j++) {
    println(tags.getString(j));
  }
  }
  }
  
 void draw(){
  for(int i=0; i<numElements; i++){
    float ht =height/float(textsize);
    float offset=ht/2;
    float topL = ht*i;
    fill(220,222,255);
    pushMatrix();
    translate(50, offset+ht*i);
    rect(0,0,250,textsize*2, 7);
    textSize(32);
    fill(0);   // Fill color black
    text("LAX", 0,offset);
    popMatrix();
  }
  }
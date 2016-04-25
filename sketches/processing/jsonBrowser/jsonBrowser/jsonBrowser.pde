import de.bezier.guido.*;
import java.util.*;

JSONObject json;
JSONArray values;
int numElements;
int textsize;
List<String> filenames;
IntList ids;
String soundgroup = "Tibetan Bell";

Listbox listbox;
Object lastItemClicked;


void setup() {
size(1024,768);
 textsize = 16;
  filenames = new ArrayList<String>();
    Interactive.make( this );

  json = loadJSONObject("/Users/erikparr/Documents/_Projects/Landscapes/sketches/python/Drift/metadata.json");
  //JSONObject soundgroup = json.getJSONObject("Tibetan Bell");
  JSONArray values = json.getJSONArray(soundgroup);
  ids = new IntList();
  numElements = values.size()-1;
  print("numelements:"+numElements);

      listbox = new Listbox( 20, 60, width-40, height-80 );

  for (int i = 1; i < values.size(); i++) {
        JSONObject soundEntry = values.getJSONObject(i);
        int id = soundEntry.getInt("id");
        ids.append(id);
        String filename = soundEntry.getString("filename");
            filenames.add(filename);
                    listbox.addItem( filename);

      JSONArray tags = soundEntry.getJSONArray("tags");
      println("-");
      println("filename: "+filename);
  for (int j = 0; j < tags.size(); j++) {
    println(tags.getString(j));
  }
  }


  }

 void draw(){
     background(240);

  //for(int i=0; i<numElements; i++){
  //  float ht =height/float(textsize);
  //  float offset=ht/2;
  //  float topL = ht*i;
  //  fill(220,222,255);
  //  pushMatrix();
  //  translate(50, offset+ht*i);
  //  rect(0,0,250,textsize*2, 7);
  //  textSize(textsize);
  //  fill(0);   // Fill color black
  //  text(filenames.get(i), 20,offset);
  //  text(ids.get(i), 150,offset);
  //  popMatrix();
  //}
  }

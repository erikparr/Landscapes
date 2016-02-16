XML root;

String xmlPath = 
"/Users/erikparr/Documents/_Projects/Landscapes/sketches/python/LandscapeStudy/sounddata.xml";

void setup() {

   root = loadXML(xmlPath);
   println("root: "+root.getName());
   println("childz: "+ root.getContent());
   
   XML[] children = root.getChildren();
  for (int i = 0; i < children.length; i++) {
    println(children[i].getName());
  }
  
}
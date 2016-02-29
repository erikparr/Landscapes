JSONObject json;
JSONArray values;

void setup() {

  json = loadJSONObject("/Users/erikparr/Documents/_Projects/Landscapes/sketches/python/Drift/metadata.json");
  JSONObject soundgroup = json.getJSONObject("soundgroup");
  JSONArray values = json.getJSONArray("soundgroup");


  //int id = json.getInt("id");
  //String species = json.getString("species");
  //String name = json.getString("name");
  //length = json.length();

  println("Length: " + values.isNull(0));
}
import websockets.*;

WebsocketClient wsc;
boolean inputLoaded = false;

void initWebSockets(String url) {
  wsc= new WebsocketClient(this, url);
  delay(1000);
  wsc.sendMessage("{\"type\": \"get input config\"}");
}

void webSocketEvent(String msg) {
  JSONObject json = parseJSONObject(msg);
  if (json != null) {
    String msgType = json.getString("type");

    switch(msgType) {

    case "markers":
      JSONObject markersJSON = json.getJSONObject("markers"); 
      try {
        JSONArray markersArray = markersJSON.getJSONArray("markers");
        if (markersArray.size() > 0) {
          for (int i=0; i<markersArray.size(); i++) {
            JSONObject markerObject = markersArray.getJSONObject(i);
            int markerID = markerObject.getInt("id");

            JSONArray cornersJSON = markerObject.getJSONArray("corners");
            float cornerX1 = cornersJSON.getJSONArray(0).getFloat(0);
            float cornerY1 = cornersJSON.getJSONArray(0).getFloat(1);
            float cornerX2 = cornersJSON.getJSONArray(1).getFloat(0);
            float cornerY2 = cornersJSON.getJSONArray(1).getFloat(1);
            float cornerX3 = cornersJSON.getJSONArray(2).getFloat(0);
            float cornerY3 = cornersJSON.getJSONArray(2).getFloat(1);
            float cornerX4 = cornersJSON.getJSONArray(3).getFloat(0);
            float cornerY4 = cornersJSON.getJSONArray(3).getFloat(1);

            PVector corner = new PVector(cornerX1, cornerY1);
            PVector center = new PVector((cornerX1+cornerX2+cornerX3+cornerX4)/4, (cornerY1+cornerY2+cornerY3+cornerY4)/4);
            PVector[] cornerArray = {new PVector(cornerX1, cornerY1), new PVector(cornerX2, cornerY2), new PVector(cornerX3, cornerY3), new PVector(cornerX4, cornerY4)};
            mechamarkers.updateMarker(markerID, millis(), center, corner, cornerArray);
          }
        }
      } 
      catch (Exception e) {
        println(e);
      }
      break;

    case "input config":
      println(msg);
      mechamarkers.inputGroupList = new ArrayList<InputGroup>();
      inputGroups = new HashMap<String, InputGroup>();
      inputs = new HashMap<String, Input>();
      String inputGroupConfigString = json.getString("config");
      JSONObject inputGroupConfig = parseJSONObject(inputGroupConfigString);
      try {
        JSONArray inputGroupArray = inputGroupConfig.getJSONArray("groups");
        if (inputGroupArray.size() > 0) {
          for (int i=0; i<inputGroupArray.size(); i++) {
            JSONObject inputGroupObj = inputGroupArray.getJSONObject(i);
            String n = inputGroupObj.getString("name");
            int id = inputGroupObj.getInt("anchorID");
            int tO = inputGroupObj.getInt("detectWindow");
            float ms = inputGroupObj.getInt("markerSize");
            mechamarkers.inputGroupList.add(new InputGroup(n, markers.get(id), ms));
            markers.get(id).timeout = tO;
            inputGroups.put(n, mechamarkers.inputGroupList.get(i));
            
            JSONArray jinputs = inputGroupObj.getJSONArray("inputs");
            if (inputs.size() > 0) {
              for (int j=0; j<inputs.size(); j++) {
                JSONObject jinput = jinputs.getJSONObject(j);
                String iN = jinput.getString("name");
                String t = jinput.getString("type");
                int aID = jinput.getInt("actorID");
                int aTO = jinput.getInt("detectWindow");
                JSONObject rp = jinput.getJSONObject("relativePosition");
                float rpd = rp.getFloat("distance");
                float rpa = rp.getFloat("angle");
                float rpd2 = rpd;
                float rpa2 = rpa;
                if (t.equals("SLIDER")) {
                  JSONObject ep = jinput.getJSONObject("endPosition");
                  rpd2 = ep.getFloat("distance");
                  rpa2 = ep.getFloat("angle");
                }
                inputGroups.get(n).addInput(iN, t, markers.get(aID), rpd, rpa, rpd2, rpa2);
                markers.get(aID).timeout = aTO;
              }
            }
          }
        }
      }
      catch (Exception e) {
        println(e);
      }
      inputLoaded = true;
      break;

    default:
      break;
    }
  }
}

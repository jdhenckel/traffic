

interface Convertible {
  void convert(Target tar);
}

// These classes allow you to write CONVERT only one time and it will work for either save or load.

interface Target {
  boolean isLoading();
  int aInt(String s, int x);
  float aFloat(String s, float x);
  boolean aBool(String s, boolean x);
  PVector aV2(String s, PVector x);
  Convertible aObject(String s, Convertible obj, Class factory);
  ArrayList aObjectList(String s, ArrayList list, Class factory);
}

//================

class TargetForSave implements Target {
  JSONObject jo;
  boolean isLoading() { return false; }
  TargetForSave() { jo = new JSONObject(); }
  int aInt(String s, int x) {  jo.setInt(s,x); return x;  }
  float aFloat(String s, float x)  {  jo.setFloat(s,x); return x;  }
  boolean aBool(String s, boolean x)  {  jo.setBoolean(s,x); return x;  }
  PVector aV2(String s, PVector v)  {  jo.setFloat(s+".x",v.x); jo.setFloat(s+".y",v.y); return v;  }
  Convertible aObject(String s, Convertible obj, Class factory) {
    jo.setJSONObject(s,convertToJson(obj)); return obj;  
  }  
  ArrayList aObjectList(String s, ArrayList list, Class factory) {
    JSONArray a = new JSONArray();
    for (int i=0; i<list.size(); ++i)
      a.append(convertToJson((Convertible) list.get(i)));
    jo.setJSONArray(s,a);
    return list;
  }
  JSONObject convertToJson(Convertible obj) {
    TargetForSave tar = new TargetForSave();
    obj.convert(tar);
    return tar.jo;
  }
}


class TargetForLoad implements Target {
  JSONObject jo;
  boolean isLoading() { return true; }
  TargetForLoad(JSONObject v) { jo = v; }
  int aInt(String s, int x) { return jo.getInt(s, x); }
  float aFloat(String s, float x) { return jo.getFloat(s, x); }
  boolean aBool(String s, boolean x)  {  return jo.getBoolean(s, x); }
  PVector aV2(String s, PVector v) {
    if (v==null) v=new PVector();
    v.x = jo.getFloat(s+".x", v.x);
    v.y = jo.getFloat(s+".y", v.y);
    return v;
  }
  Convertible aObject(String s, Convertible obj, Class factory) {
    return convertFromJson(jo.getJSONObject(s), obj, factory);
  }
  ArrayList aObjectList(String s, ArrayList list, Class factory) {
    JSONArray a = jo.getJSONArray(s);
    if (list == null) 
      list = new ArrayList();
    if (list.size() > a.size()) 
      list.subList(a.size(), list.size()).clear();
    for (int i = 0; i < a.size(); ++i) {
      Object obj = i < list.size() ? list.get(i) : null;
      convertFromJson(a.getJSONObject(i), (Convertible) obj, factory);
      if (i < list.size()) list.set(i, obj); else list.add(obj);
    }
    jo.setJSONArray(s, a);
    return list;
  }
  // Helper function to 1.create obj (if nec), 2. create new Target, 3. copy from tar to obj, 4. return the obj
  Convertible convertFromJson(JSONObject jo, Convertible obj, Class factory) {
    if (obj==null) try {
      obj = (Convertible) factory.newInstance();
    } catch (Exception e) {
      println(e);
      return null;
    }
    TargetForLoad tar = new TargetForLoad(jo);
    obj.convert(tar);
    return obj;
  }
}
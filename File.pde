

void saveStuff() {
  savePause();
  selectOutput("Select a file to save:", "saveCallback");
}

void saveCallback(File selection) {
  if (selection != null) {
    println("User selected " + selection.getAbsolutePath() + " " + selection.getName());
    String name = selection.getName();
    if (name.indexOf('.') < 0) name += ".traffic";
    TargetForSave tar = new TargetForSave();
    World_convert(tar);
    saveJSONObject(tar.jo, "saved-games/" + name);
  }
  restorePause();
}

void loadStuff() {
  savePause();
  selectInput("Select a file to load:", "loadCallback");
}

void loadCallback(File selection) {
  if (selection != null) {
    println("User selected " + selection.getAbsolutePath());
    TargetForLoad tar = new TargetForLoad(loadJSONObject(selection));
    World_convert(tar);
  }
  restorePause();
}


//-------------
boolean savedPause;

void savePause() {
  savedPause = pause;
  pause = true;
}

void restorePause() {
  pause = savedPause;
}
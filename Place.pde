class Place {
  String name;
  Location location;
  SimplePointMarker marker;
  ScreenPosition screenPosition;
  
  Place(String _name, Location _location) {
    name = _name;
    location = _location;
    marker= new SimplePointMarker(_location);
    screenPosition = marker.getScreenPosition(currentMap);
  }
  
  void refreshScreenPosition(){
    screenPosition = marker.getScreenPosition(currentMap);
  }
}

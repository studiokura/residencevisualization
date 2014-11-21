class Artist {
  String id;
  String name;
  String country;
  int year;
  int month;
  String monthname;
  String bio;
  ArrayList<ArtistMoveArc> trips;
  IntList tripTimes;
  
  Artist(String _id, String _name, String _country, int _year, int _month, String _monthname, String _bio) {
    id = _id;
    name = _name;
    country = _country;
    year = _year;
    month = _month;
    monthname = _monthname;
    bio = _bio;
    trips = new ArrayList();
    tripTimes = new IntList();
  }

  void addTrip(int time, String orig, String dest, String placeName){
    tripTimes.append(time);
    Place origPlace = getPlace(orig);
    Place destPlace = getPlace(dest);
    ArtistMoveArc trip;
    //println("adding trip to " + name + " from " + origPlace.name + " to " + destPlace.name);
    origPlace.refreshScreenPosition();
    destPlace.refreshScreenPosition();
    float xpos = origPlace.screenPosition.x;
    float ypos = origPlace.screenPosition.y;
    float txpos = destPlace.screenPosition.x;
    float typos = destPlace.screenPosition.y;
    String countrypos = country;
    String artistPos = name;
    String spacePos = placeName;
    trip = new ArtistMoveArc(xpos, ypos, txpos, typos, countrypos, artistPos, spacePos, orig, dest);
    trip.origName = orig;
    trip.destName = dest;
    trips.add(trip);
  } 
}

import de.fhpotsdam.unfolding.mapdisplay.*;
import de.fhpotsdam.unfolding.utils.*;
import de.fhpotsdam.unfolding.marker.*;
import de.fhpotsdam.unfolding.tiles.*;
import de.fhpotsdam.unfolding.interactions.*;
import de.fhpotsdam.unfolding.ui.*;
import de.fhpotsdam.unfolding.*;
import de.fhpotsdam.unfolding.core.*;
import de.fhpotsdam.unfolding.mapdisplay.shaders.*;
import de.fhpotsdam.unfolding.data.*;
import de.fhpotsdam.unfolding.geo.*;
import de.fhpotsdam.unfolding.texture.*;
import de.fhpotsdam.unfolding.events.*;
import de.fhpotsdam.utils.*;
import de.fhpotsdam.unfolding.providers.*;
import de.fhpotsdam.unfolding.mapdisplay.MapDisplayFactory;
import java.util.Collections;

UnfoldingMap map;

ArrayList<Place> places;
ArrayList<Artist> artists;
ArrayList<Country> countries;
int totalArtists;
int numberOfCountries;
int numberOfCountriesMax = 14;
StringList rankedCountries;
StringList abcCountries;

String title;
Location secondLoopLocation;
int secondLoopZoomLevel;

UnfoldingMap currentMap;
UnfoldingMap mapDetail;
UnfoldingMap map1, map2, map3, map4, map5, map6, map7;

int eSize=5;
int year;
float x;
float y;
float easing = 0.1;
boolean first=true;
int num=0;
int count;
int mapZoom=1;
PFont font, font1, font2, font3;
boolean readyToAddToCountriesList = true;

void setup() {
  size(1200, 800, P2D);
  //size(1200, 800);
  smooth();
  //size(1000, 800);
  frameRate(20);

  //size(1300, 800, OPENGL);
  font=loadFont("SansSerif-24.vlw");
  font1=loadFont("SansSerif-13.vlw");
  font2=loadFont("SansSerif-15.vlw");
  font3=loadFont("SansSerif-18.vlw");
  textFont(font1);
  map1 = new UnfoldingMap(this, 320, 50, 880, 700, new StamenMapProvider.WaterColor());
  map2 = new UnfoldingMap(this, new MapQuestProvider.Aerial());
  map3 = new UnfoldingMap(this, new OpenStreetMap.OpenStreetMapProvider());
  map4 = new UnfoldingMap(this, new OpenMapSurferProvider.Grayscale  ());
  map5 = new UnfoldingMap(this, new AcetateProvider.Basemap  ());
  map6 = new UnfoldingMap(this, new EsriProvider.WorldShadedRelief());//MapQuestProvider
  MapUtils.createDefaultEventDispatcher(this, map1, map2, map3, map4);
  currentMap = map1;
  currentMap.zoomAndPanTo(new Location(30.5f, 30.4f), 2); //World map

  boolean firstrow;

  //Importing artists, trips and locations
  artists = new ArrayList();
  countries = new ArrayList();
  places = new ArrayList();
  //Table artistsTable = loadTable("visualization_data - artists.csv", "header");
  Table artistsTable = loadTable("visualization_data_test - artists.csv", "header");
  totalArtists = artistsTable.getRowCount()-1;
  println(totalArtists + " total rows in artists table"); 
  //Table tripsTable = loadTable("visualization_data - trips.csv", "header");
  Table tripsTable = loadTable("visualization_data_test - trips.csv", "header");
  println((tripsTable.getRowCount()-1) + " total rows in trips table"); 
  firstrow = true;
  for (TableRow row : artistsTable.rows()) {
    if (!firstrow) {
      String artist_id = row.getString("artist_id");
      String fullname = row.getString("fullname");
      String country = row.getString("country");
      boolean countryBool = isCountry(country);
      if (!isCountry(country)) {
        //println("new country: " + country);
        countries.add(new Country(country));
      }
      getCountry(country).addOne();
      //println("the country: " + getCountry(country).name + " people: " + getCountry(country).people);
      int year = row.getInt("year");
      int month = row.getInt("month");
      String monthname = row.getString("monthname");
      String bio = row.getString("bio");
      artists.add(new Artist(artist_id, fullname, country, year, month, monthname, bio));
      //println(artist_id + " (" + fullname + ", " + country + ", " + year + ")");
      for (TableRow row2 : tripsTable.rows()) {
        String artist_id2 = row2.getString("artist_id");
        //println(artist_id + " vs. " + artist_id2 + ": " + (artist_id.equals(artist_id2)));
        if (artist_id.equals(artist_id2)) {
          Artist eachArtist = artists.get(artists.size()-1);
          int tripTime = row2.getInt("delay");
          String tripOrig = row2.getString("origin_location");
          if (!placeExists(tripOrig)) {
            //println(tripOrig + " doesn't exist yet");
            FloatList location = geocode(tripOrig);
            float lat = location.get(0);
            float lng = location.get(1);
            Location lineLocation = new Location(lat, lng);
            //println(location_id + " (" + lat + ", " + lng + ")");
            places.add(new Place(tripOrig, lineLocation));
          } 
          else {
            //println(tripOrig + " already exists");
          }
          String tripDest = row2.getString("destination_location");
          if (!placeExists(tripDest)) {
            //println(tripDest + " doesn't exist yet");
            FloatList location = geocode(tripDest);
            float lat = location.get(0);
            float lng = location.get(1);
            Location lineLocation = new Location(lat, lng);
            //println(location_id + " (" + lat + ", " + lng + ")");
            places.add(new Place(tripDest, lineLocation));
          } 
          else {
            //println(tripOrig + " already exists");
          }
          String tripPlace = row2.getString("destination_name");
          //println(artist_id2 + " (" + tripTime + ", " + tripOrig + ", " + tripDest + ", " + tripPlace + ")");
          eachArtist.addTrip(tripTime, tripOrig, tripDest, tripPlace);
        }
      }
    }
    firstrow = false;
  }

  //Importing settings
  StringList settings = new StringList();
  Table settingsTable = loadTable("visualization_data_test - settings.csv", "header");
  for (TableRow row : settingsTable.rows()) {
    String value = row.getString("value");
    settings.append(value);
  }
  println(settings);
  title = settings.get(0);
  secondLoopLocation = getPlace(settings.get(1)).location;
  secondLoopZoomLevel = int(settings.get(2));
  

  //Getting the country list ready to show how many artists visited
  Collections.sort(countries);
  println(countries);
  numberOfCountries = countries.size();
  if (numberOfCountries > numberOfCountriesMax) {
    numberOfCountries = numberOfCountriesMax;
  }
  rankedCountries = new StringList();
  abcCountries = new StringList();
  for (int i=0; i<numberOfCountries; i++) {
    rankedCountries.append(countries.get(i).name);
    abcCountries.append(countries.get(i).name);
  }
  //println(rankedCountries);
  abcCountries.sort();
  //println(abcCountries);

  year = artists.get(0).year;

  textSize(18);
  smooth();
}

void draw() {
  tint(255);
  background(240);

  currentMap.draw();

  strokeWeight(1);
  noFill();
  fill(255, 0, 0, 200);

  //year 
  textFont(font);
  textSize(24);
  fill(0);
  text(year, 18, 45);

  //title
  textFont(font);
  textSize(24);
  fill(0);
  text(title, 328, 45);

  //country count;
  textSize(14);
  noStroke();
  fill(255, 180);
  rect(10, 50, 300, 290);
  fill(0);
  textFont(font1);
  for (int i=0; i<numberOfCountries; i++) {
    String thisCountryName = abcCountries.get(i);
    Country thisCountry = getCountry(thisCountryName);
    fill(40, 200);
    rect(120, 58+20*i, thisCountry.currentPeople*12, 14);
    fill(40);
    text(thisCountryName, 20, 70+20*i);

    if (thisCountry.currentPeople>0) {
      fill(255);
      text(thisCountry.currentPeople, 120, 70+20*i);
    }
  }

  if (num>=1) {
    //Loop for each artist
    for (int i = totalArtists-1; i>=0; i--) {
      //println("Getting artist " + i + " on num=" + num);
      //Loop for each trip of current artist
      for (int j=0; j<artists.get(i).trips.size(); j++) {
        if (num>=i+1 /*&& j==0*/) {
          artists.get(i).trips.get(j).move(artists.get(i).trips.get(j).targetX, artists.get(i).trips.get(j).targetY, artists.get(i).trips.get(j).originX, artists.get(i).trips.get(j).originY);
        }
        if (num==i+1) {
          year = artists.get(i).year;
          if (j==0) {
            artists.get(i).trips.get(j).bio();
          }
          if (artists.get(i).trips.get(j).count > artists.get(i).tripTimes.get(j)) {
            artists.get(i).trips.get(j).moveName();
          }
        }
      }
    }
  }
  //println("mapZoom"+mapZoom);

  //timer
  count+=6;
  if (count>200) {
    count=0;
    num++;
    readyToAddToCountriesList = true;
    if (num > totalArtists) {
      //map zoom
      mapZoom++;
      if (mapZoom>2) {
        mapZoom=1;
      }
      //println("mapZoom="+mapZoom);
      num=0;
      year = artists.get(0).year;

      if (mapZoom==2) {
        //println("zooming currentMap to mapZoom 2");
        currentMap.zoomAndPanTo(secondLoopLocation, secondLoopZoomLevel); //Detailed map (second loop)
      }
      if (mapZoom==1) {
        //println("zooming currentMap to mapZoom 1");
        currentMap.zoomAndPanTo(new Location(30.5f, 30.4f), 2); //World map
      }

      //Refresh all ArtistMoveArc ScreenPositions
      //println("refreshing all artists");
      for (int i=0; i<artists.size(); i++) {
        Artist eachArtist;
        //println("  refreshing artist #" + (i+1) + " of " + artists.size());
        eachArtist = artists.get(i);
        for (int j=0; j<eachArtist.trips.size(); j++) {
          //println("    refreshing trip #" + (j+1) + " of " + eachArtist.trips.size());
          ArtistMoveArc eachTrip = eachArtist.trips.get(j);
          //println("got the trip");
          Place origPlace = getPlace(eachTrip.origName);
          Place destPlace = getPlace(eachTrip.destName);
          //println("refreshing screen position");
          origPlace.refreshScreenPosition();
          destPlace.refreshScreenPosition();
          float xpos = origPlace.screenPosition.x;
          float ypos = origPlace.screenPosition.y;
          float txpos = destPlace.screenPosition.x;
          float typos = destPlace.screenPosition.y;
          String countrypos = eachArtist.country;
          String artistPos = eachArtist.name;
          String spacePos = eachTrip.space;
          String origName = eachTrip.origName;
          String destName = eachTrip.destName;
          //println("making a new trip");
          ArtistMoveArc newTrip = new ArtistMoveArc(xpos, ypos, txpos, typos, countrypos, artistPos, spacePos, origName, destName);
          //println("replacing the trip");
          eachArtist.trips.set(j, newTrip);
          //println("trip got replaced");
          //println("    refreshed " + eachArtist.name + "'s trip from " + eachTrip.origName + " to " + eachTrip.destName + " (#" + (j+1) + " of " + eachArtist.trips.size() + ")");
        }
      }
      //println("refreshed all artists");

      //country count reset
      for (int i=0; i<numberOfCountries; i++) {
        countries.get(i).currentPeople = 0;
      }
      //Reset all artist trips
      for (int i = 0; i<2; i++) {
        Artist eachArtist = artists.get(i);
        for (int j=0; j<eachArtist.trips.size(); j++) {
          eachArtist.trips.get(i).reset();
        }
      }
    }
    //println("num="+num);
  }
}

void keyPressed() {
  if (key == '1') {
    currentMap = map1;
  } 
  else if (key == '2') {
    currentMap = map2;
  } 
  else if (key == '3') {
    currentMap = map3;
  } 
  else if (key == '4') {
    currentMap = map4;
  } 
  else if (key == '5') {
    currentMap = map5;
  } 
  else if (key == '6') {
    currentMap = map6;
  } 
  else if (key == '7') {
    currentMap = map7;
  }
}

Place getPlace(String name) {
  for (int i=0; i<places.size(); i++) {
    if (name.equals(places.get(i).name)) return places.get(i);
  }
  return null;
}
Artist getArtist(String id) {
  for (int i=0; i<artists.size(); i++) {
    if (id.equals(artists.get(i).id)) return artists.get(i);
  }
  return null;
}
Artist getArtistByFullname(String name) {
  for (int i=0; i<artists.size(); i++) {
    if (name.equals(artists.get(i).name)) return artists.get(i);
  }
  return null;
}
Country getCountry(String name) {
  for (int i=0; i<countries.size(); i++) {
    if (name.equals(countries.get(i).name)) return countries.get(i);
  }
  return null;
}
boolean isCountry(String name) {
  if (countries.size() > 0) {
    for (int i=0; i<countries.size(); i++) {
      if (name.equals(countries.get(i).name)) return true;
    }
  }
  return false;
}
boolean placeExists(String name) {
  if (places.size() > 0) {
    for (int i=0; i<places.size(); i++) {
      if (name.equals(places.get(i).name)) return true;
    }
  }
  return false;
}
FloatList geocode(String place) {
  place = java.net.URLEncoder.encode(place);
  JSONObject json;
  if (fileExists(dataPath("geocoding/" + place + ".json")) == false) {
    println(place + ": fetching the JSON over the internet..."); 
    String lines[] = loadStrings("http://maps.googleapis.com/maps/api/geocode/json?sensor=false&address=" + place);
    saveStrings(dataPath("geocoding/" + place + ".json"), lines);
    //saveStrings(dataPath(place + ".json"), lines);

    //json = loadJSONObject("http://maps.googleapis.com/maps/api/geocode/json?sensor=false&address=" + place);
  }
  else {
    //println(place + ": JSON cached on disk");
  }
  json = loadJSONObject("geocoding/" + place + ".json");
  JSONArray results = json.getJSONArray("results");
  JSONObject result = results.getJSONObject(0);
  JSONObject geometry = result.getJSONObject("geometry");
  JSONObject location = geometry.getJSONObject("location");
  FloatList ret = new FloatList();
  ret.append(location.getFloat("lat"));
  ret.append(location.getFloat("lng"));
  return ret;
}
boolean fileExists(String path) {
  File file=new File(path);
  boolean exists = file.exists();
  if (exists) {
    return true;
  }
  else {
    return false;
  }
} 


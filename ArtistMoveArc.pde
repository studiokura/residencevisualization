class ArtistMoveArc {
  float x;
  float y;
  float originX;
  float originY;
  String origName;
  float targetX;
  float targetY;
  String destName;
  String country;
  String artist;
  String space;
  int a=255; //line alfa
  int b=0;//image alfa;
  int countInc=6;
  int count;
  PImage art;
  int imageSize=80;
  int size=5;
  int size2=5;
  int time, time2;
  boolean go;
  ArtistMoveArc(float xpos, float ypos, float txpos, float typos, String countrypos, String artistPos, String spacePos, String orig, String dest) {
    x=xpos;
    y=ypos;
    originX=xpos;
    originY=ypos;
    targetX=txpos;
    targetY=typos;
    country=countrypos;
    artist=artistPos;
    space=spacePos;
    origName = orig;
    destName = dest;
    go = true;
  }
  void move(float tX, float tY, float sX, float sY) {
    for (int i=0; i<numberOfCountries; i++) {
      //if (go == true) {
      if (readyToAddToCountriesList) {
        if (country.equals(countries.get(i).name)) {
          //println("Increasing " + country + " by 1. go=" + go); 
          countries.get(i).currentPeople ++;
          go=false;
          readyToAddToCountriesList = false;
          //println("Increased " + country + " by 1. go=" + go);
        }
      }
    }
    randomSeed(0);
    int yRandom=int(random(50));
    //artist name
    textFont(font2);
    textSize(18);  
    noStroke();
    fill(255, a);
    // text(artist, sX-50, sY-yRandom);

    //space name
    text(space, tX-50, tY-yRandom);
    fill(0, 0, 255);
    ellipse(tX, tY, size2, size2);

    fill(255, 0, 0);

    time++;
    size=12;
    if (time>1*2) {
      size=5;
    }

    ellipse(sX, sY, size, size);

    //alfa 
    a-=5;

    if (a<0) {
      a=0;
    }

    float d=dist(sX, sY, tX, tY);

    beginShape();
    noFill();
    vertex(sX, sY);
    stroke(255, 0, 0, a+100);
    bezierVertex(sX, sY-d/1.5, tX, tY-d/1.5, tX, tY);
    endShape();

    count+=countInc;
    if (count>150) {
      countInc=0;
    }
  }

  void bio() {

    noStroke();
    //background for artist bio
    fill(255, 180);
    rect(10, 350, 300, 400);
    //artist bio
    textFont(font1);
    textSize(13);
    fill(0, a+100);

    Artist theArtist = getArtistByFullname(artist);
    String profileName = theArtist.name;
    String profileResidence = theArtist.country + " / Residency: " + theArtist.monthname + " " + theArtist.year;
    String profileFull = theArtist.bio;
    textFont(font2);
    textSize(15);
    text(profileName, 20, 380+imageSize, 280, 400);
    textSize(15);
    textFont(font1);
    text(profileResidence, 20, 380+imageSize + 25, 280, 400);
    textSize(13);
    int spacing = 50;
    //if(match(profileResidence, "Born:") != null) spacing += 25;
    //if(match(profileResidence, "Residencies:") != null) spacing += 25;
    //if(match(profileResidence, ".*/.*/.*") != null) spacing += 25;
    //println(profileResidence.length());
    if (profileResidence.length() > 35) spacing += 25;
    text(profileFull, 20, 380+imageSize + spacing, 280, 400);

    //artist image
    String artistPhoto=(theArtist.id+".jpg");
    if (fileExists(dataPath(artistPhoto))) {
      art=loadImage(artistPhoto);
    }
    else {
      art=loadImage("_nopicture_artist.png");
    }
    tint(255, a+100); 
    image(art, 20, 360, imageSize, imageSize);
    //println(country);
  }

  void moveName() {
    float dx = targetX - x;
    if (abs(dx) > 1) {
      x += dx * easing;
    }  
    float dy = targetY - y;
    //y=sY;
    if (abs(dy) > 1) {
      y += dy * easing;
    }
    if (dist(x, y, targetX, targetY)<50) {
      time2++;
      size2=12;
      if (time2>1*2) {
        size2=5;
      }
    }
    fill(0, a);
    textSize(12);
    text(artist, x, y);
  }

  void reset() {
    time=0;
    time2=0;
    a=255;
  }
}


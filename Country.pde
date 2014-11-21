class Country implements Comparable {
  String name;
  int people;
  int currentPeople;

  Country(String _name) {
    name = _name;
    currentPeople = 0;
  }

  // Adds one to the final total of artists
  int addOne() {
    people++;
    return people;
  }

  // Adds one to the number of artist that have already been shown
  int update() {
    currentPeople++;
    return currentPeople;
  }

  int getValue() {
    return people;
  }

  String toString() {
    return name + " (" + str(people) + ")";
  }

  public int compareTo(Object o) {
    Country n = (Country) o;
    int i1 = getValue();
    int i2 = n.getValue();
    return i1 == i2 ? 0 : (i1 > i2 ? -1 : 1);
  }
}


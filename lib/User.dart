


  class User {
    int id;
    String name;

    User({this.id = 0, this.name = ''});

    // Other methods or properties in the class...

    // Convert User object to a Map
    Map<String, dynamic> toMap({bool excludeId = false}) {
      Map<String, dynamic> map = {
        'name': name,
      };
      if (!excludeId) {
        map['id'] = id;
      }
      return map;
    }
  }



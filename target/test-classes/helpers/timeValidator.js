function fn(s) {
    var dateTimeFormatter = Java.type("java.time.format.DateTimeFormatter");
    var resolverStyle = Java.type("java.time.format.ResolverStyle");
    var dateFormatter = dateTimeFormatter.ofPattern("yyyy-MM-dd").withResolverStyle(resolverStyle.STRICT);

    try {
      dateFormatter.parse(s);
      return true;
    } catch(e) {
      karate.log('*** invalid date string:', s);
      return false;
    }

  } 
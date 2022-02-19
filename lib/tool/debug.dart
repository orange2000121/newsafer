/*
 * Copyright 2021 R-Dap
 * 
 * @Author: XiaNight 賴資敏
*/

class Printcolor {
  static void log(String message, {String color = '', String? backgroundcolor}) {
    print('\u001b[0m$backgroundcolor$color$message\u001b[0m');
  }
}

void printcolor(String message, {String color = '', String? backgroundcolor}) {
  print('\u001b[0m$backgroundcolor$color$message\u001b[0m');
}

class DColor {
  /// Error or important messages.]
  static final String red = '\u001b[31m';

  /// Starting or Success messages.
  static final String green = '\u001b[32m';

  /// Highlighted logs.
  static final String yellow = '\u001b[33m';

  /// Highlighted messages.
  static final String blue = '\u001b[34m';

  /// Important messages 2.
  static final String magenta = '\u001b[35m';

  /// Important messages.
  static final String cyan = '\u001b[36m';

  /// normal messages.
  static final String white = '\u001b[37m';

  /// Warning messages.
  static final String orange = '\u001b[38;5;202m';
}

class BackGroundColor {
  static final String blackBackground = "\u001B[40m";
  static final String redBackground = "\u001B[41m";
  static final String greenBackground = "\u001B[42m";
  static final String yellowBackground = "\u001B[43m";
  static final String blueBackground = "\u001B[44m";
  static final String purpleBackground = "\u001B[45m";
  static final String cyanBlackground = "\u001B[46m";
  static final String whiteBlackground = "\u001B[47m";
}

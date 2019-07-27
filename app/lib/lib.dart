library streamini;

import 'dart:math' as math;

class Uuid 
{
  static math.Random _random = math.Random();
  static String createUUID() {
    return s4()+s4()+"-"+s4()+"-"+s4()+"-"+s4()+"-"+s4()+s4()+s4();
  }
  static String s4() {
    return (_random.nextInt(0xFFFF)+0x10000).toRadixString(16).substring(0,4);
  }
}
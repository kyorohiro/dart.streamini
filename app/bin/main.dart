import 'dart:io' as io;
import 'package:args/args.dart' as args;
import 'dart:math' as math;

class CommandArguments {
  String _address;
  int _port;
  String get address => _address;
  int get port => _port;
  String _outputDir;
  String get outputDir => _outputDir;
  CommandArguments._empty();

  static CommandArguments arges(List<String> arguments) {
    args.ArgParser parser = args.ArgParser();
    parser.addOption("address", abbr: 'a', defaultsTo: "0.0.0.0", help: "binding address");
    parser.addOption("port", abbr: 'p', defaultsTo: "80", help: "binding port");
    parser.addOption("output-dir", abbr: 'o', defaultsTo: "./.o", help: "output dir");

    args.ArgResults result =  parser.parse(arguments);
    String address = result["address"];
    String port = result["port"];
    
    print("addr:${address},port:${port}");
    return CommandArguments._empty()
      .._address= address
      .._port= int.parse(port);
  }
}

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

class FilePath {
  String _date;
  String _uuid;

  String get date => _date;
  String get uuid => _uuid;
  
  FilePath.fromCurrentFateTime() {
    DateTime datetime = DateTime.now();
    String y = datetime.year.toString();
    String m = zeroFilling(datetime.month.toString());
    String d = zeroFilling(datetime.day.toString());
    String s = zeroFilling(datetime.second.toString());
    this._date = "${y}_${m}_${d}_${s}";
    this._uuid = Uuid.createUUID();
  }

  @override
  String toString(){
    return this._date+"/"+this._uuid;
  }

  String zeroFilling(String v) {
    int numOfFilling = 2- v.length;
   
    for(int i=0;i<numOfFilling;i++){
      v = "0"+ v;
    }
    return v;
  }
 
}

main(List<String> arguments) async {
  CommandArguments args = CommandArguments.arges(arguments);
  io.HttpServer server = await io.HttpServer.bind(args._address, args._port);
  print("binding");
  server.listen((io.HttpRequest req){
    FilePath fp = FilePath.fromCurrentFateTime();
    req.listen((List<int> bytes){
      
    });
    req.response.write("xxx");
    req.response.close();
  });
}

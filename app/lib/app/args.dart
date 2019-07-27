import 'package:args/args.dart' as args;

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
    String outputDir = result["output-dir"];
    
    print("addr:${address},port:${port}");
    return CommandArguments._empty()
      .._address= address
      .._port= int.parse(port)
      .._outputDir = outputDir;
  }
}

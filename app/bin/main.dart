import 'dart:io' as io;
import 'package:args/args.dart' as args;
import 'package:streamini/app/db.dart';
import 'package:streamini/lib.dart' as lib;
import 'package:streamini/app.dart';


onUploadRequest(DB db, io.HttpRequest req) async {
    FilePath fp = FilePath.fromCurrentDateTime();
    Writer writer = await db.createWriter();
    req.listen((List<int> bytes){
      writer.add(bytes);
    }).onDone((){
      writer.close();
      req.response.close();
    });
}

onMessageRequest(DB db, io.HttpRequest req) async {
    FilePath fp = FilePath.fromCurrentDateTime();
    Writer writer = await db.createWriter();
    req.listen((List<int> bytes){
      writer.add(bytes);
    }).onDone((){
      writer.close();
      req.response.close();
    });
}

main(List<String> arguments) async {
  CommandArguments args = CommandArguments.arges(arguments);
  //
  //
  DB db = await DB.create(args.outputDir);

  //
  //
  io.HttpServer server = await io.HttpServer.bind(args.address, args.port);
  print("binding");
  server.listen((io.HttpRequest req) async {
    print("path==>${req.uri.path}");
    if(req.uri.path.startsWith("/upload")) {
      onUploadRequest(db, req);
    } 
    else if(req.uri.path.startsWith("/stream")) {
      
    }
  });
}

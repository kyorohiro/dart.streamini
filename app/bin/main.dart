import 'dart:io' as io;
import 'dart:typed_data';
import 'package:streamini/app/db.dart';
import 'package:streamini/app.dart';


const String uploadPath = "/upload";
const String streamPath = "/stream";
const String viewPath = "/view";

onUploadRequest(DB db, io.HttpRequest req) async {
    Writer writer;
    try {
      writer = await db.createWriter();
    } catch(e){
    }

    try {
      await for(List<int> bytes in req) {
        writer.add(bytes);
      }
      req.response.write("id:"+writer.uuid);
    } catch(e){
    }
    try {
      writer.close();
    } catch(e){
    }

    try{
      await req.response.close();
    } catch(e){
    }

}

onMessageRequest(DB db, io.HttpRequest req) async {
    Writer writer;
    try {
      writer =  await db.createWriterFromUuid(req.uri.path.replaceFirst( streamPath+"/", ""));
      await for(List<int> bytes in req) {
        writer.add(bytes);
      }
      await req.response.write("id:"+writer.uuid);
    }catch(e){
      print(e);
    }
    try {
      writer.close();
    } catch(e){
      print(e);
    }

    try{
      await req.response.close();
    } catch(e){
      print(e);
    }

}

onView(DB db, io.HttpRequest req) async {
      String uuid = req.uri.path.replaceFirst(viewPath+"/", "");
      Uint8List buffer = Uint8List(10*1000);
      int length = 0;
      Reader reader;
      try {
        reader = await db.createReaderFromUuid(uuid);
      } catch(e){
        print(e);
      }
      try {
      do{
        length = await reader.readInto(buffer);
        if(length <= 0) {
          break;
        }
        if(buffer.length == length) {
          req.response.add(buffer);
        }else {
          req.response.add(buffer.sublist(0, length));
        }
      }while(true);
      } catch(e){
        print(e);
      }
      try {
        await reader.close();
      } catch(e){
        print(e);
      }
      try {
        await req.response.close();
      } catch(e){
        print(e);
      }
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
    print("path==>${req.uri.path}<==");
    try {
      if(req.uri.path.startsWith(uploadPath)) {
        onUploadRequest(db, req);
      } 
      else if(req.uri.path.startsWith(streamPath)) {
        onMessageRequest(db, req);
      }
      else if(req.uri.path.startsWith(viewPath)){
        onView(db, req);
      }
      else {
        req.response.write("Hello!!");
        await req.response.close();
      }
    } catch(e){
      print(e);
      try{
        await req.response.close();
      }catch(e){
        print(e);
      }
    }
  });
}

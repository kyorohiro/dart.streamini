import 'package:streamini/lib.dart' as lib;
import 'dart:io' as io;
import 'package:path/path.dart' as path;

class DB {
  String _outputDir;
  String get outoutDir => _outputDir;

  DB._empty();
  static Future<DB> create(String outputDir) async {
    String out = "";
    if(path.isAbsolute(outputDir)) {
      out = outputDir;
    } else {
      out = path.join(io.Directory.current.path, outputDir);
    }

    DB db = DB._empty().._outputDir = out;
    return db;
  }

  init() async {
    io.Directory dir = io.Directory(outoutDir);
    if(!await dir.exists()) {
      await dir.create(recursive: true);
    }  
  }

  Future<Writer> createWriter() async {
    FilePath fp = FilePath.fromCurrentFateTime();
    io.File file = new io.File(path.join(this.outoutDir, fp.toString()));
    io.Directory dir = file.parent;
//    if(!await dir.exists()) {
//      await dir.create(recursive: true);
 //   } 

    Writer w = Writer(await file.create(recursive: true));
    await w.init();
    return w;
  }
}

class Writer {
  io.File output;
  io.RandomAccessFile rand;
  int index = 0;

  List<List<int>> _stack = [];
  
  Writer(this.output) {
  }

  init() async {
    if(!await output.exists()) {
      await output.create(recursive: true);
    }
    this.rand =  await output.open(mode: io.FileMode.write);
    if(rand == null){
      print("======================================ZAS=");
    }
  }

  bool acting = false;
  bool isClose = false;
  act() async {
    if(acting){
      return;
    }
    acting = true;
    while(this._stack.length > 0) {
      List<int> data = this._stack.removeAt(0);
      await this.rand.writeFrom(data);
      index = data.length;
    }
    acting = false;
    if(isClose) {
      if(rand != null){
      await rand.close();
      }
    }
  }
  

  add(List<int> data, {int start=0, int end}) async {
   if(end == null) {
     end = data.length;
   }
   _stack.add(data.sublist(start,end));
  }

  close() {
    isClose = true;
    act();
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
    this._uuid = lib.Uuid.createUUID();
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

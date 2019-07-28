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
    FilePath fp = FilePath.fromCurrentDateTime();
    io.File file = io.File(path.join(this.outoutDir, fp.toString()));
    Writer w = Writer(await file.create(recursive: true));
    await w.init();
    return w;
  }

  Future<Writer> createWriterFromUuid(String uuid) async {
    FilePath fp = FilePath.fromCurrentDateTime();
    io.File file = io.File(path.join(this.outoutDir, uuid));
    Writer w = Writer(await file.create(recursive: true));
    await w.init(index: await file.length());
    return w;
  }
}

class Writer {
  io.File output;
  io.RandomAccessFile rand;
  int _index = 0;

  List<List<int>> _stack = [];
  
  Writer(this.output) {
  }

  init({index=0}) async {
    _index = index;
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
    while(this._stack.isNotEmpty) {
      List<int> data = this._stack.removeAt(0);
      await this.rand.setPosition(_index);
      await this.rand.writeFrom(data);
      _index += data.length;
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
  String _time;
  String _uuid;

  String get date => _date;
  String get time => _time;
  String get uuid => _uuid;
  
  FilePath.fromCurrentDateTime() {
    DateTime datetime = DateTime.now();
    String y = datetime.year.toString();
    String m = zeroFilling(datetime.month.toString());
    String d = zeroFilling(datetime.day.toString());
    String h = zeroFilling(datetime.hour.toString());
    String mi = zeroFilling(datetime.minute.toString());
    String s = zeroFilling(datetime.second.toString());
    this._date = "${y}_${m}_${d}";
    this._time = "${h}_${mi}";//_${s}";
    this._uuid = lib.Uuid.createUUID();
  }

  @override
  String toString(){
    return this._date+"/"+this._time+"/"+this._uuid;
  }

  String zeroFilling(String v) {
    int numOfFilling = 2- v.length;
   
    for(int i=0;i<numOfFilling;i++){
      v = "0"+ v;
    }
    return v;
  }
 
}

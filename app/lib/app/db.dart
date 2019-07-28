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
    Writer w = Writer(await file.create(recursive: true),fp.toString());
    await w.init();
    return w;
  }

  Future<Writer> createWriterFromUuid(String uuid) async {
    uuid = uuid.replaceAll(".", "-");
    if(uuid.contains(new RegExp("""[^a-zA-Z0-9/]""")) && uuid.length > 1024) {
      throw "worng param";
    }
    io.File file = io.File(path.join(this.outoutDir, uuid));
    try{
      Writer w = Writer(await file.create(recursive: true),uuid);
      await w.init(index: await file.length());
      return w;
    } catch(e){
      
    }
  }

  Future<Reader> createReaderFromUuid(String uuid) async {
    io.File file = io.File(path.join(this.outoutDir, uuid));
    Reader r = Reader(file);
    await r.init(index: await file.length());
    return r;
  }
}

class Reader {
  io.File input;
  io.RandomAccessFile rand;
  int _index = 0;

  List<List<int>> _stack = [];
  
  Reader(this.input);

  init({index=0}) async {
    _index = index;
    if(!await input.exists()) {
      throw "not found";
    }
    this.rand =  await input.open(mode: io.FileMode.read);
    if(rand == null){
      print("======================================ZAS=");
    }
  }

  Future<int> readInto(List<int> buffer, {int start=0, int end}) async {
   return rand.readInto(buffer,start=start,end=end);
  }

  close() {
    this.rand.close();
  }
}

class Writer {
  io.File output;
  io.RandomAccessFile rand;
  int _index = 0;
  String uuid;

  List<List<int>> _stack = [];
  
  Writer(this.output,this.uuid) {
  }

  init({index=0}) async {
    _index = index;
    if(!await output.exists()) {
      await output.create(recursive: true);
    }
    io.FileMode mode = io.FileMode.write;
    if(index == 0) {
      mode = io.FileMode.write;
    } else {
      mode = io.FileMode.append;
    }
    this.rand =  await output.open(mode: mode);
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
   act();
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

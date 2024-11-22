import 'dart:io';
import 'dart:ui';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:excel/excel.dart';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pick_or_save/pick_or_save.dart';
import 'package:path/path.dart' as path;

class Download_Page extends StatefulWidget{
  final List<int> absent_present;
  final String file_path;
  Download_Page({required this.absent_present,required this.file_path});

  @override
  State<StatefulWidget> createState() => _Download_Page();
}

class _Download_Page extends State<Download_Page>{

  var dummy_file;
  var filePath;
  //Building Excel Start
  @override
  void initState() {
    super.initState();
    buildExcelsheet(widget.absent_present,widget.file_path);
  }

  buildExcelsheet(List<int> absent_present,String file_path) async{
    print("My 0's 1's list $absent_present");
    if(absent_present.length==0) return;
    //Selected file
    var file = file_path;
    var bytes = File(file).readAsBytesSync();
    var selectedExcel = Excel.decodeBytes(bytes);
    print(selectedExcel["Sheet1"].sheetName);
    Sheet sheetObject = selectedExcel["Sheet1"];
    String sheetName = sheetObject.sheetName;



    //Assets File
    // 'assets/excel_sheets/dummy_excel.xlsx' copying actual excel to assets excel
    ByteData data = await rootBundle.load('assets/excel_sheets/dummy_excel.xlsx');
    var dummy_bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    dummy_file = Excel.decodeBytes(dummy_bytes);
    Sheet dummyObject = dummy_file["Sheet1"];
    String dummyName = dummyObject.sheetName;


    for(int i=0;i<sheetObject.maxRows;i++){
      var cell1 = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i));
      var cell2 = dummyObject.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i));
      cell2.value = cell1.value;
      cell1 = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i));
      cell2 = dummyObject.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i));
      cell2.value = cell1.value;
      cell2 = dummyObject.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i));
      cell2.value = TextCellValue('Absent');
    }

    //After copying printing assets XL
    for(int i=0;i<sheetObject.maxRows;i++){
      var cell1 = dummyObject.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i));
      var cell2 = dummyObject.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i));
      var cell3 = dummyObject.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i));
      String str1 = cell1.value.toString();
      String str2 = cell2.value.toString();
      String str3 = cell3.value.toString();
      print("dummy before  $str1 $str2 $str3");
    }

    //Marking Attendance
    for(int i=0;i<absent_present.length;i++)
      {
        var cell = dummyObject.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i));
        if(absent_present[i]==1) cell.value = TextCellValue('Present');
      }

    //After Marking Attendance assets XL
    for(int i=0;i<sheetObject.maxRows;i++){
      var cell1 = dummyObject.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i));
      var cell2 = dummyObject.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i));
      var cell3 = dummyObject.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i));
      String str1 = cell1.value.toString();
      String str2 = cell2.value.toString();
      String str3 = cell3.value.toString();
      print("dummy after  $str1 $str2 $str3");
    }

    var fileBytes = dummy_file.save();
    var directory = await getApplicationDocumentsDirectory();
    filePath = path.join(directory.path, 'Today_Attendance.xlsx');
    File(filePath)
      ..createSync(recursive: true)
      ..writeAsBytesSync(fileBytes);
    print("File saved inside App at: $filePath");

  }
  //Building Excel End




  //Permission Handling
  bool permissionGranted = false;
  Future<void> _getStoragePermission() async {
    DeviceInfoPlugin plugin = DeviceInfoPlugin();
    AndroidDeviceInfo android = await plugin.androidInfo;
    if (android.version.sdkInt < 33) {
      if (await Permission.storage.request().isGranted) {
        setState(() {
          permissionGranted = true;
        });
      } else if (await Permission.storage.request().isPermanentlyDenied) {
        await openAppSettings();
      } else if (await Permission.audio.request().isDenied) {
        setState(() {
          permissionGranted = false;
        });
      }
    } else {
      if (await Permission.photos.request().isGranted) {
        setState(() {
          permissionGranted = true;
        });
      } else if (await Permission.photos.request().isPermanentlyDenied) {
        await openAppSettings();
      } else if (await Permission.photos.request().isDenied) {
        setState(() {
          permissionGranted = false;
        });
      }
    }
  }


  //Saving/Downloading files
  save_file() async {

    if(widget.absent_present.length==0)
      {
        var directory = await getApplicationDocumentsDirectory();
        filePath = path.join(directory.path, 'Today_Attendance.xlsx');
        print("Trying to Save prev which is at: $filePath");
        var bytes = File(filePath).readAsBytesSync();
        dummy_file = Excel.decodeBytes(bytes);
        final uint8List = await dummy_file.encode();
        List<String>? result = await PickOrSave().fileSaver(
            params: FileSaverParams(
              saveFiles: [
                SaveFileInfo(
                    fileData: uint8List,
                    fileName: "Previous_Sheet.xlsx")
              ],
            )
        );
        String savedFilePath = result![0];
        print("Saved test file path as Len 0: $savedFilePath");
        return;
      }

    else{
      final uint8List = await dummy_file.encode();
      List<String>? result = await PickOrSave().fileSaver(
          params: FileSaverParams(
            saveFiles: [
              SaveFileInfo(
                  fileData: uint8List,
                  fileName: "Atttendance_Sheet.xlsx")
            ],
          )
      );
      String savedFilePath = result![0];
      print("Saved test file path: $savedFilePath");
    }



  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        leading: IconButton(
          icon: Icon(Icons.home),
          onPressed: () => Navigator.popUntil(context, ModalRoute.withName('/')),
        ),
        title: const Text("AutoXL"),
        titleTextStyle: TextStyle(
            fontWeight: FontWeight.bold, fontSize: 25, color: Colors.black),
        shadowColor: Colors.black,
        elevation: 10,
      ),
      body: Center(
        child: Container(
          color: Colors.grey[800],
          width: 400,
          child: Column(
            children: [

              const SizedBox(height: 40),
              Image.asset('assets/images/All_set_image-min.png',width: 300,),

              const SizedBox(height: 40),
              //Download Excel button
              SimpleElevatedButtonWithIcon(
                label: const Text('Download XLS'),
                iconData: Icons.download,
                color: Colors.blue[300],
                onPressed: () {
                  //Navigator.push(context, MaterialPageRoute(builder: (context)=>  Speech_recog_page() ));
                  _getStoragePermission();
                  save_file();
                },
                fontsize: 25,
              ),

              const SizedBox(height: 10),

              //Go Home button
              SimpleElevatedButtonWithIcon(
                label: const Text('Go Back Home'),
                iconData: Icons.home,
                color: Colors.blue[300],
                onPressed: () {
                  Navigator.popUntil(context, ModalRoute.withName('/'));
                },
                fontsize: 25,
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

}



class SimpleElevatedButtonWithIcon extends StatelessWidget {
  const SimpleElevatedButtonWithIcon(
      {required this.label,
        this.color,
        this.iconData,
        required this.onPressed,
        this.padding = const EdgeInsets.symmetric(horizontal: 44, vertical: 16),
        this.fontsize,
        Key? key})
      : super(key: key);
  final Widget label;
  final Color? color;
  final IconData? iconData;
  final Function onPressed;
  final EdgeInsetsGeometry padding;
  final double? fontsize;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed as void Function()?,
      icon: Icon(iconData),
      label: label,
      style: ElevatedButton.styleFrom(backgroundColor: color, padding: padding,textStyle: TextStyle(fontSize: fontsize,fontWeight: FontWeight.bold)),
    );
  }

}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:autoxl/Download_page.dart';
import 'package:excel/excel.dart' as ex;

class Manual_page extends StatefulWidget{
  final String file_path;
  Manual_page({required this.file_path});

  @override
  State<StatefulWidget> createState() => _Manual_page();
}

class _Manual_page extends State<Manual_page>{

  List<int> absent_present =[];
  late ex.Sheet sheetObject;
  int curr_index = 0;
  List<Map<String, String>> listOfColumns = [
   // {"Roll": "04E8", "Name": "Kranthi", "Marking": "Present"},
  ];
  final ScrollController _scrollController = ScrollController();


  @override
  void initState() {
    super.initState();
    buildExcelsheet(widget.file_path);

    // Scroll to the end after the widget is built
  }

  buildExcelsheet (String file_path) async{
    var file = file_path;
    var bytes = File(file).readAsBytesSync();
    var selectedExcel = ex.Excel.decodeBytes(bytes);
    print(selectedExcel["Sheet1"].sheetName);
    sheetObject = selectedExcel["Sheet1"];
    String sheetName = sheetObject.sheetName;
  }

  add_to_livetable(int i,int val_0_1){
    var cell1 = sheetObject.cell(ex.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i));
    var cell2 = sheetObject.cell(ex.CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i));
    Map<String, String> temp;
    String rollno = cell1.value.toString().substring(5,);

    String name='';
    if( cell2.value.toString().length>11)
    name = cell2.value.toString()[0]+cell2.value.toString().substring(1,10).toLowerCase();
    else
      name = cell2.value.toString()[0]+cell2.value.toString().substring(1,).toLowerCase();



    if(val_0_1==1)
    temp = {"Roll": rollno, "Name":  name, "Marking": "Present"};
    else
    temp = {"Roll": rollno, "Name": name, "Marking": "Absent"};
    listOfColumns.add(temp);
    print("Im added: $temp");
    setState(() {
    });


    Future.delayed(Duration(milliseconds: 100), () {
      _scrollToEnd();
    });
  }


  void _scrollToEnd() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text("AutoXL"),
        titleTextStyle: TextStyle(
            fontWeight: FontWeight.bold, fontSize: 25, color: Colors.black),
        shadowColor: Colors.black,
        elevation: 10,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                //Minus button
                ElevatedButton(
                  onPressed: () {
                    absent_present.add(0);
                    add_to_livetable(curr_index,0);
                    curr_index++;
                  },
                  child: Icon(Icons.remove_circle,color: Colors.black),
                  style: ButtonStyle(
                    shape: WidgetStateProperty.all(CircleBorder()),
                    padding: WidgetStateProperty.all(EdgeInsets.all(20)),
                    backgroundColor: WidgetStateProperty.all(Colors.blue), // <-- Button color
                    overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
                      if (states.contains(WidgetState.pressed)) return Colors.red; // <-- Splash color
                    }),
                  ),
                ),

                //Reset button
                ElevatedButton(
                  onPressed: () {
                    absent_present = [];
                    listOfColumns = [];
                    curr_index=0;
                    setState(() {
                    });
                  },
                  child: Icon(Icons.refresh,color: Colors.black),
                  style: ButtonStyle(
                    shape: WidgetStateProperty.all(CircleBorder()),
                    padding: WidgetStateProperty.all(EdgeInsets.all(20)),
                    backgroundColor: WidgetStateProperty.all(Colors.blue), // <-- Button color
                    overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
                      if (states.contains(WidgetState.pressed)) return Colors.red; // <-- Splash color
                    }),
                  ),
                ),

                //Add button
                ElevatedButton(
                  onPressed: () {
                    absent_present.add(1);
                    add_to_livetable(curr_index,1);
                    curr_index++;
                  },
                  child: Icon(Icons.add_circle,color: Colors.black),
                  style: ButtonStyle(
                    shape: WidgetStateProperty.all(CircleBorder()),
                    padding: WidgetStateProperty.all(EdgeInsets.all(20)),
                    backgroundColor: WidgetStateProperty.all(Colors.blue), // <-- Button color
                    overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
                      if (states.contains(WidgetState.pressed)) return Colors.red; // <-- Splash color
                    }),
                  ),
                ),
              ],
            ),


            //Live XL filling view
        Container(
          height: 400,
          width: 325,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black,
              width: 2,
            ),
            color: Colors.yellow[500],
            borderRadius: BorderRadius.circular(20),
          ),

          child: SingleChildScrollView(
            scrollDirection: Axis.vertical, // Scroll vertically
            controller: _scrollController,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal, // Scroll horizontally if needed
              child: DataTable(
                columns: [
                  DataColumn(label: Text('Roll no')),
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Marking')),
                ],
                rows: listOfColumns
                    .map(
                      (element) => DataRow(
                    cells: <DataCell>[
                      DataCell(Text(element["Roll"]!)),
                      DataCell(Text(element["Name"]!)),
                      DataCell(Text(element["Marking"]!)),
                    ],
                  ),
                )
                    .toList(),
              ),
            ),
          ),

        ),




            //Submit button
            ElevatedButton(
              child: Text('Submit',style: TextStyle(color: Colors.black),),
              onPressed: () {
                Navigator.push(context,PageTransition(type: PageTransitionType.rightToLeft,
                    child: Download_Page(absent_present: absent_present,file_path: widget.file_path)));
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  textStyle: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      )),
            ),




          ],
        ),
      ),
    );
  }

}

import 'dart:collection';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:autoxl/Download_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:excel/excel.dart' as ex;

class Speech_recog_page extends StatefulWidget {

  final int index_no;
  final List<String> allfiles;
  Speech_recog_page({required this.index_no,required this.allfiles});

  @override
  State<StatefulWidget> createState() => _speech_recog_page();
}

class _speech_recog_page extends State<Speech_recog_page> {
  Color cellColor = Colors.red;
  String cellText = 'Unmute';

  //Speech Recognition Start
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _wordsSpoken = '';
  List<int> absent_present=[];

  @override
  void initState() {
    super.initState();
    initspeech();
  }

  void initspeech() async{
    _speechEnabled = await _speechToText.initialize();
    setState(() { });
  }

  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _wordsSpoken = result.recognizedWords;
    });
  }

  //Speech Recognition End


  //Fill 0's 1's
  fill_0s_1s() async{
    List<String> arr = _wordsSpoken.split(" ");
    final hs = HashSet<String>();
    for(String word in arr)
    {
      if(word.toLowerCase() != 'present') hs.add(word);
    }

    //Selected file
    var file = widget.allfiles[widget.index_no];
    var bytes = File(file).readAsBytesSync();
    var selectedExcel = ex.Excel.decodeBytes(bytes);
    print(selectedExcel["Sheet1"].sheetName);
    ex.Sheet sheetObject = selectedExcel["Sheet1"];
    String sheetName = sheetObject.sheetName;

    //Making 0's 1's list
    for(int i=0;i<sheetObject.maxRows;i++){
      var cell = sheetObject.cell(ex.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i));
      String str1 = cell.value.toString();
      str1 = str1.substring(str1.length-2);
      if(hs.contains(str1)) absent_present.add(1);
      else absent_present.add(0);
    }
    print("Voice based rolls: $hs");
    print("Absent Present List using Voice: $absent_present");
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
              Container(
                margin: EdgeInsetsDirectional.only(
                    start: 20, top: 10, end: 20, bottom: 0),
                padding: EdgeInsetsDirectional.all(20),
                decoration: BoxDecoration(
                    color: cellColor,
                    border: Border.all(
                      color: Colors.grey,
                      width: 2,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.grey,
                        blurRadius: 20,
                      ),
                    ]),
                child: Column(
                  children: [
                    InkWell(
                        onTap: () {
                          print("GGGGGGGGGGGGGGGGGGGGGGGGGGG");
                          change_mic_bg();

                          print("HHHHHHHHHHHHHHHHHHHHHHHHHHH");
                        },
                        customBorder: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child:  const  Icon(
                          Icons.mic,
                          color: Colors.black,
                          size: 150.0,
                          shadows: [
                            Shadow(
                                blurRadius: 10,
                                offset: Offset(4, 3),
                                color: Colors.grey)
                          ],
                        )),
                    Text(
                      "" + cellText.toString(),
                      style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          fontFamily: GoogleFonts.oswald().fontFamily),
                    ),
                  ],
                ),

              ),


              // Live Text Box
              Container(
                  height: 300,
                  width: 300,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(border: Border.all(width: 2),color: Colors.grey[300],borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                     BoxShadow(
                    offset: Offset(
                      5.0,
                      5.0,
                    ),
                    blurRadius: 10.0,
                    spreadRadius: 2.0,
                  )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SingleChildScrollView(
                      child: Text("LIVE TXT: \n $_wordsSpoken")
                      ),


                      //Clear box floating button
                      Align(
                        alignment: Alignment.bottomRight,
                        child: FloatingActionButton(
                          onPressed: () {
                            _stopListening();
                            _wordsSpoken ="";
                            cellColor = Colors.red.shade300;
                            cellText = 'Unmute';
                          },
                          backgroundColor: Colors.red[200],
                          child: const Icon(Icons.cancel),
                        ),
                      ),

                    ],
                  )
              ),


              //Submit Button
              ElevatedButton(
                child: Text('Submit',style: TextStyle(color: Colors.black),),
                onPressed: () {

                  fill_0s_1s();
                  Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft,
                      child: Download_Page(absent_present:absent_present,file_path: widget.allfiles[widget.index_no])));
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
        ));
  }

  change_mic_bg() {
    setState(() {
      if (cellText == "Unmute") {
        cellColor = Colors.green.shade300;
        cellText = 'Mute';
        _startListening();
      } else {
        cellColor = Colors.red.shade300;
        cellText = 'Unmute';
        _stopListening();
      }
    });
  }
}

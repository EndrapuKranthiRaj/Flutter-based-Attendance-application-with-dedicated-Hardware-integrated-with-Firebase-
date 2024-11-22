import 'package:autoxl/Manual_page.dart';
import 'package:autoxl/speech_recog_page.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Download_page.dart';


class Excel_selection extends StatefulWidget {
  final int page_no;
  Excel_selection({required this.page_no});

  @override
  State<StatefulWidget> createState() => _Excel_selection();

}

class _Excel_selection extends State<Excel_selection> {

  @override
  void initState() {
    super.initState();
    getSharedPreferences();
    frebase_initializatio();
    print(_itemCount);
  }

  String deviceAttendance = "hello";

  List<int> absent_present =[];
  int _selectedIndex = 0;
  String curr ="";
  String show_me_inlist="";
  List<String> allfiles = [];
  List<String> filenames = [];
  List<String>? dummy;
  int _itemCount = 0;

  // Firebase initialization
  frebase_initializatio() async{
    DatabaseReference testref = FirebaseDatabase.instance.ref().child('attendance');
    final snapshot =  await testref.get();
    if(snapshot.exists){
      setState(() {
        deviceAttendance = snapshot.value.toString();
        absent_present = deviceAttendance.split('').map(int.parse).toList();
        print("Device Attendance:  $deviceAttendance");
        print(absent_present);
      });
    }
    else{
      print("Failed to Fetch Attendance from Firebase or Empty Data in firebase");
    }

  }
  //Shared preferences start
  late SharedPreferences sps;
  getSharedPreferences() async{
    sps = await SharedPreferences.getInstance();
    await grtFromsp();
  }

  grtFromsp() async{
    dummy = await sps.getStringList('mypaths');
    setState(() {
      print("Im dummy $dummy");
      if(dummy!=null) allfiles = dummy!;
      _itemCount = allfiles.length;
    });
    print("Fetch Completed");
    await build_filenames();
  }

  deleteall_files() async{
    await sps.setStringList('mypaths', []);
  }

  build_filenames() async{
    for(int i=0;i<allfiles.length;i++)
      {
        curr ="";
        int j=allfiles[i].length-1;
        while(allfiles[i][j]!='/')
          {
            curr = allfiles[i][j]+curr;
            j--;
          }
        filenames.add(curr);
      }
    setState(() {
      print(curr);
    });

  }


  //Shared preferences end


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

        body: Column(
          children: [
            Container(
              width: 400,
              padding: EdgeInsetsDirectional.all(10),
              decoration: BoxDecoration( borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),color: Colors.blue),
              child: Center(child: Text("Select an Excel",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20, )),)
            ),

            SizedBox(height: 20),

            SizedBox(
              height:370,
              child: ListView.builder(
                itemCount: _itemCount,
                itemBuilder: (context, index) {
                  if(filenames[index].length>27)
                  {
                    show_me_inlist = filenames[index].substring(0,23)+"...";
                  }
                  else show_me_inlist = filenames[index];

                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: _selectedIndex == index ? Colors.grey : Colors.transparent,
                        borderRadius: BorderRadius.circular(5),  // Rectangular with slight rounding
                        border: const Border(
                          bottom: BorderSide(width: 2,color:Colors.black),
                          left: BorderSide(width: 2,color:Colors.black),
                          right: BorderSide(width: 2,color:Colors.black),
                          top:  BorderSide(width: 1,color:Colors.black),
                        ),
                      ),
                      padding: EdgeInsets.all(8),
                      child: Row(
                        children: [
                          Container(
                            width: 20,  // Adjust size
                            height: 20,  // Adjust size
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,  // Rectangle instead of circle
                              //color: _selectedIndex == index ? Colors.green : Colors.transparent,  // Fill on selection
                              border: Border.all(
                                color: Colors.black,
                                width: 2,
                              ),
                            ),
                            child: _selectedIndex == index ? Icon(Icons.check_box,size: 15,):Icon(null),
                          ),
                          SizedBox(width: 10),  // Space between checkbox and text
                          Text(
                            show_me_inlist,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              height: 1,
                              fontFamily: GoogleFonts.oswald().fontFamily,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );

                },
              ),
            ),

            SizedBox(height: 50),

            //Next button
            ElevatedButton(
              child: Text('Next',style: TextStyle(color: Colors.black),),
              onPressed: (){
                if(widget.page_no==1)
                Navigator.push(context,PageTransition(type: PageTransitionType.rightToLeft, child: Speech_recog_page(index_no: _selectedIndex,allfiles: allfiles,)));
                else if(widget.page_no==2)
                Navigator.push(context,PageTransition(type: PageTransitionType.rightToLeft, child: Manual_page(file_path: allfiles[_selectedIndex],)));
                else if(widget.page_no==3)
                  Navigator.push(context,PageTransition(type: PageTransitionType.rightToLeft, child: Download_Page(absent_present: absent_present,file_path: allfiles[_selectedIndex],)));

              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[400],
                padding: EdgeInsets.symmetric(horizontal: 70, vertical: 15),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),),
              ),
            ),

            SizedBox(height: 10),

            //Delete All
            ElevatedButton(
              child: Text('Delete ALL',style: TextStyle(color: Colors.black),),
              onPressed: () async {
                await deleteall_files();
                //Navigator.push(context,PageTransition(type: PageTransitionType.rightToLeft, child: Speech_recog_page()));
                List<String> arr=[];
                Navigator.pop(context, arr);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[400],
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),),
            ),
            ),
          ],



        ),
      );
  }
}
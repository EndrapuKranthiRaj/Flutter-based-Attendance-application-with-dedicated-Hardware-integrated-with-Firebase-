import 'dart:io';
import 'package:autoxl/Excel_selection.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:autoxl/Download_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:collection';


Future main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AutoXL',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'AutoXL'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

//change 1 for git

class _MyHomePageState extends State<MyHomePage> {

  List<File> files = [];
  List<String> allfiles = [];
  List<String>? dummy;
  var hs = HashSet<String>();

  //Shared preferences start
  late SharedPreferences sp;




  getSharedPreferences() async{
    sp = await SharedPreferences.getInstance();
    await grtFromsp();
  }

  saveIntosp()
  {
    sp.setStringList('mypaths', allfiles);
  }

  grtFromsp() async{
    dummy = await sp.getStringList('mypaths');
    if(dummy!=null) allfiles = dummy!;
    await fill_hashset(allfiles);
  }

  fill_hashset(List<String> allfiles) async{
    String curr = "";
    for(int i=0;i<allfiles.length;i++)
    {
      curr ="";
      int j=allfiles[i].length-1;
      while(allfiles[i][j]!='/')
      {
        curr = allfiles[i][j]+curr;
        j--;
      }
      hs.add(curr);
    }
    setState(() {
      print(curr);
    });
  }


  @override
  void initState() {
    super.initState();
    getSharedPreferences();
  }

  //Shared preferences end

  refreshme(List<String> changedfiles)
  {
    setState(() {
      allfiles = changedfiles;
      hs.clear();
    });
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //backgroundColor: Colors.black87,
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
              //Upload container
              InkWell(
                onTap: () {
                  file_upload();
                  print(files);
                },
                  customBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                child: Container(
                  width: 400,
                  decoration: BoxDecoration(
                      color: Colors.amber[300],
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
                      const Icon(
                        Icons.file_upload_outlined,
                        color: Colors.blue,
                        size: 200.0,
                        shadows: [Shadow(blurRadius: 10, offset: Offset(8, 6))],
                      ),
                      Text(
                        "Excel",
                        style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            fontFamily: GoogleFonts.oswald().fontFamily),
                      )
                    ],
                  ),
                )
              ),


              Container(

                child: Column(
                  children: [

                    //Speech recognition button
                    SimpleElevatedButtonWithIcon(
                      label: const Text('Speech Recognition'),
                      iconData: Icons.mic,
                      color: Colors.blue[300],
                      onPressed: () async {
                        print('bronrobrobro.................');
                        if(allfiles.isEmpty) {
                          Alertbox(context);
                          print("GHGHGHGHGHGHGHGH $files");
                        }
                        else {
                          print("allfiles is not empty");
                          print(allfiles);
                        List<String> changedfiles = await Navigator.push(
                              context,
                              PageTransition(
                                  type: PageTransitionType.rightToLeft,
                                  child: Excel_selection(page_no: 1)));

                        refreshme(changedfiles);
                        }
                      },
                      fontsize: 15,
                    ),

                    const SizedBox(height: 10),

                    //Manual attendance Button
                    SimpleElevatedButtonWithIcon(
                      label: const Text('Manual Attendance'),
                      iconData: Icons.pending_actions_sharp,
                      color: Colors.green,
                      onPressed: () async{
                        if(allfiles.isEmpty) Alertbox(context);
                        else {
                          List<String> changedfiles = await Navigator.push(
                              context,
                              PageTransition(
                                  type: PageTransitionType.rightToLeft,
                                  child: Excel_selection(page_no:2)));

                          refreshme(changedfiles);
                        }
                      },
                      fontsize: 15,
                    ),

                    const SizedBox(height: 10),

                    //Dedicated Device button
                    SimpleElevatedButtonWithIcon(
                      label: const Text('  Dedicated Device  '),
                      iconData: Icons.account_balance_wallet,
                      color: Colors.green,
                      onPressed: () async{
                        if(allfiles.isEmpty) Alertbox(context);
                        else {
                          List<String> changedfiles = await Navigator.push(
                              context,
                              PageTransition(
                                  type: PageTransitionType.rightToLeft,
                                  child: Excel_selection(page_no:3)));

                          refreshme(changedfiles);
                        }
                      },
                      fontsize: 15,
                    ),

                    const SizedBox(height: 10),

                    //Download attendance Button
                    SimpleElevatedButtonWithIcon(
                      label: const Text('Previous Attendance'),
                      iconData: Icons.download_for_offline_sharp,
                      color: Colors.green,
                      onPressed: () {
                        if(allfiles.isEmpty ) Alertbox(context);
                        else {
                          Navigator.push(
                              context,
                              PageTransition(
                                  type: PageTransitionType.rightToLeft,
                                  child: Download_Page(absent_present: [],file_path: "")));
                        }
                      },
                      fontsize: 15,
                    ),
                  ],
                ),
              )
            ],
          ),
        ));
  }

  //File Upload
  file_upload() async {
    print("fffffffffffffff");
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom,
        allowedExtensions: ['xlsx']);

    String curr = "";
    String str1 = "";
    if (result != null) {
      str1 = result.files.single.path!;
      int j = str1.length - 1;
      while (str1[j] != '/') {
        curr = str1[j] + curr;
        j--;
      }
    }
    
    if(!hs.contains(curr) && curr!=""){
      allfiles.add(str1);
      saveIntosp();
      print("File added: $allfiles");
      //Pushing into Hashset
      hs.add(curr);

    }
    else {
      print("---------");
      print("---------");
      print("---------");
      print("---------");
      print("$curr already present");
      stdout.write("Your Hashset ------------ ");
      print(hs);
      print("---------");
      print("---------");
      print("---------");
      print("---------");
    }
  }

  //Alert Box
  Alertbox(BuildContext context) {
    // Create button
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // Create AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Alert"),
      content: Text("Have to Select an Excel File"),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
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
      style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: padding,
          textStyle:
              TextStyle(fontSize: fontsize, fontWeight: FontWeight.bold)),
    );
  }
}

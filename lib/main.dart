import 'package:dyt/geolocator_options.dart';
import 'package:dyt/local_db.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'firebase_options.dart';
import 'home.dart';
import 'kakao_map_controller.dart';

InAppLocalhostServer server = InAppLocalhostServer(port: 8080);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await server.start();
  await dotenv.load();
  await LocalDB.initDatabase();
print("1");
  await Get.putAsync(() async {
    final locationService = LocationService();
    print("2");
    await locationService.initService();

    return locationService;
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      // title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: '코인 노래방'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // This allows the body to extend behind the app bar and status bar
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          clipBehavior: Clip.none,
          elevation: 0,
          centerTitle: true,
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Flexible(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
                    decoration: BoxDecoration(
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black45,
                          offset: Offset(0, 2),
                          blurRadius: 3
                        )
                      ],
                      border: Border.all(
                        color: Color(0xffFFB6C1),
                      ),
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 13,),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () async {
                    if(Get.isRegistered<KakaoMapController>(tag: "kakaoController")) {
                      await Get.find<KakaoMapController>(tag: "kakaoController").initMethod();
                      setState(() {});
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
                    decoration: BoxDecoration(
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black45,
                            offset: Offset(0, 2),
                            blurRadius: 3
                        )
                      ],
                      border: Border.all(
                        color: Color(0xffFFB6C1),
                      ),
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Icon(Icons.refresh),
                  ),
                )
              ],
            ),
          ),
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
          ),
        ),
        // Remove padding caused by the status bar
        body: Home());
  }
}

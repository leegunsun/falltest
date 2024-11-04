import 'package:dyt/geolocator_options.dart';
import 'package:dyt/local_db.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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

  await Get.putAsync(() async {
    final locationService = LocationService();
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
  final LocationService locationService = Get.find<LocationService>();
  KakaoMapController? _kakaoMapController;
  Worker? _worker;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _worker = ever(locationService.userLatLng, (_) {
      _userLocationRef();
    });
  }

  Future<void> _userLocationRef () async {
    if (_kakaoMapController != null) {
      await _kakaoMapController?.initMethod();
      _kakaoMapController?.polylines.clear();
      _kakaoMapController?.webViewController.reload();
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _worker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await _showExitConfirmationDialog(context);
        return shouldPop;
      },
      child: Scaffold(
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 13, vertical: 10),
                      decoration: BoxDecoration(
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black45,
                              offset: Offset(0, 2),
                              blurRadius: 3)
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
                  const SizedBox(
                    width: 13,
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () async {
                      if (_kakaoMapController != null) {
                        await _kakaoMapController?.initMethod();
                        _kakaoMapController?.polylines.clear();
                        _kakaoMapController?.webViewController.reload();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 13, vertical: 10),
                      decoration: BoxDecoration(
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black45,
                              offset: Offset(0, 2),
                              blurRadius: 3)
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
        // body: LocationMapPage(),
          body: Home(sendController: (controller) {
            _kakaoMapController = controller;
          },)
      ),
    );
  }

  Future<bool> _showExitConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('앱을 종료 하시겠습니까?'),
        content: Text('확인을 눌러서 앱을 종료하세요.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('아니오'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('예'),
          ),
        ],
      ),
    ) ??
        false;
  }
}



class LocationMapPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Location with Red Dot'),
      ),
      body:
      // Obx(() {
         GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng( 37.48891558895957, 127.12721264903897),
            zoom: 15,
          ),
          markers: {
            Marker(
              markerId: MarkerId('currentLocation'),
              position:  LatLng( 37.48891558895957, 127.12721264903897),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            ),
          },
        )
      // }),
    );
  }
}
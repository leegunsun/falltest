import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  int _counter = 0;
  String _launch = 'Unknown';

  void _isHCodeToggel() {
    setState(() {
      isHardCoding = !isHardCoding;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Center(child: Text('하드 코딩', style: TextStyle(color: isHardCoding ? Colors.grey : Colors.black),),),
              Center(child: Text(hCodeUri,  style: TextStyle(color: isHardCoding ? Colors.grey : Colors.black))),
              Divider(),
              Center(child: Text('호출', style: TextStyle(color: !isHardCoding ? Colors.grey : Colors.black))),
              Center(child: Text('$_launch', style: TextStyle(color: !isHardCoding ? Colors.grey : Colors.black))),
              Divider(),
              // Spacer(),
              ElevatedButton(onPressed: _isHCodeToggel, child: Text('하드코딩 => $isHardCoding')),
              ElevatedButton(
                onPressed: LaunchMode_platformDefault,
                child: const Text(
                  'LaunchMode_platformDefault',
                ),
              ),
              ElevatedButton(
                onPressed: LaunchMode_externalApplication,
                child: const Text(
                  'LaunchMode_externalApplication',
                ),
              ),
              ElevatedButton(
                onPressed: LaunchMode_externalNonBrowserApplication,
                child: const Text(
                  'LaunchMode_externalNonBrowserApplication',
                ),
              ),
              ElevatedButton(
                onPressed: LaunchMode_inAppWebView,
                child: const Text(
                  'LaunchMode_inAppWebView',
                ),
              ),
              ElevatedButton(
                onPressed: LaunchMode_inAppBrowserView,
                child: const Text(
                  'LaunchMode_inAppBrowserView',
                ),
              ),
              Text('231208 현재 실행 안되고 있음 -> 시간이 경과 했을 때 [naver.com]으로 이동 되는지 확인해 봐야함')
            ],
          ),
        ),
      ),
    );
  }

  String hCodeUri = 'https://teata.page.link/?link=https://teata.page.link&apn=com.example.teatb&afl=https://www.naver.com';
  bool isHardCoding = false;

  dynamic defaultSetting() async {
    var testUri;

    if (isHardCoding) {
      testUri = launchUrl(Uri.parse(hCodeUri));
    } else {
      testUri = await DynamiclinkService.instance.createDynamicLink('test');
      _launch = testUri.toString();
    }

    print(testUri);
    return testUri;
  }

  LaunchMode_platformDefault() async {
    var testUri = await defaultSetting();

    launchUrl(testUri, mode: LaunchMode.platformDefault);
  }

  LaunchMode_externalApplication() async {
    var testUri = await defaultSetting();

    launchUrl(testUri, mode: LaunchMode.externalApplication);
  }

  LaunchMode_externalNonBrowserApplication() async {
    var testUri = await defaultSetting();

    launchUrl(testUri, mode: LaunchMode.externalNonBrowserApplication);
  }

  LaunchMode_inAppWebView() async {
    var testUri = await defaultSetting();

    launchUrl(testUri, mode: LaunchMode.inAppWebView);
  }

  LaunchMode_inAppBrowserView() async {
    var testUri = await defaultSetting();

    launchUrl(testUri, mode: LaunchMode.inAppBrowserView);
  }
}

class DynamiclinkService {
  static final DynamiclinkService _singleton = DynamiclinkService._internal();

  DynamiclinkService._internal();

  static DynamiclinkService get instance => _singleton;

  createDynamicLink(String text) async {
    final dynamicLinkParams = DynamicLinkParameters(
        link: Uri.parse('https://teata.page.link'),
        uriPrefix: 'https://teata.page.link',
        androidParameters: AndroidParameters(
          packageName: 'com.example.teatb',
          fallbackUrl: Uri.parse('https://www.naver.com'), // Fallback URL
          // minimumVersion: 125,
        ),
        iosParameters: IOSParameters(
            bundleId: 'com.example.deeplink',
            fallbackUrl: Uri.parse('https://www.naver.com')));

    final Uri dynamicLink = await FirebaseDynamicLinks.instance.buildLink(dynamicLinkParams);

    // final dynamicLink = await dynamicLinkParams.longDynamicLink;

    print(dynamicLink);
    // print('${dynamicLink.shortUrl}');
    return dynamicLink;
  }
}

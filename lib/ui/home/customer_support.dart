// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
//
// class CustomerSupport extends StatefulWidget {
//   @override
//   _CustomerSupportState createState() => _CustomerSupportState();
// }
//
// class _CustomerSupportState extends State<CustomerSupport> {
//   final flutterWebviewPlugin = new FlutterWebviewPlugin();
//
//   @override
//   void initState() {
//     flutterWebviewPlugin.onUrlChanged.listen((String url) {
//       print(url);
//     });
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     flutterWebviewPlugin.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WebviewScaffold(
//       appBar: AppBar(
//         title: Text('Blog'),
//       ),
//       url: "http://blog.codetotalk.com",
//       withZoom: true,
//       clearCache: true,
//       clearCookies: false,
//       supportMultipleWindows: true,
//       appCacheEnabled: true,
//       allowFileURLs: true,
//       enableAppScheme: true,
//       mediaPlaybackRequiresUserGesture: true,
//       //scrollBar: true,
//       withJavascript: true,
//       ignoreSSLErrors: true,
//       withLocalStorage: true,
//       resizeToAvoidBottomInset: true,
//       initialChild: Container(
//         color: Colors.white,
//         child: const Center(
//           child: CircularProgressIndicator(
//             backgroundColor: Colors.black,
//           ),
//         ),
//       ),
//     );
//   }
// }

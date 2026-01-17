import 'package:adhub/adhub.dart';
import 'package:adhub/adplugin/AdLoader/ad_loader.dart';
import 'package:adhub/adplugin/Provider/ad_plugin_provider.dart';
import 'package:flutter/material.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AdPluginProvider(
      child: AdLoader(
        child: MaterialApp(
          home: Adhub(
            onComplete: (context, mainJson) async {
              // Navigation
            },
            jsonUrl: "",
            apiKey: "",
            version: '',
            child: SizedBox(),
          ),
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}

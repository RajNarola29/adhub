import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../AdLoader/ad_loader_provider.dart';
import '../MainJson/main_json.dart';

class AdPluginProvider extends StatelessWidget {
  final Widget child;

  const AdPluginProvider({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AdLoaderProvider>(
          create: (context) {
            return AdLoaderProvider();
          },
        ),
        ChangeNotifierProvider<MainJson>(
          create: (context) {
            return MainJson();
          },
        ),
      ],
      child: child,
    );
  }
}

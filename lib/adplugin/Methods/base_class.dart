import 'package:applovin_max/applovin_max.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import '../MainJson/main_json.dart';
import 'google_init.dart';

class BaseClass {
  Future<void> initAdNetworks({
    required BuildContext context,
    required Function() onInitComplete,
  }) async {
    MainJson mainJson = context.read<MainJson>();
    if (mainJson.data![mainJson.version]['adNetwork']['google']) {
      await GoogleInit().onInit();
    }
    if (mainJson.data![mainJson.version]['adNetwork']['appLovin']) {
      await AppLovinMAX.initialize(
        mainJson.data!['adIds']['applovin']['id'] != ""
            ? mainJson.data!['adIds']['applovin']['id']
            : "xiAs_Fs3BiExPelVuawzyDTU2Sy4GL2d6KB1c7C1loiv64T5oquTwRRIJbHC3qO0qRI_65NChIkGy3U2i6rWXn",
      );
      Logger().d("ApplovinMAX initialized");
    }

    Future.delayed(const Duration(milliseconds: 400), () {
      onInitComplete();
    });
  }
}

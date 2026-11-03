import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/favourite/controllers/favourite_controller.dart';

class RecentPlay extends GetView<FavouriteController> {
  const RecentPlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
            child: Center(
        child: Text('最近播放'),
      ),
    );
  }
}
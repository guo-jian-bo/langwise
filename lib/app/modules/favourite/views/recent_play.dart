import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/favourite/controllers/favourite_controller.dart';

class RecentPlay extends GetView<FavouriteController> {
  final String tagText;
  const RecentPlay({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  @override
  Widget build(BuildContext context) {
    return Container(
            child: Center(
        child: Text('最近播放'),
      ),
    );
  }
}

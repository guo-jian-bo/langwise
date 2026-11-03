import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/theme/theme.dart';
import '../common/elements_cards/elements_type_card_widget.dart';
import '../model/elements_detils_data_model.dart';


class ElementsWordCardDialog{
  static Future<void> show({
    required BuildContext context,
    ElementsDetilsDataModel? data,
  }) async {
    await showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return ElementsWordCardDialogWidget(data: data);
      },
    );
  }
}

class ElementsWordCardDialogWidget extends StatefulWidget {
  final ElementsDetilsDataModel? data;
  const ElementsWordCardDialogWidget({super.key, this.data});

  @override
  State<ElementsWordCardDialogWidget> createState() => _ElementsWordCardDialogWidgetState();
}

class _ElementsWordCardDialogWidgetState extends State<ElementsWordCardDialogWidget> {
  @override
  Widget build(BuildContext context) {
    if(widget.data == null){
      return const SizedBox();
    }
    return GestureDetector(
      onTap: () => Get.back(),
      child: Material(
        color: AppTheme.cOverlayBackground,
        child: Center(
          child: GestureDetector(
            onTap: (){},
            child: ElementsTypeCardWidget(
              data: widget.data,
            ),
          ),
        ),
      ),
    );
  }
}
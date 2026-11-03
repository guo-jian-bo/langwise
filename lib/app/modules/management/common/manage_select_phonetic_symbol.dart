
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/https/https.dart';
import '../../../../common/widgets/widgets.dart';

/// 选择音标弹窗
class ManageSelectPhoneticSymbol{
  static Future<PhonicsEntityDatas?> show({
    required BuildContext context,
  }) async {
    return await showCupertinoDialog<PhonicsEntityDatas?>(
      context: context,
      builder: (context) {
        return const ManageSelectPhoneticSymbolWidget();
      },
    );

  }
}

class ManageSelectPhoneticSymbolWidget extends StatefulWidget {

  const ManageSelectPhoneticSymbolWidget({super.key});

  @override
  State<ManageSelectPhoneticSymbolWidget> createState() => _ManageSelectPhoneticSymbolWidgetState();
}

class _ManageSelectPhoneticSymbolWidgetState extends State<ManageSelectPhoneticSymbolWidget> {
  final GlobalKey containerKey = GlobalKey();

  // table控制器
  AsyncDataTableSource? dessertDataSourceAsync;

  int offset = 0;
  int limit = 20;

  /// uid控制器
  final TextEditingController uidController = TextEditingController();
  /// ipa控制器
  final TextEditingController ipaController = TextEditingController();
  /// ipa字母控制器
  final TextEditingController ipaLetterController = TextEditingController();
  /// 等级名称控制器
  final TextEditingController levelNameController = TextEditingController();

  PhonicsEntityDatas? selectedItem;

  @override
  void initState(){
    super.initState();
  }

  Future<DesertsFakeWebServiceResponse<PhonicsEntityDatas>> getDateList() async{
    try {
      Map<String, dynamic> parameters = {
        "offset": offset,
        "limit": limit,
      };
      Map<String, dynamic> data = {
        "uid": uidController.text,
        "ipa": ipaController.text,
        "graphemes": ipaLetterController.text,
        "levelName": levelNameController.text,
      };

      PhonicsEntity? response = await ModuleUtil.getPhonicsList(parameters, data);
      if(response == null) {
        return DesertsFakeWebServiceResponse<PhonicsEntityDatas>(0, []);
      }
      List<PhonicsEntityDatas> resDatas = [];
      
      List<PhonicsEntityDatas?> datas = response.datas??[];
      for(PhonicsEntityDatas? item in datas){
        if(item != null){
          resDatas.add(item);
        }
      }
      return DesertsFakeWebServiceResponse<PhonicsEntityDatas>(response.count??0, resDatas);

    } catch (e) {
      return DesertsFakeWebServiceResponse<PhonicsEntityDatas>(0, []);
    } finally{
      if(mounted) setState(() {});
    }
  }



  @override
  Widget build(BuildContext context) {
    return DialogBoxWidget(
      onCancel: () {
        Get.back();
      },
      onDefine: () {
        if(selectedItem == null){
          ToastUtils.showToast(text: '请选择音标');
          return;
        }
        Get.back(result: selectedItem);
      },
      title: "选择音标",
      width: 1200.wMin,
      child: Container(
        key: containerKey,
        padding: EdgeInsets.symmetric(horizontal: 24.wMin),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleWidget(),
            _buildTableWidget(context),
          ],
        ),
      ),
    );
  }


  Widget _buildTitleWidget(){
    return Row(
      children: [
        SearchWidget(
          width: 160.wMin,
          height: 42.wMin,
          hintText: 'uid',
          controller: uidController,
          onSubmitted: (value) {
            dessertDataSourceAsync?.refresh();
          },
        ),
        SizedBox(width: 24.wMin),
        SearchWidget(
          width: 160.wMin,
          height: 42.wMin,
          hintText: '音标',
          controller: ipaController,
          onSubmitted: (value) {
            dessertDataSourceAsync?.refresh();
          },
        ),
        SizedBox(width: 24.wMin),
        SearchWidget(
          width: 160.wMin,
          height: 42.wMin,
          hintText: '音标字母',
          controller: ipaLetterController,
          onSubmitted: (value) {
            dessertDataSourceAsync?.refresh();
          },
        ),
        SizedBox(width: 24.wMin),
        SearchWidget(
          width: 160.wMin,
          height: 42.wMin,
          hintText: '等级名称',
          controller: levelNameController,
          onSubmitted: (value) {
            dessertDataSourceAsync?.refresh();
          },
        ),
      ],
    );
  }

  Widget _buildTableWidget(BuildContext context) {
    return Container(
      height: 500.wMin,
      child: AsyncDataTableWidget<PhonicsEntityDatas>(
        dataRowHeight: 70.wMin,
        headingRowHeight: 50.wMin,
        pageNumPosition: PageNumPosition.bottom,
        showCheckboxColumn: true,
        defaultRowBgColor: Colors.transparent,
        verticalInside: BorderSide(color: Colors.transparent, width: 0.5.wMin),
        fetchData: (currentPage, startingAt, count, sortedBy, sortedAsc, noData) async {
          offset = startingAt;
          limit = count;
          dessertDataSourceAsync?.deselectAll();
          selectedItem = null;
          return await getDateList();
        },
        columns: _buildColumns(),
        dataCellBuilder: (value, startIndex) {
          return _buildDataCell(value, startIndex);
        },
        onRowSelectChanged: (selected, id, value) {
          dessertDataSourceAsync?.deselectAll();
          Future.delayed(const Duration(milliseconds: 110), (){
            dessertDataSourceAsync?.setRowSelection(ValueKey<int>(value.uid), true);
            selectedItem = value;
          });
          
        },
        sourceCallback: (source) {
          dessertDataSourceAsync = source;
        },
      ),
    );
  }

  /// 构建表格列
  List<DataColumn> _buildColumns() {
    TextStyle textStyle = TextStyle(
      color: Colors.white,
      fontSize: 14.wMin,
      fontWeight: FontWeight.w400,
    );

    return [
      
      DataColumn2(
        fixedWidth: 100.wMin,
        headingRowAlignment: MainAxisAlignment.center,
        label: Text('uid', style: textStyle),
      ),
      DataColumn2(
        fixedWidth: 100.wMin,
        headingRowAlignment: MainAxisAlignment.center,
        label: Text('ipa', style: textStyle),
      ),
      DataColumn2(
        fixedWidth: 100.wMin,
        headingRowAlignment: MainAxisAlignment.center,
        label: Text('音标字母', style: textStyle),
      ),
      DataColumn2(
        fixedWidth: 300.wMin,
        headingRowAlignment: MainAxisAlignment.center,
        label: Text('等级名称', style: textStyle),
      ),
      DataColumn2(
        fixedWidth: 520.wMin,
        headingRowAlignment: MainAxisAlignment.center,
        label: Text('示例单词', style: textStyle),
      ),

    ];
  }

  /// 构建数据单元格
  List<DataCell> _buildDataCell(PhonicsEntityDatas datas, int index) {
    return [
      _buildDataCellItem("${datas.uid}"),
      _buildDataCellItem(datas.ipa??""),
      _buildDataCellItem(datas.graphemes??""),
      _buildDataCellItem(datas.levelName??""),
      _buildDataCellItem(datas.words?.join(", ")??""),

    ];
  }

  DataCell _buildDataCellItem(String text){
    return DataCell(
      DataGeneralColumnWidget(
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.wMin,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }


}

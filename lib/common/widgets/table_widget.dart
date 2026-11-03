import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class TableWidget extends StatefulWidget {
  final Alignment alignment;
  final double itemMinWidth;
  final double itemMinHeight;
  final List<Widget> titles;
  final List<List<Widget>> content;
  const TableWidget({
    super.key, 
    required this.titles, 
    required this.content,
    this.itemMinWidth = 100, 
    this.itemMinHeight = 50,
    this.alignment = Alignment.center,
  });

  @override
  State<TableWidget> createState() => _TableWidgetState();
}

class _TableWidgetState extends State<TableWidget> with WidgetsBindingObserver{
  double contentWidth = 0;

  List<List<GlobalKey>> cententRowKeys = [];

  List<double> columnMaxWidgths = [];

  bool isLoadRead = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    setKey();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getColumnMaxWidget();
    });
  }

  void setKey(){
    isLoadRead = true;
    if(mounted) setState(() {});
    contentWidth = 0;
    columnMaxWidgths.clear();
    for(int i = 0; i < widget.titles.length; i++){
      columnMaxWidgths.add(0);
    }

    cententRowKeys.clear();
    if(widget.content.isNotEmpty){

      for(int i = 0; i < widget.content.length; i++){
        List<GlobalKey> itemList = [];
        for (int j = 0; j < widget.content[i].length; j++) {
          itemList.add(GlobalKey());
        }
        cententRowKeys.add(itemList);
      }
    }
  }

  @override
  void didUpdateWidget(covariant TableWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(oldWidget.titles.length != widget.titles.length || oldWidget.content.length != widget.content.length){
      setKey();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        getColumnMaxWidget();
      });
    }
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    getColumnMaxWidget();
  }


  void getColumnMaxWidget(){
    if(widget.content.isEmpty) {
      isLoadRead = false;
      if(mounted) setState(() {});
      return;
    }

    for(int i = 0; i < widget.content.length; i++){
      for(int j = 0; j < widget.content[i].length; j++){
        if(j >= columnMaxWidgths.length) continue;
        
        RenderBox? renderBox = cententRowKeys[i][j].currentContext?.findRenderObject() as RenderBox?;
        if(renderBox == null) continue;
        
        double width = renderBox.size.width;
        
        if(width > columnMaxWidgths[j]){
          columnMaxWidgths[j] = width;
        }

      }
    }

    

    contentWidth = 0;
    for(int i = 0; i < columnMaxWidgths.length; i++){
      contentWidth += columnMaxWidgths[i];
    }

    isLoadRead = false;
    if(mounted) setState(() {});
  }

  

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // if(cententRowKeys.isEmpty || columnMaxWidgths.isEmpty) return const SizedBox();
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 12, right: 12, bottom: MediaQuery.of(context).padding.bottom,
      ),
      physics: const ClampingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          Opacity(
            opacity: isLoadRead ? 0 : 1,
            child: Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(width: 1, color: Color(0xff33394D)),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(widget.titles.length, (index){
                  return Container(
                    width: columnMaxWidgths[index] == 0 ? null : columnMaxWidgths[index],
                    alignment: widget.alignment,
                    constraints: BoxConstraints(
                      minWidth: widget.itemMinWidth,
                      minHeight: widget.itemMinHeight,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        right: const BorderSide(width: 1, color: Color(0xff33394D)),
                        left: index != 0 ? BorderSide.none : const BorderSide(width: 1, color: Color(0xff33394D)), 
                      ),
                    ),
                    child: widget.titles[index],
                  );
                }),
              ),
            ),
          ),
          
          
          Expanded(
            child: Visibility(
              visible: !(cententRowKeys.isEmpty || columnMaxWidgths.isEmpty),
              child: SizedBox(
                width: contentWidth != 0 ? contentWidth : MediaQuery.of(context).size.width,
                child: ListView.separated(
                  physics: const ClampingScrollPhysics(),
                  itemCount: widget.content.length,
                  padding: EdgeInsets.zero,
                  separatorBuilder: (context, index) => Container(height: 1, color: const Color(0xff33394D)),
                  itemBuilder: (context, index) {
                
                    List<Widget> row = widget.content[index];
                
                    return Container(
                      decoration: index == widget.content.length - 1 ? const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(width: 1, color: Color(0xff33394D)),
                        ),
                      ) : null,
                      child: IntrinsicHeight(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(widget.titles.length, (index1) {
                            return Container(
                              key: cententRowKeys[index][index1],
                              width: columnMaxWidgths[index1] == 0 ? null : columnMaxWidgths[index1],
                              alignment: widget.alignment,
                              constraints: BoxConstraints(
                                minWidth: widget.itemMinWidth,
                                minHeight: widget.itemMinHeight,
                              ),
                              decoration: BoxDecoration(
                                border: Border(
                                  right: const BorderSide(width: 1, color: Color(0xff33394D)),
                                  left: index1 != 0 ? BorderSide.none : const BorderSide(width: 1, color: Color(0xff33394D)), 
                                ),
                              ),
                              child: index1 < row.length ? row[index1] : const SizedBox(),
                            );
                                  
                                  
                          }),
                        ),
                      ),
                    );
                
                  },
                
                ),
              ),
            ),
          ),
          
          
        ],
      ),
    );
  }
}
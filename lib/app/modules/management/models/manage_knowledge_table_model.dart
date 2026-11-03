
import '../../../../common/entities/entities.dart';
import '../../../../common/enum/enum.dart';

class ManageKnowledgeTableModel{
  String id;
  ElementsCardType type;
  bool isSelected;
  bool enableSelect;


  EnWordEntity? word;
  EnPhraseEntity? phrase;
  EnSentenceEntity? sentence;
  EnTextEntity? text;
  EnTextEntity? reveal;
  ManageScriptEntity? script;

  /// 选择的语义
  List<EnEntitySemantics>? selectSemantics;

  ManageKnowledgeTableModel({
    required this.id,
    required this.type,
    this.isSelected = false,
    this.enableSelect = true,
    this.selectSemantics,
    this.word,
    this.phrase,
    this.sentence,
    this.text,
    this.reveal,
    this.script,
  });

  ManageKnowledgeTableModel copy() {
    return ManageKnowledgeTableModel(
      id: id,
      type: type,
      isSelected: isSelected,
      enableSelect: enableSelect,
      selectSemantics: selectSemantics,
      word: word,
      phrase: phrase,
      sentence: sentence,
      text: text,
      reveal: reveal,
      script: script,
    );
  }
}

class ManageKnowledgePagerModel{
  int offset;
  int limit;
  int count;
  List<ManageKnowledgeTableModel>? datas;

  ManageKnowledgePagerModel({
    this.offset = 0,
    this.limit = 0,
    this.count = 0,
    this.datas,
  });
}
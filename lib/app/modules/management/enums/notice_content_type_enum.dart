
enum NoticeContentTypeEnum {
  txt("txt", "普通文本"),
  md("md", "Markdown");

  const NoticeContentTypeEnum(this.value, this.name);

  final String value;
  final String name;


  static NoticeContentTypeEnum? fromValue(String? value){
    
    for(var item in NoticeContentTypeEnum.values){
      if(item.value == value){
        return item;
      }
    }
    return null;
  }

}

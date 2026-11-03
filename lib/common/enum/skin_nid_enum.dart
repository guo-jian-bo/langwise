enum SkinNidEnum {
  sticky_note("sticky_note", "便利贴"),
  name_tag("name_tag", "姓名贴"),
  form_blank("form_blank", "表格"),
  picture_page("picture_page", "图画书页"),
  profile_card("profile_card", "人物卡"),
  email_client("email_client", "邮箱"),
  letter_paper("letter_paper", "信纸"),
  message_slip("message_slip", "留言条"),
  diary_notebook("diary_notebook", "日记本"),
  textbook_page("textbook_page", "课本页"),
  report_paper("report_paper", "报告纸"),
  bulletin_board("bulletin_board", "公告栏"),
  speech_card("speech_card", "发言卡"),
  newspaper_column("newspaper_column", "报纸栏"),
  storybook_spread("storybook_spread", "故事书页");

  final String skinNid;
  final String skinName;

  const SkinNidEnum(this.skinNid, this.skinName);

  factory SkinNidEnum.fromSkinNid(String skinNid) {
    for (SkinNidEnum value in SkinNidEnum.values) {
      if (value.skinNid == skinNid) {
        return value;
      }
    }
    return sticky_note;
  }

}


// | `sticky_note` | 便利贴 |
// | `name_tag` | 姓名贴 |
// | `form_blank` | 表格 |
// | `picture_page` | 图画书页 |
// | `profile_card` | 人物卡 |
// | `email_client` | 邮箱 |
// | `letter_paper` | 信纸 |
// | `message_slip` | 留言条 |
// | `diary_notebook` | 日记本 |
// | `textbook_page` | 课本页 |
// | `report_paper` | 报告纸 |
// | `bulletin_board` | 布告栏 |
// | `speech_card` | 发言卡 |
// | `newspaper_column` | 报纸栏 |
// | `storybook_spread` | 故事书页 |
class CurrentMemberInfoEntity {
  final int? teamId;
  final int? memberId;
  final String? nickname;
  final String? avatarUrl;
  final String? avatar;
  final String? birthday;
  final int? addressCode;
  final String? address;
  final int? grade;
  final int? assessmentTier;
  final int? assessmentFreeDay;
  final int? freeAssessmentCount; //免费评测剩余次数
  final int? freeAssessmentTotal; //免费评测总数
  final int? assessmentServicePkgId;
  final int? assessmentServicePkgVersion;
  final int? assessmentPrice;

  const CurrentMemberInfoEntity({
    this.teamId,
    this.memberId,
    this.nickname,
    this.avatarUrl,
    this.avatar,
    this.birthday,
    this.addressCode,
    this.address,
    this.grade,
    this.assessmentTier,
    this.assessmentFreeDay,
    this.freeAssessmentCount,
    this.freeAssessmentTotal,
    this.assessmentServicePkgId,
    this.assessmentServicePkgVersion,
    this.assessmentPrice,
  });

  factory CurrentMemberInfoEntity.fromJson(Map<String, dynamic> json) {
    return CurrentMemberInfoEntity(
      teamId: json['teamId']?.toInt(),
      memberId: json['memberId']?.toInt(),
      nickname: json['nickname']?.toString(),
      avatarUrl: json['avatarUrl']?.toString(),
      avatar: json['avatar']?.toString(),
      birthday: json['birthday']?.toString(),
      addressCode: json['addressCode']?.toInt(),
      address: json['address']?.toString(),
      grade: json['grade']?.toInt(),
      assessmentTier: json['assessmentTier']?.toInt(),
      assessmentFreeDay: json['assessmentFreeDay']?.toInt(),
      freeAssessmentCount: json['freeAssessmentCount']?.toInt(),
      freeAssessmentTotal: json['freeAssessmentTotal']?.toInt(),
      assessmentServicePkgId: json['assessmentServicePkgId']?.toInt(),
      assessmentServicePkgVersion: json['assessmentServicePkgVersion']?.toInt(),
      assessmentPrice: json['assessmentPrice']?.toInt(),
    );
  }
}

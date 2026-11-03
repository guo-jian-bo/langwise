

class ContentReviewKnowledgeImagesRequest {
  final String type;
  final int semanticId;
  final int uid;

  const ContentReviewKnowledgeImagesRequest({
    required this.type,
    required this.semanticId,
    required this.uid,
  });

  Map<String, dynamic> toJson() => {
        'type': type,
        'semanticId': semanticId,
        'uid': uid,
      };
}

class ContentReviewSubContent {
  final String? type;
  final int? uid;
  final int? semanticId;

  const ContentReviewSubContent({
    this.type,
    this.uid,
    this.semanticId,
  });

  factory ContentReviewSubContent.fromJson(Map<String, dynamic> json) => ContentReviewSubContent(
        type: json['type']?.toString(),
        uid: json['uid'] is num ? (json['uid'] as num).toInt() : int.tryParse(json['uid']?.toString() ?? ''),
        semanticId: json['semanticId'] is num
            ? (json['semanticId'] as num).toInt()
            : int.tryParse(json['semanticId']?.toString() ?? ''),
      );

  Map<String, dynamic> toJson() => {
        'type': type,
        'uid': uid,
        'semanticId': semanticId,
      };
}

class ContentReviewImage {
  final int? semanticImageRelationId;
  final int? imageId;
  final String? imageUrl;
  final String? imageKey;
  final int? styleId;
  final String? style;
  final String? styleTitle;
  final String? locale;
  final String? localeTitle;
  final int? imageScore;
  final String? md5;
  final int? taskId;
  final int? size;
  final int? width;
  final int? height;
  final String? workFlow;
  final int? noiseSeed;
  final int? promptId;
  final String? prompt;
  final String? iconUrl;
  final int? batchId;
  final String? created;
  final String? updated;
  final bool? locked;

  const ContentReviewImage({
    this.semanticImageRelationId,
    this.imageId,
    this.imageUrl,
    this.imageKey,
    this.styleId,
    this.style,
    this.styleTitle,
    this.locale,
    this.localeTitle,
    this.imageScore,
    this.md5,
    this.taskId,
    this.size,
    this.width,
    this.height,
    this.workFlow,
    this.noiseSeed,
    this.promptId,
    this.prompt,
    this.iconUrl,
    this.batchId,
    this.created,
    this.updated,
    this.locked,
  });

  factory ContentReviewImage.fromJson(Map<String, dynamic> json) => ContentReviewImage(
        semanticImageRelationId: json['semanticImageRelationId'] is num
            ? (json['semanticImageRelationId'] as num).toInt()
            : int.tryParse(json['semanticImageRelationId']?.toString() ?? ''),
        imageId: json['imageId'] is num ? (json['imageId'] as num).toInt() : int.tryParse(json['imageId']?.toString() ?? ''),
        imageUrl: json['imageUrl']?.toString(),
        imageKey: json['imageKey']?.toString(),
        styleId: json['styleId'] is num ? (json['styleId'] as num).toInt() : int.tryParse(json['styleId']?.toString() ?? ''),
        style: json['style']?.toString(),
        styleTitle: json['styleTitle']?.toString(),
        locale: json['locale']?.toString(),
        localeTitle: json['localeTitle']?.toString(),
        imageScore: json['imageScore'] is num
            ? (json['imageScore'] as num).toInt()
            : int.tryParse(json['imageScore']?.toString() ?? ''),
        md5: json['md5']?.toString(),
        taskId: json['taskId'] is num ? (json['taskId'] as num).toInt() : int.tryParse(json['taskId']?.toString() ?? ''),
        size: json['size'] is num ? (json['size'] as num).toInt() : int.tryParse(json['size']?.toString() ?? ''),
        width: json['width'] is num ? (json['width'] as num).toInt() : int.tryParse(json['width']?.toString() ?? ''),
        height: json['height'] is num ? (json['height'] as num).toInt() : int.tryParse(json['height']?.toString() ?? ''),
        workFlow: json['workFlow']?.toString(),
        noiseSeed: json['noiseSeed'] is num
            ? (json['noiseSeed'] as num).toInt()
            : int.tryParse(json['noiseSeed']?.toString() ?? ''),
        promptId: json['promptId'] is num
            ? (json['promptId'] as num).toInt()
            : int.tryParse(json['promptId']?.toString() ?? ''),
        prompt: json['prompt']?.toString(),
        iconUrl: json['iconUrl']?.toString(),
        batchId: json['batchId'] is num ? (json['batchId'] as num).toInt() : int.tryParse(json['batchId']?.toString() ?? ''),
        created: json['created']?.toString(),
        updated: json['updated']?.toString(),
        locked: json['locked'],
      );

  Map<String, dynamic> toJson() => {
        'semanticImageRelationId': semanticImageRelationId,
        'imageId': imageId,
        'imageUrl': imageUrl,
        'imageKey': imageKey,
        'styleId': styleId,
        'style': style,
        'styleTitle': styleTitle,
        'locale': locale,
        'localeTitle': localeTitle,
        'imageScore': imageScore,
        'md5': md5,
        'taskId': taskId,
        'size': size,
        'width': width,
        'height': height,
        'workFlow': workFlow,
        'noiseSeed': noiseSeed,
        'promptId': promptId,
        'prompt': prompt,
        'iconUrl': iconUrl,
        'batchId': batchId,
        'created': created,
        'updated': updated,
        'locked': locked,
      };
}

class ContentReviewContentPos {
  final String? title;
  final String? description;
  final String? pos;
  final String? posTitle;
  final dynamic imageModuleType;
  final dynamic semanticList;
  final int? styleId;
  final List<ContentReviewImage>? images;

  const ContentReviewContentPos({
    this.title,
    this.description,
    this.pos,
    this.posTitle,
    this.imageModuleType,
    this.semanticList,
    this.styleId,
    this.images,
  });

  factory ContentReviewContentPos.fromJson(Map<String, dynamic> json) {
    List<ContentReviewImage> images = [];
    final raw = json['images'];
    if (raw is List) {
      for (final e in raw) {
        if (e is Map<String, dynamic>) {
          images.add(ContentReviewImage.fromJson(e));
        }
      }
    }

    return ContentReviewContentPos(
      title: json['title']?.toString(),
      description: json['description']?.toString(),
      pos: json['pos']?.toString(),
      posTitle: json['posTitle']?.toString(),
      imageModuleType: json['imageModuleType'],
      semanticList: json['semanticList'],
      styleId: json['styleId'] is num ? (json['styleId'] as num).toInt() : int.tryParse(json['styleId']?.toString() ?? ''),
      images: images,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'pos': pos,
        'posTitle': posTitle,
        'imageModuleType': imageModuleType,
        'semanticList': semanticList,
        'styleId': styleId,
        'images': images?.map((e) => e.toJson()).toList(),
      };
}

class ContentReviewStyleCountryGroup {
  final String? country;
  final String? iconUrl;
  final int? imageCount;
  final List<ContentReviewImage>? images;
  final int? styleId;

  const ContentReviewStyleCountryGroup({
    this.country,
    this.iconUrl,
    this.imageCount,
    this.images,
    this.styleId
  });

  factory ContentReviewStyleCountryGroup.fromJson(Map<String, dynamic> json) {
    List<ContentReviewImage> images = [];
    final raw = json['images'];
    if (raw is List) {
      for (final e in raw) {
        if (e is Map<String, dynamic>) {
          images.add(ContentReviewImage.fromJson(e));
        }
      }
    }

    return ContentReviewStyleCountryGroup(
      country: json['country']?.toString(),
      iconUrl: json['iconUrl']?.toString(),
      imageCount: json['imageCount'] is num
          ? (json['imageCount'] as num).toInt()
          : int.tryParse(json['imageCount']?.toString() ?? ''),
      images: images,
      styleId: json['styleId'] is num ? (json['styleId'] as num).toInt() : int.tryParse(json['styleId']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
        'country': country,
        'iconUrl':iconUrl,
        'imageCount': imageCount,
        'images': images?.map((e) => e.toJson()).toList(),
        'styleId': styleId,
      };
}

class ContentReviewStyleGroup {
  final String? style;
  final String? styleTitle;
  final List<ContentReviewStyleCountryGroup>? countryGroups;
  final num? order;

  const ContentReviewStyleGroup({
    this.style,
    this.styleTitle,
    this.countryGroups,
    this.order,
  });

  factory ContentReviewStyleGroup.fromJson(Map<String, dynamic> json) {
    List<ContentReviewStyleCountryGroup> countryGroups = [];
    final raw = json['countryGroups'];
    if (raw is List) {
      for (final e in raw) {
        if (e is Map<String, dynamic>) {
          countryGroups.add(ContentReviewStyleCountryGroup.fromJson(e));
        }
      }
    }

    return ContentReviewStyleGroup(
      style: json['style']?.toString(),
      styleTitle: json['styleTitle']?.toString(),
      countryGroups: countryGroups,
      order: json['order'] is num ? (json['order'] as num) : num.tryParse(json['order']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
        'style': style,
        'styleTitle': styleTitle,
        'countryGroups': countryGroups?.map((e) => e.toJson()).toList(),
        'order': order,
      };
}

class ContentReviewKnowledgeImagesResponseData {
  final int? userId;
  final String? content;
  final ContentReviewSubContent? subContent;
  final String? contentType;
  final int? imageCount;
  final bool? batchStatus;
  final int? reviewedCount;
  final List<ContentReviewContentPos>? contentPosList;
  final List<ContentReviewStyleGroup>? styleGroups;
  final List<int>? contentIds;
  final List<int>? taskIds;

  const ContentReviewKnowledgeImagesResponseData({
    this.userId,
    this.content,
    this.subContent,
    this.contentType,
    this.imageCount,
    this.batchStatus,
    this.reviewedCount,
    this.contentPosList,
    this.styleGroups,
    this.contentIds,
    this.taskIds,
  });

  factory ContentReviewKnowledgeImagesResponseData.fromJson(Map<String, dynamic> json) {
    List<ContentReviewContentPos> contentPosList = [];
    final rawPos = json['contentPosList'];
    if (rawPos is List) {
      for (final e in rawPos) {
        if (e is Map<String, dynamic>) {
          contentPosList.add(ContentReviewContentPos.fromJson(e));
        }
      }
    }

    List<ContentReviewStyleGroup> styleGroups = [];
    final rawGroups = json['styleGroups'];
    if (rawGroups is List) {
      for (final e in rawGroups) {
        if (e is Map<String, dynamic>) {
          styleGroups.add(ContentReviewStyleGroup.fromJson(e));
        }
      }
    }

    List<int> contentIds = [];
    final rawContentIds = json['contentIds'];
    if (rawContentIds is List) {
      for (final e in rawContentIds) {
        final v = e is num ? e.toInt() : int.tryParse(e?.toString() ?? '');
        if (v != null) contentIds.add(v);
      }
    }

    List<int> taskIds = [];
    final rawTaskIds = json['taskIds'];
    if (rawTaskIds is List) {
      for (final e in rawTaskIds) {
        final v = e is num ? e.toInt() : int.tryParse(e?.toString() ?? '');
        if (v != null) taskIds.add(v);
      }
    }

    return ContentReviewKnowledgeImagesResponseData(
      userId: json['userId'] is num ? (json['userId'] as num).toInt() : int.tryParse(json['userId']?.toString() ?? ''),
      content: json['content']?.toString(),
      subContent: json['subContent'] is Map<String, dynamic> ? ContentReviewSubContent.fromJson(json['subContent']) : null,
      contentType: json['contentType']?.toString(),
      imageCount: json['imageCount'] is num
          ? (json['imageCount'] as num).toInt()
          : int.tryParse(json['imageCount']?.toString() ?? ''),
      batchStatus: json['batchStatus'] is bool ? json['batchStatus'] as bool : null,
      reviewedCount: json['reviewedCount'] is num
          ? (json['reviewedCount'] as num).toInt()
          : int.tryParse(json['reviewedCount']?.toString() ?? ''),
      contentPosList: contentPosList,
      styleGroups: styleGroups,
      contentIds: contentIds,
      taskIds: taskIds,
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'content': content,
        'subContent': subContent?.toJson(),
        'contentType': contentType,
        'imageCount': imageCount,
        'batchStatus': batchStatus,
        'reviewedCount': reviewedCount,
        'contentPosList': contentPosList?.map((e) => e.toJson()).toList(),
        'styleGroups': styleGroups?.map((e) => e.toJson()).toList(),
        'contentIds': contentIds,
        'taskIds': taskIds,
      };
}

class ContentReviewImageConvertRequest {
  final String promptId;
  final List<String> styleId;
  final String numberOfImages;

  const ContentReviewImageConvertRequest({
    required this.promptId,
    required this.styleId,
    required this.numberOfImages,
  });

  Map<String, dynamic> toJson() => {
        'promptId': promptId,
        'styleId': styleId,
        'numberOfImages': numberOfImages,
      };
}

class ContentReviewImageConvertResponseData {
  final dynamic data;

  const ContentReviewImageConvertResponseData({this.data});

  factory ContentReviewImageConvertResponseData.fromJson(dynamic json) => ContentReviewImageConvertResponseData(data: json);

  dynamic toJson() => data;
}

class ContentReviewImageCreateRequest {
  final List<String> styleIds;
  final String numberOfImages;
  final ContentReviewSubContent subContent;

  const ContentReviewImageCreateRequest({
    required this.styleIds,
    required this.numberOfImages,
    required this.subContent,
  });

  Map<String, dynamic> toJson() => {
        'styleIds': styleIds,
        'numberOfImages': numberOfImages,
        'subContent': subContent.toJson(),
      };
}

class ContentReviewImageTakedownRequest {
  final int relationUid;

  const ContentReviewImageTakedownRequest({required this.relationUid});

  Map<String, dynamic> toQueryParameters() => {
        'relationUid': relationUid,
      };
}

class ContentReviewImagesReviewedListRequest {
  final String? content;
  final List<String>? taskIds;

  const ContentReviewImagesReviewedListRequest({
    this.content,
    this.taskIds,
  });

  Map<String, dynamic> toJson() => {
        'content': content,
        'taskIds': taskIds,
      };
}

class ContentReviewDifficultyRange {
  final int? max;
  final int? min;

  const ContentReviewDifficultyRange({
    this.max,
    this.min,
  });

  factory ContentReviewDifficultyRange.fromJson(Map<String, dynamic> json) => ContentReviewDifficultyRange(
        max: json['max'] is num ? (json['max'] as num).toInt() : int.tryParse(json['max']?.toString() ?? ''),
        min: json['min'] is num ? (json['min'] as num).toInt() : int.tryParse(json['min']?.toString() ?? ''),
      );

  Map<String, dynamic> toJson() => {
        'max': max,
        'min': min,
      };
}

class ContentReviewTaskImage {
  final int? imageId;
  final int? styleId;
  final String? imageUrl;
  final String? md5;
  final bool? option;

  const ContentReviewTaskImage({
    this.imageId,
    this.styleId,
    this.imageUrl,
    this.md5,
    this.option,
  });

  factory ContentReviewTaskImage.fromJson(Map<String, dynamic> json) => ContentReviewTaskImage(
        imageId: json['imageId'] is num ? (json['imageId'] as num).toInt() : int.tryParse(json['imageId']?.toString() ?? ''),
        styleId: json['styleId'] is num ? (json['styleId'] as num).toInt() : int.tryParse(json['styleId']?.toString() ?? ''),
        imageUrl: json['imageUrl']?.toString(),
        md5: json['md5']?.toString(),
        option: json['option'] is bool ? json['option'] as bool : null,
      );

  Map<String, dynamic> toJson() => {
        'imageId': imageId,
        'styleId': styleId,
        'imageUrl': imageUrl,
        'md5': md5,
        'option': option,
      };
}

class ContentReviewImageTaskItem {
  final int? taskId;
  final int? promptId;
  final List<int>? imageIds;
  final List<ContentReviewTaskImage>? images;
  final int? createUserId;
  final String? status;
  final String? contentType;
  final String? content;
  final String? definition;
  final String? description;
  final ContentReviewDifficultyRange? difficulty;
  final String? posTitle;
  final String? typeTitle;
  final String? styleTitle;
  final String? localeTitle;
  final String? iconUrl;
  final String? prompt;
  final String? finished;

  ContentReviewImageTaskItem({
    this.taskId,
    this.promptId,
    this.imageIds,
    this.images,
    this.createUserId,
    this.status,
    this.contentType,
    this.content,
    this.definition,
    this.description,
    this.difficulty,
    this.posTitle,
    this.typeTitle,
    this.styleTitle,
    this.localeTitle,
    this.iconUrl,
    this.prompt,
    this.finished,
  });

  factory ContentReviewImageTaskItem.fromJson(Map<String, dynamic> json) {
    List<int> imageIds = [];
    final rawImageIds = json['imageIds'];
    if (rawImageIds is List) {
      for (final e in rawImageIds) {
        final v = e is num ? e.toInt() : int.tryParse(e?.toString() ?? '');
        if (v != null) imageIds.add(v);
      }
    }

    List<ContentReviewTaskImage> images = [];
    final rawImages = json['images'];
    if (rawImages is List) {
      for (final e in rawImages) {
        if (e is Map<String, dynamic>) {
          images.add(ContentReviewTaskImage.fromJson(e));
        }
      }
    }

    final taskId = json['taskId'] is num ? (json['taskId'] as num).toInt() : int.tryParse(json['taskId']?.toString() ?? '');

    return ContentReviewImageTaskItem(
      taskId: taskId,
      promptId: json['promptId'] is num ? (json['promptId'] as num).toInt() : int.tryParse(json['promptId']?.toString() ?? ''),
      imageIds: imageIds,
      images: images,
      createUserId: json['createUserId'] is num
          ? (json['createUserId'] as num).toInt()
          : int.tryParse(json['createUserId']?.toString() ?? ''),
      status: json['status']?.toString(),
      contentType: json['contentType']?.toString(),
      content: json['content']?.toString(),
      definition: json['definition']?.toString(),
      description: json['description']?.toString(),
      difficulty: json['difficulty'] is Map<String, dynamic> ? ContentReviewDifficultyRange.fromJson(json['difficulty']) : null,
      posTitle: json['posTitle']?.toString(),
      typeTitle: json['typeTitle']?.toString(),
      styleTitle: json['styleTitle']?.toString(),
      localeTitle: json['localeTitle']?.toString(),
      iconUrl: json['iconUrl']?.toString(),
      prompt: json['prompt']?.toString(),
      finished: json['finished']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'taskId': taskId,
        'promptId': promptId,
        'imageIds': imageIds,
        'images': images?.map((e) => e.toJson()).toList(),
        'createUserId': createUserId,
        'status': status,
        'contentType': contentType,
        'content': content,
        'definition': definition,
        'description':description,
        'difficulty': difficulty?.toJson(),
        'posTitle': posTitle,
        'typeTitle': typeTitle,
        'styleTitle': styleTitle,
        'localeTitle': localeTitle,
        'iconUrl': iconUrl,
        'prompt': prompt,
        'finished': finished,
      };
}

class ContentReviewImagesReviewedListResponseData {
  final int? count;
  final List<ContentReviewImageTaskItem>? list;

  const ContentReviewImagesReviewedListResponseData({
    this.count,
    this.list,
  });

  factory ContentReviewImagesReviewedListResponseData.fromJson(Map<String, dynamic> json) {
    List<ContentReviewImageTaskItem> list = [];
    final raw = json['list'];
    if (raw is List) {
      for (final e in raw) {
        if (e is Map<String, dynamic>) {
          list.add(ContentReviewImageTaskItem.fromJson(e));
        }
      }
    }

    return ContentReviewImagesReviewedListResponseData(
      count: json['count'] is num ? (json['count'] as num).toInt() : int.tryParse(json['count']?.toString() ?? ''),
      list: list,
    );
  }

  Map<String, dynamic> toJson() => {
        'count': count,
        'list': list?.map((e) => e.toJson()).toList(),
      };
}

class ContentReviewLoadPromptRequest {
  final int relationUid;

  const ContentReviewLoadPromptRequest({required this.relationUid});

  Map<String, dynamic> toQueryParameters() => {
        'relationUid': relationUid,
      };
}

class ContentReviewLoadPromptResponseData {
  final String? prompt;

  const ContentReviewLoadPromptResponseData({this.prompt});

  factory ContentReviewLoadPromptResponseData.fromJson(Map<String, dynamic> json) =>
      ContentReviewLoadPromptResponseData(prompt: json['prompt']?.toString());

  Map<String, dynamic> toJson() => {
        'prompt': prompt,
      };
}

class ContentReviewImageRegenerateRequest {
  final String taskId;
  final String prompt;

  const ContentReviewImageRegenerateRequest({
    required this.taskId,
    required this.prompt,
  });

  Map<String, dynamic> toJson() => {
        'taskId': taskId,
        'prompt': prompt,
      };
}

class ContentReviewAuditHistoryRequest {
  final String? content;
  final String? startDate;
  final String? endDate;
  final int? offset;
  final int? limit;

  const ContentReviewAuditHistoryRequest({
    this.content,
    this.startDate,
    this.endDate,
    this.offset,
    this.limit,
  });

  Map<String, dynamic> toJson() => {
        'content': content,
        'startDate': startDate,
        'endDate': endDate,
        'offset': offset,
        'limit': limit,
      };
}

class ContentReviewImageAuditHistoryItem extends ContentReviewImageTaskItem {
  final int? checkedUserId;
  final String? checked;
  final String? userName;

  ContentReviewImageAuditHistoryItem({
    super.taskId,
    super.promptId,
    super.imageIds,
    super.images,
    super.createUserId,
    super.status,
    super.contentType,
    super.content,
    super.definition,
    super.description,
    super.difficulty,
    super.posTitle,
    super.typeTitle,
    super.styleTitle,
    super.localeTitle,
    super.iconUrl,
    super.prompt,
    super.finished,
    this.checkedUserId,
    this.checked,
    this.userName,
  });

  factory ContentReviewImageAuditHistoryItem.fromJson(Map<String, dynamic> json) {
    final base = ContentReviewImageTaskItem.fromJson(json);

    return ContentReviewImageAuditHistoryItem(
      taskId: base.taskId,
      promptId: base.promptId,
      imageIds: base.imageIds,
      images: base.images,
      createUserId: base.createUserId,
      status: base.status,
      contentType: base.contentType,
      content: base.content,
      definition: base.definition,
      description: base.description,
      difficulty: base.difficulty,
      posTitle: base.posTitle,
      typeTitle: base.typeTitle,
      styleTitle: base.styleTitle,
      localeTitle: base.localeTitle,
      iconUrl: base.iconUrl,
      prompt: base.prompt,
      finished: base.finished,
      checkedUserId: json['checkedUserId'] is num
          ? (json['checkedUserId'] as num).toInt()
          : int.tryParse(json['checkedUserId']?.toString() ?? ''),
      checked: json['checked']?.toString(),
      userName: json['userName']?.toString(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'checkedUserId': checkedUserId,
        'checked': checked,
        'userName': userName,
      };
}

class ContentReviewImageAuditHistoryResponseData {
  final int? offset;
  final int? limit;
  final int? count;
  final List<ContentReviewImageAuditHistoryItem>? datas;

  const ContentReviewImageAuditHistoryResponseData({
    this.offset,
    this.limit,
    this.count,
    this.datas,
  });

  factory ContentReviewImageAuditHistoryResponseData.fromJson(Map<String, dynamic> json) {
    List<ContentReviewImageAuditHistoryItem> datas = [];
    final raw = json['datas'];
    if (raw is List) {
      for (final e in raw) {
        if (e is Map<String, dynamic>) {
          datas.add(ContentReviewImageAuditHistoryItem.fromJson(e));
        }
      }
    }

    return ContentReviewImageAuditHistoryResponseData(
      offset: json['offset'] is num ? (json['offset'] as num).toInt() : int.tryParse(json['offset']?.toString() ?? ''),
      limit: json['limit'] is num ? (json['limit'] as num).toInt() : int.tryParse(json['limit']?.toString() ?? ''),
      count: json['count'] is num ? (json['count'] as num).toInt() : int.tryParse(json['count']?.toString() ?? ''),
      datas: datas,
    );
  }

  Map<String, dynamic> toJson() => {
        'offset': offset,
        'limit': limit,
        'count': count,
        'datas': datas?.map((e) => e.toJson()).toList(),
      };
}

class ContentReviewImageTaskDistributeRequest {
  const ContentReviewImageTaskDistributeRequest();

  Map<String, dynamic> toJson() => {};
}

class ContentReviewImageAuditStatisticsAuditor {
  final int? userId;
  final String? auditorName;
  final int? taskCount;
  final int? imageCount;
  final int? abandonedTaskCount;
  final int? failedTaskCount;

  const ContentReviewImageAuditStatisticsAuditor({
    this.userId,
    this.auditorName,
    this.taskCount,
    this.imageCount,
    this.abandonedTaskCount,
    this.failedTaskCount,
  });

  factory ContentReviewImageAuditStatisticsAuditor.fromJson(Map<String, dynamic> json) => ContentReviewImageAuditStatisticsAuditor(
        userId: json['userId'] is num ? (json['userId'] as num).toInt() : int.tryParse(json['userId']?.toString() ?? ''),
        auditorName: json['auditorName']?.toString(),
        taskCount: json['taskCount'] is num
            ? (json['taskCount'] as num).toInt()
            : int.tryParse(json['taskCount']?.toString() ?? ''),
        imageCount: json['imageCount'] is num
            ? (json['imageCount'] as num).toInt()
            : int.tryParse(json['imageCount']?.toString() ?? ''),
        abandonedTaskCount: json['abandonedTaskCount'] is num
            ? (json['abandonedTaskCount'] as num).toInt()
            : int.tryParse(json['abandonedTaskCount']?.toString() ?? ''),
        failedTaskCount: json['failedTaskCount'] is num
            ? (json['failedTaskCount'] as num).toInt()
            : int.tryParse(json['failedTaskCount']?.toString() ?? ''),
      );

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'auditorName': auditorName,
        'taskCount': taskCount,
        'imageCount': imageCount,
        'abandonedTaskCount': abandonedTaskCount,
        'failedTaskCount': failedTaskCount,
      };
}

class ContentReviewImageAuditStatisticsResponseData {
  final int? totalTaskCount;
  final int? totalImageCount;
  final int? totalNoCheckedTaskCount;
  final int? totalNoCheckedImageCount;
  final int? totalAbandonedTaskCount;
  final List<ContentReviewImageAuditStatisticsAuditor>? auditorStats;

  const ContentReviewImageAuditStatisticsResponseData({
    this.totalTaskCount,
    this.totalImageCount,
    this.totalNoCheckedTaskCount,
    this.totalNoCheckedImageCount,
    this.totalAbandonedTaskCount,
    this.auditorStats,
  });

  factory ContentReviewImageAuditStatisticsResponseData.fromJson(Map<String, dynamic> json) {
    List<ContentReviewImageAuditStatisticsAuditor> auditorStats = [];
    final raw = json['auditorStats'];
    if (raw is List) {
      for (final e in raw) {
        if (e is Map<String, dynamic>) {
          auditorStats.add(ContentReviewImageAuditStatisticsAuditor.fromJson(e));
        }
      }
    }

    return ContentReviewImageAuditStatisticsResponseData(
      totalTaskCount: json['totalTaskCount'] is num
          ? (json['totalTaskCount'] as num).toInt()
          : int.tryParse(json['totalTaskCount']?.toString() ?? ''),
      totalImageCount: json['totalImageCount'] is num
          ? (json['totalImageCount'] as num).toInt()
          : int.tryParse(json['totalImageCount']?.toString() ?? ''),
      totalNoCheckedTaskCount: json['totalNoCheckedTaskCount'] is num
          ? (json['totalNoCheckedTaskCount'] as num).toInt()
          : int.tryParse(json['totalNoCheckedTaskCount']?.toString() ?? ''),
      totalNoCheckedImageCount: json['totalNoCheckedImageCount'] is num
          ? (json['totalNoCheckedImageCount'] as num).toInt()
          : int.tryParse(json['totalNoCheckedImageCount']?.toString() ?? ''),
      totalAbandonedTaskCount: json['totalAbandonedTaskCount'] is num
          ? (json['totalAbandonedTaskCount'] as num).toInt()
          : int.tryParse(json['totalAbandonedTaskCount']?.toString() ?? ''),
      auditorStats: auditorStats,
    );
  }

  Map<String, dynamic> toJson() => {
        'totalTaskCount': totalTaskCount,
        'totalImageCount': totalImageCount,
        'totalNoCheckedTaskCount': totalNoCheckedTaskCount,
        'totalNoCheckedImageCount': totalNoCheckedImageCount,
        'totalAbandonedTaskCount': totalAbandonedTaskCount,
        'auditorStats': auditorStats?.map((e) => e.toJson()).toList(),
      };
}

class ContentReviewApprovedImagesRequest {
  final String taskId;

  const ContentReviewApprovedImagesRequest({required this.taskId});

  Map<String, dynamic> toJson() => {
        'taskId': taskId,
      };
}

class ContentReviewApprovedImage {
  final int? imageId;
  final int? styleId;
  final String? imageUrl;
  final String? md5;

  const ContentReviewApprovedImage({
    this.imageId,
    this.styleId,
    this.imageUrl,
    this.md5,
  });

  factory ContentReviewApprovedImage.fromJson(Map<String, dynamic> json) => ContentReviewApprovedImage(
        imageId: json['imageId'] is num ? (json['imageId'] as num).toInt() : int.tryParse(json['imageId']?.toString() ?? ''),
        styleId: json['styleId'] is num ? (json['styleId'] as num).toInt() : int.tryParse(json['styleId']?.toString() ?? ''),
        imageUrl: json['imageUrl']?.toString(),
        md5: json['md5']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'imageId': imageId,
        'styleId': styleId,
        'imageUrl': imageUrl,
        'md5': md5,
      };
}

class ContentReviewApproveRequest {
  final int relationUid;
  final String taskId;
  final String imageId;

  const ContentReviewApproveRequest({
    required this.relationUid,
    required this.taskId,
    required this.imageId,
  });

  Map<String, dynamic> toJson() => {
        'taskId': taskId,
        'imageId': imageId,
      };

  Map<String, dynamic> toQueryParameters() => {
        'relationUid': relationUid,
      };
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'json_classes.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Pool _$PoolFromJson(Map<String, dynamic> json) => Pool(
  (json['id'] as num).toInt(),
  json['name'] as String,
  json['created_at'] as String,
  json['updated_at'] as String,
  (json['creator_id'] as num).toInt(),
  json['description'] as String,
  json['is_active'] as bool,
  json['category'] as String,
  (json['post_ids'] as List<dynamic>).map((e) => (e as num).toInt()).toList(),
  json['creator_name'] as String,
  (json['post_count'] as num).toInt(),
);

Map<String, dynamic> _$PoolToJson(Pool instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
  'creator_id': instance.creatorId,
  'description': instance.description,
  'is_active': instance.isActive,
  'category': instance.category,
  'post_ids': instance.postIds,
  'creator_name': instance.creatorName,
  'post_count': instance.postCount,
};

Post _$PostFromJson(Map<String, dynamic> json) => Post(
  (json['id'] as num).toInt(),
  json['created_at'] as String,
  json['updated_at'] as String,
  PostFile.fromJson(json['file'] as Map<String, dynamic>),
  PostPreview.fromJson(json['preview'] as Map<String, dynamic>),
  PostSample.fromJson(json['sample'] as Map<String, dynamic>),
  PostScore.fromJson(json['score'] as Map<String, dynamic>),
  PostFlags.fromJson(json['flags'] as Map<String, dynamic>),
  json['rating'] as String,
  (json['fav_count'] as num).toInt(),
  (json['sources'] as List<dynamic>).map((e) => e as String).toList(),
  (json['pools'] as List<dynamic>).map((e) => (e as num).toInt()).toList(),
  PostRelationships.fromJson(json['relationships'] as Map<String, dynamic>),
  json['description'] as String,
  (json['comment_count'] as num).toInt(),
);

Map<String, dynamic> _$PostToJson(Post instance) => <String, dynamic>{
  'id': instance.id,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
  'file': instance.file,
  'preview': instance.preview,
  'sample': instance.sample,
  'score': instance.score,
  'flags': instance.flags,
  'rating': instance.rating,
  'fav_count': instance.favCount,
  'sources': instance.sources,
  'pools': instance.pools,
  'relationships': instance.relationships,
  'description': instance.description,
  'comment_count': instance.commentCount,
};

PostFile _$PostFileFromJson(Map<String, dynamic> json) => PostFile(
  (json['width'] as num).toInt(),
  (json['height'] as num).toInt(),
  json['ext'] as String,
  (json['size'] as num).toInt(),
  json['md5'] as String,
  json['url'] == null ? null : Uri.parse(json['url'] as String),
);

Map<String, dynamic> _$PostFileToJson(PostFile instance) => <String, dynamic>{
  'width': instance.width,
  'height': instance.height,
  'ext': instance.ext,
  'size': instance.size,
  'md5': instance.md5,
  'url': instance.url?.toString(),
};

PostPreview _$PostPreviewFromJson(Map<String, dynamic> json) => PostPreview(
  (json['width'] as num).toInt(),
  (json['height'] as num).toInt(),
  json['url'] == null ? null : Uri.parse(json['url'] as String),
);

Map<String, dynamic> _$PostPreviewToJson(PostPreview instance) =>
    <String, dynamic>{
      'width': instance.width,
      'height': instance.height,
      'url': instance.url?.toString(),
    };

PostSample _$PostSampleFromJson(Map<String, dynamic> json) => PostSample(
  json['has'] as bool,
  (json['height'] as num).toInt(),
  (json['width'] as num).toInt(),
  json['url'] == null ? null : Uri.parse(json['url'] as String),
);

Map<String, dynamic> _$PostSampleToJson(PostSample instance) =>
    <String, dynamic>{
      'has': instance.has,
      'height': instance.height,
      'width': instance.width,
      'url': instance.url?.toString(),
    };

PostScore _$PostScoreFromJson(Map<String, dynamic> json) => PostScore(
  (json['up'] as num).toInt(),
  (json['down'] as num).toInt(),
  (json['total'] as num).toInt(),
);

Map<String, dynamic> _$PostScoreToJson(PostScore instance) => <String, dynamic>{
  'up': instance.up,
  'down': instance.down,
  'total': instance.total,
};

PostFlags _$PostFlagsFromJson(Map<String, dynamic> json) => PostFlags(
  json['pending'] as bool,
  json['flagged'] as bool,
  json['note_locked'] as bool,
  json['status_locked'] as bool,
  json['rating_locked'] as bool,
  json['deleted'] as bool,
);

Map<String, dynamic> _$PostFlagsToJson(PostFlags instance) => <String, dynamic>{
  'pending': instance.pending,
  'flagged': instance.flagged,
  'note_locked': instance.noteLocked,
  'status_locked': instance.statusLocked,
  'rating_locked': instance.ratingLocked,
  'deleted': instance.deleted,
};

PostRelationships _$PostRelationshipsFromJson(Map<String, dynamic> json) =>
    PostRelationships(
      (json['parent_id'] as num?)?.toInt(),
      json['has_children'] as bool,
      json['has_active_children'] as bool,
      (json['children'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
    );

Map<String, dynamic> _$PostRelationshipsToJson(PostRelationships instance) =>
    <String, dynamic>{
      'parent_id': instance.parentId,
      'has_children': instance.hasChildren,
      'has_active_children': instance.hasActiveChildren,
      'children': instance.children,
    };

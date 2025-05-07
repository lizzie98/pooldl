// The classes in this file represent the API responses.
// ignore_for_file: public_member_api_docs, avoid_positional_boolean_parameters

import 'package:json_annotation/json_annotation.dart';

part 'json_classes.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Pool {
  Pool(
    this.id,
    this.name,
    this.createdAt,
    this.updatedAt,
    this.creatorId,
    this.description,
    this.isActive,
    this.category,
    this.postIds,
    this.creatorName,
    this.postCount,
  );

  factory Pool.fromJson(Map<String, dynamic> json) => _$PoolFromJson(json);
  final int id;
  final String name;
  final String createdAt;
  final String updatedAt;
  final int creatorId;
  final String description;
  final bool isActive;
  final String category;
  final List<int> postIds;
  final String creatorName;
  final int postCount;

  Map<String, dynamic> toJson() => _$PoolToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Post {
  Post(
    this.id,
    this.createdAt,
    this.updatedAt,
    this.file,
    this.preview,
    this.sample,
    this.score,
    this.flags,
    this.rating,
    this.favCount,
    this.sources,
    this.pools,
    this.relationships,
    this.description,
    this.commentCount,
  );

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);
  final int id;
  final String createdAt;
  final String updatedAt;
  final PostFile file;
  final PostPreview preview;
  final PostSample sample;
  final PostScore score;
  final PostFlags flags;
  final String rating;
  final int favCount;
  final List<String> sources;
  final List<int> pools;
  final PostRelationships relationships;
  final String description;
  final int commentCount;

  Map<String, dynamic> toJson() => _$PostToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class PostFile {
  PostFile(this.width, this.height, this.ext, this.size, this.md5, this.url);

  factory PostFile.fromJson(Map<String, dynamic> json) =>
      _$PostFileFromJson(json);
  final int width;
  final int height;
  final String ext;
  final int size;
  final String md5;
  final Uri? url;

  Map<String, dynamic> toJson() => _$PostFileToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class PostPreview {
  PostPreview(this.width, this.height, this.url);

  factory PostPreview.fromJson(Map<String, dynamic> json) =>
      _$PostPreviewFromJson(json);
  final int width;
  final int height;
  final Uri? url;

  Map<String, dynamic> toJson() => _$PostPreviewToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class PostSample {
  PostSample(this.has, this.height, this.width, this.url);

  factory PostSample.fromJson(Map<String, dynamic> json) =>
      _$PostSampleFromJson(json);
  final bool has;
  final int height;
  final int width;
  final Uri? url;

  Map<String, dynamic> toJson() => _$PostSampleToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class PostScore {
  PostScore(this.up, this.down, this.total);

  factory PostScore.fromJson(Map<String, dynamic> json) =>
      _$PostScoreFromJson(json);
  final int up;
  final int down;
  final int total;

  Map<String, dynamic> toJson() => _$PostScoreToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class PostFlags {
  PostFlags(
    this.pending,
    this.flagged,
    this.noteLocked,
    this.statusLocked,
    this.ratingLocked,
    this.deleted,
  );

  factory PostFlags.fromJson(Map<String, dynamic> json) =>
      _$PostFlagsFromJson(json);
  final bool pending;
  final bool flagged;
  final bool noteLocked;
  final bool statusLocked;
  final bool ratingLocked;
  final bool deleted;

  Map<String, dynamic> toJson() => _$PostFlagsToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class PostRelationships {
  PostRelationships(
    this.parentId,
    this.hasChildren,
    this.hasActiveChildren,
    this.children,
  );

  factory PostRelationships.fromJson(Map<String, dynamic> json) =>
      _$PostRelationshipsFromJson(json);
  final int? parentId;
  final bool hasChildren;
  final bool hasActiveChildren;
  final List<int> children;

  Map<String, dynamic> toJson() => _$PostRelationshipsToJson(this);
}

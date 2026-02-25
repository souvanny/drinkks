// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paginated_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PaginatedResponseModel _$PaginatedResponseModelFromJson(
  Map<String, dynamic> json,
) => _PaginatedResponseModel(
  items: (json['items'] as List<dynamic>)
      .map((e) => VenuesModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  total: (json['total'] as num).toInt(),
  page: (json['page'] as num).toInt(),
  limit: (json['limit'] as num).toInt(),
  pages: (json['pages'] as num).toInt(),
);

Map<String, dynamic> _$PaginatedResponseModelToJson(
  _PaginatedResponseModel instance,
) => <String, dynamic>{
  'items': instance.items,
  'total': instance.total,
  'page': instance.page,
  'limit': instance.limit,
  'pages': instance.pages,
};

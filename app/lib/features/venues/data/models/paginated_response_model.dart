import 'package:freezed_annotation/freezed_annotation.dart';
import 'venues_model.dart';

part 'paginated_response_model.freezed.dart';
part 'paginated_response_model.g.dart';

@freezed
abstract class PaginatedResponseModel with _$PaginatedResponseModel {
  const factory PaginatedResponseModel({
    required List<VenuesModel> items,
    required int total,
    required int page,
    required int limit,
    required int pages,
  }) = _PaginatedResponseModel;

  factory PaginatedResponseModel.fromJson(Map<String, dynamic> json) =>
      _$PaginatedResponseModelFromJson(json);
}
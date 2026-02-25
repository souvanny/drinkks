// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'paginated_response_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PaginatedResponseModel {

 List<VenuesModel> get items; int get total; int get page; int get limit; int get pages;
/// Create a copy of PaginatedResponseModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaginatedResponseModelCopyWith<PaginatedResponseModel> get copyWith => _$PaginatedResponseModelCopyWithImpl<PaginatedResponseModel>(this as PaginatedResponseModel, _$identity);

  /// Serializes this PaginatedResponseModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaginatedResponseModel&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.total, total) || other.total == total)&&(identical(other.page, page) || other.page == page)&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.pages, pages) || other.pages == pages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),total,page,limit,pages);

@override
String toString() {
  return 'PaginatedResponseModel(items: $items, total: $total, page: $page, limit: $limit, pages: $pages)';
}


}

/// @nodoc
abstract mixin class $PaginatedResponseModelCopyWith<$Res>  {
  factory $PaginatedResponseModelCopyWith(PaginatedResponseModel value, $Res Function(PaginatedResponseModel) _then) = _$PaginatedResponseModelCopyWithImpl;
@useResult
$Res call({
 List<VenuesModel> items, int total, int page, int limit, int pages
});




}
/// @nodoc
class _$PaginatedResponseModelCopyWithImpl<$Res>
    implements $PaginatedResponseModelCopyWith<$Res> {
  _$PaginatedResponseModelCopyWithImpl(this._self, this._then);

  final PaginatedResponseModel _self;
  final $Res Function(PaginatedResponseModel) _then;

/// Create a copy of PaginatedResponseModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? total = null,Object? page = null,Object? limit = null,Object? pages = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<VenuesModel>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,pages: null == pages ? _self.pages : pages // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PaginatedResponseModel].
extension PaginatedResponseModelPatterns on PaginatedResponseModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaginatedResponseModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaginatedResponseModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaginatedResponseModel value)  $default,){
final _that = this;
switch (_that) {
case _PaginatedResponseModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaginatedResponseModel value)?  $default,){
final _that = this;
switch (_that) {
case _PaginatedResponseModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<VenuesModel> items,  int total,  int page,  int limit,  int pages)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaginatedResponseModel() when $default != null:
return $default(_that.items,_that.total,_that.page,_that.limit,_that.pages);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<VenuesModel> items,  int total,  int page,  int limit,  int pages)  $default,) {final _that = this;
switch (_that) {
case _PaginatedResponseModel():
return $default(_that.items,_that.total,_that.page,_that.limit,_that.pages);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<VenuesModel> items,  int total,  int page,  int limit,  int pages)?  $default,) {final _that = this;
switch (_that) {
case _PaginatedResponseModel() when $default != null:
return $default(_that.items,_that.total,_that.page,_that.limit,_that.pages);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PaginatedResponseModel implements PaginatedResponseModel {
  const _PaginatedResponseModel({required final  List<VenuesModel> items, required this.total, required this.page, required this.limit, required this.pages}): _items = items;
  factory _PaginatedResponseModel.fromJson(Map<String, dynamic> json) => _$PaginatedResponseModelFromJson(json);

 final  List<VenuesModel> _items;
@override List<VenuesModel> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  int total;
@override final  int page;
@override final  int limit;
@override final  int pages;

/// Create a copy of PaginatedResponseModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaginatedResponseModelCopyWith<_PaginatedResponseModel> get copyWith => __$PaginatedResponseModelCopyWithImpl<_PaginatedResponseModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaginatedResponseModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaginatedResponseModel&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.total, total) || other.total == total)&&(identical(other.page, page) || other.page == page)&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.pages, pages) || other.pages == pages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),total,page,limit,pages);

@override
String toString() {
  return 'PaginatedResponseModel(items: $items, total: $total, page: $page, limit: $limit, pages: $pages)';
}


}

/// @nodoc
abstract mixin class _$PaginatedResponseModelCopyWith<$Res> implements $PaginatedResponseModelCopyWith<$Res> {
  factory _$PaginatedResponseModelCopyWith(_PaginatedResponseModel value, $Res Function(_PaginatedResponseModel) _then) = __$PaginatedResponseModelCopyWithImpl;
@override @useResult
$Res call({
 List<VenuesModel> items, int total, int page, int limit, int pages
});




}
/// @nodoc
class __$PaginatedResponseModelCopyWithImpl<$Res>
    implements _$PaginatedResponseModelCopyWith<$Res> {
  __$PaginatedResponseModelCopyWithImpl(this._self, this._then);

  final _PaginatedResponseModel _self;
  final $Res Function(_PaginatedResponseModel) _then;

/// Create a copy of PaginatedResponseModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? total = null,Object? page = null,Object? limit = null,Object? pages = null,}) {
  return _then(_PaginatedResponseModel(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<VenuesModel>,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,pages: null == pages ? _self.pages : pages // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on

// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'venues_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VenuesEntity {

 int get id; String get uuid; String get name; String? get description; int? get type; int? get rank;
/// Create a copy of VenuesEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VenuesEntityCopyWith<VenuesEntity> get copyWith => _$VenuesEntityCopyWithImpl<VenuesEntity>(this as VenuesEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VenuesEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.uuid, uuid) || other.uuid == uuid)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.type, type) || other.type == type)&&(identical(other.rank, rank) || other.rank == rank));
}


@override
int get hashCode => Object.hash(runtimeType,id,uuid,name,description,type,rank);

@override
String toString() {
  return 'VenuesEntity(id: $id, uuid: $uuid, name: $name, description: $description, type: $type, rank: $rank)';
}


}

/// @nodoc
abstract mixin class $VenuesEntityCopyWith<$Res>  {
  factory $VenuesEntityCopyWith(VenuesEntity value, $Res Function(VenuesEntity) _then) = _$VenuesEntityCopyWithImpl;
@useResult
$Res call({
 int id, String uuid, String name, String? description, int? type, int? rank
});




}
/// @nodoc
class _$VenuesEntityCopyWithImpl<$Res>
    implements $VenuesEntityCopyWith<$Res> {
  _$VenuesEntityCopyWithImpl(this._self, this._then);

  final VenuesEntity _self;
  final $Res Function(VenuesEntity) _then;

/// Create a copy of VenuesEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? uuid = null,Object? name = null,Object? description = freezed,Object? type = freezed,Object? rank = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int?,rank: freezed == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [VenuesEntity].
extension VenuesEntityPatterns on VenuesEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VenuesEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VenuesEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VenuesEntity value)  $default,){
final _that = this;
switch (_that) {
case _VenuesEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VenuesEntity value)?  $default,){
final _that = this;
switch (_that) {
case _VenuesEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String uuid,  String name,  String? description,  int? type,  int? rank)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VenuesEntity() when $default != null:
return $default(_that.id,_that.uuid,_that.name,_that.description,_that.type,_that.rank);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String uuid,  String name,  String? description,  int? type,  int? rank)  $default,) {final _that = this;
switch (_that) {
case _VenuesEntity():
return $default(_that.id,_that.uuid,_that.name,_that.description,_that.type,_that.rank);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String uuid,  String name,  String? description,  int? type,  int? rank)?  $default,) {final _that = this;
switch (_that) {
case _VenuesEntity() when $default != null:
return $default(_that.id,_that.uuid,_that.name,_that.description,_that.type,_that.rank);case _:
  return null;

}
}

}

/// @nodoc


class _VenuesEntity implements VenuesEntity {
  const _VenuesEntity({required this.id, required this.uuid, required this.name, this.description, this.type, this.rank});
  

@override final  int id;
@override final  String uuid;
@override final  String name;
@override final  String? description;
@override final  int? type;
@override final  int? rank;

/// Create a copy of VenuesEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VenuesEntityCopyWith<_VenuesEntity> get copyWith => __$VenuesEntityCopyWithImpl<_VenuesEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VenuesEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.uuid, uuid) || other.uuid == uuid)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.type, type) || other.type == type)&&(identical(other.rank, rank) || other.rank == rank));
}


@override
int get hashCode => Object.hash(runtimeType,id,uuid,name,description,type,rank);

@override
String toString() {
  return 'VenuesEntity(id: $id, uuid: $uuid, name: $name, description: $description, type: $type, rank: $rank)';
}


}

/// @nodoc
abstract mixin class _$VenuesEntityCopyWith<$Res> implements $VenuesEntityCopyWith<$Res> {
  factory _$VenuesEntityCopyWith(_VenuesEntity value, $Res Function(_VenuesEntity) _then) = __$VenuesEntityCopyWithImpl;
@override @useResult
$Res call({
 int id, String uuid, String name, String? description, int? type, int? rank
});




}
/// @nodoc
class __$VenuesEntityCopyWithImpl<$Res>
    implements _$VenuesEntityCopyWith<$Res> {
  __$VenuesEntityCopyWithImpl(this._self, this._then);

  final _VenuesEntity _self;
  final $Res Function(_VenuesEntity) _then;

/// Create a copy of VenuesEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? uuid = null,Object? name = null,Object? description = freezed,Object? type = freezed,Object? rank = freezed,}) {
  return _then(_VenuesEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int?,rank: freezed == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on

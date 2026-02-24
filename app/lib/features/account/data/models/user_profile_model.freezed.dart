// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_profile_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserProfileModel {

 String get id;@JsonKey(name: 'displayName') String? get displayName; int? get gender;@JsonKey(name: 'birthdate')@DateTimeConverter() DateTime? get birthdate;@JsonKey(name: 'about_me') String? get aboutMe;@JsonKey(name: 'photo_url') String? get photoUrl;@JsonKey(name: 'has_photo') bool get hasPhoto;
/// Create a copy of UserProfileModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserProfileModelCopyWith<UserProfileModel> get copyWith => _$UserProfileModelCopyWithImpl<UserProfileModel>(this as UserProfileModel, _$identity);

  /// Serializes this UserProfileModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserProfileModel&&(identical(other.id, id) || other.id == id)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.birthdate, birthdate) || other.birthdate == birthdate)&&(identical(other.aboutMe, aboutMe) || other.aboutMe == aboutMe)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.hasPhoto, hasPhoto) || other.hasPhoto == hasPhoto));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,displayName,gender,birthdate,aboutMe,photoUrl,hasPhoto);

@override
String toString() {
  return 'UserProfileModel(id: $id, displayName: $displayName, gender: $gender, birthdate: $birthdate, aboutMe: $aboutMe, photoUrl: $photoUrl, hasPhoto: $hasPhoto)';
}


}

/// @nodoc
abstract mixin class $UserProfileModelCopyWith<$Res>  {
  factory $UserProfileModelCopyWith(UserProfileModel value, $Res Function(UserProfileModel) _then) = _$UserProfileModelCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'displayName') String? displayName, int? gender,@JsonKey(name: 'birthdate')@DateTimeConverter() DateTime? birthdate,@JsonKey(name: 'about_me') String? aboutMe,@JsonKey(name: 'photo_url') String? photoUrl,@JsonKey(name: 'has_photo') bool hasPhoto
});




}
/// @nodoc
class _$UserProfileModelCopyWithImpl<$Res>
    implements $UserProfileModelCopyWith<$Res> {
  _$UserProfileModelCopyWithImpl(this._self, this._then);

  final UserProfileModel _self;
  final $Res Function(UserProfileModel) _then;

/// Create a copy of UserProfileModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? displayName = freezed,Object? gender = freezed,Object? birthdate = freezed,Object? aboutMe = freezed,Object? photoUrl = freezed,Object? hasPhoto = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as int?,birthdate: freezed == birthdate ? _self.birthdate : birthdate // ignore: cast_nullable_to_non_nullable
as DateTime?,aboutMe: freezed == aboutMe ? _self.aboutMe : aboutMe // ignore: cast_nullable_to_non_nullable
as String?,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,hasPhoto: null == hasPhoto ? _self.hasPhoto : hasPhoto // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [UserProfileModel].
extension UserProfileModelPatterns on UserProfileModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserProfileModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserProfileModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserProfileModel value)  $default,){
final _that = this;
switch (_that) {
case _UserProfileModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserProfileModel value)?  $default,){
final _that = this;
switch (_that) {
case _UserProfileModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'displayName')  String? displayName,  int? gender, @JsonKey(name: 'birthdate')@DateTimeConverter()  DateTime? birthdate, @JsonKey(name: 'about_me')  String? aboutMe, @JsonKey(name: 'photo_url')  String? photoUrl, @JsonKey(name: 'has_photo')  bool hasPhoto)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserProfileModel() when $default != null:
return $default(_that.id,_that.displayName,_that.gender,_that.birthdate,_that.aboutMe,_that.photoUrl,_that.hasPhoto);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'displayName')  String? displayName,  int? gender, @JsonKey(name: 'birthdate')@DateTimeConverter()  DateTime? birthdate, @JsonKey(name: 'about_me')  String? aboutMe, @JsonKey(name: 'photo_url')  String? photoUrl, @JsonKey(name: 'has_photo')  bool hasPhoto)  $default,) {final _that = this;
switch (_that) {
case _UserProfileModel():
return $default(_that.id,_that.displayName,_that.gender,_that.birthdate,_that.aboutMe,_that.photoUrl,_that.hasPhoto);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'displayName')  String? displayName,  int? gender, @JsonKey(name: 'birthdate')@DateTimeConverter()  DateTime? birthdate, @JsonKey(name: 'about_me')  String? aboutMe, @JsonKey(name: 'photo_url')  String? photoUrl, @JsonKey(name: 'has_photo')  bool hasPhoto)?  $default,) {final _that = this;
switch (_that) {
case _UserProfileModel() when $default != null:
return $default(_that.id,_that.displayName,_that.gender,_that.birthdate,_that.aboutMe,_that.photoUrl,_that.hasPhoto);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserProfileModel extends UserProfileModel {
  const _UserProfileModel({required this.id, @JsonKey(name: 'displayName') this.displayName, this.gender, @JsonKey(name: 'birthdate')@DateTimeConverter() this.birthdate, @JsonKey(name: 'about_me') this.aboutMe, @JsonKey(name: 'photo_url') this.photoUrl, @JsonKey(name: 'has_photo') this.hasPhoto = false}): super._();
  factory _UserProfileModel.fromJson(Map<String, dynamic> json) => _$UserProfileModelFromJson(json);

@override final  String id;
@override@JsonKey(name: 'displayName') final  String? displayName;
@override final  int? gender;
@override@JsonKey(name: 'birthdate')@DateTimeConverter() final  DateTime? birthdate;
@override@JsonKey(name: 'about_me') final  String? aboutMe;
@override@JsonKey(name: 'photo_url') final  String? photoUrl;
@override@JsonKey(name: 'has_photo') final  bool hasPhoto;

/// Create a copy of UserProfileModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserProfileModelCopyWith<_UserProfileModel> get copyWith => __$UserProfileModelCopyWithImpl<_UserProfileModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserProfileModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserProfileModel&&(identical(other.id, id) || other.id == id)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.birthdate, birthdate) || other.birthdate == birthdate)&&(identical(other.aboutMe, aboutMe) || other.aboutMe == aboutMe)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.hasPhoto, hasPhoto) || other.hasPhoto == hasPhoto));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,displayName,gender,birthdate,aboutMe,photoUrl,hasPhoto);

@override
String toString() {
  return 'UserProfileModel(id: $id, displayName: $displayName, gender: $gender, birthdate: $birthdate, aboutMe: $aboutMe, photoUrl: $photoUrl, hasPhoto: $hasPhoto)';
}


}

/// @nodoc
abstract mixin class _$UserProfileModelCopyWith<$Res> implements $UserProfileModelCopyWith<$Res> {
  factory _$UserProfileModelCopyWith(_UserProfileModel value, $Res Function(_UserProfileModel) _then) = __$UserProfileModelCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'displayName') String? displayName, int? gender,@JsonKey(name: 'birthdate')@DateTimeConverter() DateTime? birthdate,@JsonKey(name: 'about_me') String? aboutMe,@JsonKey(name: 'photo_url') String? photoUrl,@JsonKey(name: 'has_photo') bool hasPhoto
});




}
/// @nodoc
class __$UserProfileModelCopyWithImpl<$Res>
    implements _$UserProfileModelCopyWith<$Res> {
  __$UserProfileModelCopyWithImpl(this._self, this._then);

  final _UserProfileModel _self;
  final $Res Function(_UserProfileModel) _then;

/// Create a copy of UserProfileModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? displayName = freezed,Object? gender = freezed,Object? birthdate = freezed,Object? aboutMe = freezed,Object? photoUrl = freezed,Object? hasPhoto = null,}) {
  return _then(_UserProfileModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as int?,birthdate: freezed == birthdate ? _self.birthdate : birthdate // ignore: cast_nullable_to_non_nullable
as DateTime?,aboutMe: freezed == aboutMe ? _self.aboutMe : aboutMe // ignore: cast_nullable_to_non_nullable
as String?,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,hasPhoto: null == hasPhoto ? _self.hasPhoto : hasPhoto // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on

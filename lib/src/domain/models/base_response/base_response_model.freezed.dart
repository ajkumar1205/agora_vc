// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'base_response_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BaseResponseModel<Data> {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BaseResponseModel<Data>);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'BaseResponseModel<$Data>()';
}


}

/// @nodoc
class $BaseResponseModelCopyWith<Data,$Res>  {
$BaseResponseModelCopyWith(BaseResponseModel<Data> _, $Res Function(BaseResponseModel<Data>) __);
}


/// @nodoc


class Success<Data> extends BaseResponseModel<Data> {
  const Success(this.data): super._();
  

 final  Data data;

/// Create a copy of BaseResponseModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SuccessCopyWith<Data, Success<Data>> get copyWith => _$SuccessCopyWithImpl<Data, Success<Data>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Success<Data>&&const DeepCollectionEquality().equals(other.data, data));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(data));

@override
String toString() {
  return 'BaseResponseModel<$Data>.success(data: $data)';
}


}

/// @nodoc
abstract mixin class $SuccessCopyWith<Data,$Res> implements $BaseResponseModelCopyWith<Data, $Res> {
  factory $SuccessCopyWith(Success<Data> value, $Res Function(Success<Data>) _then) = _$SuccessCopyWithImpl;
@useResult
$Res call({
 Data data
});




}
/// @nodoc
class _$SuccessCopyWithImpl<Data,$Res>
    implements $SuccessCopyWith<Data, $Res> {
  _$SuccessCopyWithImpl(this._self, this._then);

  final Success<Data> _self;
  final $Res Function(Success<Data>) _then;

/// Create a copy of BaseResponseModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? data = freezed,}) {
  return _then(Success<Data>(
freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as Data,
  ));
}


}

/// @nodoc


class Failed<Data> extends BaseResponseModel<Data> {
  const Failed(this.error): super._();
  

 final  Exception error;

/// Create a copy of BaseResponseModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FailedCopyWith<Data, Failed<Data>> get copyWith => _$FailedCopyWithImpl<Data, Failed<Data>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Failed<Data>&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'BaseResponseModel<$Data>.failed(error: $error)';
}


}

/// @nodoc
abstract mixin class $FailedCopyWith<Data,$Res> implements $BaseResponseModelCopyWith<Data, $Res> {
  factory $FailedCopyWith(Failed<Data> value, $Res Function(Failed<Data>) _then) = _$FailedCopyWithImpl;
@useResult
$Res call({
 Exception error
});




}
/// @nodoc
class _$FailedCopyWithImpl<Data,$Res>
    implements $FailedCopyWith<Data, $Res> {
  _$FailedCopyWithImpl(this._self, this._then);

  final Failed<Data> _self;
  final $Res Function(Failed<Data>) _then;

/// Create a copy of BaseResponseModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(Failed<Data>(
null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as Exception,
  ));
}


}

// dart format on

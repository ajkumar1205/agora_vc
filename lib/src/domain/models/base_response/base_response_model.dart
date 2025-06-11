import 'package:freezed_annotation/freezed_annotation.dart';

part 'base_response_model.freezed.dart';

@freezed
abstract class BaseResponseModel<Data> with _$BaseResponseModel<Data> {

  const BaseResponseModel._();

  const factory BaseResponseModel.success(Data data) = Success<Data>;

  const factory BaseResponseModel.failed(Exception error) = Failed<Data>;

}

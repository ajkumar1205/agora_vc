


import 'package:agora_vc/src/domain/models/base_response/base_response_model.dart';

abstract class BaseRepository<Provider> {
  final Provider provider;

  BaseRepository({required this.provider});

  Future<dynamic> get(
    Future call
  ) async {
    try {
      final res = await call;
      if (res == null) {
        return BaseResponseModel.failed(Exception("Something went wrong"));
      }
      return BaseResponseModel.success(res);
    } on Exception catch (e) {
      return BaseResponseModel.failed(e);
    }
  }
}
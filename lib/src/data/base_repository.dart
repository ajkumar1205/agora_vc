


import 'package:agora_vc/src/domain/models/base_response/base_response_model.dart';

abstract class BaseRepository<Provider> {
  final Provider provider;

  BaseRepository({required this.provider});

  Future<BaseResponseModel<Type>> get<Type>(
    Future call
  ) async {
    try {
      final res = (await call) as Type?;
      if (res == null) {
        return BaseResponseModel<Type>.failed(Exception("Something went wrong"));
      }
      return BaseResponseModel<Type>.success(res);
    } on Exception catch (e) {
      return BaseResponseModel<Type>.failed(e);
    }
  }
}
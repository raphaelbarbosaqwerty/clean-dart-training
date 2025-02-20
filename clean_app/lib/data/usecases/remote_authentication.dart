import 'package:clean_app/data/models/models.dart';
import 'package:clean_app/domain/entities/account_entity.dart';
import 'package:clean_app/domain/helpers/helpers.dart';
import 'package:meta/meta.dart';

import '../../domain/usecases/usecases.dart';
import '../http/http.dart';

class RemoteAuthentication implements Authentication {
  final HttpClient httpClient;
  final String url;

  RemoteAuthentication({
    @required this.httpClient,
    @required this.url,
  });

  Future<AccountEntity> auth(AuthenticationParams params) async {
    try {
      final httpResponse = await httpClient.request(
        url: url,
        method: 'post',
        body: RemoteAuthenticationParams.fromDomain(params).toJson()
      );
      return RemoteAccountModel.fromJson(httpResponse).toEntity();
    } on HttpError catch(error) {
      throw error == HttpError.unauthorized ? DomainError.invalidCredentials : DomainError.unexpected;
    }
  }
}

class RemoteAuthenticationParams {
  final String email;
  final String password;

  RemoteAuthenticationParams({
    @required this.email,
    @required this.password,
  });

  factory RemoteAuthenticationParams.fromDomain(AuthenticationParams entity) => 
    RemoteAuthenticationParams(email: entity.email, password: entity.secret);

  Map toJson() => {'email': email, 'password': password};
}
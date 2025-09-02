import 'package:equatable/equatable.dart';

class AuthToken extends Equatable {
  final String acessToken;
  final int expiresIn;

  const AuthToken({
    required this.acessToken,
    required this.expiresIn,
    required String token,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [acessToken, expiresIn];
}

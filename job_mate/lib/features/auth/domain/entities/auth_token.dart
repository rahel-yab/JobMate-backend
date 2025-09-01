import 'package:equatable/equatable.dart';

class AuthToken extends Equatable{
  final String accessToken;
  final int expiresIn;

  const AuthToken({
    required this.accessToken,
    required this.expiresIn
  });
  
  @override
  // TODO: implement props
  List<Object?> get props => [accessToken,expiresIn];

}
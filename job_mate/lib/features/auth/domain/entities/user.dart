import 'package:equatable/equatable.dart';

class User extends Equatable{
  final String userId;
  final String email;
  final String? firstName;
  final String? lastName;
  final String provider;


  const User({
    required this.userId,
    required this.email,
    this.firstName,
    this.lastName,
    required this.provider,

  });
  
  @override
  // TODO: implement props
  List<Object?> get props => [userId,email,firstName,lastName,provider];
  
}
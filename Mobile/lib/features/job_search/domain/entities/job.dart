import 'package:equatable/equatable.dart';

class Job extends Equatable {
  final String title;
  final String company;
  final String location;
  final List<String> requirements;
  final String type;
  final String source;
  final String link;
  final String language;

  Job({
    required this.title,
    required this.company,
    required this.location,
    required this.requirements,
    required this.type,
    required this.source,
    required this.link,
    required this.language,
  });
  
  @override
  // TODO: implement props
  List<Object?> get props => [title,company,location,requirements,type,source,link,language];
}
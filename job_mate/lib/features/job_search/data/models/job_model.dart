import 'package:job_mate/features/job_search/domain/entities/job.dart';

class JobModel extends Job {
  JobModel({
    required String title,
    required String company,
    required String location,
    required List<String> requirements,
    required String type,
    required String source,
    required String link,
    required String language,
  }) : super(
          title: title,
          company: company,
          location: location,
          requirements: requirements,
          type: type,
          source: source,
          link: link,
          language: language,
        );

  factory JobModel.fromJson(Map<String, dynamic> json) {
  return JobModel(
    title: json['title'] ?? '',
    company: json['company'] ?? '',
    location: json['location'] ?? '',
    requirements: List<String>.from(json['requirements'] ?? []),
    type: json['type'] ?? '',
    source: json['source'] ?? '',
    link: json['link'] ?? '',
    language: json['language'] ?? '',
  );
}


  Map<String, dynamic> toJson() => {
  'title': title,
  'company': company,
  'location': location,
  'requirements': requirements,
  'type': type,
  'source': source,
  'link': link,
  'language': language,
};

}
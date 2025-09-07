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
      title: json['Title'],
      company: json['Company'],
      location: json['Location'],
      requirements: List<String>.from(json['Requirements']),
      type: json['Type'],
      source: json['Source'],
      link: json['Link'],
      language: json['Language'],
    );
  }

  Map<String, dynamic> toJson() => {
    'Title': title,
    'Company': company,
    'Location': location,
    'Requirements': requirements,
    'Type': type,
    'Source': source,
    'Link': link,
    'Language': language,
  };
}
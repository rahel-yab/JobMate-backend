import 'package:flutter/material.dart';
import 'package:job_mate/features/job_search/domain/entities/job.dart';

class JobSuggestionWidget extends StatelessWidget {
  final List<Job> jobs;
  
  const JobSuggestionWidget({super.key, required this.jobs});
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '💼 Job Suggestions:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF005148),
          ),
        ),
        const SizedBox(height: 12),
        ...jobs.map((job) => JobCard(job: job)).toList(),
      ],
    );
  }
}

class JobCard extends StatelessWidget {
  final Job job;
  
  const JobCard({super.key, required this.job});
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              job.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF005148),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.business, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  job.company,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  job.location,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            if (job.requirements.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                'Requirements:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              Wrap(
                spacing: 4.0,
                runSpacing: 4.0,
                children: job.requirements
                    .map((req) => Chip(
                          label: Text(
                            req,
                            style: const TextStyle(fontSize: 12),
                          ),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          backgroundColor: const Color(0xFFEAF6F4),
                        ))
                    .toList(),
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Handle apply now action
                  if (job.link.isNotEmpty) {
                    // Open job link
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF005148),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Apply Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
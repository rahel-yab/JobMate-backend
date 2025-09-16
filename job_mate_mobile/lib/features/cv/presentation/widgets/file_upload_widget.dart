import 'package:flutter/material.dart';

class FileUploadWidget extends StatelessWidget {
  final String? filePath;
  final VoidCallback onPickFile;

  const FileUploadWidget({super.key, this.filePath, required this.onPickFile});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPickFile,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: const Color(0xFFEAF6F4),
          border: Border.all(color: Colors.white, width: 2),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Center(
          child:
              filePath == null
                  ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.cloud_upload, size: 50, color: Colors.black87),
                      SizedBox(height: 8),
                      Text(
                        "Tap to upload your CV",
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                    ],
                  )
                  : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.insert_drive_file,
                        size: 40,
                        color: Colors.black87,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        filePath!.split('/').last,
                        style: const TextStyle(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
        ),
      ),
    );
  }
}

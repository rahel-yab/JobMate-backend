import 'package:flutter/material.dart';
import 'package:job_mate/core/presentation/routes.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100.0),
        child: Container(
          color: Colors.teal,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(onPressed: (){}, icon: Icon(Icons.arrow_back_ios_new)),
              SizedBox(width: 8,),
              const Text(
                'Welcome Back',
                style: TextStyle(
                  color: Color.fromARGB(255, 122, 121, 121),
                  fontSize: 16,
                
                ),
                
              ),
              IconButton(onPressed: (){}, icon: Icon(Icons.person)),
              SizedBox(width: 8,),
              const Text(
                'Abebe Kebede',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                
              ),
              const SizedBox(height: 10),
              // Placeholder for logo (replace with your actual logo image)
              // Container(
              //   height: 50,
              //   width: 50,
              //   color: Colors.white, // Replace with your logo image
              //   child: const Center(child: Text('Logo')),
              // ),
              ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.asset(
                    'assets/logo.png',
                    width: 150,
                    height: 150,
                  ),
                ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'What would you like to do?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.5,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildCard(context,'CV Analysis', 'Get feedback on your resume',Routes.cvAnalysis),
                _buildCard(context,'Job Search', 'Find perfect job matches','/job-serach'),
                _buildCard(context,'Interview Prep', 'Practice with mock interviews','/interview-prep'),
                _buildCard(context,'Skill Boost', 'Get personalized learning plan','/skill-boost'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, String title, String subtitle, String route) {
    return InkWell(
      onTap: () {
        context.pushNamed(route);
      },
      child: Card(
        elevation: 4,
        color: Colors.green[50],
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
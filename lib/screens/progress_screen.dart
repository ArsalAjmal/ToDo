import 'package:flutter/material.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildProgressCard(),
              SizedBox(height: 24),
              _buildCategoryProgressList(context),
              SizedBox(height: 24),
              _buildDateSelector(),
              SizedBox(height: 24),
              _buildProgressChart(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Color(0xFF7E3FF2),
        child: Icon(Icons.add),
        elevation: 3,
      ),
    );
  }

  Widget _buildProgressCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Color(0xFF242741),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'You are on Track',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: Colors.green,
              ),
              SizedBox(width: 8),
              Text(
                '50% Progress have made',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryProgressList(BuildContext context) {
    // Category progress data
    final categoryProgress = [
      {
        'name': 'Design',
        'completion': 0.73,
        'color': Color(0xFFFF4E6A),
        'icon': Icons.brush,
      },
      {
        'name': 'Meeting',
        'completion': 0.50,
        'color': Color(0xFFFFA53E),
        'icon': Icons.people,
      },
      {
        'name': 'Learning',
        'completion': 0.35,
        'color': Color(0xFF3E97FF),
        'icon': Icons.book,
      },
    ];

    return Column(
      children: categoryProgress.map((category) {
        return Container(
          margin: EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: (category['color'] as Color).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    category['icon'] as IconData,
                    color: category['color'] as Color,
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category['name'] as String,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Stack(
                      children: [
                        Container(
                          height: 6,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade800,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        Container(
                          height: 6,
                          width: MediaQuery.of(context).size.width * 
                              0.6 * (category['completion'] as double),
                          decoration: BoxDecoration(
                            color: category['color'] as Color,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16),
              Text(
                '${((category['completion'] as double) * 100).toInt()}%',
                style: TextStyle(
                  color: category['color'] as Color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDateSelector() {
    final daysList = ['21', '21', '21', '21', '21'];
    final monthsList = ['Mon', 'Tues', 'Wed', 'Thur', 'Fri'];
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(5, (index) {
        bool isSelected = index == 2;
        return Column(
          children: [
            Text(
              daysList[index],
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            SizedBox(height: 4),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 12, 
                vertical: isSelected ? 8 : 4,
              ),
              decoration: BoxDecoration(
                color: isSelected ? Color(0xFF242741) : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                monthsList[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey,
                  fontSize: isSelected ? 12 : 10,
                ),
              ),
            ),
            if (isSelected)
              Container(
                margin: EdgeInsets.only(top: 4),
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildProgressChart() {
    return Expanded(
      child: Container(
        width: double.infinity,
        child: CustomPaint(
          painter: ChartPainter(),
          child: Container(),
        ),
      ),
    );
  }
}

class ChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final redLine = Paint()
      ..color = Color(0xFFFF4E6A)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    
    final blueLine = Paint()
      ..color = Color(0xFF3E97FF)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    
    final yellowLine = Paint()
      ..color = Color(0xFFFFA53E)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Draw red curve
    final redPath = Path();
    redPath.moveTo(0, size.height * 0.6);
    redPath.quadraticBezierTo(
      size.width * 0.2, 
      size.height * 0.2, 
      size.width * 0.5, 
      size.height * 0.4
    );
    redPath.quadraticBezierTo(
      size.width * 0.8, 
      size.height * 0.6, 
      size.width, 
      size.height * 0.3
    );
    canvas.drawPath(redPath, redLine);

    // Draw red point
    canvas.drawCircle(
      Offset(size.width, size.height * 0.3),
      6,
      Paint()..color = Color(0xFFFF4E6A),
    );
    
    // Draw blue curve
    final bluePath = Path();
    bluePath.moveTo(0, size.height * 0.7);
    bluePath.quadraticBezierTo(
      size.width * 0.3, 
      size.height * 0.8, 
      size.width * 0.5, 
      size.height * 0.5
    );
    bluePath.quadraticBezierTo(
      size.width * 0.7, 
      size.height * 0.2, 
      size.width, 
      size.height * 0.5
    );
    canvas.drawPath(bluePath, blueLine);
    
    // Draw blue point
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.5),
      6,
      Paint()..color = Color(0xFF3E97FF),
    );
    
    // Draw yellow curve
    final yellowPath = Path();
    yellowPath.moveTo(0, size.height * 0.5);
    yellowPath.quadraticBezierTo(
      size.width * 0.3, 
      size.height * 0.6, 
      size.width * 0.7, 
      size.height * 0.7
    );
    yellowPath.quadraticBezierTo(
      size.width * 0.8, 
      size.height * 0.75, 
      size.width, 
      size.height * 0.6
    );
    canvas.drawPath(yellowPath, yellowLine);
    
    // Draw yellow point
    canvas.drawCircle(
      Offset(size.width * 0.7, size.height * 0.7),
      6,
      Paint()..color = Color(0xFFFFA53E),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 
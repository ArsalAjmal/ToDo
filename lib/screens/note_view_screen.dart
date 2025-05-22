import 'package:flutter/material.dart';
import '../models/note.dart';

class NoteViewScreen extends StatelessWidget {
  final Note note;

  const NoteViewScreen({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFC8F4F9),
      appBar: AppBar(
        backgroundColor: Color(0xFFC8F4F9),
        elevation: 0,
        title: Text(
          note.title, 
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (note.isImportant)
                        Container(
                          margin: EdgeInsets.only(right: 8),
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Color(0xFFFF4E6A).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.star,
                            color: Color(0xFFFF4E6A),
                            size: 16,
                          ),
                        ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(note.category).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getCategoryIcon(note.category),
                              color: _getCategoryColor(note.category),
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text(
                              note.category,
                              style: TextStyle(
                                color: _getCategoryColor(note.category),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Created',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '${note.createdAt.day}/${note.createdAt.month}/${note.createdAt.year}',
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (note.dueDate != null) 
                    Container(
                      margin: EdgeInsets.only(top: 12),
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time,
                            color: Colors.grey.shade700,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Due: ${note.dueDate!.day}/${note.dueDate!.month}/${note.dueDate!.year} at ${note.dueDate!.hour}:${note.dueDate!.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(height: 20),
                  Divider(),
                  SizedBox(height: 12),
                  Text(
                    'Description',
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  note.content.isEmpty
                    ? Text(
                        'No description provided.',
                        style: TextStyle(
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      )
                    : Text(
                        note.content,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Work':
        return Color(0xFF3E97FF);
      case 'Personal':
        return Color(0xFFFF4E6A);
      case 'Ideas':
        return Color(0xFFFFA53E);
      case 'Design':
        return Color(0xFF9E3EFF);
      case 'Meeting':
        return Color(0xFF2CD483);
      default:
        return Color(0xFF3E97FF);
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Work':
        return Icons.work;
      case 'Personal':
        return Icons.person;
      case 'Ideas':
        return Icons.lightbulb;
      case 'Design':
        return Icons.brush;
      case 'Meeting':
        return Icons.people;
      default:
        return Icons.note;
    }
  }
}
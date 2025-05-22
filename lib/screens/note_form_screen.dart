import 'package:flutter/material.dart';
import '../models/note.dart';
import '../database/database_helper.dart';

class NoteFormScreen extends StatefulWidget {
  final Note? note;

  const NoteFormScreen({super.key, this.note});

  @override
  _NoteFormScreenState createState() => _NoteFormScreenState();
}

class _NoteFormScreenState extends State<NoteFormScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  late String selectedCategory;
  bool _isImportant = false;
  DateTime _dueDate = DateTime.now().add(Duration(days: 1));
  TimeOfDay _dueTime = TimeOfDay.now();

  // Map of category names to their colors and icons
  final Map<String, Map<String, dynamic>> categoryData = {
    'Work': {'color': Color(0xFF3E97FF), 'icon': Icons.work},
    'Personal': {'color': Color(0xFFFF4E6A), 'icon': Icons.person},
    'Ideas': {'color': Color(0xFFFFA53E), 'icon': Icons.lightbulb},
    'Design': {'color': Color(0xFF9E3EFF), 'icon': Icons.brush},
    'Meeting': {'color': Color(0xFF2CD483), 'icon': Icons.people},
  };

  @override
  void initState() {
    super.initState();

    // Initialize with provided note's category or default to 'Work'
    selectedCategory =
        widget.note?.category?.isNotEmpty == true
            ? widget.note!.category
            : 'Work';

    print('Selected category set to: $selectedCategory');

    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
      _isImportant = widget.note!.isImportant;

      if (widget.note!.dueDate != null) {
        _dueDate = widget.note!.dueDate!;
        _dueTime = TimeOfDay(
          hour: widget.note!.dueDate!.hour,
          minute: widget.note!.dueDate!.minute,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFC8F4F9),
      appBar: AppBar(
        backgroundColor: Color(0xFFC8F4F9),
        elevation: 0,
        title: Text(
          widget.note == null ? 'New Task' : 'Edit Task',
          style: TextStyle(color: Colors.black87),
        ),
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitleField(),
                SizedBox(height: 24),
                _buildCategorySelector(),
                SizedBox(height: 24),
                _buildDueDateSelector(),
                SizedBox(height: 24),
                _buildImportanceToggle(),
                SizedBox(height: 24),
                _buildContentField(),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: _saveNote,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF3CACAE),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: EdgeInsets.symmetric(vertical: 18),
                elevation: 5,
              ),
              child: Text(
                'Save',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleField() {
    return TextField(
      controller: _titleController,
      style: TextStyle(
        color: Colors.black87,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      decoration: InputDecoration(
        hintText: 'Task Title',
        hintStyle: TextStyle(color: Colors.black54),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.transparent),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Color(0xFF3CACAE), width: 2),
        ),
        filled: true,
        fillColor: Color(0xFFE7F9FA),
        prefixIcon: Icon(Icons.title, color: Color(0xFF3CACAE)),
      ),
    );
  }

  Widget _buildCategorySelector() {
    // Debug log to show which category is currently selected
    print(
      'Building category selector with selected category: $selectedCategory',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        Container(
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children:
                categoryData.keys.map((category) {
                  final isSelected = selectedCategory == category;
                  final catData = categoryData[category]!;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategory = category;
                        print('Category selected: $category');
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: 12),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? catData['color'].withOpacity(0.2)
                                : Color(0xFFE7F9FA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              isSelected
                                  ? catData['color']
                                  : Colors.transparent,
                          width: isSelected ? 2.0 : 1.0,
                        ),
                        boxShadow: [
                          if (!isSelected)
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 3,
                              offset: Offset(0, 1),
                            ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            catData['icon'],
                            color:
                                isSelected
                                    ? catData['color']
                                    : Color(0xFF3CACAE),
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            category,
                            style: TextStyle(
                              color:
                                  isSelected ? catData['color'] : Colors.grey,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDueDateSelector() {
    final formattedDate = "${_dueDate.day}/${_dueDate.month}/${_dueDate.year}";

    // Format time with leading zeros
    final hour = _dueTime.hour.toString().padLeft(2, '0');
    final minute = _dueTime.minute.toString().padLeft(2, '0');
    final formattedTime = "$hour:$minute";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Due Date & Time',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  final selectedDate = await showDatePicker(
                    context: context,
                    initialDate: _dueDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(Duration(days: 365)),
                    builder: (context, child) {
                      return Theme(
                        data: ThemeData.light().copyWith(
                          colorScheme: ColorScheme.light(
                            primary: Color(0xFF3CACAE),
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (selectedDate != null) {
                    setState(() {
                      _dueDate = selectedDate;
                    });
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Color(0xFFE7F9FA),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 3,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: Color(0xFF3CACAE),
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        formattedDate,
                        style: TextStyle(color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  final selectedTime = await showTimePicker(
                    context: context,
                    initialTime: _dueTime,
                    builder: (context, child) {
                      return Theme(
                        data: ThemeData.light().copyWith(
                          colorScheme: ColorScheme.light(
                            primary: Color(0xFF3CACAE),
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (selectedTime != null) {
                    setState(() {
                      _dueTime = selectedTime;
                    });
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Color(0xFFE7F9FA),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 3,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        color: Color(0xFF3CACAE),
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        formattedTime,
                        style: TextStyle(color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImportanceToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Mark as Important',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Switch(
          value: _isImportant,
          activeColor: Color(0xFF3CACAE),
          onChanged: (value) {
            setState(() {
              _isImportant = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildContentField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: Color(0xFFE7F9FA),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.transparent, width: 1.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 3,
                offset: Offset(0, 1),
              ),
            ],
          ),
          padding: EdgeInsets.all(0),
          child: TextField(
            controller: _contentController,
            style: TextStyle(color: Colors.black87),
            decoration: InputDecoration(
              hintText: 'Add details about your task...',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.transparent),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.transparent),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Color(0xFF3CACAE), width: 2),
              ),
              contentPadding: EdgeInsets.all(12),
              filled: true,
              fillColor: Color(0xFFE7F9FA),
            ),
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            cursorColor: Color(0xFF3CACAE),
          ),
        ),
      ],
    );
  }

  Future<void> _saveNote() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a title'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Combine date and time into a single DateTime object
      final dueDateTime = DateTime(
        _dueDate.year,
        _dueDate.month,
        _dueDate.day,
        _dueTime.hour,
        _dueTime.minute,
      );

      print('Creating note with category: $selectedCategory');

      final note = Note(
        id: widget.note?.id,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        category: selectedCategory,
        createdAt: widget.note?.createdAt ?? DateTime.now(),
        dueDate: dueDateTime,
        isImportant: _isImportant,
      );

      print('Note object created: ${note.title}, Category: ${note.category}');

      int result;
      if (widget.note == null || widget.note!.id == null) {
        // Insert new note
        result = await DatabaseHelper.insertNote(note);
        print("New note inserted with ID: $result");
      } else {
        // Update existing note
        result = await DatabaseHelper.updateNote(note);
        print("Note updated, rows affected: $result");
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Task saved successfully'),
          backgroundColor: Color(0xFF3CACAE),
          duration: Duration(seconds: 1),
        ),
      );

      // Wait for the snackbar to be visible before popping
      await Future.delayed(Duration(milliseconds: 500));
      Navigator.pop(context);
    } catch (e) {
      print("Error saving note: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving task: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

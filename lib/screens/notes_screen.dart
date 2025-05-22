import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../models/note.dart';
import '../models/user.dart';
import '../database/database_helper.dart';
import 'note_form_screen.dart';
import 'note_view_screen.dart';
import 'package:image_picker/image_picker.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List<Note> notes = [];
  List<String> categories = ['All'];
  String selectedCategory = 'All';
  User? currentUser;
  // Categories with colors and icons - matching the ones in NoteFormScreen
  final Map<String, Map<String, dynamic>> categoryDetails = {
    'Work': {'color': Color(0xFF3E97FF), 'icon': Icons.work},
    'Personal': {'color': Color(0xFFFF4E6A), 'icon': Icons.person},
    'Ideas': {'color': Color(0xFFFFA53E), 'icon': Icons.lightbulb},
    'Design': {'color': Color(0xFF9E3EFF), 'icon': Icons.brush},
    'Meeting': {'color': Color(0xFF2CD483), 'icon': Icons.people},
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadUser();
    await _loadNotes();
  }

  Future<void> _loadUser() async {
    final user = await DatabaseHelper.getUser();
    setState(() {
      currentUser = user;
    });
  }

  Future<void> _loadNotes() async {
    List<Note> allNotes;
    if (selectedCategory == 'All') {
      allNotes = await DatabaseHelper.getAllNotes();
    } else {
      allNotes = await DatabaseHelper.getNotesByCategory(selectedCategory);
    }

    // Get categories from database
    List<String> dbCategories = await DatabaseHelper.getCategories();

    // Combine predefined categories with database categories
    List<String> allCategories = ['All'];

    // Add predefined categories first
    for (String category in categoryDetails.keys) {
      if (!allCategories.contains(category)) {
        allCategories.add(category);
      }
    }

    // Add any additional categories from database
    for (String category in dbCategories) {
      if (!allCategories.contains(category)) {
        allCategories.add(category);
      }
    }

    setState(() {
      notes = allNotes;
      categories = allCategories;
    });
  }

  Future<void> _pickImage() async {
    try {
      print('Starting image picker...');
      final ImagePicker picker = ImagePicker();
      final XFile? pickedImage = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 150,
        maxHeight: 150,
        imageQuality: 85,
      );

      if (pickedImage == null) {
        print('No image selected');
        return;
      }

      print('Image selected: ${pickedImage.path}');

      // Read image as bytes
      final bytes = await pickedImage.readAsBytes();
      print('Image bytes length: ${bytes.length}');

      // Convert to base64 string
      final base64Image = base64Encode(bytes);
      print('Base64 string length: ${base64Image.length}');

      // Create updated user
      final updatedUser = User(
        id: currentUser?.id,
        name: currentUser?.name ?? 'User',
        profileImageBase64: base64Image,
      );
      print('User object created with ID: ${updatedUser.id}');

      // Save to database
      final result = await DatabaseHelper.updateUser(updatedUser);
      print('Database update result: $result');

      // Refresh UI
      await _loadUser();
      print(
        'User reloaded, profile image exists: ${currentUser?.profileImageBase64 != null}',
      );
      print(
        'Profile image length: ${currentUser?.profileImageBase64?.length ?? 0}',
      );

      setState(() {
        // Force UI update
      });
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFC8F4F9),
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUserHeader(),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Category',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  _buildCategoryFilter(),
                ],
              ),
              SizedBox(height: 16),
              _buildCategoryCards(),
              SizedBox(height: 24),
              Expanded(child: _buildNotesList()),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNote,
        backgroundColor: Color(0xFF3CACAE),
        child: Icon(Icons.add, size: 28),
        elevation: 4,
        highlightElevation: 8,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 6,
        elevation: 0,
        color: Colors.white,
        child: Container(
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Left side icons
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(Icons.home_outlined),
                      onPressed: () {}, // No action
                      color: Colors.grey.shade400,
                    ),
                    IconButton(
                      icon: Icon(Icons.calendar_today_outlined, size: 20),
                      onPressed: () {}, // No action
                      color: Colors.grey.shade400,
                    ),
                  ],
                ),
              ),

              // Spacer for the FAB
              SizedBox(width: 70),

              // Right side icons
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(Icons.search_outlined),
                      onPressed: () {}, // No action
                      color: Colors.grey.shade400,
                    ),
                    IconButton(
                      icon: Icon(Icons.settings_outlined),
                      onPressed: () {}, // No action
                      color: Colors.grey.shade400,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserHeader() {
    // Convert base64 to Image widget if available
    Widget profileImage;

    if (currentUser?.profileImageBase64 != null &&
        currentUser!.profileImageBase64!.isNotEmpty) {
      try {
        print(
          'Attempting to decode profile image of length: ${currentUser!.profileImageBase64!.length}',
        );
        final decodedBytes = base64Decode(currentUser!.profileImageBase64!);
        print('Decoded bytes length: ${decodedBytes.length}');

        profileImage = Container(
          width: 48,
          height: 48,
          child: Image.memory(
            decodedBytes,
            fit: BoxFit.cover,
            width: 48,
            height: 48,
            errorBuilder: (context, error, stackTrace) {
              print('Error rendering image: $error');
              return Center(
                child: Text(
                  'U',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        );
      } catch (e) {
        print('Error decoding profile image: $e');
        profileImage = Center(
          child: Text(
            'U',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        );
      }
    } else {
      profileImage = Center(
        child: Text(
          'U',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            Text(
              currentUser?.name ?? 'User',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: _pickImage,
          child: Stack(
            children: [
              CircleAvatar(
                backgroundColor: Color(0xFF3CACAE),
                radius: 24,
                child: ClipOval(
                  child: SizedBox(width: 48, height: 48, child: profileImage),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    size: 14,
                    color: Color(0xFF3CACAE),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.grey),
          SizedBox(width: 8),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey),
              ),
              style: TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCards() {
    return SizedBox(
      height: 110,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children:
            categoryDetails.entries.map((entry) {
              // Count notes for this category
              int notesCount =
                  notes.where((note) => note.category == entry.key).length;

              return InkWell(
                onTap: () {
                  setState(() {
                    selectedCategory = entry.key;
                  });
                  _loadNotes();
                },
                borderRadius: BorderRadius.circular(16),
                splashColor: entry.value['color'].withOpacity(0.3),
                highlightColor: entry.value['color'].withOpacity(0.1),
                child: Container(
                  width: 110,
                  margin: EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        entry.value['icon'],
                        color: entry.value['color'],
                        size: 24,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.key,
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '• $notesCount Tasks',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => _addCategoryNote(entry.key),
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: Icon(
                            Icons.add,
                            color: entry.value['color'],
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildNotesList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
          // No radius for bottom corners to merge with navbar
        ),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2)),
        ],
      ),
      padding: EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        bottom: 0, // Remove bottom padding to merge with navbar
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            selectedCategory == 'All' ? "All Tasks" : "$selectedCategory Tasks",
            style: TextStyle(
              color: Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child:
                notes.isEmpty
                    ? Center(
                      child: Text(
                        'No tasks found.\nTap + to create your first task!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    )
                    : ListView.builder(
                      padding: EdgeInsets.only(
                        bottom: 70,
                      ), // Add padding at bottom for navbar
                      itemCount: notes.length,
                      itemBuilder: (context, index) {
                        final note = notes[index];
                        Color noteColor =
                            categoryDetails.containsKey(note.category)
                                ? categoryDetails[note.category]!['color']
                                : Color(0xFF3E97FF);
                        IconData noteIcon =
                            categoryDetails.containsKey(note.category)
                                ? categoryDetails[note.category]!['icon']
                                : Icons.note;

                        return Container(
                          margin: EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            onTap: () => _viewNote(note),
                            borderRadius: BorderRadius.circular(12),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: noteColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      note.isImportant ? Icons.star : noteIcon,
                                      color: noteColor,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        note.title,
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (note.content.isNotEmpty)
                                        Text(
                                          note.content.length > 30
                                              ? '${note.content.substring(0, 30)}...'
                                              : note.content,
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                PopupMenuButton(
                                  icon: Icon(
                                    Icons.more_vert,
                                    color: Colors.grey,
                                  ),
                                  itemBuilder:
                                      (context) => [
                                        PopupMenuItem(
                                          value: 'edit',
                                          child: Text('Edit'),
                                        ),
                                        PopupMenuItem(
                                          value: 'delete',
                                          child: Text('Delete'),
                                        ),
                                      ],
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      _editNote(note);
                                    } else if (value == 'delete') {
                                      _deleteNote(note);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return GestureDetector(
      onTap: () => _showCategoryFilterDialog(),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: Color(0xFF3CACAE),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Filter By:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryFilterDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Filter by Category',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Container(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = category == selectedCategory;

                  // Get color and icon for the category
                  Color categoryColor = Color(0xFF3CACAE); // Default color
                  IconData categoryIcon = Icons.folder; // Default icon

                  if (category != 'All' &&
                      categoryDetails.containsKey(category)) {
                    categoryColor = categoryDetails[category]!['color'];
                    categoryIcon = categoryDetails[category]!['icon'];
                  }

                  return ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? categoryColor.withOpacity(0.2)
                                : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Icon(
                          category == 'All'
                              ? Icons.all_inclusive
                              : categoryIcon,
                          color: isSelected ? categoryColor : Colors.grey,
                          size: 20,
                        ),
                      ),
                    ),
                    title: Text(
                      category,
                      style: TextStyle(
                        color: isSelected ? categoryColor : Colors.black87,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    trailing:
                        isSelected
                            ? Icon(Icons.check_circle, color: categoryColor)
                            : null,
                    onTap: () {
                      setState(() {
                        selectedCategory = category;
                      });
                      _loadNotes();
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'CANCEL',
                  style: TextStyle(color: Color(0xFF3CACAE)),
                ),
              ),
            ],
          ),
    );
  }

  void _addNote() {
    // When using the main add button, respect the currently selected category
    // If "All" is selected, use "Work" as default
    String categoryToUse =
        selectedCategory == 'All' ? 'Work' : selectedCategory;
    print('Creating new note with category: $categoryToUse');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => NoteFormScreen(
              note: Note(
                title: '',
                content: '',
                category: categoryToUse,
                createdAt: DateTime.now(),
              ),
            ),
      ),
    ).then((_) => _loadNotes());
  }

  void _addCategoryNote(String category) {
    print('Creating new note for specific category: $category');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => NoteFormScreen(
              note: Note(
                title: '',
                content: '',
                category: category,
                createdAt: DateTime.now(),
              ),
            ),
      ),
    ).then((_) => _loadNotes());
  }

  void _editNote(Note note) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoteFormScreen(note: note)),
    ).then((_) => _loadNotes());
  }

  void _viewNote(Note note) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoteViewScreen(note: note)),
    );
  }

  Future<void> _deleteNote(Note note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            title: Text(
              'Delete',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            content: Text('Are you sure you want to delete this note?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel', style: TextStyle(color: Colors.black87)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await DatabaseHelper.deleteNote(note.id!);
      _loadNotes();
    }
  }
}

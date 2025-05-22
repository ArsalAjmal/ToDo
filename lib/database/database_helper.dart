import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/note.dart';
import '../models/user.dart';
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;

class DatabaseHelper {
  static Database? _database;
  static const String tableName = 'notes';
  static const String userTableName = 'user';

  // In-memory data store for web platform
  static List<Note> _inMemoryNotes = [];
  static User? _inMemoryUser;
  static int _nextId = 1;

  // Flag to determine if we're using in-memory mode (for web)
  static bool _useInMemory = kIsWeb;

  // Initialize sample data for web demo
  static bool _initialized = false;

  static Future<Database> get database async {
    if (_database != null) return _database!;

    try {
      _database = await _initDatabase();
      return _database!;
    } catch (e) {
      print('Failed to initialize database: $e');
      print('Falling back to in-memory storage');
      _useInMemory = true;
      // Return dummy database - won't be used
      throw e;
    }
  }

  // Initialize with some demo data for web
  static void _initWebDemo() {
    if (_initialized) return;
    _initialized = true;

    print('Initializing empty in-memory database for web');
    // No sample data initialization
  }

  static Future<Database> _initDatabase() async {
    try {
      String path = join(await getDatabasesPath(), 'notes.db');
      return await openDatabase(
        path,
        version: 3,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE $tableName(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title TEXT NOT NULL,
              content TEXT NOT NULL,
              category TEXT NOT NULL,
              createdAt TEXT NOT NULL,
              dueDate TEXT,
              isImportant INTEGER DEFAULT 0
            )
          ''');

          await db.execute('''
            CREATE TABLE $userTableName(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL,
              profileImageBase64 TEXT
            )
          ''');
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) {
            // Add new columns for version 2
            await db.execute('ALTER TABLE $tableName ADD COLUMN dueDate TEXT');
            await db.execute(
              'ALTER TABLE $tableName ADD COLUMN isImportant INTEGER DEFAULT 0',
            );
          }

          if (oldVersion < 3) {
            // Add user table in version 3
            await db.execute('''
              CREATE TABLE $userTableName(
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                profileImageBase64 TEXT
              )
            ''');
          }
        },
      );
    } catch (e) {
      print('Database initialization error: $e');
      rethrow;
    }
  }

  // User methods
  static Future<User?> getUser() async {
    try {
      if (_useInMemory) {
        print('Getting user from in-memory storage');
        // Initialize demo data if first use
        if (!_initialized) {
          _initWebDemo();
        }

        // Return in-memory user
        if (_inMemoryUser == null) {
          _inMemoryUser = User(name: 'User');
          print('Created default in-memory user');
        }
        print(
          'Returning in-memory user with profile image: ${_inMemoryUser?.profileImageBase64 != null}',
        );
        return _inMemoryUser;
      } else {
        print('Getting user from SQLite database');
        final db = await database;
        final List<Map<String, dynamic>> maps = await db.query(userTableName);
        print('User query result: ${maps.length} records found');

        if (maps.isEmpty) {
          // Create default user if none exists
          print('No user found, creating default user');
          final defaultUser = User(name: 'User');
          await insertUser(defaultUser);
          return defaultUser;
        }

        final user = User.fromMap(maps.first);
        print(
          'User loaded from database, has profile image: ${user.profileImageBase64 != null}',
        );
        if (user.profileImageBase64 != null) {
          print('Profile image length: ${user.profileImageBase64!.length}');
        }
        return user;
      }
    } catch (e) {
      print('Error getting user: $e');
      // Fall back to in-memory if database fails
      if (!_useInMemory) {
        _useInMemory = true;
        return getUser();
      }
      return User(name: 'User');
    }
  }

  static Future<int> insertUser(User user) async {
    try {
      if (_useInMemory) {
        print('Inserting user in in-memory storage');
        // Initialize demo data if first use
        if (!_initialized) {
          _initWebDemo();
        }

        _inMemoryUser = User(
          id: 1,
          name: user.name,
          profileImageBase64: user.profileImageBase64,
        );
        print(
          'In-memory user inserted, has profile image: ${_inMemoryUser?.profileImageBase64 != null}',
        );
        return 1;
      } else {
        print('Inserting user in SQLite database');
        final db = await database;

        // First clear any existing user (we only keep one user)
        await db.delete(userTableName);
        print('Cleared existing users from database');

        // Then insert the new user
        final userMap = user.toMap();
        print('User map for insertion: $userMap');
        final id = await db.insert(userTableName, userMap);
        print('User inserted with ID: $id');
        return id;
      }
    } catch (e) {
      print('Error inserting user: $e');
      // Fall back to in-memory if database fails
      if (!_useInMemory) {
        _useInMemory = true;
        return insertUser(user);
      }
      return -1;
    }
  }

  static Future<int> updateUser(User user) async {
    try {
      if (_useInMemory) {
        print('Updating user in in-memory storage');
        // Initialize demo data if first use
        if (!_initialized) {
          _initWebDemo();
        }

        _inMemoryUser = User(
          id: 1,
          name: user.name,
          profileImageBase64: user.profileImageBase64,
        );
        print(
          'In-memory user updated, has profile image: ${_inMemoryUser?.profileImageBase64 != null}',
        );
        return 1;
      } else {
        print('Updating user in SQLite database');
        final db = await database;

        // If no ID is provided, get the current user first
        if (user.id == null) {
          print('No user ID provided, getting current user');
          final currentUser = await getUser();
          if (currentUser?.id != null) {
            print('Using existing user ID: ${currentUser!.id}');
            // Create a new user object with the existing ID
            final updatedUser = User(
              id: currentUser.id,
              name: user.name,
              profileImageBase64: user.profileImageBase64,
            );

            // Update with the ID
            final result = await db.update(
              userTableName,
              updatedUser.toMap(),
              where: 'id = ?',
              whereArgs: [updatedUser.id],
            );
            print('User updated with ID ${updatedUser.id}, result: $result');
            return result;
          } else {
            // Insert as new user if no existing user
            print('No existing user found, inserting new user');
            return await insertUser(user);
          }
        }

        // We're updating our single user with provided ID
        final result = await db.update(
          userTableName,
          user.toMap(),
          where: 'id = ?',
          whereArgs: [user.id],
        );
        print('User updated with ID ${user.id}, result: $result');
        return result;
      }
    } catch (e) {
      print('Error updating user: $e');
      // Fall back to in-memory if database fails
      if (!_useInMemory) {
        _useInMemory = true;
        return updateUser(user);
      }
      return 0;
    }
  }

  static Future<int> insertNote(Note note) async {
    try {
      if (_useInMemory) {
        // Initialize demo data if first use
        if (!_initialized) {
          _initWebDemo();
        }

        final newNote = Note(
          id: _nextId++,
          title: note.title,
          content: note.content,
          category: note.category,
          createdAt: note.createdAt,
          dueDate: note.dueDate,
          isImportant: note.isImportant,
        );
        _inMemoryNotes.add(newNote);
        print('Note inserted with ID: ${newNote.id} (in-memory)');
        return newNote.id!;
      } else {
        final db = await database;
        final result = await db.insert(tableName, note.toMap());
        print('Note inserted with ID: $result');
        return result;
      }
    } catch (e) {
      print('Error inserting note: $e');
      // Fall back to in-memory if database fails
      if (!_useInMemory) {
        _useInMemory = true;
        return insertNote(note);
      }
      return -1;
    }
  }

  static Future<List<Note>> getAllNotes() async {
    try {
      if (_useInMemory) {
        // Initialize demo data if first use
        if (!_initialized) {
          _initWebDemo();
        }

        print(
          'Retrieved ${_inMemoryNotes.length} notes from in-memory storage',
        );
        return List.from(_inMemoryNotes)..sort((a, b) {
          if (a.isImportant != b.isImportant) {
            return a.isImportant ? -1 : 1;
          }
          return b.createdAt.compareTo(a.createdAt);
        });
      } else {
        final db = await database;
        final List<Map<String, dynamic>> maps = await db.query(
          tableName,
          orderBy: 'isImportant DESC, createdAt DESC',
        );
        print('Retrieved ${maps.length} notes from database');
        return List.generate(maps.length, (i) => Note.fromMap(maps[i]));
      }
    } catch (e) {
      print('Error getting all notes: $e');
      // Fall back to in-memory if database fails
      if (!_useInMemory) {
        _useInMemory = true;
        return getAllNotes();
      }
      return [];
    }
  }

  static Future<List<Note>> getNotesByCategory(String category) async {
    try {
      if (_useInMemory) {
        // Initialize demo data if first use
        if (!_initialized) {
          _initWebDemo();
        }

        final filtered =
            _inMemoryNotes.where((note) => note.category == category).toList()
              ..sort((a, b) {
                if (a.isImportant != b.isImportant) {
                  return a.isImportant ? -1 : 1;
                }
                return b.createdAt.compareTo(a.createdAt);
              });
        print(
          'Retrieved ${filtered.length} notes for category: $category (in-memory)',
        );
        return filtered;
      } else {
        final db = await database;
        final List<Map<String, dynamic>> maps = await db.query(
          tableName,
          where: 'category = ?',
          whereArgs: [category],
          orderBy: 'isImportant DESC, createdAt DESC',
        );
        print('Retrieved ${maps.length} notes for category: $category');
        return List.generate(maps.length, (i) => Note.fromMap(maps[i]));
      }
    } catch (e) {
      print('Error getting notes by category: $e');
      // Fall back to in-memory if database fails
      if (!_useInMemory) {
        _useInMemory = true;
        return getNotesByCategory(category);
      }
      return [];
    }
  }

  static Future<int> updateNote(Note note) async {
    try {
      if (_useInMemory) {
        // Initialize demo data if first use
        if (!_initialized) {
          _initWebDemo();
        }

        final index = _inMemoryNotes.indexWhere((n) => n.id == note.id);
        if (index != -1) {
          _inMemoryNotes[index] = note;
          print('Note updated, id: ${note.id} (in-memory)');
          return 1;
        }
        return 0;
      } else {
        final db = await database;
        final result = await db.update(
          tableName,
          note.toMap(),
          where: 'id = ?',
          whereArgs: [note.id],
        );
        print('Note updated, rows affected: $result');
        return result;
      }
    } catch (e) {
      print('Error updating note: $e');
      // Fall back to in-memory if database fails
      if (!_useInMemory) {
        _useInMemory = true;
        return updateNote(note);
      }
      return 0;
    }
  }

  static Future<int> deleteNote(int id) async {
    try {
      if (_useInMemory) {
        // Initialize demo data if first use
        if (!_initialized) {
          _initWebDemo();
        }

        final initialLength = _inMemoryNotes.length;
        _inMemoryNotes.removeWhere((note) => note.id == id);
        final result = initialLength - _inMemoryNotes.length;
        print('Note deleted, rows affected: $result (in-memory)');
        return result;
      } else {
        final db = await database;
        final result = await db.delete(
          tableName,
          where: 'id = ?',
          whereArgs: [id],
        );
        print('Note deleted, rows affected: $result');
        return result;
      }
    } catch (e) {
      print('Error deleting note: $e');
      // Fall back to in-memory if database fails
      if (!_useInMemory) {
        _useInMemory = true;
        return deleteNote(id);
      }
      return 0;
    }
  }

  static Future<List<String>> getCategories() async {
    try {
      if (_useInMemory) {
        // Initialize demo data if first use
        if (!_initialized) {
          _initWebDemo();
        }

        final categories =
            _inMemoryNotes.map((note) => note.category).toSet().toList()
              ..sort();
        print(
          'Retrieved ${categories.length} categories from in-memory storage',
        );
        return categories;
      } else {
        final db = await database;
        final List<Map<String, dynamic>> maps = await db.rawQuery(
          'SELECT DISTINCT category FROM $tableName ORDER BY category',
        );
        final categories =
            maps.map((map) => map['category'] as String).toList();
        print('Retrieved ${categories.length} categories from database');
        return categories;
      }
    } catch (e) {
      print('Error getting categories: $e');
      // Fall back to in-memory if database fails
      if (!_useInMemory) {
        _useInMemory = true;
        return getCategories();
      }
      return [];
    }
  }
}

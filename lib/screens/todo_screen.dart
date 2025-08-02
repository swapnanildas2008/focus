import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/todo_item.dart';
import '../services/database_helper.dart';
import '../utils/colors.dart';
import '../widgets/todo_item_widget.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({Key? key}) : super(key: key);

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  List<TodoItem> _todos = [];
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTodos();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadTodos() async {
    final todos = await DatabaseHelper().getTodoItems();
    setState(() {
      _todos = todos;
    });
  }

  void _onSearchChanged() {
    setState(() {}); // Trigger rebuild for search
  }

  Map<String, List<TodoItem>> get _organizedTodos {
    final Map<String, List<TodoItem>> organized = {};
    
    // Filter todos based on search
    final filteredTodos = _todos.where((todo) {
      final searchQuery = _searchController.text.toLowerCase();
      return todo.title.toLowerCase().contains(searchQuery) ||
             todo.description.toLowerCase().contains(searchQuery);
    }).toList();
    
    for (final todo in filteredTodos) {
      String dateKey;
      
      if (todo.dueTime != null) {
        final dueDate = todo.dueTime!;
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final tomorrow = today.add(const Duration(days: 1));
        final todoDate = DateTime(dueDate.year, dueDate.month, dueDate.day);
        
        if (todoDate == today) {
          dateKey = '📅 Today';
        } else if (todoDate == tomorrow) {
          dateKey = '⏰ Tomorrow';
        } else if (todoDate.isBefore(today)) {
          dateKey = '⚠️ Overdue';
        } else if (todoDate.difference(today).inDays <= 7) {
          dateKey = '📆 This Week';
        } else {
          dateKey = '📋 Later';
        }
      } else {
        dateKey = '📝 No Due Date';
      }
      
      organized[dateKey] ??= [];
      organized[dateKey]!.add(todo);
    }
    
    // Sort todos within each category
    organized.forEach((key, todos) {
      todos.sort((a, b) {
        // Sort by completion status first
        if (a.isCompleted != b.isCompleted) {
          return a.isCompleted ? 1 : -1;
        }
        // Then by priority
        if (a.priority != b.priority) {
          return b.priority.compareTo(a.priority);
        }
        // Then by due time
        if (a.dueTime != null && b.dueTime != null) {
          return a.dueTime!.compareTo(b.dueTime!);
        }
        // Finally by creation time
        return b.createdAt.compareTo(a.createdAt);
      });
    });
    
    return organized;
  }

  void _showAddTodoDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime? selectedDueTime;
    int selectedPriority = 1;
    int selectedColorIndex = 0;
    int selectedMinutes = 25;
    String selectedCategory = 'Work';
    
    final categories = ['Work', 'Personal', 'Health', 'Learning', 'Shopping', 'Other'];
    final colors = [
      AppColors.accentOrange,
      AppColors.accentPink,
      AppColors.accentPurple,
      AppColors.accentBlue,
      AppColors.accentTeal,
      AppColors.forestGreen,
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '✨ Create New Task',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Title
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Task Title *',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.title),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Description
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description (Optional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.description),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  
                  // Category dropdown
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedCategory,
                        icon: const Icon(Icons.category),
                        items: categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setDialogState(() => selectedCategory = value!);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Due date and time
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Due Date & Time'),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextButton.icon(
                                onPressed: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime.now().add(const Duration(days: 365)),
                                  );
                                  if (date != null) {
                                    final time = await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                    );
                                    if (time != null) {
                                      setDialogState(() {
                                        selectedDueTime = DateTime(
                                          date.year,
                                          date.month,
                                          date.day,
                                          time.hour,
                                          time.minute,
                                        );
                                      });
                                    }
                                  }
                                },
                                icon: const Icon(Icons.calendar_today),
                                label: Text(
                                  selectedDueTime != null
                                      ? DateFormat('MMM dd, yyyy HH:mm').format(selectedDueTime!)
                                      : 'Set Due Date',
                                ),
                              ),
                            ),
                            if (selectedDueTime != null)
                              IconButton(
                                onPressed: () {
                                  setDialogState(() => selectedDueTime = null);
                                },
                                icon: const Icon(Icons.clear),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Priority and estimated time row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Priority'),
                            DropdownButton<int>(
                              value: selectedPriority,
                              isExpanded: true,
                              items: const [
                                DropdownMenuItem(value: 0, child: Text('🟢 Low')),
                                DropdownMenuItem(value: 1, child: Text('🟡 Medium')),
                                DropdownMenuItem(value: 2, child: Text('🔴 High')),
                              ],
                              onChanged: (value) {
                                setDialogState(() => selectedPriority = value!);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Estimated Time'),
                            DropdownButton<int>(
                              value: selectedMinutes,
                              isExpanded: true,
                              items: [5, 15, 25, 30, 45, 60, 90, 120].map((minutes) {
                                return DropdownMenuItem(
                                  value: minutes,
                                  child: Text('${minutes} min'),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setDialogState(() => selectedMinutes = value!);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Color selection
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Task Color'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: colors.asMap().entries.map((entry) {
                          final index = entry.key;
                          final color = entry.value;
                          return GestureDetector(
                            onTap: () {
                              setDialogState(() => selectedColorIndex = index);
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: selectedColorIndex == index
                                    ? Border.all(color: Colors.black, width: 3)
                                    : null,
                                boxShadow: selectedColorIndex == index
                                    ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 8, spreadRadius: 2)]
                                    : null,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (titleController.text.isNotEmpty) {
                              final todo = TodoItem(
                                title: titleController.text,
                                description: descriptionController.text,
                                createdAt: DateTime.now(),
                                dueTime: selectedDueTime,
                                priority: selectedPriority,
                                colorIndex: selectedColorIndex,
                                estimatedMinutes: selectedMinutes,
                              );
                              DatabaseHelper().insertTodoItem(todo);
                              _loadTodos();
                              Navigator.of(context).pop();
                              
                              // Show success message
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('✅ Task created successfully!'),
                                  backgroundColor: AppColors.forestGreen,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Create Task'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showTaskReward() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                AppColors.forestGreen.shade100,
                AppColors.accentOrange,
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.forestGreen,
                      AppColors.accentOrange,
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '🎉 Task Complete!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Well done! You completed a task.\nYour productivity grows stronger.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.forestGreen.shade600,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.accentOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '+5 Task Coins Earned! ⭐',
                  style: TextStyle(
                    color: AppColors.accentOrange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Awesome!'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final organizedTodos = _organizedTodos;
    final completedToday = _todos.where((todo) {
      if (!todo.isCompleted) return false;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final completedDate = DateTime(
        todo.createdAt.year,
        todo.createdAt.month,
        todo.createdAt.day,
      );
      return completedDate == today;
    }).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.forestGreen.shade400,
                AppColors.forestGreen.shade600,
              ],
            ),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accentOrange,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Text(
                  '$completedToday',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.lightBackground,
              Colors.green.shade50,
            ],
          ),
        ),
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search tasks...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            
            // Organized task list
            Expanded(
              child: organizedTodos.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.task_alt,
                            size: 64,
                            color: AppColors.forestGreen.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No tasks yet!',
                            style: TextStyle(
                              fontSize: 18,
                              color: AppColors.forestGreen.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap the + button to create your first task',
                            style: TextStyle(
                              color: AppColors.forestGreen.shade400,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: organizedTodos.keys.length,
                      itemBuilder: (context, index) {
                        final dateKey = organizedTodos.keys.elementAt(index);
                        final todos = organizedTodos[dateKey]!;
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ExpansionTile(
                            initiallyExpanded: dateKey.contains('Today') || dateKey.contains('Overdue'),
                            title: Text(
                              dateKey,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Text('${todos.length} task${todos.length != 1 ? 's' : ''}'),
                            children: todos.map((todo) {
                              return TodoItemWidget(
                                todoItem: todo,
                                onToggleComplete: (todo) {
                                  todo.isCompleted = !todo.isCompleted;
                                  DatabaseHelper().updateTodoItem(todo);
                                  _loadTodos();
                                  
                                  if (todo.isCompleted) {
                                    _showTaskReward();
                                  }
                                },
                                onDelete: (todo) {
                                  DatabaseHelper().deleteTodoItem(todo.id!);
                                  _loadTodos();
                                },
                              );
                            }).toList(),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTodoDialog,
        icon: const Icon(Icons.add),
        label: const Text('New Task'),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/todo_item.dart';
import '../utils/colors.dart';

class TodoItemWidget extends StatelessWidget {
  final TodoItem todoItem;
  final Function(TodoItem) onToggleComplete;
  final Function(TodoItem) onDelete;

  const TodoItemWidget({
    Key? key,
    required this.todoItem,
    required this.onToggleComplete,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = [
      AppColors.accentOrange,
      AppColors.accentPink,
      AppColors.accentPurple,
      AppColors.accentBlue,
      AppColors.accentTeal,
      AppColors.forestGreen,
    ];

    final selectedColor = colors[todoItem.colorIndex % colors.length];
    final priorityColors = [
      AppColors.lowPriority,
      AppColors.mediumPriority,
      AppColors.highPriority,
    ];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              selectedColor.withOpacity(0.1),
              selectedColor.withOpacity(0.05),
            ],
          ),
          border: Border(
            left: BorderSide(
              color: selectedColor,
              width: 4,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checkbox
              GestureDetector(
                onTap: () => onToggleComplete(todoItem),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selectedColor,
                      width: 2,
                    ),
                    color: todoItem.isCompleted ? selectedColor : Colors.transparent,
                  ),
                  child: todoItem.isCompleted
                      ? const Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            todoItem.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              decoration: todoItem.isCompleted 
                                  ? TextDecoration.lineThrough 
                                  : null,
                              color: todoItem.isCompleted
                                  ? Colors.grey.shade500
                                  : Colors.black87,
                            ),
                          ),
                        ),
                        // Priority indicator
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: priorityColors[todoItem.priority],
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    if (todoItem.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        todoItem.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          decoration: todoItem.isCompleted 
                              ? TextDecoration.lineThrough 
                              : null,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (todoItem.dueTime != null) ...[
                          Icon(
                            Icons.schedule,
                            size: 16,
                            color: _isDueSoon(todoItem.dueTime!) 
                                ? AppColors.overdueTask 
                                : Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('MMM dd, HH:mm').format(todoItem.dueTime!),
                            style: TextStyle(
                              fontSize: 12,
                              color: _isDueSoon(todoItem.dueTime!) 
                                  ? AppColors.overdueTask 
                                  : Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Icon(
                          Icons.timer,
                          size: 16,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${todoItem.estimatedMinutes}m',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => onDelete(todoItem),
                          child: Icon(
                            Icons.delete_outline,
                            size: 20,
                            color: Colors.red.shade400,
                          ),
                        ),
                      ],
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

  bool _isDueSoon(DateTime dueTime) {
    final now = DateTime.now();
    final difference = dueTime.difference(now);
    return difference.inDays == 0 && difference.inHours < 2;
  }
}

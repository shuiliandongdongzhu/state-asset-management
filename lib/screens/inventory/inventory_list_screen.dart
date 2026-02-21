import 'package:flutter/material.dart';
import '../../database/inventory_dao.dart';
import '../../models/inventory_model.dart';
import '../../router/app_router.dart';

class InventoryListScreen extends StatefulWidget {
  const InventoryListScreen({Key? key}) : super(key: key);

  @override
  State<InventoryListScreen> createState() => _InventoryListScreenState();
}

class _InventoryListScreenState extends State<InventoryListScreen> {
  final InventoryDao _inventoryDao = InventoryDao();
  List<InventoryTaskModel> _tasks = [];
  bool _isLoading = false;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    
    try {
      final tasks = await _inventoryDao.getAllTasks();
      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('加载失败: $e')),
      );
    }
  }

  List<InventoryTaskModel> get _filteredTasks {
    switch (_selectedTab) {
      case 0: // 全部
        return _tasks;
      case 1: // 进行中
        return _tasks.where((t) => t.status == 1).toList();
      case 2: // 已完成
        return _tasks.where((t) => t.status == 2).toList();
      default:
        return _tasks;
    }
  }

  Future<void> _deleteTask(InventoryTaskModel task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除盘点任务 "${task.taskName}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _inventoryDao.deleteTask(task.id);
        await _inventoryDao.deleteRecordsByTaskId(task.id);
        _loadTasks();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('删除成功')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('删除失败: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('盘点管理'),
          bottom: TabBar(
            onTap: (index) {
              setState(() => _selectedTab = index);
            },
            tabs: const [
              Tab(text: '全部'),
              Tab(text: '进行中'),
              Tab(text: '已完成'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _filteredTasks.isEmpty
                ? const Center(child: Text('暂无盘点任务'))
                : RefreshIndicator(
                    onRefresh: _loadTasks,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredTasks.length,
                      itemBuilder: (context, index) {
                        final task = _filteredTasks[index];
                        return _buildTaskCard(task);
                      },
                    ),
                  ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showCreateTaskDialog(),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildTaskCard(InventoryTaskModel task) {
    final theme = Theme.of(context);
    final dateFormat = '${task.startDate.month}-${task.startDate.day}';
    final endDateFormat = '${task.endDate.month}-${task.endDate.day}';

    Color statusColor;
    IconData statusIcon;
    switch (task.status) {
      case 0:
        statusColor = Colors.grey;
        statusIcon = Icons.schedule;
        break;
      case 1:
        statusColor = Colors.orange;
        statusIcon = Icons.play_circle_outline;
        break;
      case 2:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      default:
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => Navigator.pushNamed(
          context,
          AppRouter.inventoryTask,
          arguments: {'taskId': task.id},
        ).then((_) => _loadTasks()),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(statusIcon, color: statusColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.taskName,
                          style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          task.taskCode,
                          style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey,
                              ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('编辑'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'scan',
                        child: Row(
                          children: [
                            Icon(Icons.qr_code_scanner, size: 18),
                            SizedBox(width: 8),
                            Text('扫码盘点'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.red[300]),
                            const SizedBox(width: 8),
                            Text('删除', style: TextStyle(color: Colors.red[300])),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          _showEditTaskDialog(task);
                          break;
                        case 'scan':
                          Navigator.pushNamed(
                            context,
                            AppRouter.inventoryScan,
                            arguments: {'taskId': task.id},
                          );
                          break;
                        case 'delete':
                          _deleteTask(task);
                          break;
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.date_range, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '$dateFormat - $endDateFormat',
                    style: theme.textTheme.bodySmall,
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      task.statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => const TaskFormDialog(),
    ).then((result) {
      if (result == true) _loadTasks();
    });
  }

  void _showEditTaskDialog(InventoryTaskModel task) {
    showDialog(
      context: context,
      builder: (context) => TaskFormDialog(task: task),
    ).then((result) {
      if (result == true) _loadTasks();
    });
  }
}

// 任务表单对话框
class TaskFormDialog extends StatefulWidget {
  final InventoryTaskModel? task;

  const TaskFormDialog({Key? key, this.task}) : super(key: key);

  @override
  State<TaskFormDialog> createState() => _TaskFormDialogState();
}

class _TaskFormDialogState extends State<TaskFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));
  int _status = 0;

  final InventoryDao _inventoryDao = InventoryDao();

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _nameController.text = widget.task!.taskName;
      _codeController.text = widget.task!.taskCode;
      _descriptionController.text = widget.task!.description ?? '';
      _startDate = widget.task!.startDate;
      _endDate = widget.task!.endDate;
      _status = widget.task!.status;
    } else {
      _codeController.text = 'INV${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final now = DateTime.now();
      final task = InventoryTaskModel(
        id: widget.task?.id ?? 'task_${now.millisecondsSinceEpoch}',
        taskName: _nameController.text.trim(),
        taskCode: _codeController.text.trim(),
        startDate: _startDate,
        endDate: _endDate,
        status: _status,
        description: _descriptionController.text.isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        createdAt: widget.task?.createdAt ?? now,
        updatedAt: now,
      );

      if (widget.task != null) {
        await _inventoryDao.updateTask(task);
      } else {
        await _inventoryDao.insertTask(task);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('保存失败: $e')),
      );
    }
  }

  Future<void> _selectDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 1));
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.task != null ? '编辑盘点任务' : '新建盘点任务'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '任务名称 *',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入任务名称';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: '任务编码 *',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入任务编码';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(true),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: '开始日期',
                        ),
                        child: Text('${_startDate.month}-${_startDate.day}'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(false),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: '结束日期',
                        ),
                        child: Text('${_endDate.month}-${_endDate.day}'),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _status,
                decoration: const InputDecoration(
                  labelText: '任务状态',
                ),
                items: const [
                  DropdownMenuItem(value: 0, child: Text('待开始')),
                  DropdownMenuItem(value: 1, child: Text('进行中')),
                  DropdownMenuItem(value: 2, child: Text('已完成')),
                  DropdownMenuItem(value: 3, child: Text('已取消')),
                ],
                onChanged: (value) {
                  setState(() => _status = value ?? 0);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: '任务说明',
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: _saveTask,
          child: const Text('保存'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}

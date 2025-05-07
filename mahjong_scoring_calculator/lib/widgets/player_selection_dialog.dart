import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../database/model/user.dart';

class PlayerSelectionDialog extends StatefulWidget {
  final Function(String, int) onPlayerSelected;
  final List<int> existingPlayerIds;

  const PlayerSelectionDialog({
    super.key,
    required this.onPlayerSelected,
    required this.existingPlayerIds,
  });

  @override
  State<PlayerSelectionDialog> createState() => _PlayerSelectionDialogState();
}

class _PlayerSelectionDialogState extends State<PlayerSelectionDialog> {
  final TextEditingController _nameController = TextEditingController();
  List<User> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final dbHelper = DatabaseHelper.instance;
    final allUsers = await dbHelper.getAllUsers();
    _users = allUsers.where((user) => 
      !widget.existingPlayerIds.contains(user.userId)).toList();
    setState(() => _isLoading = false);
  }

  Future<void> _addNewUser() async {
    if (_nameController.text.isEmpty) return;
    
    final dbHelper = DatabaseHelper.instance;
    await dbHelper.insertUser(_nameController.text);
    _nameController.clear();
    await _loadUsers();
  }

  Future<void> _deleteUser(int userId) async {
    final dbHelper = DatabaseHelper.instance;
    await dbHelper.deleteUser(userId);
    await _loadUsers();
  }

  void _showNameInputDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                autofocus: true,
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'New Player Name',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.check),
                    onPressed: () {
                      _addNewUser();
                      Navigator.pop(context);
                    },
                  ),
                ),
                onSubmitted: (_) {
                  _addNewUser();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 600,
          maxHeight: 300
        ),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListTile(
                title: const Text('Add New Player'),
                leading: const Icon(Icons.person_add),
                onTap: _showNameInputDialog,
              ),
              const Divider(),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          childAspectRatio: 3,
                          mainAxisSpacing: 5,
                          crossAxisSpacing: 5,
                        ),
                        itemCount: _users.length,
                        itemBuilder: (context, index) => Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextButton(
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                    ),
                                    child: Text(
                                      _users[index].username ?? 'Unknown',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    onPressed: () {
                                      widget.onPlayerSelected(
                                        _users[index].username!,
                                        _users[index].userId!,
                                      );
                                      Navigator.pop(context);
                                    },
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, size: 16),
                                  onPressed: () => _deleteUser(_users[index].userId!),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
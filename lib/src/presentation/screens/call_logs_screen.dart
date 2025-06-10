import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class CallLogsScreen extends StatefulWidget {
  const CallLogsScreen({super.key});

  @override
  State<CallLogsScreen> createState() => _CallLogsScreenState();
}

class _CallLogsScreenState extends State<CallLogsScreen> {
  // Mock call logs data - replace with actual data from your backend
  final List<Map<String, dynamic>> _callLogs = [
    {
      'id': '1',
      'name': 'John Doe',
      'type': 'outgoing',
      'status': 'answered',
      'duration': '05:32',
      'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
    },
    {
      'id': '2',
      'name': 'Jane Smith',
      'type': 'incoming',
      'status': 'missed',
      'duration': '00:00',
      'timestamp': DateTime.now().subtract(const Duration(hours: 5)),
    },
    {
      'id': '3',
      'name': 'Mike Johnson',
      'type': 'outgoing',
      'status': 'answered',
      'duration': '12:45',
      'timestamp': DateTime.now().subtract(const Duration(days: 1)),
    },
    {
      'id': '4',
      'name': 'Sarah Wilson',
      'type': 'incoming',
      'status': 'answered',
      'duration': '08:21',
      'timestamp': DateTime.now().subtract(const Duration(days: 1, hours: 3)),
    },
    {
      'id': '5',
      'name': 'David Brown',
      'type': 'outgoing',
      'status': 'declined',
      'duration': '00:00',
      'timestamp': DateTime.now().subtract(const Duration(days: 2)),
    },
    {
      'id': '6',
      'name': 'Emma Davis',
      'type': 'incoming',
      'status': 'answered',
      'duration': '03:15',
      'timestamp': DateTime.now().subtract(const Duration(days: 2, hours: 8)),
    },
    {
      'id': '7',
      'name': 'Chris Anderson',
      'type': 'outgoing',
      'status': 'missed',
      'duration': '00:00',
      'timestamp': DateTime.now().subtract(const Duration(days: 3)),
    },
    {
      'id': '8',
      'name': 'Lisa Taylor',
      'type': 'incoming',
      'status': 'answered',
      'duration': '15:48',
      'timestamp': DateTime.now().subtract(const Duration(days: 4)),
    },
  ];

  void _callUser(String userId, String userName) {
    // TODO: Implement call functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calling $userName...'),
        backgroundColor: Colors.lightBlue.shade600,
      ),
    );
  }

  void _deleteCallLog(String callId) {
    setState(() {
      _callLogs.removeWhere((log) => log['id'] == callId);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Call log deleted'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      // Today - show time
      final hours = timestamp.hour.toString().padLeft(2, '0');
      final minutes = timestamp.minute.toString().padLeft(2, '0');
      return '$hours:$minutes';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      // Show date
      final day = timestamp.day.toString().padLeft(2, '0');
      final month = timestamp.month.toString().padLeft(2, '0');
      return '$day/$month';
    }
  }

  IconData _getCallIcon(String type, String status) {
    if (type == 'incoming') {
      if (status == 'missed') {
        return Icons.call_received;
      } else {
        return Icons.call_received;
      }
    } else {
      if (status == 'missed' || status == 'declined') {
        return Icons.call_made;
      } else {
        return Icons.call_made;
      }
    }
  }

  Color _getCallIconColor(String type, String status) {
    if (status == 'missed') {
      return Colors.red.shade600;
    } else if (status == 'declined') {
      return Colors.orange.shade600;
    } else if (type == 'incoming') {
      return Colors.green.shade600;
    } else {
      return Colors.lightBlue.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue.shade50,
      appBar: AppBar(
        backgroundColor: Colors.lightBlue.shade600,
        foregroundColor: Colors.white,
        title: const Text(
          'Call Logs',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Implement clear all logs
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear All Logs'),
                  content: const Text(
                    'Are you sure you want to clear all call logs?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _callLogs.clear();
                        });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('All call logs cleared'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      },
                      child: const Text(
                        'Clear All',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.clear_all),
            tooltip: 'Clear All Logs',
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(Icons.history, size: 48, color: Colors.lightBlue.shade600),
                const SizedBox(height: 8),
                Text(
                  'Call History',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.lightBlue.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_callLogs.length} call logs',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),

          // Call Logs List
          Expanded(
            child: _callLogs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.phone_disabled,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No call logs',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your call history will appear here',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _callLogs.length,
                    itemBuilder: (context, index) {
                      final log = _callLogs[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade200,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: _getCallIconColor(
                              log['type'],
                              log['status'],
                            ).withOpacity(0.1),
                            radius: 24,
                            child: Icon(
                              _getCallIcon(log['type'], log['status']),
                              color: _getCallIconColor(
                                log['type'],
                                log['status'],
                              ),
                              size: 24,
                            ),
                          ),
                          title: Text(
                            log['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    log['type'] == 'incoming'
                                        ? Icons.arrow_downward
                                        : Icons.arrow_upward,
                                    size: 12,
                                    color: log['type'] == 'incoming'
                                        ? Colors.green.shade600
                                        : Colors.lightBlue.shade600,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${log['type'] == 'incoming' ? 'Incoming' : 'Outgoing'} • ${log['status']}',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              if (log['status'] == 'answered')
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 12,
                                      color: Colors.grey.shade500,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Duration: ${log['duration']}',
                                      style: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _formatTimestamp(log['timestamp']),
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () =>
                                        _callUser(log['id'], log['name']),
                                    icon: Icon(
                                      Icons.phone,
                                      color: Colors.lightBlue.shade600,
                                      size: 20,
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 32,
                                      minHeight: 32,
                                    ),
                                    padding: EdgeInsets.zero,
                                  ),
                                  IconButton(
                                    onPressed: () => _deleteCallLog(log['id']),
                                    icon: Icon(
                                      Icons.delete_outline,
                                      color: Colors.red.shade400,
                                      size: 20,
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 32,
                                      minHeight: 32,
                                    ),
                                    padding: EdgeInsets.zero,
                                  ),
                                ],
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
}

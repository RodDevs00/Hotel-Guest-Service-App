import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';

class NewRequestScreen extends ConsumerStatefulWidget {
  const NewRequestScreen({super.key, required this.serviceTypeId});

  final String serviceTypeId;

  @override
  ConsumerState<NewRequestScreen> createState() => _NewRequestScreenState();
}

class _NewRequestScreenState extends ConsumerState<NewRequestScreen> {
  final _notesController = TextEditingController();
  int _quantity = 1;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit(ServiceType type) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final session = ref.read(sessionUserProvider).value;
      final stayId = session?.stayId;
      final roomId = session?.roomId;
      if (stayId == null || roomId == null) {
        throw Exception('Your stay session expired. Sign in again.');
      }

      await ref.read(requestRepositoryProvider).createRequest(
            stayId: stayId,
            roomId: roomId,
            serviceTypeId: type.id,
            quantity: type.allowsQuantity ? _quantity : null,
            notes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request sent. Staff will see it as Pending.')),
      );
      context.go('/guest/requests');
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final types = ref.watch(serviceTypesProvider).value ?? const <ServiceType>[];
    ServiceType? type;
    for (final item in types) {
      if (item.id == widget.serviceTypeId) {
        type = item;
        break;
      }
    }

    if (type == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('New request')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final selected = type;
    return Scaffold(
      appBar: AppBar(title: Text(selected.name)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Send a request', style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 8),
          Text(
            selected.name.toLowerCase().contains('wake')
                ? 'Add the wake-up time in the notes field.'
                : 'Add any details the staff should know.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 20),
          if (selected.allowsQuantity) ...[
            Text('Quantity', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                    icon: const Icon(Icons.remove),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '$_quantity',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _quantity++),
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          TextField(
            controller: _notesController,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'Notes (optional)',
              hintText: selected.name.toLowerCase().contains('wake')
                  ? 'Example: 6:30 AM'
                  : 'Any extra details',
              alignLabelWithHint: true,
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: AppColors.error)),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _loading ? null : () => _submit(selected),
            child: _loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Submit request'),
          ),
        ],
      ),
    );
  }
}

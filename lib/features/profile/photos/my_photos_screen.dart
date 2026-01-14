import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../app/theme/app_colors.dart';
import '../controllers/profile_controller.dart';
import '../models/photo.dart';

class MyPhotosScreen extends StatefulWidget {
  const MyPhotosScreen({super.key});

  @override
  State<MyPhotosScreen> createState() => _MyPhotosScreenState();
}

class _MyPhotosScreenState extends State<MyPhotosScreen> {
  final _picker = ImagePicker();

  Future<void> _addPhoto() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 92,
    );
    if (picked == null) return;

    await context.read<ProfileController>().addPhotoFromPath(picked.path);
  }

  void _onManageTap(Photo photo) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Manage photo',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: const Text('Delete photo'),
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    await context.read<ProfileController>().deletePhotoById(
                      photo.id,
                    );
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  'Moderation note: Photos should be consensual, legal, and respectful.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final photos = context.watch<ProfileController>().me.photos;

    return Scaffold(
      appBar: AppBar(title: const Text('My Photos')),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            children: [
              Text(
                'Your photos',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              Text(
                'Long-press a photo to manage it. One upload at a time in v1.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 14),

              if (photos.isEmpty)
                _EmptyState(onAdd: _addPhoto)
              else
                _PhotoGrid(photos: photos, onTapManage: _onManageTap),

              const SizedBox(height: 18),
              Text(
                'Moderation',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              Text(
                'Help keep the community safe. Photos should be consensual, legal, and respectful.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),

          // Sticky add button
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _addPhoto,
                icon: const Icon(Icons.add),
                label: const Text('Add photo'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'No photos yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              'Add a photo so people can recognize you. Your primary photo is square in v1.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Add your first photo'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoGrid extends StatelessWidget {
  final List<Photo> photos;
  final void Function(Photo photo) onTapManage;

  const _PhotoGrid({
    required this.photos,
    required this.onTapManage,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: photos.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final photo = photos[index];
        final isPrimary = index == 0;

        return _DraggablePhotoTile(
          key: ValueKey(photo.id),
          index: index,
          photo: photo,
          isPrimary: isPrimary,
          onTapManage: () => onTapManage(photo),
          onReorder: (from, to) async {
            await context.read<ProfileController>().reorderPhotos(from, to);
          },
        );
      },
    );
  }
}

class _DraggablePhotoTile extends StatefulWidget {
  final int index;
  final Photo photo;
  final bool isPrimary;
  final VoidCallback onTapManage;
  final Future<void> Function(int from, int to) onReorder;

  const _DraggablePhotoTile({
    super.key,
    required this.index,
    required this.photo,
    required this.isPrimary,
    required this.onTapManage,
    required this.onReorder,
  });

  @override
  State<_DraggablePhotoTile> createState() => _DraggablePhotoTileState();
}

class _DraggablePhotoTileState extends State<_DraggablePhotoTile> {
  bool _isDragOver = false;

  @override
  Widget build(BuildContext context) {
    final photo = widget.photo;

    return DragTarget<int>(
      onWillAccept: (from) {
        if (from == null) return false;
        final ok = from != widget.index;
        if (ok) setState(() => _isDragOver = true);
        return ok;
      },
      onLeave: (_) => setState(() => _isDragOver = false),
      onAccept: (from) async {
        setState(() => _isDragOver = false);
        await widget.onReorder(from, widget.index);
      },
      builder: (context, _, __) {
        return GestureDetector(
          onTap: widget.onTapManage,
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  decoration: BoxDecoration(
                    color: _isDragOver ? AppColors.sparkExploreSoft : AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _isDragOver ? AppColors.sparkExplore : AppColors.border),
                  ),
                  child: (photo.localPath != null && File(photo.localPath!).existsSync())
                      ? Image.file(
                          File(photo.localPath!),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        )
                      : const Center(child: Icon(Icons.image_outlined)),
                ),
              ),

              // Primary label
              if (widget.isPrimary)
                Positioned(
                  left: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.sparkExplore,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Primary',
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(color: Colors.white),
                    ),
                  ),
                ),

              // Drag handle ONLY (tap + drag starts reorder immediately)
              Positioned(
                right: 6,
                top: 6,
                child: _DragHandle(
                  index: widget.index,
                  preview: _PhotoPreview(photo: photo),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DragHandle extends StatelessWidget {
  final int index;
  final Widget preview;

  const _DragHandle({
    required this.index,
    required this.preview,
  });

  @override
  Widget build(BuildContext context) {
    return Draggable<int>(
      data: index,
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: 110,
          height: 110,
          child: preview,
        ),
      ),
      childWhenDragging: _handle(context, opacity: 0.35),
      child: _handle(context),
    );
  }

  Widget _handle(BuildContext context, {double opacity = 0.35}) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(opacity),
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Icon(
        Icons.open_with, // four-headed arrow
        size: 18,
        color: Colors.white,
      ),
    );
  }
}

class _PhotoPreview extends StatelessWidget {
  final Photo photo;
  const _PhotoPreview({required this.photo});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        color: AppColors.surfaceMuted,
        child: (photo.localPath != null && File(photo.localPath!).existsSync())
            ? Image.file(
                File(photo.localPath!),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              )
            : const Center(child: Icon(Icons.image_outlined)),
      ),
    );
  }
}

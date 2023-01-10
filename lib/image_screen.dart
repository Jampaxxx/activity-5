import 'package:activity_five/image_model.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:provider/provider.dart';

class ImageScreen extends StatefulWidget {
  const ImageScreen({Key? key}) : super(key: key);

  @override
  State<ImageScreen> createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  late final ImageModel _model;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _model = ImageModel();
  }
  
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _model,
      child: Consumer<ImageModel>(
        builder: (context, model, child) {
          Widget widget;

          switch (model.imageSection) {
            case ImageSection.noStoragePermission:
              widget = _ImagePermissions(
                isPermanent: false,
                onPressed: _checkPermissionAndPick,
              );
              break;
            case ImageSection.noStoragePermissionPermanent:
              widget = _ImagePermissions(
                isPermanent: true,
                onPressed: _checkPermissionAndPick,
              );
              break;
            case ImageSection.browseFiles:
              widget = _PickFile(onPressed: _checkPermissionAndPick);
              break;
            case ImageSection.imageLoaded:
              widget = _ImageLoaded(file: _model.file!);
              break;
          }
          return Scaffold(
            appBar: AppBar(
              title: const Text('Activity 5'),
            ),
            body: widget,
            floatingActionButton: const FloatingActionButton(
              onPressed: null,
              child: Icon(Icons.add),
            ),
          );
        },
      ),
    );
  }

  Future<void> _checkPermissionAndPick() async {
    final hasFilePermission = await _model.requestPermission();
    if (hasFilePermission) {
      try {
        await _model.pickFile();
      } on Exception catch (e) {
        debugPrint('Error when picking a file: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occured when picking a file'),
          ),
        );
      }
    }
  }
}

class _ImagePermissions extends StatelessWidget {
  final bool isPermanent;
  final VoidCallback onPressed;

  const _ImagePermissions({
    Key? key,
    required this.isPermanent,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.only(
              left: 16.0,
              top: 24.0,
              right: 16.0,
            ),
            child: Text(
              'Read files permission',
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          Container(
            padding: const EdgeInsets.only(
              left: 16.0,
              top: 24.0,
              right: 16.0,
            ),
            child: const Text(
              'We need to request your permission to read'
                  'local files in order to load them into the app.',
              textAlign: TextAlign.center,
            ),
          ),
          if (isPermanent)
            Container(
              padding: const EdgeInsets.only(
                left: 16.0,
                top: 24.0,
                right: 16.0,
              ),
              child: const Text(
                'You need to give this permission from the system settings.',
                textAlign: TextAlign.center,
              ),
            ),
          Container(
            padding: const EdgeInsets.only(
              left: 16.0,
              top: 24.0,
              right: 16.0,
              bottom: 24.0,
            ),
            child: ElevatedButton(
              child: Text(isPermanent ? 'Open settings' : 'Allow access'),
              onPressed: () => isPermanent ? openAppSettings() : onPressed(),
            ),
          )
        ],
      ),
    );
  }
}

class _PickFile extends StatelessWidget {
  final VoidCallback onPressed;

  const _PickFile({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Center(
    child: ElevatedButton(
      child: Text('Pick Image'),
      onPressed: onPressed,
    ),
  );
}

class _ImageLoaded extends StatelessWidget {
  final File file;

  const _ImageLoaded({Key? key, required this.file}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 196.0,
        height: 196.0,
        child: Image.file(
          file,
          fit: BoxFit.fitWidth,
        ),
      ),
    );
  }
}

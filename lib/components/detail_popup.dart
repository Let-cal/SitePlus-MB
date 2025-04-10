// lib/components/detail_popup.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DetailPopup extends StatefulWidget {
  final String title;
  final List<Widget> infoSections;
  final Widget actionButtons;
  final VoidCallback? onClose;

  const DetailPopup({
    super.key,
    required this.title,
    required this.infoSections,
    required this.actionButtons,
    this.onClose,
  });

  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required List<Widget> infoSections,
    required Widget actionButtons,
    VoidCallback? onClose,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DetailPopup(
            title: title,
            infoSections: infoSections,
            actionButtons: actionButtons,
            onClose: onClose,
          ),
    );
  }

  @override
  _DetailPopupState createState() => _DetailPopupState();
}

class _DetailPopupState extends State<DetailPopup> {
  late BuildContext _stableContext;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _stableContext = context;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Container(
          height: size.height * 0.85,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      ...widget.infoSections,
                      const SizedBox(height: 24),
                      widget.actionButtons,
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 300.ms)
        .slide(
          duration: 400.ms,
          begin: const Offset(0, 0.1),
          end: Offset.zero,
          curve: Curves.easeOutQuad,
        );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.info, color: theme.colorScheme.primary),
                  const SizedBox(width: 12),
                  Text(
                    widget.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed:
                    widget.onClose ?? () => Navigator.of(_stableContext).pop(),
                icon: Icon(
                  Icons.close,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

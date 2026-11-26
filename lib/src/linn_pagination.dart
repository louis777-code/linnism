import 'package:flutter/material.dart';

import 'linn_icon_button.dart';
import 'linn_state.dart';
import 'linn_style.dart';
import 'linn_theme.dart';

/// Previous and next controls for a one-based page number.
///
/// Pass zero for both [page] and [pageCount] when there are no pages.
class LinnPagination extends StatelessWidget {
  const LinnPagination({
    required this.page,
    required this.pageCount,
    required this.onChanged,
    this.state = LinnState.idle,
    this.style,
    super.key,
  }) : assert(pageCount >= 0),
       assert(pageCount == 0 ? page == 0 : page >= 1 && page <= pageCount);

  final int page;
  final int pageCount;
  final ValueChanged<int>? onChanged;
  final LinnState state;
  final LinnThemeData? style;

  @override
  Widget build(BuildContext context) => LinnStyle.scope(context, style, _build);

  Widget _build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = MaterialLocalizations.of(context);
    final enabled = state.isInteractive && onChanged != null;
    final displayState = !enabled && state == LinnState.idle
        ? LinnState.disabled
        : state;
    final accent = LinnStyle.accent(context, displayState);
    final pageLabel = pageCount == 0
        ? 'No pages'
        : 'Page ${localizations.formatDecimal(page)} of ${localizations.formatDecimal(pageCount)}';

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: 'Pagination',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          LinnIconButton(
            icon: Icons.chevron_left,
            label: localizations.previousPageTooltip,
            onPressed: enabled && page > 1 ? () => onChanged!(page - 1) : null,
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Semantics(
              liveRegion: true,
              value: displayState == LinnState.idle ? null : displayState.label,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    pageLabel,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelLarge,
                  ),
                  if (displayState != LinnState.idle) ...[
                    const SizedBox(height: 4),
                    ExcludeSemantics(
                      child: LinnStateIndicator(
                        state: displayState,
                        color: accent,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          LinnIconButton(
            icon: Icons.chevron_right,
            label: localizations.nextPageTooltip,
            onPressed: enabled && page < pageCount
                ? () => onChanged!(page + 1)
                : null,
          ),
        ],
      ),
    );
  }
}

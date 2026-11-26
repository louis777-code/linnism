part of 'main.dart';

class _DashboardPreviews extends StatefulWidget {
  const _DashboardPreviews({required this.state, super.key});

  final LinnState state;

  @override
  State<_DashboardPreviews> createState() => _DashboardPreviewsState();
}

class _DashboardPreviewsState extends State<_DashboardPreviews> {
  static const _pageSize = 3;
  static const _resultPreviewHeight = 206.0;
  static const _projects = [
    (name: 'Riverside', active: true),
    (name: 'Hilltop', active: true),
    (name: 'North Market', active: false),
    (name: 'Lakeview', active: true),
    (name: 'Greenfield', active: false),
    (name: 'East Ridge', active: true),
    (name: 'Harbor Point', active: false),
    (name: 'West Park', active: true),
  ];

  final _controller = TextEditingController();
  bool _activeOnly = false;
  int _page = 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _confirmReset(LinnDialog dialog) async {
    final confirmed = await dialog.show(context);
    if (!mounted || confirmed != true) return;
    setState(() {
      _controller.clear();
      _activeOnly = false;
      _page = 1;
    });
    const LinnSnackbar(
      message: 'Filters cleared.',
      state: LinnState.success,
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final theme = Theme.of(context);
    final query = _controller.text.trim().toLowerCase();
    final matches = _projects
        .where(
          (p) =>
              (!_activeOnly || p.active) &&
              p.name.toLowerCase().contains(query),
        )
        .toList();
    final pageCount = (matches.length + _pageSize - 1) ~/ _pageSize;
    final visiblePage = pageCount == 0 ? 0 : _page;
    final visibleProjects = matches
        .skip((visiblePage == 0 ? 0 : visiblePage - 1) * _pageSize)
        .take(_pageSize)
        .map((p) => p.name)
        .join(' · ');
    final dialog = LinnDialog(
      title: 'Clear project filters?',
      message: state == LinnState.error
          ? 'The filters still need to be cleared.'
          : 'This clears your search and shows all projects.',
      confirmLabel: 'Clear filters',
      state: state,
    );

    final cards = [
      _ComponentCard(
        number: 13,
        title: 'LinnSearchField',
        code:
            """LinnSearchField(
  label: 'Search projects',
  state: LinnState.${state.name},
  onChanged: findProjects,
)""",
        child: LinnSearchField(
          key: const ValueKey('preview-search'),
          label: 'Search projects',
          hintText: 'e.g. Riverside',
          controller: _controller,
          state: state,
          message: state == LinnState.error
              ? 'Couldn’t refresh search results.'
              : null,
          onChanged: (_) => setState(() => _page = 1),
        ),
      ),
      _ComponentCard(
        number: 14,
        title: 'LinnFilterChip',
        code:
            """LinnFilterChip(
  label: 'Active projects',
  selected: $_activeOnly,
  state: LinnState.${state.name},
  onSelected: setActiveOnly,
)""",
        child: LinnFilterChip(
          key: const ValueKey('preview-filter-chip'),
          label: 'Active projects',
          selected: _activeOnly,
          state: state,
          onSelected: (selected) => setState(() {
            _activeOnly = selected;
            _page = 1;
          }),
        ),
      ),
      _ComponentCard(
        number: 15,
        title: 'LinnIconButton',
        code:
            """LinnIconButton(
  icon: Icons.refresh_rounded,
  label: 'Refresh projects',
  state: LinnState.${state.name},
  onPressed: refreshProjects,
)""",
        child: LinnIconButton(
          key: const ValueKey('preview-icon-button'),
          icon: Icons.refresh_rounded,
          label: 'Refresh projects',
          state: state,
          onPressed: () => const LinnSnackbar(
            message: 'Project list refreshed.',
            state: LinnState.success,
          ).show(context),
        ),
      ),
      _ComponentCard(
        number: 16,
        title: 'LinnPagination',
        previewHeight: _resultPreviewHeight,
        code:
            """LinnPagination(
  page: $visiblePage,
  pageCount: $pageCount,
  state: LinnState.${state.name},
  onChanged: selectPage,
)""",
        child: LinnPagination(
          key: const ValueKey('preview-pagination'),
          page: visiblePage,
          pageCount: pageCount,
          state: state,
          onChanged: (page) => setState(() => _page = page),
        ),
      ),
      _ComponentCard(
        number: 17,
        title: 'LinnSummaryCard',
        previewHeight: _resultPreviewHeight,
        code:
            """LinnSummaryCard(
  label: 'Matching projects',
  value: '${matches.length}',
  icon: Icons.folder_outlined,
  state: LinnState.${state.name},
)""",
        child: SizedBox(
          width: double.infinity,
          child: LinnSummaryCard(
            key: const ValueKey('preview-summary'),
            label: 'Matching projects',
            value: matches.length.toString(),
            details: matches.isEmpty
                ? 'No matching projects.'
                : visibleProjects,
            icon: Icons.folder_outlined,
            state: state,
          ),
        ),
      ),
      _ComponentCard(
        number: 18,
        title: 'LinnDialog',
        previewHeight: _resultPreviewHeight,
        code:
            """await LinnDialog(
  title: 'Clear project filters?',
  confirmLabel: 'Clear filters',
  state: LinnState.${state.name},
).show(context)""",
        child: LinnButton(
          key: const ValueKey('preview-dialog-trigger'),
          label: 'Preview dialog',
          onPressed: () => _confirmReset(dialog),
        ),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dashboard widgets',
          key: const ValueKey('dashboard-title'),
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Search and filter projects, then use the page controls to see more matches.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = _galleryCardWidth(constraints.maxWidth);
            return Wrap(
              spacing: 20,
              runSpacing: 20,
              children: [
                for (final card in cards) SizedBox(width: width, child: card),
              ],
            );
          },
        ),
      ],
    );
  }
}

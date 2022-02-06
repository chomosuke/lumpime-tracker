import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart'
    hide PageRequestListener;

typedef PageRequestListener<PageKeyType, ItemType> = void Function(
    PageKeyType pageKey,
    PagingController<PageKeyType, ItemType> pageController);

PagingController<PageKeyType, ItemType>
    usePagingController<PageKeyType, ItemType>({
  required PageRequestListener<PageKeyType, ItemType> pageRequestListener,
  required PageKeyType firstPageKey,
  String? debugLabel,
  List<Object?>? keys,
  List<Object?>? effectKeys,
}) {
  final controller = use(
    _PagingControllerHook<PageKeyType, ItemType>(
      firstPageKey: firstPageKey,
      debugLabel: debugLabel,
      keys: keys,
    ),
  );

  useEffect(() {
    void listener(page) => pageRequestListener(page, controller);
    controller.addPageRequestListener(listener);

    return () {
      controller.removePageRequestListener(listener);
      controller.refresh();
    };
  }, effectKeys ?? [1]);

  return controller;
}

class _PagingControllerHook<PageKeyType, ItemType>
    extends Hook<PagingController<PageKeyType, ItemType>> {
  final PageKeyType firstPageKey;
  const _PagingControllerHook({
    required this.firstPageKey,
    this.debugLabel,
    List<Object?>? keys,
  }) : super(keys: keys);

  final String? debugLabel;

  @override
  HookState<PagingController<PageKeyType, ItemType>,
          Hook<PagingController<PageKeyType, ItemType>>>
      createState() => _PagingControllerHookState<PageKeyType, ItemType>(
            firstPageKey: firstPageKey,
          );
}

class _PagingControllerHookState<PageKeyType, ItemType> extends HookState<
    PagingController<PageKeyType, ItemType>,
    _PagingControllerHook<PageKeyType, ItemType>> {
  final PagingController<PageKeyType, ItemType> controller;
  _PagingControllerHookState({required PageKeyType firstPageKey})
      : controller =
            PagingController<PageKeyType, ItemType>(firstPageKey: firstPageKey),
        super();

  @override
  void initHook() {
    super.initHook();
  }

  @override
  PagingController<PageKeyType, ItemType> build(BuildContext context) =>
      controller;

  @override
  void dispose() => controller.dispose();

  @override
  String get debugLabel => 'usePagingController';
}

import 'package:flutter/material.dart';

typedef TextFieldSubmitCallback = void Function(String value);

class SearchAppBar extends StatefulWidget implements PreferredSizeWidget {
  final Widget title;

  final List<Widget> actions;

  final ValueChanged<String> onSearchChanged;

  final PreferredSizeWidget bottom;

  final Color searchTextColor;

  final Color hintTextColor;

  final String initialSearch;

  /// Whether the search should take place "in the existing search bar", meaning whether it has the same background or a flipped one. Defaults to true.
  final bool inBar;

  /// Whether the back button should be colored, if this is false the back button will be Colors.grey.shade400
  final bool colorBackButton;

  /// Whether or not the search bar should close on submit. Defaults to true.
  final bool closeOnSubmit;

  /// Whether the text field should be cleared when it is submitted
  final bool clearOnSubmit;

  /// Whether ot not the empty text should be submitted when click the clear button
  final bool submitOnClear;

  /// A void callback which takes a string as an argument, this is fired every time the search is submitted. Do what you want with the result.
  final TextFieldSubmitCallback onSubmitted;

  /// Whether or not the search bar should add a clear input button, defaults to true.
  final bool showClearButton;

  /// What the hintText on the search bar should be. Defaults to 'Pesquisar'.
  final String hintText;

  /// The controller to be used in the textField.
  final TextEditingController controller;

  SearchAppBar({
    this.title,
    this.actions,
    ValueChanged<String> onSearchTextChanged,
    this.bottom,
    this.initialSearch,
    this.searchTextColor = Colors.white,
    this.hintTextColor = Colors.white70,
    TextFieldSubmitCallback onSubmitted,
    this.controller,
    this.hintText = 'Pesquisar',
    this.inBar = true,
    this.colorBackButton = true,
    this.closeOnSubmit = false,
    this.clearOnSubmit = false,
    this.submitOnClear = false,
    this.showClearButton = true,
  })  : this.preferredSize = Size.fromHeight(kToolbarHeight + (bottom?.preferredSize?.height ?? 0.0)),
        this.onSearchChanged = onSearchTextChanged ?? ((_) {}),
        this.onSubmitted = onSubmitted ?? ((_) {});

  @override
  final Size preferredSize;

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchAppBar> {
  /// Whether search is currently active.
  bool _isSearching = false;

  /// Whether the clear button should be active (fully colored) or inactive (greyed out)
  bool _clearActive = false;

  TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = widget.controller ?? TextEditingController();
    if (widget.showClearButton) controller.addListener(_clearButtonControllerListener);
    if (controller is SearchAppBarController) {
      (controller as SearchAppBarController)._searchBarState = this;
    }
    if (widget.initialSearch != null) {
      _isSearching = true;
      controller.text = widget.initialSearch;
    }
  }

  @override
  void dispose() {
    if (widget.showClearButton) controller.removeListener(_clearButtonControllerListener);
    if (controller is SearchAppBarController) {
      (controller as SearchAppBarController)._searchBarState = null;
    }
    super.dispose();
  }

  void _clearButtonControllerListener() {
    if (controller.text.isEmpty) {
      // If clear is already disabled, don't disable it

      if (_clearActive) {
        setState(() {
          _clearActive = false;
        });
      }
    } else {
      // If clear is already enabled, don't enable it
      if (!_clearActive) {
        setState(() {
          _clearActive = true;
        });
      }
    }
  }

  /// Initializes the search bar.
  ///
  /// This adds a new route that listens for onRemove (and stops the search when that happens), and then calls [setState] to rebuild and start the search.
  void _beginSearch() {
    ModalRoute.of(context).addLocalHistoryEntry(LocalHistoryEntry(onRemove: () {
      setState(() {
        _isSearching = false;
      });
      widget.onSearchChanged('');
      widget.onSubmitted('');
      controller.clear();
    }));

    setState(() {
      _isSearching = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isSearching ? _buildSearchBar(context) : _buildAppBar(context);
  }

  /// Builds, saves and returns the default app bar.
  ///
  /// This calls the [buildDefaultAppBar] provided in the constructor, and saves it to [_defaultAppBar].
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: widget.title,
      actions: [_getSearchAction(context)]..addAll(widget.actions),
      bottom: widget.bottom,
    );
  }

  /// Builds the search bar!
  ///
  /// The leading will always be a back button.
  /// backgroundColor is determined by the value of inBar
  /// title is always a [TextField] with the key 'SearchBarTextField', and various text stylings based on [inBar]. This is also where [onSubmitted] has its listener registered.
  ///
  AppBar _buildSearchBar(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final Color barColor = widget.inBar ? theme.primaryColor : theme.canvasColor;

    // Don't provide a color (make it white) if it's in the bar, otherwise color it or set it to grey.
    final Color buttonColor = widget.inBar
        ? null
        : (widget.colorBackButton
            ? theme.primaryColor ?? theme.primaryColor ?? Colors.grey.shade400
            : Colors.grey.shade400);
    final Color buttonDisabledColor = widget.inBar ? Color.fromRGBO(255, 255, 255, 0.25) : Colors.grey.shade300;

    return AppBar(
      leading: BackButton(color: buttonColor),
      backgroundColor: barColor,
      title: Directionality(
          textDirection: Directionality.of(context),
          child: TextField(
            key: Key('SearchBarTextField'),
            keyboardType: TextInputType.text,
            style: TextStyle(color: widget.searchTextColor, fontSize: 18.0),
            decoration: InputDecoration.collapsed(
              hintText: widget.hintText,
              hintStyle: TextStyle(color: widget.hintTextColor, fontSize: 16.0),
            ),
            onSubmitted: (String val) async {
              if (widget.closeOnSubmit) {
                //await Navigator.maybePop(context);
              }

              if (widget.clearOnSubmit) {
                controller.clear();
              }

              widget.onSubmitted(val);
            },
            autofocus: widget.initialSearch == null,
            controller: controller,
            onChanged: widget.onSearchChanged,
          )),
      actions: !widget.showClearButton
          ? widget.actions
          : <Widget>[
              // Show an icon if clear is not active, so there's no ripple on tap
              IconButton(
                  icon: Icon(Icons.clear, color: _clearActive ? buttonColor : buttonDisabledColor),
                  disabledColor: buttonDisabledColor,
                  onPressed: !_clearActive
                      ? null
                      : () {
                          controller.clear();
                          widget.onSearchChanged('');
                          if (widget.submitOnClear) widget.onSubmitted('');
                        })
            ]
        ..addAll(widget.actions),
      bottom: widget.bottom,
    );
  }

  /// Returns an [IconButton] suitable for an Action
  ///
  /// Put this inside your [buildDefaultAppBar] method!
  IconButton _getSearchAction(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.search),
      onPressed: _beginSearch,
    );
  }
}

class SearchAppBarController extends TextEditingController {
  _SearchBarState _searchBarState;

  bool get isSearching => _searchBarState?._isSearching ?? false;
}

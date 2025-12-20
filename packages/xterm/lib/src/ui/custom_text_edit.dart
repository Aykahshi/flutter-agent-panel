import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextEdit extends StatefulWidget {
  CustomTextEdit({
    super.key,
    required this.child,
    required this.onInsert,
    required this.onDelete,
    required this.onComposing,
    required this.onAction,
    required this.onKeyEvent,
    required this.focusNode,
    this.autofocus = false,
    this.readOnly = false,
    // this.initEditingState = TextEditingValue.empty,
    this.inputType = TextInputType.text,
    this.inputAction = TextInputAction.newline,
    this.keyboardAppearance = Brightness.light,
    this.deleteDetection = false,
  });

  final Widget child;

  final void Function(String) onInsert;

  final void Function() onDelete;

  final void Function(String?) onComposing;

  final void Function(TextInputAction) onAction;

  final KeyEventResult Function(FocusNode, KeyEvent) onKeyEvent;

  final FocusNode focusNode;

  final bool autofocus;

  final bool readOnly;

  final TextInputType inputType;

  final TextInputAction inputAction;

  final Brightness keyboardAppearance;

  final bool deleteDetection;

  @override
  CustomTextEditState createState() => CustomTextEditState();
}

class CustomTextEditState extends State<CustomTextEdit> with TextInputClient {
  TextInputConnection? _connection;

  bool _isInputReady = false;

  @override
  void initState() {
    widget.focusNode.addListener(_onFocusChange);
    super.initState();
    // Warm-up delay: Wait for the window/view to be fully ready before allowing IME connection.
    // This prevents "view ID is null" errors on Windows startup.
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _isInputReady = true;
        });
        // If we have focus, retry connection now that we are ready
        if (widget.focusNode.hasFocus) {
          _openInputConnection();
        }
      }
    });
  }

  @override
  void didUpdateWidget(CustomTextEdit oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.focusNode != oldWidget.focusNode) {
      oldWidget.focusNode.removeListener(_onFocusChange);
      widget.focusNode.addListener(_onFocusChange);
    }

    if (!_shouldCreateInputConnection) {
      _closeInputConnectionIfNeeded();
    } else {
      if (oldWidget.readOnly && widget.focusNode.hasFocus) {
        _openInputConnection();
      }
    }
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    _closeInputConnectionIfNeeded();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      onKeyEvent: _onKeyEvent,
      child: widget.child,
    );
  }

  bool get hasInputConnection => _connection != null && _connection!.attached;

  void requestKeyboard() {
    if (widget.focusNode.hasFocus) {
      _openInputConnection();
    } else {
      widget.focusNode.requestFocus();
    }
  }

  void closeKeyboard() {
    if (hasInputConnection) {
      _connection?.close();
    }
  }

  void setEditingState(TextEditingValue value) {
    _currentEditingState = value;
    _connection?.setEditingState(value);
  }

  Rect? _cachedRect;
  Rect? _cachedCaretRect;

  void setEditableRect(Rect rect, Rect caretRect) {
    _cachedRect = rect;
    _cachedCaretRect = caretRect;

    if (!hasInputConnection) {
      return;
    }

    _applyEditableRect(rect, caretRect);
  }

  void _applyEditableRect(Rect rect, Rect caretRect) {
    if (!mounted) return;

    // RenderTerminal now sends LOCAL coordinates.
    // With explicit viewId, the engine knows the view's global position.
    // We pass local coords directly with zero transform.
    _connection?.setEditableSizeAndTransform(
      rect.size,
      Matrix4.translationValues(0, 0, 0),
    );
    _connection?.setCaretRect(caretRect);
  }

  void _onFocusChange() {
    _openOrCloseInputConnectionIfNeeded();
  }

  KeyEventResult _onKeyEvent(FocusNode focusNode, KeyEvent event) {
    if (_currentEditingState.composing.isCollapsed) {
      return widget.onKeyEvent(focusNode, event);
    }

    return KeyEventResult.skipRemainingHandlers;
  }

  void _openOrCloseInputConnectionIfNeeded() {
    if (widget.focusNode.hasFocus && widget.focusNode.consumeKeyboardToken()) {
      _openInputConnection();
    } else if (!widget.focusNode.hasFocus) {
      _closeInputConnectionIfNeeded();
    }
  }

  bool get _shouldCreateInputConnection => kIsWeb || !widget.readOnly;

  void _openInputConnection() {
    if (!_shouldCreateInputConnection || !mounted || !_isInputReady) {
      return;
    }

    if (hasInputConnection) {
      _connection!.show();
    } else {
      // Ensure we have a valid view before attaching.
      final view = View.maybeOf(context);
      if (view == null) {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted && widget.focusNode.hasFocus) {
            _openInputConnection();
          }
        });
        return;
      }

      final config = TextInputConfiguration(
        viewId: view.viewId, // CRITICAL FIX: Explicitly pass viewId
        inputType: widget.inputType,
        inputAction: widget.inputAction,
        keyboardAppearance: widget.keyboardAppearance,
        autocorrect: false,
        enableSuggestions: false,
        enableIMEPersonalizedLearning: false,
      );

      try {
        _connection = TextInput.attach(this, config);

        // We can now call these immediately as we provided a valid viewId
        _connection!.show();
        _connection!.setEditingState(_initEditingState);

        // Resend the cached editable rects so the IME knows where to appear.
        if (_cachedRect != null && _cachedCaretRect != null) {
          _applyEditableRect(_cachedRect!, _cachedCaretRect!);
        }
      } catch (e) {
        if (e is PlatformException &&
            (e.message?.contains('view ID') == true ||
                e.message?.contains('client') == true)) {
          // Failure to attach (View not ready). Reset connection and retry.
          _connection = null;
          Future.delayed(const Duration(milliseconds: 200), () {
            if (mounted && widget.focusNode.hasFocus) {
              _openInputConnection();
            }
          });
        } else {
          // Rethrow other exceptions (dev errors)
          rethrow;
        }
      }
    }
  }

  void _closeInputConnectionIfNeeded() {
    if (_connection != null && _connection!.attached) {
      _connection!.close();
      _connection = null;
    }
  }

  TextEditingValue get _initEditingState => widget.deleteDetection
      ? const TextEditingValue(
          text: '  ',
          selection: TextSelection.collapsed(offset: 2),
        )
      : const TextEditingValue(
          text: '',
          selection: TextSelection.collapsed(offset: 0),
        );

  late var _currentEditingState = _initEditingState.copyWith();

  @override
  TextEditingValue? get currentTextEditingValue {
    return _currentEditingState;
  }

  @override
  AutofillScope? get currentAutofillScope {
    return null;
  }

  String? _textBeforeComposition;

  @override
  void updateEditingValue(TextEditingValue value) {
    final oldState = _currentEditingState;
    _currentEditingState = value;

    print(
        'updateEditingValue: text="${value.text}", composing=${value.composing}, selection=${value.selection}');
    print('oldState: text="${oldState.text}", composing=${oldState.composing}');
    print('_textBeforeComposition: $_textBeforeComposition');

    // Handle composition start: store the text state as it was before IME started
    if (!value.composing.isCollapsed && oldState.composing.isCollapsed) {
      _textBeforeComposition = oldState.text;
    }

    // Get input after composing is done
    if (!_currentEditingState.composing.isCollapsed) {
      final text = _currentEditingState.text;
      final composingText = _currentEditingState.composing.textInside(text);
      widget.onComposing(composingText);
      return;
    }

    widget.onComposing(null);

    // If we just finished a composition, use the stored base text for comparison
    final baseText = _textBeforeComposition ?? oldState.text;
    _textBeforeComposition = null;

    final newText = _currentEditingState.text;

    if (newText == baseText) {
      return;
    }

    // Handle backspace/deletion
    if (newText.length < baseText.length) {
      if (baseText.startsWith(newText)) {
        final count = baseText.length - newText.length;
        for (var i = 0; i < count; i++) {
          widget.onDelete();
        }
      }
    }
    // Handle insertion
    else {
      String insertedText;
      if (newText.startsWith(baseText)) {
        insertedText = newText.substring(baseText.length);
      } else {
        // content was replaced (common with IME)
        final init = _initEditingState.text;
        if (newText.startsWith(init)) {
          insertedText = newText.substring(init.length);
        } else {
          insertedText = newText;
        }
      }

      if (insertedText.isNotEmpty) {
        widget.onInsert(insertedText);
      }
    }

    // Reset editing state if composing is done
    if (_currentEditingState.composing.isCollapsed &&
        _currentEditingState.text != _initEditingState.text) {
      _connection?.setEditingState(_initEditingState);
      _currentEditingState = _initEditingState;
    }
  }

  @override
  void performAction(TextInputAction action) {
    // print('performAction $action');
    widget.onAction(action);
  }

  @override
  void updateFloatingCursor(RawFloatingCursorPoint point) {
    // print('updateFloatingCursor $point');
  }

  @override
  void showAutocorrectionPromptRect(int start, int end) {
    // print('showAutocorrectionPromptRect');
  }

  @override
  void connectionClosed() {
    // print('connectionClosed');
  }

  @override
  void performPrivateCommand(String action, Map<String, dynamic> data) {
    // print('performPrivateCommand $action');
  }

  @override
  void insertTextPlaceholder(Size size) {
    // print('insertTextPlaceholder');
  }

  @override
  void removeTextPlaceholder() {
    // print('removeTextPlaceholder');
  }

  @override
  void showToolbar() {
    // print('showToolbar');
  }
}

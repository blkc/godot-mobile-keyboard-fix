extends Control
class_name MobileTextEdit

signal text_changed(new_text: String)

@export var placeholder_text: String = ""
@export var text: String = "":
    get:
        if _is_web_mobile:
            return _current_text
        return _text_edit.text if _text_edit else text

var _text_edit: TextEdit
var _js_interface = null
var _js_callback = null
var _html_input_id: String = ""
var _is_web_mobile: bool = false
var _current_text: String = ""
var _display_label: Label

func _ready() -> void:
    set_focus_mode(Control.FOCUS_CLICK)
    _detect_web_mobile()
    if _is_web_mobile:
        _setup_for_mobile()
    else:
        _setup_native()

func _detect_web_mobile() -> void:
    if not OS.has_feature("web"):
        return
    if not JavaScriptBridge:
        return
    var js = JavaScriptBridge.get_interface("GodotMobileInput")
    if js and js.isMobile():
        _is_web_mobile = true
        _js_interface = js

func _setup_native() -> void:
    _text_edit = TextEdit.new()
    _text_edit.placeholder_text = placeholder_text
    _text_edit.text = text
    _text_edit.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    _text_edit.text_changed.connect(func(): text_changed.emit(_text_edit.text))
    add_child(_text_edit)

func _setup_for_mobile() -> void:
    var panel = Panel.new()
    panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(panel)

    _display_label = Label.new()
    _display_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    _display_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
    _display_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    _display_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    _display_label.text = placeholder_text
    _display_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
    add_child(_display_label)

    _js_callback = JavaScriptBridge.create_callback(_on_js_event)
    _html_input_id = _js_interface.createInput(placeholder_text, 1000)

func _gui_input(event: InputEvent) -> void:
    if _is_web_mobile and event is InputEventMouseButton and event.pressed:
        _js_interface.activateInput(_html_input_id, _js_callback)
        get_viewport().set_input_as_handled()

func _on_js_event(args) -> void:
    if not args or len(args) == 0:
        return
    var ev = args[0]
    if ev.type == "text_changed":
        _current_text = str(ev.text)
        if _current_text.is_empty():
            _display_label.text = placeholder_text
            _display_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
        else:
            _display_label.text = _current_text
            _display_label.add_theme_color_override("font_color", Color(1, 1, 1))
        text_changed.emit(_current_text)

func _exit_tree() -> void:
    if _is_web_mobile and _js_interface and _html_input_id != "":
        _js_interface.destroyInput(_html_input_id)

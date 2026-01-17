extends Control

@onready var output: RichTextLabel = %OutputText
@onready var standard_text_edit: TextEdit = %StandardTextEdit
@onready var mobile_text_edit: Control = %MobileTextEdit
@onready var standard_text_edit_sub: TextEdit = %StandardTextEditSub
@onready var mobile_text_edit_sub: Control = %MobileTextEditSub

func _ready() -> void:
    standard_text_edit.text_changed.connect(_on_standard_text_changed)
    standard_text_edit_sub.text_changed.connect(_on_standard_sub_text_changed)
    mobile_text_edit.text_changed.connect(_on_mobile_text_changed)
    mobile_text_edit_sub.text_changed.connect(_on_mobile_sub_text_changed)
    _log("Ready - tap a text field to test")

func _on_standard_text_changed() -> void:
    _log("[Standard] " + standard_text_edit.text)

func _on_standard_sub_text_changed() -> void:
    _log("[Standard SubViewport] " + standard_text_edit_sub.text)

func _on_mobile_text_changed(new_text: String) -> void:
    _log("[Fixed] " + new_text)

func _on_mobile_sub_text_changed(new_text: String) -> void:
    _log("[Fixed SubViewport] " + new_text)

func _log(msg: String) -> void:
    output.text = "[" + Time.get_time_string_from_system() + "] " + msg + "\n" + output.text

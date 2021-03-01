# open-tabletop
# Copyright (c) 2020-2021 Benjamin 'drwhut' Beddows
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

extends WindowDialog

signal requesting_room_details()
signal setting_lighting(lamp_color, lamp_intensity, lamp_sunlight)
signal setting_skybox(skybox_entry)

onready var _apply_button = $VBoxContainer/HBoxContainer/ApplyButton
onready var _clear_skybox_button = $VBoxContainer/TabContainer/Skybox/ClearSkyboxButton
onready var _lamp_color_picker = $VBoxContainer/TabContainer/Lighting/ColorPickerButton
onready var _lamp_intensity_slider = $VBoxContainer/TabContainer/Lighting/HBoxContainer/IntensitySlider
onready var _lamp_intensity_value_label = $VBoxContainer/TabContainer/Lighting/HBoxContainer/IntensityValueLabel
onready var _lamp_type_button = $VBoxContainer/TabContainer/Lighting/TypeButton
onready var _skybox_dialog = $SkyboxDialog
onready var _skybox_preview = $VBoxContainer/TabContainer/Skybox/SkyboxPreview

# Clear the currently selected skybox, and set it to the default skybox.
func clear_skybox() -> void:
	_skybox_preview.set_entry({
		"description": "The default skybox for OpenTabletop.",
		"name": "Default",
		"texture_path": ""
	})
	
	_clear_skybox_button.disabled = true

# Set the room details in the room dialog.
# skybox_entry: The skybox's entry in the asset DB.
# lamp_color: The color of the room lamp.
# lamp_intensity: The intensity of the room lamp.
# lamp_sunlight: If the room lamp is emitting sunlight.
func set_room_details(skybox_entry: Dictionary, lamp_color: Color,
	lamp_intensity: float, lamp_sunlight: bool) -> void:
	
	if skybox_entry.empty():
		clear_skybox()
	else:
		_skybox_preview.set_entry(skybox_entry)
	
	_lamp_color_picker.color = lamp_color
	_lamp_intensity_slider.value = lamp_intensity
	_set_lamp_intensity_value_label(lamp_intensity)
	_lamp_type_button.selected = 0 if lamp_sunlight else 1

func _ready():
	clear_skybox()

# Set the lamp intensity value label as a percentage value.
# value: The value to display in the label.
func _set_lamp_intensity_value_label(value: float) -> void:
	_lamp_intensity_value_label.text = str(round(value * 100)) + "%"

func _on_ApplyButton_pressed():
	_apply_button.disabled = true
	
	emit_signal("setting_skybox", _skybox_preview.get_entry())
	
	emit_signal("setting_lighting", _lamp_color_picker.color,
		_lamp_intensity_slider.value, _lamp_type_button.selected == 0)

func _on_ChangeSkyboxButton_pressed():
	_skybox_dialog.popup_centered()

func _on_ClearSkyboxButton_pressed():
	_apply_button.disabled = false
	
	clear_skybox()

func _on_ColorPickerButton_color_changed(_color: Color):
	_apply_button.disabled = false

func _on_preview_clicked():
	_apply_button.disabled = false

func _on_RoomDialog_about_to_show():
	_apply_button.disabled = true
	emit_signal("requesting_room_details")

func _on_IntensitySlider_value_changed(value: float):
	_apply_button.disabled = false
	_set_lamp_intensity_value_label(value)

func _on_SkyboxDialog_entry_requested(_pack: String, _type: String, entry: Dictionary):
	_apply_button.disabled = false
	
	_skybox_preview.set_entry(entry)
	_skybox_dialog.visible = false
	
	_clear_skybox_button.disabled = false

func _on_TypeButton_item_selected(_index: int):
	_apply_button.disabled = false
extends Node3D

func _on_animation_player_animation_finished(anim_name):
	get_parent().animation_finished(anim_name)

func _on_attack_area_body_entered(body):
	get_parent().attack_area_entered(body)

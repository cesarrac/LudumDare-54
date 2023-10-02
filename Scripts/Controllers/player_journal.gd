extends Node2D
class_name PlayerJournal

var cur_chapter : = -1
var story_bits : = {}

func has_bit_tagged(bit_tag : String)->bool:
	return story_bits.has(bit_tag)

func has_bit_completed(bit_tag : String)->bool:
	print("checking bit %s" % bit_tag)
	if has_bit_tagged(bit_tag) == false: return false
	return story_bits[bit_tag].completed

func on_new_bit(tag : String, completed : = false)->void:
	if has_bit_tagged(tag): 
		print("Player already has bit tagged %s" % tag)
		return
	story_bits[tag] = {}
	story_bits[tag].completed = false
	story_bits[tag].ticks = 0
	story_bits[tag].max_ticks = -1

func complete_bit(tag : String)->void:
	if has_bit_tagged(tag) == false: return
	story_bits[tag].completed = true

func remove_bit(tag : String)->bool:
	return story_bits.erase(tag)

func tick_bit(tag : String)->bool:
	if story_bits.has(tag) == false: return false
	story_bits[tag].ticks += 1
	if story_bits[tag].ticks >= story_bits[tag].max_ticks:
		story_bits[tag].completed = true
		return true
	return false

func goto_chapter(c : int)->void:
	cur_chapter = c

func edit_bit(tag : String)->void:
	if story_bits.has(tag) == false: 
		on_new_bit(tag)
	var cur =  story_bits[tag].max_ticks
	if cur < 0: cur = 1
	else: cur += 1
	story_bits[tag].max_ticks = cur
	print('bit %s to to max ticks %s' % [tag, story_bits[tag].max_ticks])

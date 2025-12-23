class_name ComponentTags extends Node

var tags: Array[String] = []

## Assign [param new_tag] tag to the Actor.
func add(new_tag: String) -> void:
    if not tags.has(new_tag):
        tags.append(new_tag)


## Returns true if [param target_tag] was an assigned tag and got removed.
func remove(target_tag: String) -> bool:
    var index := tags.find(target_tag)
    if index == -1:
        return false

    tags.remove_at(index)
    return true


## Returns true if [param new_tag] is assigned.
func exists(target_tag: String) -> bool:
    return tags.find(target_tag) >= - 1


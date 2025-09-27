extends Resource
class_name ChoiceOption

# The text to display on the button, e.g., "Red", "Higher"
@export var text: String

# A description of the reward, e.g., "+3 Coins", "Gain an Artifact"
@export var reward_description: String

# The function to call to grant the reward.
# This will be connected to a function in the Stage class itself.
@export var reward_callable: Callable

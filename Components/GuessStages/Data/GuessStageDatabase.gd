class RedBlackStage extends Stage:
    func _init():
        name = "Red/Black"
        options = [
            _create_option("Red", "+1 Coin", Callable(self, "_grant_reward").bind(1)),
            _create_option("Black", "+1 Coin", Callable(self, "_grant_reward").bind(1))
        ]

    func evaluate_choice(choice: ChoiceOption, _revealed_cards: Array, new_card: CardData, _ruleset: RuleSet) -> bool:
        return choice.text == new_card.color

    func _create_option(text: String, reward_desc: String, reward_callable: Callable) -> ChoiceOption:
        var option = ChoiceOption.new()
        option.text = text
        option.reward_description = reward_desc
        option.reward_callable = reward_callable
        return option

    func _grant_reward(amount: int) -> void:
        PlayerInventory.add_coins(amount)

class HigherLowerStage extends Stage:
    func _init():
        name = "Higher/Lower"
        options = [
            _create_option("Higher", "+2 Coins", Callable(self, "_grant_reward").bind(2)),
            _create_option("Lower", "+2 Coins", Callable(self, "_grant_reward").bind(2))
        ]

    func evaluate_choice(choice: ChoiceOption, _revealed_cards: Array, new_card: CardData, ruleset: RuleSet) -> bool:
        if _revealed_cards.size() == 0:
            return false
        var previous_card = _revealed_cards[-1]
        var success = (choice.text == "Higher" and new_card.rank > previous_card.rank) \
                      or (choice.text == "Lower" and new_card.rank < previous_card.rank)
        if not success and ruleset.allow_equal_rank_win:
            success = new_card.rank == previous_card.rank
        return success
    
    func _create_option(text: String, reward_desc: String, reward_callable: Callable) -> ChoiceOption:
        var option = ChoiceOption.new()
        option.text = text
        option.reward_description = reward_desc
        option.reward_callable = reward_callable
        return option

    func _grant_reward(amount: int) -> void:
        PlayerInventory.add_coins(amount)

class InsideOutsideStage extends Stage:
    func _init():
        name = "Inside/Outside"
        options = [
            _create_option("Inside", "+2 Coins", Callable(self, "_grant_reward").bind(2)),
            _create_option("Outside", "+2 Coins", Callable(self, "_grant_reward").bind(2))
        ]

    func evaluate_choice(choice: ChoiceOption, _revealed_cards: Array, new_card: CardData, _ruleset: RuleSet) -> bool:
        if _revealed_cards.size() < 2:
            return false
        var card1 = _revealed_cards[-1]
        var card2 = _revealed_cards[-2]
        var low = min(card1.rank, card2.rank)
        var high = max(card1.rank, card2.rank)
        return (choice.text == "Inside" and new_card.rank > low and new_card.rank < high) \
            or (choice.text == "Outside" and (new_card.rank < low or new_card.rank > high))
            
    func _create_option(text: String, reward_desc: String, reward_callable: Callable) -> ChoiceOption:
        var option = ChoiceOption.new()
        option.text = text
        option.reward_description = reward_desc
        option.reward_callable = reward_callable
        return option

    func _grant_reward(amount: int) -> void:
        PlayerInventory.add_coins(amount)

class SuitStage extends Stage:
    func _init():
        name = "Suit"
        options = [
            _create_option("hearts", "+4 Coins", Callable(self, "_grant_reward").bind(4)),
            _create_option("diamonds", "+4 Coins", Callable(self, "_grant_reward").bind(4)),
            _create_option("clubs", "+4 Coins", Callable(self, "_grant_reward").bind(4)),
            _create_option("spades", "+4 Coins", Callable(self, "_grant_reward").bind(4))
        ]

    func evaluate_choice(choice: ChoiceOption, _revealed_cards: Array, new_card: CardData, _ruleset: RuleSet) -> bool:
        return choice.text == new_card.suit

    func _create_option(text: String, reward_desc: String, reward_callable: Callable) -> ChoiceOption:
        var option = ChoiceOption.new()
        option.text = text
        option.reward_description = reward_desc
        option.reward_callable = reward_callable
        return option

    func _grant_reward(amount: int) -> void:
        PlayerInventory.add_coins(amount)

class BusCompletionStage extends Stage:
    func _init():
        name = "Bus Completed!"
        options = [
            _create_option("Claim Bonus", "+25 Coins", Callable(self, "_grant_reward").bind(25))
        ]

    func evaluate_choice(_choice: ChoiceOption, _revealed_cards: Array, _new_card: CardData, _ruleset: RuleSet) -> bool:
        # A reward stage always succeeds. The reward is granted by the choice's callable.
        return true

    func _create_option(text: String, reward_desc: String, reward_callable: Callable) -> ChoiceOption:
        var option = ChoiceOption.new()
        option.text = text
        option.reward_description = reward_desc
        option.reward_callable = reward_callable
        return option

    func _grant_reward(amount: int) -> void:
        PlayerInventory.add_coins(amount)

There are two main db tables here:

A `Game` has all information pertaining to a snapshot of a game:
* Holds multiple `Player`s
* Has an auth_token for users that want to join a game
* Has a ordering of `Player`s
* Chips in the pot
* Cards in the river (which are visible to all players)
The following fields will be used to represent the data above:
```
has_secure_token :auth_token, length: 36

name :string
player_ordering :string // comma separated ids
community_cards :string
pot :integer
active_player :integer
deck :string

has_many :players
```

A `Player` has additional information pertaining to the game:
* Holds the hole cards (alphabetically sorted)
* The number of chips this player has
* An auth_token used to authenticate each player action
```
has_secure_token :auth_token, length: 36

name :string
chips :integer
hole_cards :string

```


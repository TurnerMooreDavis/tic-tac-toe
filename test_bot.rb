require './bot.rb'
puts b = Bot.new('o')
turn_data = [
  {'player' => 'x', 'position' => 0, 'turn_number' => 0},
  # {'player' => 'o', 'position' => 4, 'turn_number' => 1},
  # {'player' => 'x', 'position' => 1, 'turn_number' => 2},
  # {'player' => 'o', 'position' => 8, 'turn_number' => 3},
  # {'player' => 'x', 'position' => 2, 'turn_number' => 4}
]
puts ids = b.similar_game_ids(turn_data)
puts position = b.project_winning_turn(ids, 'o', 1)

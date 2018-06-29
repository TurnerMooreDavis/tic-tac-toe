require './bot.rb'
puts b = Bot.new('o')
turn_data = [
{'player' => 'x', 'position' => 0, 'turn_number' => 0},
{'player' => 'o', 'position' => 4, 'turn_number' => 1},
{'player' => 'x', 'position' => 1, 'turn_number' => 2},
{'player' => 'o', 'position' => 8, 'turn_number' => 3},
{'player' => 'x', 'position' => 2, 'turn_number' => 4}
]
d =  b.save_game('x', turn_data)
puts d

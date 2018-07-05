require './bot.rb'

def draw
  puts ""
  3.times do |r|
    row = ""
    3.times do |c|
      row += @filled_squares[(r*3 + c)] ? "#{@filled_squares[(r*3 + c)]} " : ". "
    end
    puts row
  end
end

def turn(input, player)
  @filled_squares[input] = player
  @empty_squares[input] = nil
  @turn_data << {'player' => player, 'position' => input, 'turn_number' => @turn_number}
  @turn_number += 1
  draw
  detect_winner(player)
  @active_player = player == 'x' ? 'o': 'x'
end

def detect_winner(player)
  @winning_sets.each do |set|
    values = @filled_squares.values_at(*set)
    if values == Array.new(3, player)
      @bot.save_game(player, @turn_data)
      @winner = player
    end
  end
  if @filled_squares.compact.count == 9 && @winner == nil
    @bot.save_game('c', @turn_data)
    @winner = 'c'
  end
end

def play(automate)
  @bot = Bot.new("o")
  @empty_squares = [0,1,2,3,4,5,6,7,8]
  @filled_squares = Array.new(9)
  @winner = nil
  @active_player = nil
  @turn_data = []
  @turn_number = 0
  @winning_sets = [
    [0,1,2],
    [3,4,5],
    [6,7,8],
    [0,3,6],
    [1,4,7],
    [2,5,8],
    [0,4,8],
    [2,4,6]
  ]
  draw
  while !@winner do
    if @active_player == 'o'
      similar_game_ids = @bot.similar_game_ids(@turn_data)
      turn_position = @bot.project_winning_turn(similar_game_ids, 'o', @turn_number, @empty_squares.compact)
      turn(turn_position, 'o')
    else
      position = automate ? @empty_squares.compact.sample : gets.chomp.to_i
      turn(position, "x")
    end
  end

  puts "winner is #{@winner}"
end

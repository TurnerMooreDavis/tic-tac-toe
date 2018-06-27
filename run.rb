puts "let the games begin!"

@empty_squares = [0,1,2,3,4,5,6,7,8]
@filled_squares = Array.new(9)
@winner = nil
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
def draw
  puts ""
  3.times do |r|
    row = ""
    3.times do |c|
      row += @filled_squares[(r*3 + c)] ? @filled_squares[(r*3 + c)] : ". "
    end
    puts row
  end
end

def turn(input, player)
  @filled_squares[input] = "#{player} "
  @empty_squares[input] = nil
  draw
  detect_winner(player)
end

def detect_winner(player)
  @winning_sets.each do |set|
    values = @filled_squares.values_at(*set)
    if values == Array.new(3, player)
      p 'winner'
      @winner = player
    end
  end
end

draw
while !@winner do
  turn(gets.chomp.to_i, "x")
  turn(@empty_squares.compact.sample, 'o')
end

puts "winner is #{@winner}"

puts "let the games begin!"

@empty_squares = [0,1,2,3,4,5,6,7,8]
@filled_squares = Array.new(9)


def draw
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
end

draw
turn(gets.chomp.to_i, "x")
draw
turn(@empty_squares.compact.sample, 'o')
draw   

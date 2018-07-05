require './game.rb'

puts "let the games begin!"

puts "please enter a number between 0 and 8"

puts "Would you like to play? (y/n)"

@key = gets.chomp

puts "Would you like to automate? (y/n)"

@automate = gets.chomp == 'y'

if @automate
  puts 'how many games would you like to automate?'
  @game_count = gets.chomp.to_i
else
  @game_count = 1
end


while @key == 'y'
  @game_count.times do
    play(@automate)
  end
  puts "Would you like to play again? (y/n)"
  @key = gets.chomp
end

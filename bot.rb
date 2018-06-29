require 'mysql2'

class Bot

  def initialize(player)
    @player = player
    @client = Mysql2::Client.new(:host => "localhost", :username => "root", :database => "tic_tac_toe_bot")
  end
  
  def player
    @player
  end

  def save_turn(player, position, turn_number, game)
    @client.query("INSERT INTO turns (player, position, turn_number, game_id) VALUES ('#{player}', #{position}, #{turn_number}, #{game})")
  end

  def save_game(winner, turn_data)
    insert_query = "INSERT INTO games (winner) VALUES ('#{winner}')"
    @client.query(insert_query)
    game_id = @client.query("SELECT LAST_INSERT_ID()").first['LAST_INSERT_ID()']
    turn_data.each do |td|
      save_turn(td['player'], td['position'], td['turn_number'], game_id)
    end
    return true
  end
end

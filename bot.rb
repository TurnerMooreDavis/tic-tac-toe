require 'mysql2'

class Bot

  def initialize(player)
    @player = player
    @client = Mysql2::Client.new(:host => "localhost", :username => "root", :database => "tic_tac_toe_bot")
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

  def similar_game_ids(previous_turns)
    first_turn = previous_turns.first
    recursively_collect_similar_games([], first_turn['turn_number'], first_turn['player'], first_turn['position'], previous_turns)
  end

  def recursively_collect_similar_games(game_ids, turn_number, player, position, previous_turns)
    query = "SELECT game_id FROM turns WHERE player='#{player}' && turn_number=#{turn_number} && position=#{position}"
    query += " && game_id IN (#{game_ids.join(',')})" if game_ids.count > 0
    results = @client.query(query)
    new_game_ids = []

    results.each do |r|
      new_game_ids << r['game_id']
    end

    if new_game_ids.count == 0
      return []
    elsif(turn_number + 1 == previous_turns.count)
      return new_game_ids
    else
      next_turn_number = turn_number + 1
      next_turn = previous_turns[next_turn_number]
      recursively_collect_similar_games(new_game_ids, next_turn['turn_number'], next_turn['player'], next_turn['position'], previous_turns)
    end
  end

  def project_winning_turn(similar_game_ids, player, turn_number)
    position_data = Array.new(9, {'wins' => 0, 'losses' => 0})
    similar_game_ids.each do |game_id|
      query = "SELECT * from turns WHERE turn_number=#{turn_number} && game_id=#{game_id}"
      results = @client.query(query)
      turn = results.first
      turn_position = turn['position'].to_i
      query = "SELECT * from games WHERE game_id=#{game_id}"
      results = @client.query(query)
      game = results.first
      hash_key = player == game['winner'] ? 'wins' : 'losses'
      position_data[turn_position][hash_key] += 1
    end
    percentages = []
    position_data.each do |position|
      percentages << (position['wins']/(position['wins'] + position['losses']))
    end
    return percentages.each_with_index.max[1]
  end

end

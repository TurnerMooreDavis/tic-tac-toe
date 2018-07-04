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
    return false if is_duplicate_game?(turn_data)
    insert_query = "INSERT INTO games (winner) VALUES ('#{winner}')"
    @client.query(insert_query)
    game_id = @client.query("SELECT LAST_INSERT_ID()").first['LAST_INSERT_ID()']
    turn_data.each do |td|
      save_turn(td['player'], td['position'], td['turn_number'], game_id)
    end
    return true
  end

  def is_duplicate_game?(turn_data)
    sorted_data = turn_data.sort{|x,y| y['turn_number'] <=> x['turn_number']}
    query = "SELECT * from games"
    results = @client.query(query)
    results.each do |g|
      game_id = g["game_id"]
      query = "SELECT player, position, turn_number from turns WHERE game_id = #{game_id}"
      results = @client.query(query)
      game_data = []
      results.each do |result|
        game_data << result
      end
      sorted_game_data = game_data.sort{|x,y| y['turn_number'] <=> x['turn_number']}
      return true if sorted_data == sorted_game_data
    end
    return false
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

  def project_winning_turn(similar_game_ids, player, turn_number, empty_squares)
    position_data = []
    9.times { position_data << {'wins' => 0, 'losses' => 0} }
    similar_game_ids.each do |game_id|
      query = "SELECT * from turns WHERE turn_number=#{turn_number} && game_id=#{game_id}"
      results = @client.query(query)
      turn = results.first
      turn_position = turn['position'].to_i
      puts "turn position #{turn_position}"
      query = "SELECT * from games WHERE game_id=#{game_id}"
      results = @client.query(query)
      game = results.first
      puts "game is #{game}"
      puts "winner was #{game['winner']}"
      hash_key = player == game['winner'] ? 'wins' : 'losses'
      d = position_data[turn_position]
      puts d
      d[hash_key] += 1
      puts "position data #{position_data}"
    end
    scores = []
    position_data.each do |position|
      scores << (position['wins'] - position['losses'])
    end
    puts "scores #{scores}"
    max_score = scores.max
    possible_positions = []
    scores.each_with_index do |score, index|
      if score == max_score
        possible_positions << index
      end
    end
    best_position = possible_positions.sample
    return empty_squares.include?(best_position) ? best_position : empty_squares.sample
  end

end

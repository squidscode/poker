ACTIVE_GAMES = {}

class GamesController < ApplicationController
  def create
    if params[:action] == "create"
      game_name = params[:name]
      player_name = params[:player_name]
      token = params[:authenticity_token]
      @game = Game.new(name:game_name, active_player:0, pot:0); @game.save
      player = Player.new(name:player_name, game_id:@game.id, chips:BUY_IN)
      if !@game.save || !player.save
        # an error happened
        print(@game.errors.full_messages)
        print(player.errors.full_messages)
      else
        # the game was successfully created
        print("Game was created!!")
        @game.active_player = player.id
        @game.save
        cookies[:game_auth_token] = @game.auth_token
        cookies[:player_auth_token] = player.auth_token
        redirect_to "/games/#{@game.id}"
      end
    end
  end

  def index
    @games = Game.all
    render "menu"
  end

  def show
    @game = Game.find(params[:id])
    @players = Player.where(game_id:@game.id)
    @player = Player.where(
      game_id:@game.id,
      auth_token:cookies[:player_auth_token]
    ).limit(1)[0]

    # Used for selectively rendering things
    @is_admin = cookies[:game_auth_token] == @game.auth_token
    @is_player = @player != nil
    @is_active_player = self.is_active_player?

    if @game.pot == 0 \
      && (@game.community_cards == "" || @game.community_cards == nil)
      @in_lobby = true
    else
      @in_lobby = false
    end

    if @is_admin
      @player_requests = PlayerRequest.where(game_id:@game.id)
    end

    render "game"
  end

  def update
    @game = Game.find(params[:id])
    @players = Player.where(game_id:params[:id])
    is_admin = cookies[:game_auth_token] == @game.auth_token
    active_player = @game.active_player == 0 ? nil : Player.find(@game.active_player)
    if params[:commit] == "Start Game" && is_admin && @players.length > 1
      get_active_game(params[:id]).play_game()
    elsif params[:commit] == "Bet" && self.is_active_player?
      bet = Integer(params[:bet])
      @game.raise(active_player, bet)
      get_active_game(params[:id]).unpause()
    elsif params[:commit] == "Fold" && self.is_active_player?
      @game.fold(active_player)
      get_active_game(params[:id]).unpause()
    end
  end

  def is_active_player?
    active_player = @game.active_player == 0 ? nil : Player.find(@game.active_player)
    return active_player != nil && cookies[:player_auth_token] == active_player.auth_token
  end

  def get_active_game(id)
    if ACTIVE_GAMES.include?(id)
      return ACTIVE_GAMES[id]
    else
      ACTIVE_GAMES[id] = Game.find(id)
      return ACTIVE_GAMES[id]
    end
  end

  def destroy
  end
end

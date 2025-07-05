INITIAL_CHIPS = 1000

class GamesController < ApplicationController
  def create
    if params[:action] == "create"
      game_name = params[:game][:name]
      player_name = params[:game][:player_name]
      token = params[:authenticity_token]
      @game = Game.new(name:game_name, active_player:0, pot:0); @game.save
      player = Player.new(name:player_name, game_id:@game.id, chips:INITIAL_CHIPS)
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
    @game = Game.new()
    render "menu"
  end

  def show
    @game = Game.find(params[:id])
    @players = Player.where(game_id:@game.id)

    @is_admin = cookies[:game_auth_token] == @game.auth_token

    @player = Player.where(
      game_id:@game.id,
      auth_token:cookies[:player_auth_token]
    ).limit(1)[0]
    @is_player = @player != nil

    if @game.pot == 0 \
      && (@game.community_cards == "" || @game.community_cards == nil)
      @in_lobby = true
    else
      @in_lobby = false
    end

    if @is_admin
      @player_requests = []
    end

    render "game"
  end

  def update
  end

  def destroy
  end
end

class PlayersController < ApplicationController
  def create
    pr = PlayerRequest.new(name:params[:name], game_id:params[:game_id])
    game = Game.find(pr.game_id)
    if pr.save
      cookies[:player_auth_token] = pr.auth_token
    end
    redirect_back(fallback_location: root_path)
  end
  
  def destroy
    p = Player.where(id:params[:player_id]).limit(1)[0]
    game = Game.find(p.game_id)
    if p != nil && cookies[:game_auth_token] == game.auth_token
      p.destroy
    end
    redirect_back(fallback_location: root_path)
  end

  def approve
    pr = PlayerRequest.where(id:params[:player_request_id]).limit(1)[0]
    game = Game.find(pr.game_id)
    if pr != nil && cookies[:game_auth_token] == game.auth_token
      pr.delete
      player = Player.create(
        name:pr.name, game_id:pr.game_id, auth_token:pr.auth_token, chips: BUY_IN
        fold: 0
      )
      puts player.errors.full_messages
      redirect_back(fallback_location: root_path)
    end
  end

  def deny
    pr = PlayerRequest.where(id:params[:player_request_id]).limit(1)[0]
    game = Game.find(pr.game_id)
    if pr != nil && cookies[:game_auth_token] == game.auth_token
      pr.destroy
    end
    redirect_back(fallback_location: root_path)
  end
end

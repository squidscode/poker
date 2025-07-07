class PlayersController < ApplicationController
  def create
    pr = PlayerRequest.new(name:params[:name], game_id:params[:game_id])
    if pr.save
      cookies[:player_auth_token] = pr.auth_token
      redirect_to "/games/#{params[:game_id]}"
    end
  end

  def approve
    pr = PlayerRequest.where(id:params[:player_request_id]).limit(1)[0]
    if pr != nil
      pr.delete
      player = Player.create(
        name:pr.name, game_id:pr.game_id, auth_token:pr.auth_token, chips: BUY_IN
      )
      puts player.errors.full_messages
      redirect_back(fallback_location: root_path)
    end
  end

  def deny
    pr = PlayerRequest.where(id:params[:player_request_id]).limit(1)[0]
    if pr != nil
      pr.delete
    end
    redirect_back(fallback_location: root_path)
  end
  
  def destroy

  end
end

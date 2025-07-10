class PlayersController < ApplicationController
  def create
    pr = PlayerRequest.new(name:params[:name], game_id:params[:game_id])
    if pr.save
      cookies[:player_auth_token] = pr.auth_token
    end
    ActionCable.server.broadcast("game_admin_#{pr.game_id}", {action: "reload"})
  end
  
  def destroy
    p = Player.where(id:params[:player_id]).limit(1)[0]
    game = Game.find(p.game_id)
    if p != nil && cookies[:game_auth_token] == game.auth_token
      # kick and force a fold!
      p.kick = 1
      p.fold = 1
      p.save
    end
    ActionCable.server.broadcast("game_admin_#{p.game_id}", {action: "reload"})
    ActionCable.server.broadcast("game_#{p.game_id}", {action: "reload"})
  end

  def approve
    pr = PlayerRequest.where(id:params[:player_request_id]).limit(1)[0]
    game = Game.find(pr.game_id)
    if pr != nil && cookies[:game_auth_token] == game.auth_token
      pr.delete
      player = Player.create(
        name:pr.name, game_id:pr.game_id, auth_token:pr.auth_token, chips: BUY_IN
      )
      ActionCable.server.broadcast("game_admin_#{pr.game_id}", {action: "reload"})
      ActionCable.server.broadcast("game_#{pr.game_id}", {action: "reload"})
    end
  end

  def deny
    pr = PlayerRequest.where(id:params[:player_request_id]).limit(1)[0]
    game = Game.find(pr.game_id)
    if pr != nil && cookies[:game_auth_token] == game.auth_token
      pr.destroy
    end
    ActionCable.server.broadcast("game_admin_#{pr.game_id}", {action: "reload"})
  end
end

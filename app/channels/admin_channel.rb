class AdminChannel < ApplicationCable::Channel
  def subscribed
    stream_from "game_admin_#{params[:id]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end

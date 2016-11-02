SocialShareButton::Engine.routes.draw do
  root to: "share#get_count"

  get '/reset_share_count' => 'share#reset_share_count', as: :reset_share_count

end
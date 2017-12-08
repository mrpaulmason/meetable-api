Rails.application.routes.draw do
  get "/ping", to: proc { [200, {}, ['']] }
end

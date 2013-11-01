Spree::Core::Engine.routes.draw do
  match '/paysio_charges', :to => 'paysio_payments#paysio_charges', :as => :paysio_charges, via: [:get, :post]
  match '/paysio_events', :to => 'paysio_payments#paysio_events', :as => :paysio_events, via: [:get, :post]
end

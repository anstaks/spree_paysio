Spree::Core::Engine.routes.draw do
  [:get, :post] '/paysio_charges', :to => 'paysio_payments#paysio_charges', :as => :paysio_charges
  [:get, :post] '/paysio_events', :to => 'paysio_payments#paysio_events', :as => :paysio_events
end

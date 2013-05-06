module SpreePaysio
  class Engine < Rails::Engine
    require 'spree/core'
    # isolate_namespace Spree
    engine_name 'spree_paysio'

    config.autoload_paths += %W(#{config.root}/lib)

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), '../../app/**/*_decorator*.rb')) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
      # Spree::Gateway::Paysio.register
    end

    initializer "spree_paysio.register.payment_methods" do |app|
      app.config.spree.payment_methods += [
        Spree::PaymentMethod::PaysioCom
      ]
    end

    config.to_prepare &method(:activate).to_proc
  end
end

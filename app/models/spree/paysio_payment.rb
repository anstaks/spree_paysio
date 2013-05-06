module Spree
  class PaysioPayment < ActiveRecord::Base
    has_one :payment, :as => :source

    attr_accessor :wallet 
    
    attr_accessible :charge_id, :merchant_id, :object, :order_id, :payment_system_id, :wallet

    validate :charge_id, presence: true
    validate :payment_system_id, presence: true
    # validate :order_id, presence: true

    def success?
      charge = PaysioPayment.retrieve_charge(charge_id)
      ['paid', 'pending'].include? charge.status
    end

    def authorization
    end

    def change_payment_state(state)
      status = case state
        when 'paid'
          :complete
        when 'success'
          :complete
        when 'pending'
          :pend
        when 'failure'
          :failure
        when 'refunded'
          :void
        else
          :pend
        end
      payment_object = payment
      payment_object.send(status)
    end

    class << self
      # Public: Creates new charge
      #
      # order       - The Spree::Order object for pay process.
      # params      - The request params object.
      # return_url  - The String represnt url address where Pays.io should return.
      #
      # Returns created Paysio::Charge object.
      def create_charge(order, params, return_url)
        charge = any_charge?(order, params[:payment_system_id])
        if charge
          charge.respond_to?(:charge_id) ? retrieve_charge(charge.charge_id) : charge
        else
          attributes = {
            amount: "#{order.total.to_i * 100}",
            order_id: "#{order.number}",
            currency_id: 'rur',
            description: "Order ##{order.number}",
            payment_system_id: params[:payment_system_id],
            success_url: return_url,
            failure_url: return_url,
            return_url: return_url
          }

          if params[:wallet].present? && params[:wallet][:account].present?
            attributes[:wallet] = { :account => params[:wallet][:account] }
          end

          begin
            Paysio.api_key = PaymentMethod::PaysioCom.preferences[:client_api_key]
            Paysio::Charge.create(attributes)
          rescue Paysio::Errors::BadRequest => e
            e
          end
        end

      end
      
      # Public: Process recieved charge from paysio.
      #
      # charge_id  - Charge id param .
      #
      # Returns Paysio::Charge object.
      def process_charge(charge_id)
        charge = retrieve_charge(charge_id)

        paysio_payment = find_by_charge_id(charge.id)
        if paysio_payment.present?
          paysio_payment.change_payment_state(charge.status)
        end
        charge
      end

      # Public: Process recieved event from paysio.
      #
      # event_id  - Event id param .
      #
      # Returns Paysio::Event object.
      def process_event(event_id)
        Paysio.api_key = PaymentMethod::PaysioCom.preferences[:client_api_key]
        event = Paysio::Event.retrieve(event_id)
        if event.data.object == 'charge'
          status = case event.type
          when 'charge.success'
            'success'
          when 'charge.failure'
            'failure'
          when 'charge.refund'
            'refunded'
          else
            ''
          end
          paysio_payment = find_by_charge_id(event.data.id)
          if paysio_payment.present?
            paysio_payment.change_payment_state(status)
          end
        end
        event           
      end

      def retrieve_charge(charge_id)
        Paysio.api_key = PaymentMethod::PaysioCom.preferences[:client_api_key]
        Paysio::Charge.retrieve(charge_id)
      end

      # amount  bigint  сумма платежа в центах
      # payment_system_id string  код платежной системы
      # status  string  статус платежа
      # description string описание платежа
      # created string дата создания в формате Unix Time
      def charges_all(params = {})
        Paysio.api_key = PaymentMethod::PaysioCom.preferences[:client_api_key]
        Paysio::Charge.all(params)
      end

      # Public: Checks local stored payments and pays.io charges for payment this order.
      #
      # order             - The Spree::Order object check.
      # payment_system_id - The payment_system_id to check.
      #
      # Returns true if the charge already exists or false - if not.
      def any_charge?(order, payment_system_id)
        paysio_payment = find_by_order_id(order.number)
        if paysio_payment.present? && paysio_payment.payment_system_id == params[:payment_system_id]
          paysio_payment
        else
          charges = charges_all(amount: "#{order.total.to_i * 100}", 
                        payment_system_id: payment_system_id,
                        description: "Order ##{order.number}")
          # We assume that described above conditions is enought to find charge
          if charges.count > 0
            charges.first
          end
        end
      end
      alias :exists? :any_charge?
    end
  end
end
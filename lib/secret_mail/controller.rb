require 'mail'


class UnkownAction < StandardError
end


module SecretMail
  class Controller
    def self.process message, &block
      message.to.each do |to|
        record = MailAction.find_valid(to, message.from[0])
        if record
          Controller.new record, message, &block
        end
      end
    end


    def create
      s = MailAction.create(@message.from[0], @record.params, @message.subject)
      s.save
      @created = s
    end


    def destroy
      s = MailAction.find_valid(@message.subject.strip, @message.from[0])
      s.destroy
      s.save
    end


    private
    def initialize record, message, &block
      @record = record
      @message = message

      action = record.action
      if respond_to?(action)
        send(action.to_s)
        if(@created && block_given?)
          yield :created, @created, message
        end
      else
        if block_given?
          yield action.to_sym, record, message
        else
          raise UnkownAction, "Action: #{action} not implemented in the controller"
        end
      end
    end
  end

end

require 'mail'


class UnkownAction < StandardError
end


module SecretMail
  class Controller
    def self.process message
      record = MailAction.find_valid(message.to, message.from)
      if record
        Controller.new record, message
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
    def initialize record, message
      @record = record
      @message = message

      action = record.action
      if respond_to?(action)
        send(action.to_s)
      else
        raise UnkownAction, "Action: #{action} not implemented in the controller"
      end
    end
  end

end

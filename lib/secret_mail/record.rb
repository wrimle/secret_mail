require 'rubygems'
require 'base32_pure'
require 'json'
require 'uuidtools'
require 'active_record'


module SecretMail
  class MailAction < ActiveRecord::Base
    def self.create from, action, params = {}
      # Create a secret mail address
      r = SecureRandom.random_bytes(5)
      secret = Base32::Crockford.encode(r).downcase

      # Create object with sender
      record = MailAction.new({
        :secret_mail => "#{secret}@#{self.mail_domain}",
        :from => from,
        :action => action,
        :params => params,
      })
    end


    def self.find_valid secret_mail, from
      s = find_by_secret_mail(secret_mail)
      if s && s.crypted_from
        s.valid_sender?(from) ? s : nil
      else
        s
      end
    end

    def from= v
      self.salt = UUIDTools::UUID::random_create.to_s
      self.crypted_from = MailAction.sign(salt, v)
    end


    def valid_sender? v
      crypted_from == MailAction.sign(salt, v)
    end


    def action= v
      self.packed_action = [v].to_json
    end


    def action
      (self.packed_action && JSON.parse(self.packed_action)[0]) || nil
    end


    def params= v
      self.packed_params = [v].to_json
    end


    def params
      (self.packed_params && JSON.parse(self.packed_params)[0]) || nil
    end


    protected
    def self.mail_domain v = nil
      if v
        @mail_domain = v
      else
        @mail_domain
      end
    end


    def self.sign salt, v
      namespace = UUIDTools::UUID.parse(salt)
      UUIDTools::UUID.sha1_create(namespace, v).hexdigest
    end

  end
end

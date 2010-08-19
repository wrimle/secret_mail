$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'secret_mail'
require 'spec'
require 'spec/autorun'
require 'fileutils'
require 'db/create_tables'

Spec::Runner.configure do |config|
  SecretMail::MailAction.mail_domain "example.com"

  ActiveRecord::Base.establish_connection(
      :adapter => "sqlite3",
      :database => "db/test.sqlite3"
  ) 
  ActiveRecord::Base.connection
  ActiveRecord::Migrator.migrate("db/migrate")
  begin
    CreateTables.down
  rescue
  end
  CreateTables.up
 
  attributes = {
    :secret_mail => "blog@example.com",
    :action => "create",
    :params => "mail_to"
  }
  record = SecretMail::MailAction.new(attributes)
  record.save

  attributes = {
    :secret_mail => "destroy@example.com",
    :action => "destroy",
    :params => {}
  }
  record = SecretMail::MailAction.new(attributes)
  record.save


  Mail.defaults do
    delivery_method :test
  end
end

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

include SecretMail

describe "MailAction" do
  begin
    salt = UUIDTools::UUID::random_create.to_s
    attributes = {
      :secret_mail => "secret@example.com",
      :from => "from@example.com",
      :action => "mail_to",
      :params => {}
    }
    MailAction.new(attributes).save
  end


  it "creates a secret mail address for a sender email and an action" do
    mail_from = "from@example.com"
    action = "mail_to"
    params = { :to => "secret@example.com" }
    record = MailAction::create(mail_from, action, params)
    
    record.secret_mail.should be_a(String)
    record.secret_mail.length.should be > 0
    record.secret_mail.should include("@#{MailAction.mail_domain}")

    record.action.should_not == nil
    record.params.should_not == nil

    record.should be_valid_sender(mail_from)
    record.save
  end


  it "checks that the sender is valid" do
    secret_mail = "secret@example.com"
    from = "wrong@example.com"
    record = MailAction::find_valid(secret_mail, from)
    record.should be(nil)
  end


  it "finds an action based on secret_mail and sender" do
    from = "from@example.com"
    # The secret is in the mails to field
    secret_mail = "secret@example.com"
    record = MailAction::find_valid(secret_mail, from)
    record.should_not be(nil)
    record.action.should_not == nil
  end


  it "destroys a secret_mail when asked to" do
    from = "from@example.com"
    secret_mail = "secret@example.com"
    record = MailAction::find_valid(secret_mail, from)
    record.should_not be(nil)
    record.destroy
  end

end


describe SecretMail::Controller do
  begin
  end

  it "takes a mail message and translates it to a controller action" do
    @mail = Mail.new do
      to "blog@example.com"
      from "from@example.com"
      subject "user@example.com"
      body "A body"
    end

    controller = SecretMail::Controller::process(@mail)
  end


  it "creates a new secret mail address if email address has action create" do
    @mail = Mail.new do
      to "blog@example.com"
      from "from@example.com"
      subject "user@example.com"
      body "A body"
    end

    controller = SecretMail::Controller::process(@mail)
    controller.instance_eval do
      secret_mail = @created.secret_mail
      r = SecretMail::MailAction.find_valid(secret_mail, "from@example.com")
      r.should_not == nil

      r.action.should_not == nil
      r.params.should_not == nil
      r.salt.should_not == nil
      r.crypted_from.should_not == nil
    end
  end


  it "destroys a secret mail address if email address has action destroy" do
    create_mail = Mail.new do
      to "blog@example.com"
      from "from@example.com"
      subject "user@example.com"
      body "A body"
    end

    controller = SecretMail::Controller::process(create_mail)

    destroy_mail = Mail.new do
      to "destroy@example.com"
      from "from@example.com"
      body "A body"
    end
    controller.instance_eval do
      destroy_mail.subject @created.secret_mail
    end
    secret_mail = destroy_mail.subject
    controller = SecretMail::Controller::process(destroy_mail)

    record = SecretMail::MailAction.find_valid(secret_mail, "from@example.com")
    record.should == nil
  end

end

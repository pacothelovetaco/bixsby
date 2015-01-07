require 'mail'

ACCOUNTS = YAML.load_file(File.expand_path("../../../../config/email_settings.yml", __FILE__))

module Bixmail
  def connect_to_email_account(account_name)
      Mail.defaults do
        retriever_method ACCOUNTS[account_name][:protocol].to_sym, 
                         :address    => ACCOUNTS[account_name][:address],
                         :port       => ACCOUNTS[account_name][:port],
                         :user_name  => ACCOUNTS[account_name][:user_name],
                         :password   => ACCOUNTS[account_name][:password],
                         :enable_ssl => ACCOUNTS[account_name][:enable_ssl]
      end
  end

  def new_messages?(session_id)
    output = []
    ACCOUNTS.each do |key, settings|
      connect_to_email_account(key)
      messages = Mail.find(read_only: true, keys: ['NOT','SEEN'])
      output << @bixsby.respond("BMAIL RESPONSE You have #{messages.count} new emails in #{key}")
    end
    bixsby_say session_id, output.join("\n")
  end

  def list_messages(session_id, account_name)
    connect_to_email_account(account_name.downcase)
    messages = Mail.find(read_only: true, keys: ['NOT','SEEN'])
    
    output = []
    if messages.empty?
      output << "You have no new messages."
    else
      output << "You have messages from:"
      messages.each do |message|
        output << "#{message.from.join("and ")} regarding #{message.subject || 'no subject'}"
      end
    end
    bixsby_say session_id, output.join("\n\n")
  end

  def read(session_id, message)
    bixsby_say session_id, message.body
  end
  
  def compose(session_id, opt={})
    mail = Mail.new do
           from    opts[:from]
           to      opts[:recipient]
           subject opts[:subject]
           body    opts[:body]
    end
    mail.deliver!
    bixsby_say session_id, "Message sent to #{opts[:to]}, sir."
  end

  def list_accounts(session_id)
    output = []
    output << "I'm only aware of these Email accounts:"
    ACCOUNTS.each do |account, settings|
      output << "- #{account}"
    end
    bixsby_say session_id, output.join("\n")
  end
end

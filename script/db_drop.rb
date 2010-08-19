#!/bin/env ruby

require 'rubygems'
require 'active_record'
require 'yaml'
require 'db/create_tables'

db_yaml = case
          when File.exists?(f = "config/database.yml") then
            f
          when File.exists?(f = "#{ENV['HOME']}/.secret_mail/config/database.yml") then
            f
          when File.exists?(f = "/etc/secret_mail/database.yml") then
            f
          else
            nil
          end

dbconfig = YAML::load(File.open(db_yaml))
ActiveRecord::Base.establish_connection(dbconfig)
ActiveRecord::Base.connection

begin
  CreateTables.down
rescue ActiveRecord::StatementInvalid
  puts "Dropping failed. Tables already down?"
end

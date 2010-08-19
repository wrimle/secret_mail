class CreateTables < ActiveRecord::Migration
  def self.up
    create_table :mail_actions do |t|
      t.string :secret_mail
      t.string :crypted_from
      t.string :salt
      t.string :packed_action
      t.string :packed_params

      t.timestamps
    end

    add_index :mail_actions, :secret_mail
  end

  def self.down
    drop_table :mail_actions
  end
end

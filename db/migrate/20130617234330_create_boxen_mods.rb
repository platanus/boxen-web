class CreateBoxenMods < ActiveRecord::Migration
  def change
    create_table :boxen_mods do |t|
      t.string :name
      t.datetime :last_check
      t.string :repo
      t.string :current_version
      t.string :last_version
      t.boolean :updated
      t.integer :position

      t.timestamps
    end
  end
end

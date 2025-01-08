class CreateNotifications < ActiveRecord::Migration[7.1]
  def change
    create_table :notifications do |t|
      t.string :title
      t.text :body
      t.references :notifiable, polymorphic: true, null: false
      t.boolean :read
      t.string :status

      t.timestamps
    end
  end
end

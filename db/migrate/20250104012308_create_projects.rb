class CreateProjects < ActiveRecord::Migration[6.0]  
  def change  
    create_table :projects do |t|  
      t.references :product, foreign_key: true  
      t.references :fire_alarm_control_panel, foreign_key: true  
      t.references :graphic_system, foreign_key: true   
      t.timestamps  
    end  
  end  
end
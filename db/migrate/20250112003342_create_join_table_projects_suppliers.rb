class CreateJoinTableProjectsSuppliers < ActiveRecord::Migration[7.1]
  def change
    create_join_table :projects, :suppliers do |t|
      # t.index [:project_id, :supplier_id]
      # t.index [:supplier_id, :project_id]
    end
  end
end

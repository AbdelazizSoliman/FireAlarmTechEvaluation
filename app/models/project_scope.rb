class ProjectScope < ApplicationRecord
    belongs_to :project
    has_many :systems
    has_and_belongs_to_many :suppliers, join_table: :project_scopes_suppliers

  end
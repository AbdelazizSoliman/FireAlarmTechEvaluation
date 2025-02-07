class ManualPullStation < ApplicationRecord
  self.inheritance_column = nil # Disable STI for the type column

  belongs_to :subsystem
  belongs_to :supplier
end

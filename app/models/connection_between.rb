class ConnectionBetween < ApplicationRecord
  belongs_to :subsystem
  belongs_to :supplier
end

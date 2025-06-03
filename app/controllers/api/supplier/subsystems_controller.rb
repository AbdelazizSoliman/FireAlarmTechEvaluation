module Api
  module Supplier
    class SubsystemsController < Api::ApplicationController
      def index
        if params[:system_ids].present?
          system_ids = params[:system_ids].map(&:to_i)
          subsystems = Subsystem.where(system_id: system_ids)
        else
          subsystems = Subsystem.all
        end
        render json: subsystems
      end
    end
  end
end

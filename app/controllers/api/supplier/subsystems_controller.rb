module Api
    module Supplier
      class SubsystemsController < ApplicationController
        skip_before_action :verify_authenticity_token
  
        def index
          subsystems = Subsystem.where(system_id: params[:system_id])
          render json: subsystems
        end
      end
    end
  end
  
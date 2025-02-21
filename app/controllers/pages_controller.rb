class PagesController < ApplicationController
  before_action :authenticate_user! # Ensure user is signed in before accessing this page
end

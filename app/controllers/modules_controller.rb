class ModulesController < ApplicationController
  def index
    render :modules, :layout => false
  end
end

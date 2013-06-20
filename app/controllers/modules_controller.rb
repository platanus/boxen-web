class ModulesController < ApplicationController
  skip_before_filter :auth, :only => :script

  def index

    render :modules, :layout => false
  end
end

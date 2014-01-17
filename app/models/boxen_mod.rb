class BoxenMod < ActiveRecord::Base
  attr_accessible :current_version, :last_check, :last_version, :name, :position, :repo, :updated
end

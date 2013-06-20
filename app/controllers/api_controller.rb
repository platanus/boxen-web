require 'octokit'
require 'versionomy'

class ApiController < ApplicationController
    respond_to :json

    # Get all the modules
    def modules
        begin
            # Update persitend data from puppetfile
            update_from_puppetfile

            render json: BoxenMod.order(:position).all.to_json
        rescue
            raise
            render json: {status: "ERROR"}
        end
    end

    # Check the status for a particular module
    # params    :name   module name
    def check_status
        begin
            # Authenticat to github to make the requests
            github = Octokit::Client.new(:login => current_user.login, :oauth_token => current_user.access_token)

            # Check if the modules are up-to-date
            mod = BoxenMod.find_by_name(params[:name])

            # Get the tags from the current_version modules
            tags = github.tags mod.repo
            tags = tags.map { |t| Versionomy.parse(t.name) rescue nil }
            tags = tags.select { |t| not t.nil? }

            last_version = tags.reduce { |r, t| if r.nil? or r < t then t else r end }
            current_version = Versionomy.parse(mod.current_version)
            updated = current_version >= last_version

            puts updated

            # Change last checked date
            mod.last_check = DateTime.now
            mod.last_version = last_version.to_s
            mod.updated = updated
            mod.save

            # Response data
            mod_response = {
                "name" => mod.name,
                "repo" => mod.repo,
                "last_version" => mod.last_version,
                "current_version" => mod.current_version,
                "all_versions" => (tags.map &:to_s),
                "updated" => mod.updated,
                "last_check" => mod.last_check,
            }

            render json: mod_response
        rescue
            raise
            render json: {status: "ERROR"}
        end
    end

    # Get the latest commits from an out-dated repo
    # params    :name   module name
    def changes
        begin
            # Authenticat to github to make the requests
            github = Octokit::Client.new(:login => current_user.login, :oauth_token => current_user.access_token)

            # Check if the modules are up-to-date
            mod = BoxenMod.find_by_name(params[:name])

            commits = github.compare(mod.repo, mod.current_version, mod.last_version)

            response = {
                "changes" => commits.commits,
                "name" => mod.name,
            }

            render json: response
        rescue
            raise
            render json: {status: "ERROR"}
        end
    end

    #####################
    # Private methods
    private

    # Get the puppetfile and update all the modules current versions
    def update_from_puppetfile

        # Authenticat to github to make the requests
        github = Octokit::Client.new(:login => current_user.login, :oauth_token => current_user.access_token)

        # Get Puppetfile from the repo
        puppet = github.contents ENV['REPOSITORY'], :path => 'Puppetfile', :accept => 'application/vnd.github.VERSION.raw'

        # Get the modules from the Puppetfile
        modules = puppet.scan /^github\s*["']([^"']*)["']\s*,\s*["']([^"']*)["'](?:\s*,\s*\:repo\s*=>\s*["']([^"']*)["'])?/m

        # Check if the modules are up-to-date
        modules.each_with_index do |mod, index|
            repo = mod[2] || "boxen/puppet-#{mod[0]}"

            current_version = Versionomy.parse(mod[1])

            # Save to db
            boxen_mod = BoxenMod.find_or_create_by_name(mod[0]) do |m|
                m.repo = repo
                m.current_version = current_version.to_s
                m.position = index
            end

            # Update data
            boxen_mod.repo = repo
            boxen_mod.current_version = current_version.to_s
            boxen_mod.position = index
            boxen_mod.save

        end
    end

end

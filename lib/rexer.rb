module Rexer
  def self.definition_file
    ".extensions.rb"
  end

  def self.definition_lock_file
    ".extensions.lock"
  end

  Config = Data.define(
    # The prefix of the command such as bundle install and bin/rails redmine:plugins:migrate.
    #
    # For example, if the command_prefix is set "docker compose exec -T app",
    # then bundle install will be executed as follows:
    #
    #   docker compose exec -T app bundle install
    #
    :command_prefix
  )

  def self.config
    @config ||= Config.new(command_prefix: ENV["REXER_COMMAND_PREFIX"])
  end
end

require "pathname"
require "zeitwerk"

loader = Zeitwerk::Loader.for_gem
loader.setup
loader.eager_load

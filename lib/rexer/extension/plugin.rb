require "open3"

module Rexer
  module Extension
    module Plugin
      def self.dir
        Pathname.new("plugins")
      end

      class Base
        def initialize(definition)
          @definition = definition
          @name = definition.name
          @hooks = definition.hooks || {}
        end

        private

        attr_reader :name, :hooks, :definition

        def plugin_dir
          @plugin_dir ||= Plugin.dir.join(name.to_s)
        end

        def plugin_exists?
          plugin_dir.exist? && !plugin_dir.empty?
        end

        def needs_db_migration?
          plugin_dir.join("db", "migrate").then {
            _1.exist? && !_1.empty?
          }
        end

        def run_db_migrate(extra_envs = {})
          return unless needs_db_migration?

          envs = {"NAME" => name.to_s}.merge(extra_envs)
          _, error, status = Open3.capture3(envs, "bin/rails redmine:plugins:migrate")

          raise error unless status.success?
        end

        def source
          @source ||= definition.source.then do |src|
            Source.const_get(src.type.capitalize).new(**src.options)
          end
        end
      end

      class Installer < Base
        def install
          return if plugin_exists?

          load_from_source
          run_db_migrate
          hooks[:installed]&.call
        end

        private

        def load_from_source
          source.load(plugin_dir.to_s)
        end
      end

      class Uninstaller < Base
        def uninstall
          return unless plugin_exists?

          reset_db_migration
          remove_plugin
          hooks[:uninstalled]&.call
        end

        private

        def reset_db_migration
          run_db_migrate("VERSION" => "0")
        end

        def remove_plugin
          plugin_dir.rmtree
        end
      end

      class Updater < Base
        def update
          return unless plugin_exists?

          update_source
          run_db_migrate
          hooks[:updated]&.call
        end

        private

        def update_source
          source.update(plugin_dir.to_s)
        end
      end
    end
  end
end

require "rails_instrument/version"

module RailsInstrument
  class Middleware
    def initialize(app, options = {})
      @app = app
    end

    def call(env)
      $rails_instrument = {}
      status, headers, body = @app.call(env)
      begin
        headers["X-View-Runtime"] = ($rails_instrument["process_action.action_controller"][:view_runtime] / 1000).to_s
        headers["X-DB-Runtime"] = ($rails_instrument["process_action.action_controller"][:db_runtime] / 1000).to_s
        headers["X-DB-Query-Count"] = $rails_instrument[:sql_count].to_s
      rescue
        # Do nothing
      end

      [status, headers, body]
    end
  end

  class Engine < ::Rails::Engine
    initializer "my_engine.add_middleware" do |app|
      app.middleware.use RailsInstrument::Middleware

      ActiveSupport::Notifications.subscribe("process_action.action_controller") do |name, start, finish, id, payload|
        $rails_instrument ||= {}
        $rails_instrument[name] = payload
      end

      ActiveSupport::Notifications.subscribe("sql.active_record") do |name, start, finish, id, payload|
        $rails_instrument ||= {}
        $rails_instrument[:sql_count] ||= 0
        $rails_instrument[:sql_count] += 1 if payload[:name] != "SCHEMA"
      end
    end
  end
end

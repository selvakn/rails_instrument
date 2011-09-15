require "rails_instrument/version"

module RailsInstrument
  class <<self
    # Resets the instrument statistics and counts
    def reset!
      $rails_instrument = {}
    end

    def init #:nodoc:
      $rails_instrument ||= {}
      $rails_instrument[:sql_count] ||= 0
    end

    def data #:nodoc:
      $rails_instrument
    end

    # Return the number of sql fired from the last reset
    def sql_count
      data[:sql_count]
    end

    # Taken a block and return the instrument object for the operation done on the block.
    # TODO: Make it to work with nested instrument blocks
    def instrument(&block)
      raise "A block is not passed" unless block_given?
      RailsInstrument.reset!
      yield
      self
    end

    def increment_sql_count #:nodoc:
      data[:sql_count] += 1
    end
  end

  class Middleware  #:nodoc:
    def initialize(app, options = {})
      @app = app
    end

    def call(env)
      RailsInstrument.reset!
      status, headers, body = @app.call(env)
      begin
        headers["X-View-Runtime"] = (RailsInstrument.data["process_action.action_controller"][:view_runtime] / 1000).to_s
        headers["X-DB-Runtime"] = (RailsInstrument.data["process_action.action_controller"][:db_runtime] / 1000).to_s
        headers["X-DB-Query-Count"] = RailsInstrument.sql_count.to_s
      rescue => e
        # Do nothing
      end

      [status, headers, body]
    end
  end

  class Engine < ::Rails::Engine  #:nodoc:
    initializer "my_engine.add_middleware" do |app|
      app.middleware.use RailsInstrument::Middleware

      ActiveSupport::Notifications.subscribe("process_action.action_controller") do |name, start, finish, id, payload|
        RailsInstrument.init
        $rails_instrument[name] = payload
      end

      ActiveSupport::Notifications.subscribe("sql.active_record") do |name, start, finish, id, payload|
        RailsInstrument.init
        RailsInstrument.increment_sql_count unless (payload[:name] == "SCHEMA" || %w(BEGIN COMMIT ROLLBACK).include?(payload[:sql]))
      end
    end
  end
end

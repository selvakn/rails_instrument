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
        headers["X-View-Runtime"] = (view_runtime / 1000).to_s
        headers["X-DB-Runtime"] = (db_runtime / 1000).to_s
        headers["X-DB-Query-Count"] = sql_count.to_s

        if html_reponse?(headers)
          new_body = Rack::Response.new([], status, headers)
          body.each do |fragment|
            new_body.write fragment.gsub("</body>", "#{sql_html_overlay}</body>")
          end
          body = new_body
        end
      rescue => e
        headers["X-Rails-Instrument"] = "Error"
      end

      [status, headers, body]
    end

    private
    def html_reponse?(headers)
      headers['Content-Type'] =~ /html/
    end

    def sql_html_overlay
      %Q{<div style="position: fixed; bottom: 0pt; right: 0pt; cursor: pointer; border-style: solid; border-color: rgb(153, 153, 153); -moz-border-top-colors: none; -moz-border-right-colors: none; -moz-border-bottom-colors: none; -moz-border-left-colors: none; -moz-border-image: none; border-width: 2pt 0pt 0px 2px; padding: 5px; border-radius: 10pt 0pt 0pt 0px; background: none repeat scroll 0% 0% rgba(200, 200, 200, 0.8); color: rgb(119, 119, 119); font-size: 18px;" title="DB query counts / duration (For Development purpose only)">#{sql_count} / #{"%.3f" % db_runtime}</div>}
    end

    def db_runtime
      RailsInstrument.data["process_action.action_controller"][:db_runtime]
    end

    def view_runtime
      RailsInstrument.data["process_action.action_controller"][:view_runtime]
    end

    def sql_count
      RailsInstrument.sql_count
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

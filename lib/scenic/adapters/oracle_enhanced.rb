require_relative 'oracle_enhanced/views'

module Scenic
  module Adapters
    # An adapter for managing Oracle views.
    class OracleEnhanced
      def initialize(connectable = ActiveRecord::Base)
        @connectable = connectable
      end

      def views
        Views.new(connection).all
      end

      def create_view(name, sql_definition)
        execute "CREATE VIEW #{quote_table_name(name)} AS #{sql_definition}"
      end

      def update_view(name, sql_definition)
        drop_view(name)
        create_view(name, sql_definition)
      end

      def replace_view(name, sql_definition)
        execute "CREATE OR REPLACE VIEW #{quote_table_name(name)} AS #{sql_definition}"
      end

      def drop_view(name)
        execute "DROP VIEW #{quote_table_name(name)}"
      end

      def create_materialized_view(name, sql_definition)
        execute "CREATE MATERIALIZED VIEW #{quote_table_name(name)} AS #{sql_definition}"
      end

      def update_materialized_view(name, sql_definition)
        # IndexReapplication.new(connection: connection).on(name) do
          drop_materialized_view(name)
          create_materialized_view(name, sql_definition)
        # end
      end

      def drop_materialized_view(name)
        execute "DROP MATERIALIZED VIEW #{quote_table_name(name)}"
      end

      def refresh_materialized_view(name, concurrently: false, cascade: false)
        # refresh_dependencies_for(name) if cascade

        if concurrently
          execute "REFRESH MATERIALIZED VIEW CONCURRENTLY #{quote_table_name(name)}"
        else
          execute "REFRESH MATERIALIZED VIEW #{quote_table_name(name)}"
        end
      end

      private

      attr_reader :connectable
      delegate :execute, :quote_table_name, to: :connection

      def connection
        connectable.connection
      end
    end
  end
end

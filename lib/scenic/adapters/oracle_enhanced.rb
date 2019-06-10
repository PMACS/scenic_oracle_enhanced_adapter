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

      # `_sql_definition` argument allows `create_view` to be reversed in a migration rollback
      def drop_view(name, _sql_definition = nil)
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

      # `_sql_definition` argument allows `create_materialized_view` to be reversed in a migration rollback
      def drop_materialized_view(name, _sql_definition = nil)
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
      
      def create_pk_for_view(object:, key: 'id')
        key_name = [object.to_s.split('.').last, key.to_s, 'pk'].join('_')
        suppress_messages do
          say_with_time do
            execute <<-SQL
            ALTER VIEW #{object} ADD CONSTRAINT #{key_name} PRIMARY KEY (#{key}) DISABLE
            SQL
            "Primary key #{key_name} created for #{object}."
          end
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

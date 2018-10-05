module Scenic
  module Adapters
    class OracleEnhanced
      class Views
        def initialize(connection)
          @connection = connection
          @current_schema = fetch_current_schema
        end

        def all
          views_from_oracle.map(&method(:to_scenic_view))
        end

        private

        attr_reader :connection,
                    :current_schema

        def fetch_current_schema
          ActiveRecord::Base.connection
                            .execute("select sys_context('userenv', 'current_schema') from dual")
                            .fetch
                            .first
        end

        def views_from_oracle
          # NOTE: Oracle cannot `UNION` on `LONG` fields,
          # and the `all_mviews.query` field and `all_views.text` field
          # are both `LONG` fields. Thus, we must use `UNION ALL`.
          # Luckily, we are not here concerned about duplicates.
          cursor = ActiveRecord::Base.connection.select_all(<<-SQL)
            SELECT 'm'        AS KIND,
                   mview_name AS VIEWNAME,
                   owner      AS NAMESPACE,
                   query      AS DEFINITION
            FROM   all_mviews
            UNION ALL
            SELECT 'v'       AS KIND,
                   view_name AS VIEWNAME,
                   owner     AS NAMESPACE,
                   text      AS DEFINITION
            FROM   all_views
          SQL
        end

        def to_scenic_view(result)
          namespace, viewname = result['namespace'], result['viewname']

          if namespace != 'SYS'
            namespaced_viewname = "#{oracle_identifier(namespace)}.#{oracle_identifier(viewname)}"
          else
            namespaced_viewname = oracle_identifier(viewname)
          end

          Scenic::View.new(
            name: namespaced_viewname,
            definition: result['definition'].strip,
            materialized: result['kind'] == 'm'
          )
        end

        def oracle_identifier(name)
          connection.quote_column_name_or_expression(name)
        end
      end
    end
  end
end

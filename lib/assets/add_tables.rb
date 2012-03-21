module AddTables

  class T

    def self.conn
      ActiveRecord::Base.connection
    end

    def self.create(table, fields)
      conn.drop_table(table) if conn.tables.include?(table.to_s)
      conn.create_table(table)
      fields.each do |field, type|
        conn.add_column(table, field, type)
      end
    end

  end

end

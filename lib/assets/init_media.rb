module InitMedia

  class T #validate mediatype titles >1 character?

    include InitMedia

    def self.conn
      ActiveRecord::Base.connection
    end

    def self.create(table, fields)
      conn.drop_table(table) if conn.tables.include?(table.to_s)
      conn.create_table(table)
      fields.each do |field, type|
        conn.add_column(table, field, type)
      end
      InitMedia.init_obj(table.to_s.capitalize.singularize)
    end

    def self.alter(table, fields)
      o = Object.const_get(table.to_s.capitalize.singularize)
      o.new.attributes.reject {|x| x=="id"}.each do |field, type|
        conn.remove_column(table, field) unless (fields.has_key? field and o.columns_hash[field].sql_type.to_s.downcase == fields[field].downcase) #same mediatype => just rename column
      end
      o.reset_column_information
      fields.each do |field, type|
        conn.add_column(table, field, type) unless o.new.respond_to? field.to_sym
        o.class_eval "serialize :#{field}, Array" if type.downcase=="array"
      end
      o.reset_column_information
    end

  end

  def init_obj(title)
    Object.send(:remove_const, title) if Object.const_defined?(title)
    Object.const_set( title, Class.new(ActiveRecord::Base) {
      establish_connection(:development)
      has_many :media, :as => :data
    } )
    Media.where(:title => title, :data_type => "Mediatype")[0].data.arguments.each do |x|
      Object.const_get(title).class_eval "serialize :#{x[0]}, Array" if x[1]=="Array"
    end
  end
  module_function :init_obj

end

require_relative 'db_connection'
require_relative '01_mass_object'
require 'active_support/inflector'

class MassObject
  def self.parse_all(results)
    # objs = []
    results.map do |result|
      self.new(result)  
      # objs << obj
    end
    # objs
  end
end

class SQLObject < MassObject
  def self.columns
    return @columns if @columns
    
    columns = DBConnection.execute2(<<-SQL)
      SELECT *
      FROM #{table_name}
    SQL
    .first
    .map(&:to_sym)

    columns.each do |column|
      define_method(column) { attributes[column] }
      define_method("#{column}=") { |arg| attributes[column] = arg }
    end
    
    @columns = columns
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.to_s.pluralize.underscore
  end

  def self.all
    data = DBConnection.execute(<<-SQL)
      SELECT *
      FROM #{self.table_name}
    SQL
    self.parse_all(data)
  end

  def self.find(id)
    data = DBConnection.execute(<<-SQL, id)
      SELECT *
      FROM #{self.table_name}
      WHERE id = ?
      LIMIT 1
      SQL
    self.parse_all(data).first
  end

  def attributes
    @attributes ||= {}
  end

  def insert
    col_names = attributes.keys.join(", ")
    question_marks = (["?"] * attributes.keys.length).join(", ")
    
    DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO #{self.class.table_name} (#{col_names})
      VALUES (#{question_marks})
    SQL
    
    self.id = DBConnection.last_insert_row_id
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      attr_sym = attr_name.to_sym
      
      if self.class.columns.include?(attr_sym)
        attributes[attr_sym] = value
      else
        raise "unknown attribute name '#{attr_name}'"
      end
    end
  end

  def save
    id.nil? ? insert : update
  end

  def update
    set_line = attributes.keys.map do |attr_name|
      "#{attr_name} = ?"
    end.join(", ")
    
    DBConnection.execute(<<-SQL, *attribute_values, id)
      UPDATE #{self.class.table_name}
      SET #{set_line}
      WHERE id = ?
    SQL
  end

  def attribute_values
    attributes.map { |attribute, _| send(attribute) }
  end
end

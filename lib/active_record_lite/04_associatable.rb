require_relative '03_searchable'
require 'active_support/inflector'

# Phase IVa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key,
  )

  def model_class
    Module.const_get(class_name.to_s)
  end

  def table_name
    return "humans" if class_name.to_s.downcase == "human"
    class_name.to_s.downcase.pluralize
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    defaults = {
      :foreign_key => "#{name}_id".to_sym,
      :class_name => "#{name}".capitalize,
      :primary_key => :id
    }
    
    options = defaults.merge(options)
    
    options.each do |key, val|
      self.send("#{key}=", val)
    end

  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    defaults = {
      :foreign_key => "#{self_class_name}_id".downcase.to_sym,
      :class_name => "#{name}".capitalize.singularize,
      :primary_key => :id
    }
    
    options = defaults.merge(options)
    
    options.each do |key, val|
      self.send("#{key}=", val)
    end
    
  end
end

module Associatable
  # Phase IVb
  def belongs_to(name, options = {})
    #save options
    bt_options = BelongsToOptions.new(name, options)
    
    define_method(name) do
      #send?
      bt_foreign_key = bt_options.foreign_key

      #get the target model
      bt_model = bt_options.model_class
      
      #find the models we want
      bt_model.where(bt_options.primary_key => send(bt_foreign_key)).first
    end
    
  end

  def has_many(name, options = {})
    #save options
    hm_options = HasManyOptions.new(name, self.name, options)
    
    define_method(name) do
      #send?
      hm_foreign_key = hm_options.foreign_key

      #get the target model
      hm_model = hm_options.model_class

      #find the models we want
      hm_model.where(hm_foreign_key => send(hm_options.primary_key))
    end
  end

  def assoc_options
    # Wait to implement this in Phase V. Modify `belongs_to`, too.
  end
end

class SQLObject
  extend Associatable
end

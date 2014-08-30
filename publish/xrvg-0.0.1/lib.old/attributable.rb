#
# Module to be able to declare attribute, initializing them by default, with type checking
# also define syntaxically simpler builder
#
# See :
# - +Object+
# - +Attributable+

require 'utils'

#
# Object extension to provide the Class[] syntax for building objects, with +Attributable+ module.
#
# TODO : must be defined only for Class objects !!
class Object

  # operator [] definition for shorter and more recognizable object creation syntax. 
  #
  # Especially useful when creating Attributable dependant objects.
  #   c = Circle[ :center, p, :radius, 0.1 ]
  def Object.[](*args)
    return self.new( *args )
  end
end


# Attribute class used by Attributable module
#
# Attribute syntax : 
#   attribute :attr1 default_value type
# with :
# - dvalue nil if no default_value (in that case, attribute is said to be required )
# - if type is not specified, default_value must be, and type will be the type of this default_value
# type can be an Array of types
class Attribute
  attr_accessor :symbol, :default_value, :type

  def initialize( symbol, default_value, type )  #:nodoc:
    @symbol = symbol
    @default_value = default_value
    @type = type
  end

end

# Attributable module
# 
# Allows class attribute definition in a concise and effective way. Can be viewed as a :attr_accessor extension. See also +Attribute+
#
# Example :
#   class A
#      attribute :a 1.0; # type is then Float
#      attribute :b      # attribute is required
#   end
#
#   a = A[ :a, 10.0, :b, 2.0 ]
#   a.a => 10.0
module Attributable

  module ClassMethods #:nodoc:
    def init_attributes
      if not @attributes
	@attributes = {}
	newattributes = (self.superclass.ancestors.include? Attributable) ? self.superclass.attributes : {}
	@attributes = @attributes.merge( newattributes )
      else
	# Trace("Attributable::init_attributes self #{self} already initialized")
      end
      # Trace("Attributable::init_attributes self #{self} superclass#{self.superclass} superclass ancestors  #{self.superclass.ancestors.inspect} result #{@attributes}")
    end

    def add_attribute( attribute )
      # Trace("Attributable::add_attribute self #{self} attribute #{attribute.inspect}")
      init_attributes
      @attributes[ attribute.symbol ] = attribute
    end

    def attributes()
      init_attributes
      # Trace("Attributable::attributes self #{self} attributes #{@attributes}")
      return @attributes
    end

    def checkvaluetype( value, type )
      typeOK = nil
      types = type
      types.each do |type|
	if value.is_a? type
	  typeOK = true
	  break
	end
      end
      if not typeOK
	raise( "Attributable::checkvaluetype for class #{self} : default_value #{value.inspect} is not of type #{types.inspect}" )
      end
    end

    def attribute( symbol, default_value=nil, type=nil )
      if (not type and default_value)
	type = [default_value.class]
      elsif type
	if not type.is_a? Array
	  type = [type]
	end
	 if default_value
	   checkvaluetype( default_value, type )
	 end
      end

      self.add_attribute( Attribute.new( symbol, default_value, type ) )
      attr_accessor symbol
    end

    def instance_variable_set( *args )
      # Trace("Attributable::instance_variable_set self #{self} args #{args}")
      super( *args )
    end
  end

  def self.included( receiver )  #:nodoc:
    # inherit_attributes; does not work because Module is not inherited by subclasses
    receiver.extend( ClassMethods )
  end

  def initialize(*args)  #:nodoc:
    # first check if every specified attribute is meaningfull for the class
    args.foreach do |symbol, value|
      if not self.class.attributes.key? symbol
	raise( "Attributable::initialize for class #{self} does not have attribute #{symbol}" )
      end
    end

    # then check specification coherence, and do initialization
    spec = Hash[ *args ]
    self.class.attributes.each_pair do |symbol, attr|
      if spec.key? symbol
	value = spec[ symbol ]
	if attr.type
	  self.class.checkvaluetype( value, attr.type )
	end
	# do init after checking
	self.method("#{symbol.to_s}=").call(value)
      else
	if not attr.default_value
	  raise( "Attributable::initialize for class #{self} : attribute #{symbol} is required : attributes #{self.class.attributes.inspect}" )
	end
	self.method("#{symbol.to_s}=").call(attr.default_value)
      end
    end
  end

end

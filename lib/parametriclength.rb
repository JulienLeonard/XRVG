# File for ParametricLength module

require 'geometry2D'

module XRVG
# Utilitary module to provide length sampling frrom parameter one
# 
# Use pointfromparam method to compute points
module ParametricLength

  # abstract method to provide range to be sampled to compute samples for length interpolation
  def parameter_range
    raise NotImplementedError.new("#{self.class.name}#parameter_range is an abstract method.")
  end

  # abstract method to compute point from parameter
  def pointfromparameter( parameter, container )
    raise NotImplementedError.new("#{self.class.name}#pointfromparameter is an abstract method.")
  end

  ParametricLength::NSAMPLES = 129

  # compute the length of the bezier curve defined by the points
  #
  # Algo : 
  # 
  # for the moment, just take a fix number of samples, and some it
  def compute_length_interpolator() #:nodoc:
    sum = 0.0
    previous = nil
    samplelist = [0.0, 0.0]
    new      = V2D[0.0,0.0]
    self.parameter_range.samples( ParametricLength::NSAMPLES ) do |abs|
      self.pointfromparameter( abs, new )
      # Trace("compute_length_interpolator: abs #{abs} point #{new.inspect}")
      if previous
	sum+= (new - previous).r
	samplelist += [sum, abs]
      else
	previous = V2D[0.0,0.0]
      end
      previous.x = new.x
      previous.y = new.y
    end
    @length = samplelist[-2]

    # Trace("compute_length_interpolator: samplelist #{samplelist.inspect}")
    if @length == 0.0
      newsamplelist = [0.0,0.0,0.0,1.0]
      invsamplelist = [0.0,0.0,1.0,0.0]
    else
      newsamplelist = []
      invsamplelist = []
      samplelist.foreach do |sum, abs|
	newsamplelist += [sum / @length, abs ]
	invsamplelist += [abs, sum / @length ]
      end
    end
    @abs_interpolator    = Interpolator.new( :samplelist, invsamplelist )
    @length_interpolator = Interpolator.new( :samplelist, newsamplelist )
  end

  def load_length_interpolator( abscissas, lengths )
    # puts "load_length_interpolator enter #{abscissas.length} lengths #{lengths.length}"
    # newsamplelist = []
    # invsamplelist = []
    @length = lengths[-1]
    values = []
    if @length.fequal?( 0.0 )
      abscissas = [0.0]
      values    = [0.0]
    else
      lengths.each do |clength|
	values << clength/@length
      end
    end
    # puts "load_length_interpolator abscissas #{abscissas.inspect}"
    # puts "load_length_interpolator values #{values.inspect}"
    @abs_interpolator    = Interpolator.new( :samplelist,  [abscissas, values].forzip )
    @length_interpolator = Interpolator.new( :samplelist,  [values, abscissas].forzip )
    # puts "load_length_interpolator leave"
  end


  def length_interpolator() #:nodoc:
    # puts "length_interpolator enter"
    if not defined? @length_interpolator
      self.compute_length_interpolator()
    end
    return @length_interpolator
  end

  def abs_interpolator() #:nodoc:
    # puts "abs_interpolator enter"
    if not defined? @abs_interpolator
      self.compute_length_interpolator()
    end
    return @abs_interpolator
  end

  def length
    if @length == nil
      self.compute_length()
    end
    return @length
  end

  def compute_length() #:nodoc:
    # puts "compute_length enter"
    self.length_interpolator()
    return @length
  end

  def parameterfromlength( lvalue ) #:nodoc:
    # puts "parameterfromlength enter lvalue #{lvalue}"
    result = self.length_interpolator.interpolate( lvalue )
    # Trace("parameterfromlength lvalue #{lvalue} result #{result}")
    return result
  end

  def lengthfromparameter( lvalue ) #:nodoc:
    result = self.abs_interpolator.interpolate( lvalue )
    # Trace("lengthfromparameter lvalue #{lvalue} result #{result}")
    return result
  end
end
end

# Trace utility
#  
# Consists in a Trace class, and a Trace global method

# Trace "static" class, to be able to globally inhibit or activate traces 
#  Trace.inihibit
#  Trace.activate
class Trace
  @@active = true
  def Trace.active?
    return @@active
  end
  def Trace.inhibit
    @@active = nil
  end
  def Trace.activate
    @@active = true
  end
end

# Standard trace method
#   Trace("hello world") 
# Check before printing the string if traces are active
def Trace(string)
  if Trace.active?
    puts string
  end
end

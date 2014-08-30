# assertion utility
# must be used with care, as expensive
#
class AssertionError < StandardError
end

#
# Assert method, to check for a block, and raise an error if check is not true
#   Assert("1 is different from 0"){ 1 == 0}
def Assert(message=nil, &block)
   unless(block.call)
     raise AssertionError, (message || "Assertion failed")
   end
end

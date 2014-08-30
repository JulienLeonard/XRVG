# This file has to be included if you want to start a XRVG script
#
# Please refer to README for XRVG introduction

# XRVG version (used in rakefile)
XRVG_VERSION = "0.0.83"

# XRVG namespace
module XRVG
end

# Standard Ruby extensions
require 'enumerator'

# XRVG Infrastructure
require 'trace'

# XRVG new mixins 
require 'samplation'
require 'attributable'
require 'interpolation'
require 'parametriclength'

# XRVG base class extensions
require 'utils'
require 'geometry2D'
require 'intersection'

# XRVG base classes
require 'color'
require 'frame'
require 'shape'
require 'render'
require 'bezier'

# XRVG extensions
require 'fitting'
require 'bezierbuilders'
require 'beziermotifs'
require 'beziertools'
require 'interbezier'
require 'geovariety'
require 'spiral'
# require 'graph'




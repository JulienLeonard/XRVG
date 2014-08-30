#!/usr/bin/env ruby

#--
# Copyright (c) 2008 Julien Léonard
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++
#
# = XRVG
#
# XRVG, as "X Ruby Vector Graphics", is a pure Ruby library whose purpose is to define advanced declarative and algorithmic means to generate vector graphics.
#
# You may be interested in consulting the following link[http://xrvg.rubyforge.org/], which describes XRVG philosophy and capabilities in a more tutoring way.
#
# From here, you can browse the following interesting hubs :
# - utils[files/utils_rb.html]
# - shape[files/shape_rb.html]
# - render[files/render_rb.html]
# - attributable[files/attributable_rb.html]
# - samplable[files/samplation_rb.html]
#
# Author::    Julien LEONARD
# Copyright:: Copyright (c) 2008 Julien LEONARD
# License::   MIT licence
# Version::   0.0.1

# RAKEVERSION = '0.0.1'

# Standard Ruby extensions
require 'enumerator'

# XRVG Infrastructure
require 'trace'
require 'assertion'

# XRVG new mixins 
require 'samplation'
require 'attributable'
require 'interpolation'

# XRVG base class extensions
require 'utils'
require 'geometry2D'

# XRVG base classes
require 'color'
require 'frame'
require 'shape'
require 'render'
# require 'bezier'
# require 'bezierspline'

# XRVG extensions
# require 'bezierbuilders'
# require 'beziertools'
# require 'interbezier'
# require 'ondulation'


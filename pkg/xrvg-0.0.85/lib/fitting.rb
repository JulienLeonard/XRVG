#
# Fitting file. See +Fitting+
#

require 'matrix'; # for matrix inversion
require 'bezier.rb'; # for error computation

module XRVG
#
# = Fitting computation class
# == Intro
# Used to compute cubic curve fitting on a list of points (that is sampling inverse operation). Only 2D.
# == Example
# Compute the most fitting single piece bezier curve given list of points
#  bezier    = Fitting.compute( points )
# Compute multipieces bezier curve given list of points
#  bezier    = Fitting.adaptative_compute( points )
class Fitting

  # compute first parameter t estimated values from length between consecutive points
  def Fitting.initparameters( pointlist, parameters=nil ) #:nodoc:
    lengths = [0.0]
    pointlist.pairs do |p1, p2|
      lengths.push( lengths[-1] + (p1-p2).r )
    end
    tlength = lengths[-1]
    if not parameters
      if not tlength == 0.0
	parameters = lengths.map {|length| length / tlength}
      else
	parameters = [0.0] * pointlist.length
      end
    end
    return [parameters, tlength]
  end

  # compute control points from polynomial bezier representation
  #
  # a, b, c, d are such as 
  #  piece( t ) = at3 + bt2 + ct + d
  def Fitting.bezierpiece( a, b, c, d )
    p0 = d
    p1 = p0 + c / 3.0
    p2 = p1 + c / 3.0 + b / 3.0
    p3 = p0 + c + b + a
    return [p0, p1, p2, p3]
  end


  # Base method
  # 
  # Given a pointlist, compute the closest matching cubic bezier curve
  #
  # Result is in the form [p1, pc1, pc2, p2], with [p1, pc1, pc2, p2] V2D
  #
  # maxerror is normalized with curve length. In case of good match (that is pointlist can be modelized by cubic bezier curve), 
  # result error will be under maxerror. If not, result may be above maxerror. In that case, computation is stopped because error
  # no longer decrease, or because iteration is too long.
  def Fitting.compute( pointlist, maxerror=0.01, maxiter=100 )
    parameters, tlength = Fitting.initparameters( pointlist )
    perror = 1.0
    niter = 0
    while true
      bezier, coeffs = Fitting.iterate( pointlist, parameters )
      error = Fitting.error( bezier, pointlist, parameters ) / tlength
      parameters = Fitting.renormalize( bezier, coeffs, pointlist, parameters )
      if (error < maxerror || (error-perror).abs < 0.00001 || niter > maxiter )
	break
      end
      niter += 1
    end
    return bezier
  end

  # adaptative computation with automatic splitting if error not low enough, or if convergence is not fast enough
  #
  #
  def Fitting.adaptative_compute( pointlist, maxerror=0.0001, maxiter=10, tlength=nil )
    parameters, tlengthtmp = Fitting.initparameters( pointlist )
    if parameters == [0] * pointlist.length
      return [Bezier.single(:vector, pointlist[0], V2D::O, pointlist[0], V2D::O),0.0]
    end
    tlength ||= tlengthtmp
    niter = 0
    bezier = nil
    while true
      bezier, coeffs = Fitting.iterate( pointlist, parameters )
      error = Fitting.error( bezier, pointlist, parameters ) / tlength
      parameters = Fitting.renormalize( bezier, coeffs, pointlist, parameters )

      # pointlist.length > 8 because matching with a bezier needs at least 4 points
      if (niter > maxiter and error > maxerror and pointlist.length > 8)
	pointlists = [pointlist[0..pointlist.length/2 - 1], pointlist[pointlist.length/2 - 1 ..-1]]
	beziers = []
	errors  = []
	pointlists.each do |subpointlist|
	  subbezier, suberror = Fitting.adaptative_compute( subpointlist, maxerror, maxiter, tlength )
	  beziers << subbezier
	  errors  << suberror
	end
	bezier = beziers.sum
	error  = errors.max
	break
      elsif (error < maxerror || niter > maxiter)
	break
      end
      perror = error
      niter += 1
    end
    return [bezier, error]
  end

  # algo comes from http://www.tinaja.com/glib/bezdist.pdf
  def Fitting.renormalize( bezier, coeffs, pointlist, parameters )
    a3, a2, a1, a0 = coeffs
    dxdu = Proc.new {|u| 3.0*a3.x*u**2 + 2.0*a2.x*u + a1.x}
    dydu = Proc.new {|u| 3.0*a3.y*u**2 + 2.0*a2.y*u + a1.y}
    container = V2D[]
    z    = Proc.new {|u,p4| p = bezier.point( u, container, :parameter ); (p.x - p4.x) * dxdu.call( u ) + (p.y - p4.y) * dydu.call( u )}
    newparameters = []
    [pointlist, parameters].forzip do |point, parameter|
      u1 = parameter
      if parameter < 0.99
	u2 = parameter + 0.01
      else
	u2 = parameter - 0.01
      end
      z1 = z.call(u1,point)
      z2 = z.call(u2,point)
      if z1 == z2
	u2 += 0.01
	z2 = z.call(u2,point)
      end
      if z1 == z2
	u2 -= 0.01
	z2 = z.call(u2,point)
      end
      newparameters << (z2 * u1 - z1 * u2)/(z2-z1)
    end
    return newparameters
  end
  
  # error is max error  between points in pointlist and points sampled from bezier with parameters
  def Fitting.error( bezier, pointlist, parameters )
    maxerror = 0.0
    container = V2D[]
    [pointlist, parameters].forzip do |point, parameter|
      # Trace("point #{point.inspect} parameter #{parameter}")
      error = (point - bezier.point( parameter, container, :parameter )).r
      if error > maxerror
	maxerror = error
      end
    end
    # Trace("Fitting.error #{maxerror}")
    return maxerror
  end

  # iterate method compute new bezier parameters from pointlist and previous bezier parameters
  # 
  # Algo comes from http://www.tinaja.com/glib/bezdist.pdf
  #
  # TODO : optimized
  def Fitting.iterate( pointlist, parameters )
    p0 = pointlist[0]
    p1 = pointlist[-1]

    sumt0 = parameters.map{ |t| t**0.0 }.sum
    sumt1 = parameters.map{ |t| t**1.0 }.sum
    sumt2 = parameters.map{ |t| t**2.0 }.sum
    sumt3 = parameters.map{ |t| t**3.0 }.sum
    sumt4 = parameters.map{ |t| t**4.0 }.sum
    sumt5 = parameters.map{ |t| t**5.0 }.sum
    sumt6 = parameters.map{ |t| t**6.0 }.sum

    psumt1 = [pointlist, parameters].forzip.foreach(2).map {|point, t| point * (t**1.0) }.inject(V2D::O){|sum, item| sum + item}
    psumt2 = [pointlist, parameters].forzip.foreach(2).map {|point, t| point * (t**2.0) }.inject(V2D::O){|sum, item| sum + item}
    psumt3 = [pointlist, parameters].forzip.foreach(2).map {|point, t| point * (t**3.0) }.inject(V2D::O){|sum, item| sum + item}

    coeff11 = sumt6 - 2 * sumt4 + sumt2
    coeff12 = sumt5 - sumt4 - sumt3 + sumt2

    coeff21 = coeff12
    coeff22 = sumt4 - 2 * sumt3 + sumt2

    result1 = (p0 - p1) * (sumt4 - sumt2) - p0 * (sumt3 - sumt1) + psumt3 - psumt1
    result2 = (p0 - p1) * (sumt3 - sumt2) - p0 * (sumt2 - sumt1) + psumt2 - psumt1
    
    matrix = Matrix[ [coeff11, coeff12], [coeff21, coeff22] ]
    matrixinv = matrix.inverse
    ax, bx = (matrixinv * Vector[result1.x, result2.x])[0..-1]
    ay, by = (matrixinv * Vector[result1.y, result2.y])[0..-1]

    a = V2D[ax, ay]
    b = V2D[bx, by]
    d = p0
    c = p1- (a + b + p0)

    piece = Fitting.bezierpiece( a, b, c, d )
    return [Bezier.raw( *piece ), [a, b, c, d] ]
  end    
end

end # end XRVG

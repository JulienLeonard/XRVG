require 'xrvg'
include XRVG

Range.O;                   #=> (0.0..1.0)
Range.Angle;               #=> (0.0..2*Math::PI)
(1.0..2.0).reverse;        #=> (2.0..1.0)
(1.0..2.0).sym;            #=> (0.0..2.0)
(1.0..2.0).symend;         #=> (1.0..3.0)
(1.0..2.0).size;           #=> 1.0
(1.0..2.0).translate(0.3); #=> (1.3..2.3)


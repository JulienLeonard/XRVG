require 'xrvg'
include XRVG

# Samplable module
(1.0..2.0).sample(0.5);      #=> 1.5
(1.0..2.0).samples( 3 );     #=> [1.0, 1.5, 2.0]
(1.0..2.0).mean;             #=> 1.5; equiv to sample(0.5)
(1.0..2.0).middle;           #=> alias for previous
(1.0..2.0).rand;             #=> random value in range
(1.0..2.0).rand( 2 );        #=> [rand1, rand2] in range
(1.0..2.0).complement(1.2);  #=> 1.8
(1.0..2.0).abscissa(1.2);    #=> 0.2; inverse of sample

# Splittable module
(1.0..2.0).split(0.2,0.3);    #=> (1.2..1.3)
(1.0..2.0).splits( 2 );       #=> [(1.0..1.5),(1.5..2.0)]


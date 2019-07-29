: $Id: izap.mod,v 1.3 2010/06/22 06:40:59 ted Exp $

COMMENT
izap.mod

Delivers an oscillating current that starts at t = del >= 0.
The frequency of the oscillation increases linearly with time
from f0 at t == del to f1 at t == del + dur, 
where both del and dur are > 0.

Uses event delivery system to ensure compatibility with adaptive integration.

Original implementation 12/4/2008 NTC
ENDCOMMENT

NEURON {
  POINT_PROCESS SinOsc
  RANGE  del, dur, freq, i, grampbar,eramp, rampg,rampi, ramppos, gsinbar,esin, sing, sini, sinphase,  bias, bias_i, noise, noisei
  : NONSPECIFIC_CURRENT i
  ELECTRODE_CURRENT i
}

UNITS {
  (nA) = (nanoamp)
  (umho) = (micromho)
  PI = (pi) (1)
}

PARAMETER {
  v		(mV)
  esin = -70 	(mV)
  del = 0		(ms)
  dur = 0		(ms)
  freq = 5		(1/s)  : frequency is in Hz
  gsinbar = 0.01 (umho)  
  sinphase = 90 : (1000/freq)/2

  grampbar = 0	(umho)
  eramp  = 0	(mV)
  ramppos = 1	(1)		: >0.5(right) / <0.5 (left)
  
  bias = 0 (nA)
  noise = 0 (nA)
  
}

ASSIGNED {
  on (1)

  
  i (nA)

  sini (nA)
  sing (umho)
  
  rampi (nA)
  rampg (umho)
  
  bias_i (nA)
  noisei (nA)
  
}

PROCEDURE seed(x) {
  set_seed(x)
}

INITIAL {
  i = 0
  on = 0
  sing = 0 
  sini = 0  
  rampg = 0 
  rampi = 0
  bias_i = 0
  
  while(sinphase < 0 || sinphase >360)  {
	if (sinphase < 0) { sinphase =sinphase+360 }
	if (sinphase > 360) { sinphase = sinphase-360 }		
  } 
  : do nothing if dur == 0
  if (dur>0) {
    net_send(del, 1)  : to turn it on and start frequency ramp
  }
  
}

COMMENT
The angular velocity in radians/sec is w = 2*PI*f, 
where f is the instantaneous frequency in Hz.

Assume for the moment that the frequency ramp starts at t = 0.
Then the angular displacement is
theta = 2*PI * ( f0*t + (f1 - f0)*(t^2)/(2*dur) ) 
      = 2*PI * t * (f0 + (f1 - f0)*t/(2*dur))
But the ramp starts at t = del, so just substitute t-del for every occurrence of t
in the formula for theta.
ENDCOMMENT

BEFORE BREAKPOINT { 
	noisei = noise * normrand(0,1)
}
BREAKPOINT {
  if (on==0)
  {
    i = 0
  }
  else
  {
    
	if (t > del && t < del+dur){
		: Ramp
		if (t <= del+dur*ramppos ) {		: Inc
			rampg = (grampbar / (dur*ramppos) ) * (t -del)
		} else {	: Dec
			rampg = -(grampbar / (dur*(1-ramppos)) ) * (t - del) + (grampbar / (dur*(1-ramppos)) ) * (dur)
		}		
		rampi = rampg * (eramp-v)
		
		sing = gsinbar + gsinbar * sin( 2*PI * (t-del +  ((1000/freq) * (sinphase/360))  ) * (freq) * (0.001) )					
		sini = sing*(esin-v)
		
		bias_i = bias
		
		
		i = rampi + sini + bias_i
	}
	else
	{
		sing = 0 
		sini = 0
		i=0
	}
  }
  i  = noisei + i 
		: printf("test %f uS * %f mV = %f nA / %f pA \n ",rampg, eramp-v, rampi, (eramp-v)*rampg*1e3)
  
}

NET_RECEIVE (w) {
  : respond only to self-events with flag > 0
  if (flag == 1) {
    if (on==0) {
      on = 1  : turn it on
      net_send(t+dur, 1)  : to stop frequency ramp, freezing frequency at f1
    } else {
      on = 0  : turn it off
    }
  }
}

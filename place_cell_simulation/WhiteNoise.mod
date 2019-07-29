NEURON {
  POINT_PROCESS WhiteNoise
  RANGE i,del,dur,std,bias
  ELECTRODE_CURRENT i
}

UNITS {
  (nA) = (nanoamp)
}

PARAMETER {
  del=0    (ms)
  dur=0   (ms)
  std=0.2   (nA)
  bias = 0 (nA)
}

ASSIGNED {
  i (nA)
  ival (nA)
  noise (nA)
  on (1)
}

INITIAL {
  i = 0
  on = 0
  
  net_send(del, 1)
  
}

PROCEDURE seed(x) {
  set_seed(x)
}

BEFORE BREAKPOINT {
	if  (on) {
		noise = std * normrand(0,1 )
		ival = noise + bias
	} else {
		ival = 0
	}  
}

BREAKPOINT {
  i = ival
}

NET_RECEIVE (w) {
  if (flag == 1) {
    if (on == 0) {
      : turn it on
      on = 1
      : prepare to turn it off
      net_send(dur, 1)
    } else {
      : turn it off
      on = 0
    }
  }
}
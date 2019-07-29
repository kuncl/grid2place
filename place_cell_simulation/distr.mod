TITLE ...just to store peak membrane voltage
: M.Migliore June 2001

UNITS {
	(mA) = (milliamp)
	(mV) = (millivolt)

}

PARAMETER {
	v (mV)
}


NEURON {
	SUFFIX ds
        RANGE vmax, vmin
}

ASSIGNED {
	vmax
	vmin
}

INITIAL {
	vmax=v
	vmin=v
}


BREAKPOINT {
	if (v>vmax) {vmax=v}
	if (v<vmin) {vmin=v}
}

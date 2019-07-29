: $Id: netstim.mod 2212 2008-09-08 14:32:26Z hines $
: comments at end

NEURON	{ 
  ARTIFICIAL_CELL VecStim0805
  RANGE start
  THREADSAFE : only true if every instance has its own distinct Random
}

PARAMETER {
	start		= 1 (ms)	: start of first spike
}

ASSIGNED {
	event (ms)
	ispike
	number
	space
	on
}

INITIAL {
	ispike = 0
	event = 0
	on = 0 
	nextevent() 
	
	if (on) {
		net_send(event,1)
	}
}	

PROCEDURE init_sequence(t(ms)) {
	VERBATIM 
	{
		void* vv;int i, size; double* px;
		i = (int)ispike;
		vv = *((void**)(&space));
		if (vv) {
			size = vector_capacity(vv);
			
			if (size > 0) {
				on = 1;
				event = 0;
				ispike = 0;
				
			}
		} else {
				on = 0;
		}		
	}
	ENDVERBATIM
}

NET_RECEIVE (w) {
	if (flag == 1) {
		ispike = ispike + 1
		net_event(t)
		nextevent()
		if (on) {
			net_send(event,1)
		}
	} 
	if (flag ==3) {
		if (on == 1) {
			init_sequence(t)
			net_send(0,1)
		}
	}
}

VERBATIM
extern double* vector_vec();
extern void* vector_arg();
extern int vector_capacity(void* vv);
ENDVERBATIM

PROCEDURE nextevent() {
	VERBATIM 
	{
		void* vv;int i, size; double* px;
		i = (int)ispike;
		vv = *((void**)(&space));
		if (vv) {
			size = vector_capacity(vv);
			
			if (i < size) {
				px=vector_vec(vv);
				// printf("Next Event =%f / %d \n",px[i],size);
				
				event = px[i]+start-t;
				on = 1;
			} else {
				on = 0;
			}
		} else {
				on = 0;
		}
		
	}
	ENDVERBATIM

}

PROCEDURE src() {
VERBATIM
	void** vv;
	vv = (void**)(&space);
	*vv = (void*)0;
	if (ifarg(1)) {
		*vv = vector_arg(1);
	}
ENDVERBATIM

}



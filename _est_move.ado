* Move a previously named store to a new name
program define _est_move
	version 13
	syntax name(name=from id="store to move" local), to(name local)
	tempname current
	estimates store `current' // hold current estimates
	quietly estimates restore `from' //re-store
	estimates store `to'
	estimates drop `from'  // clear name
	quietly estimates restore `current'
	estimates drop `current'
end

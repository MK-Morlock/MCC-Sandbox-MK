//by Bon_Inf*
// INPUT: x-coord, y-coord, direction, distance, height difference
// OUTPUT: the vector of [x-coord,y-coord] + distance in the direction

params ["_xpos", "_ypos", "_dir", "_dist", "_height"];


// using Pythagoras' a^2+b^2=c^2 to compensate height dispersion
_actualdistance = sqrt (_dist^2 - _height^2);

// getting what we want:
_newpos = [round (_xpos + _actualdistance*sin(_dir)), round (_ypos + _actualdistance*cos(_dir)),0];


_newpos
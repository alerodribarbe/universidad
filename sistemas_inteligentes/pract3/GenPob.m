function Poblacion=GenPob(NPob, Nobjetos)
%function Poblacion=GenPob(NPob, NIND)
R=rand(NPob,Nobjetos);
Poblacion=R>0.5;%genera una matriz de todos los individuos con cada mochila
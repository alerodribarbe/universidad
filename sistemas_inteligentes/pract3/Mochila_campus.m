
%%% DATOS DEL  PROBLEMA
%%Datos Mochila de Clase
clear all
Pesos=[     150   100   400    180  500  1500  500    450   380   250   250   80  20  60   45  200];
Beneficios=[10    10     7     2     3     8     5     9     3     5     7     4   8  10   8    9];
cMax=2500;  %%Capacidad maxima permitida 2,5 kg
Minimo=90;  %%Beneficio minimo deseado


function [mejorFitness mejorIndividuo ] = MochilaAG(Pesos,Beneficios,cMax,Minimo)
% poblacion inicial
N=length(Pesos);  %% Número de objetos
NInd = 8;  %% Número de individuos de la población (empezamos con uno bajo para controlar el proceso)
pobActual = GenPob(NInd, N);
Fitness=EvalPob(pobActual,Pesos,Beneficios,cMax);

MAXGEN = 3;  %% Número máximo de generaciones que se iterará
mejorIndividuo=zeros(MAXGEN,N);
mejorFitness=zeros(MAXGEN,1);
Pcross=0.9;
Pmut=0.1;

gen = 1;                     
while (gen < MAXGEN)  %% Añadir condiciones de parada
    
    [mejorFitness(gen),indi] = max(Fitness);
    mejorIndividuo(gen,:) = pobActual(indi,:);
    
    %% Seleccionar los mejores candidatos
    k=3;
    Parejas=Torneo(Fitness,k,NInd);
    
    %% Cruzar
    pobCross=Cruce(pobActual,Parejas,Pcross);
    
    %% Mutar  
    pobMut = Mutacion(pobCross,Pmut);
    fitMut=EvalPob(pobMut,Pesos,Beneficios,cMax);
    
    %% Reemplazar
    [pobActual,Fitness]=Reemplazo(pobMut,pobActual,fitMut,Fitness);
    
    
    gen=gen+1;
end

gen
max(mejorFitness)
end
    


function mejores_parejas=Torneo(Fitness,k)
mejores_parejas=zeros(1,length(Fitness));
mejorfit=0;
for i=1:NInd
    for j=1:k
    e1 = randi([1 length(Fitness)]);
    if(Fitness(e1)>mejorfit)
        mejorfit=Fitness(e1);
        ind=e1;
    end
    mejores_parejas(i)=ind;
    end
end
end


function pobCross=Cruce(pobActual,SEMENTALES,Pcross)

hijos=zeros(1,length(SEMENTALES));
machos_hebras=reshape(SEMENETALES,4,2);

for i=1:length(SEMENTALES)
    macho=machos_hembras(i,1);
    hembra=mahcos_hembras(i,2);

    corte=randi([1 length(macho)-1]);

    hijo1=[macho([1:corte]),hembra([corte+1:end])];
    hijo2=[hembra([1:corte]),macho([corte+1:end])];
    hijos(2*i-1,:) = hijo1;
    hijos(2*i,:) = hijo2;
end










end
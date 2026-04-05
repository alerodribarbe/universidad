


function [ best_sol , best_cost , log , num_gens ] =solve_bin_ga( dist , slope , speed , time_s , accel , bus_stop , params, time_limit )
n = length(dist);


 % --- 2. Initialise population ---
 pop_size = 50;
 

% Genera la matriz usando una distribución uniforme y convierte a double (0 o 1)
pop = rand(pop_size, n) < 0.2;
 best_cost = inf;
 best_sol = zeros (1 , n ) ;
 log = [];
 num_gens = 0;
 t_start = tic;
 Pcross=1;
 Pmut=1/n;
 
 matriz_costes=PrecalcularCostes(dist, slope, speed, time_s, accel, params);
 
 while toc( t_start ) < time_limit - 0.5

 num_gens = num_gens + 1;

 % --- 3. Evaluate population
 population_ev=EvalPob(pop, matriz_costes, params);  %%PUEDE QUE LO TENGA QUE SACAR DEL BUCLE
 % --- 4. Selection
 k=3;
 padres=Torneo(population_ev,k);
 % --- 5. Crossover
 hijos_cruzados=cruce(pop,padres,Pcross);
 % --- 6. Mutation
 hijos_mutados=Mutacion(hijos_cruzados,Pmut);
 % --- 7. Elitism :

 poblacion_nueva=Elitismo(population_ev,pop, hijos_mutados);

 % --- 8. Update best ---


ev_nueva=EvalPob(poblacion_nueva,matriz_costes, params);
%ev_nueva = ev_nueva(:)'; 
[coste, idx] = min(ev_nueva);

if coste<best_cost
    best_cost = coste; 
    best_sol = poblacion_nueva(idx, :);
end

 log(num_gens) = best_cost;
 pop=poblacion_nueva;

 end
  fprintf('PMUT %f\n', Pmut);

end


function valor_CO2 = EvalPob(pop, coste_base, params)
    
    khw = ((pop * coste_base) / params(12))/3600;   %los 1 son electrico
    
    valor_CO2 = ((1 - pop) * coste_base); % los 1 pasan a ser 0 y los 0->1
    
    khw = khw';

    valor_CO2 = valor_CO2';
    
    % Aplicar restricciones de batería
    indices = khw > params(8); 
    valor_CO2(indices) = Inf; % Los que sobrepasen la batería se eliminan
    
end

function mejores_parejas = Torneo(Fitness, k)
    n = length(Fitness);
    % Generamos una matriz [k x n] con índices aleatorios de competidores
    competidores = randi(n, k, n); 
    
    % Buscamos el índice del mínimo (el mejor) en cada columna de competidores
    [~, idx_min] = min(Fitness(competidores)); 
    
    % Extraemos los ganadores
    lineal_idx = sub2ind([k, n], idx_min, 1:n);
    mejores_parejas = competidores(lineal_idx);
end



function hijos=cruce(pobActual,elegidos,Pcross)
hijos = zeros(length(pobActual), size(pobActual, 2));
for i=1:2:length(elegidos)

    macho=pobActual(elegidos(i), :);  %cogemos la fila entera
    hembra=pobActual(elegidos(i+1), :); %cogemos la fila entera
    corte=randi([1, length(macho)-1]);

    hijo1 = [macho(1:corte), hembra(corte+1:end)];
    hijo2 = [hembra(1:corte), macho(corte+1:end)];
    hijos(i,:) = hijo1;
    hijos(i+1,:) = hijo2;
end

end


function pobmutada = Mutacion(hijos_cruzados, Pmut)
    % Creamos una matriz de números aleatorios del mismo tamaño que la población.
    % Si el número es menor que Pmut, ponemos un 1 lógico (verdadero).
    mascara_mutacion = rand(size(hijos_cruzados)) < Pmut;
    
    pobmutada = hijos_cruzados;
  
    pobmutada(mascara_mutacion) = ~pobmutada(mascara_mutacion);
end


function pobcambiada = Elitismo(punt_pop_antigua, pop, hijos_mutados)
   
    pobcambiada = hijos_mutados;
    
    [~, pos_padres] = sort(punt_pop_antigua, 'ascend');
    
    nuevos=length(punt_pop_antigua)*0.5;
    for i =1:nuevos

        pobcambiada(i, :) = pop(pos_padres(i), :);
    end
   


end





function coste_base = PrecalcularCostes(dist, slope, speed, time_s, accel, params)
    m = length(dist);
    coste_base = zeros(m, 1); % Vector columna [m x 1]
    
    for j = 1:m
        coste_base(j) = segment_kgCO2(dist(j), slope(j), speed(j), time_s(j), accel(j), params);
    end
end
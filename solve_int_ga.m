function [best_sol, best_cost, log, num_gens] = solve_int_ga(M_maquinas, M_tiempos, time_limit)

[J, M] = size(M_maquinas);

% --- 1. Compute number of operations per job ---
n_ops = sum(M_maquinas > 0, 2)'; % 1xJ vector de numero de operaciones de cada trabajo
N_op = sum(n_ops); % total operaciones

% --- 2. Build base chromosome (unshuffled) ---
base=[];
for j = 1:J
    base = [base, repmat(j, 1, n_ops(j))];
end

% --- 3. Initialise population ---
pop_size = 50;
pop = zeros(pop_size, N_op);
for i = 1:pop_size
    pop(i,:) = base(randperm(N_op));
end
fitness=evalPob(pop,M_tiempos,M_maquinas);
best_cost = Inf;
best_sol = base;
log = [];
num_gens = 0;
t_start = tic;

while toc(t_start) < time_limit - 0.5
    num_gens = num_gens + 1;

    % --- 5. Selection ---

    k = round(pop_size*0.03);
    padres=torneo(fitness,k);

    % --- 6. Crossover (e.g. OX, PMX) ---

    hijos=JOX(pop,padres);

    % --- 7. Mutation (e.g. swap, insert) ---
    Pmut=0.3;
    hijos_mutados=mutation(hijos,Pmut);

    % --- 8. Elitism ---

    [mejores_padres_hijos,fitness_nuevo]=elitism(pop,hijos_mutados,fitness,M_maquinas,M_tiempos);

    % --- 9. Update best ---
    [coste, idx] = min(fitness_nuevo);

    log(end+1) = best_cost;

    if coste<best_cost
    best_cost = coste; 
    best_sol = mejores_padres_hijos(idx, :);
    end

   pop=mejores_padres_hijos;

end

end



function Fitness=evalPob(pop,M_tiempos,M_maquinas)

[NIND,~]=size(pop);
Fitness=zeros(1,NIND);
for i=1:NIND
    Fitness(i)=makespan(pop(i,:),M_tiempos,M_maquinas);
end

end

function cMax = makespan(chromosome, times, machines)
    [njobs, nmachines] = size(machines);

    job_time = zeros(1, njobs);
    machine_time = zeros(1, nmachines);
    op_count = zeros(1, njobs);

    for i = 1:length(chromosome)
        j = chromosome(i);

        op_count(j) = op_count(j) + 1;
        
        k = op_count(j);

        m = machines(j, k);

        d = times(j, k);

        s = max(job_time(j), machine_time(m));

        job_time(j) = s + d;

        machine_time(m) = s+d;
    end

    cMax = max(job_time);
end

function mejores_parejas = torneo(Fitness, k)
    n = length(Fitness);
    % Generamos una matriz [k x n] con índices aleatorios de competidores
    competidores = randi(n, k, n); 
    
    % Buscamos el índice del mínimo (el mejor) en cada columna de competidores
    [~, idx_min] = min(Fitness(competidores)); 
    
    % Extraemos los ganadores
    lineal_idx = sub2ind([k, n], idx_min, 1:n);
    mejores_parejas = competidores(lineal_idx);
end

function childs = JOX(pop, parentsIdxs)
    
    [pop_size, n] = size(pop);
    childs = zeros(pop_size, n);
    
    % Cruzamos cada pareja del bucle, lo recorremos de 2 en 2
    for i = 2:2:length(parentsIdxs)
        
        % Cogemos los padres
        father = pop(parentsIdxs(i-1), :);
        mother = pop(parentsIdxs(i), :);

        % Seleccionamos aleatoriamente un trabajo 'job' del padre
        job = father (round(length(father)/2));

        % Localizamos las posiciones diferentes a job en cada padre
        not_jobIdxs = [find(father~=job); find(mother~=job)];

        % Creamos los 2 hijos
        childx = father;
        childx(not_jobIdxs(1, :)) = mother(not_jobIdxs(2, :));

        childy = mother;
        childy(not_jobIdxs(2,:)) = father(not_jobIdxs(1, :));

        childs(i-1, :) = childx;
        childs(i, :)   = childy;
    end
end

function hijos_mutados = mutation(hijos, pMut)
    
    [pop_size, n] = size(hijos);

    hijos_mutados=hijos;

    % Para cada hijo, decidimos si se muta o no de forma independiente
    for i = 1:pop_size

        % El azar y la probabilidad deciden si se muta cada individuo
        if rand() < pMut   
            % Seleccionamos 2 posiciones diferentes al azar
           idx = randperm(n, 2); j = idx(1); k = idx(2); 
            hijos_mutados(i, [j,k]) = hijos_mutados(i, [k, j]);

        end
    
    end
        
end

function [new_pop, new_fitnesses] = elitism(pop, childs, fitnesses, M_maquinas, M_tiempos)
    
    % 1. Mezclamos los indivíduos
    pop = [pop; childs]; % Mezclamos los indivíduos (los concatenamos)
    
    % 2. Ordenamos los indivíduos en fundión de su fitness

    % Aprovechamos los que ya teníamos calculados y evaluamos los nuevos
    fitnesses = [fitnesses evalPob(childs, M_tiempos, M_maquinas)];

    [~, bestIdxs] = mink(fitnesses, length(fitnesses)/2); % Nos quedamos solo con los indices

    % 3. Machacamos los peores indivíduos
    new_fitnesses = fitnesses(bestIdxs);
    new_pop = pop(bestIdxs, :);
end







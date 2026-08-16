function [best_tour , best_dist , log] = solve_tsp_sa(coords , max_time)

n = size(coords, 1);  %numero de ciudedes

log = [];   %en cada iteracion guardamos la distancia de best_tour
cont_iteraciones=1;

distancias=generacion(coords); %matriz de distancias de ciudades

current_tour = randperm(n);         
current_dist = fDist(current_tour, distancias);
best_tour = current_tour;                        
best_dist = current_dist;  

    T     = 1000000; %tempreatura max
    T_min = 0.00001; %temp min
    alpha = 0.99;   
tic;
while (max_time > toc) && (T > T_min)

    sucesor=randomsuccesor2_opt(current_tour);

    new_dist = fDist(sucesor, distancias);
    deltaE = new_dist - current_dist;

    if(deltaE<=0)  %miramos si el candidato es mejor
        current_tour=sucesor; %cogemos si el canidato es mejor
        current_dist=new_dist;

            if current_dist < best_dist
                best_tour = current_tour;
                best_dist = current_dist;
            end
    else
        if rand() < exp(-deltaE / T)
        current_tour=sucesor;    %vemos aleatoriamente si cogemos o no
        current_dist=new_dist;

        end   
    end
    
    log(cont_iteraciones)=best_dist; %añadimos la mejor distancia de esta iteracion

    cont_iteraciones=cont_iteraciones+1;

    T = T * alpha; %enfriamos
 end
end



%FUNCION EUCLIDEA
function d=euclidea(a,b)
    d=sqrt((a(1) - b(1))^2 + (a(2) - b(2))^2);
end



%FUNCION PARA GENERAR LA MATRIZ
function matriz=generacion(coords)
n=length(coords);
matriz=zeros(n);
    for i = 1:n
        for j = 1:n
            a =[coords(i,1), coords(i,2)];
            b = [coords(j,1), coords(j,2)];

            matriz(i, j) = euclidea(a, b);
        end
    end

end


%FUNCION PARA CALCULAR LA DISTANCIA DE UN RECORRIDO
function dist=fDist(tour,distancias)
dist=0;
for i=1:length(tour)-1
    dist=dist + distancias(tour(i),tour(i+1));
end
    dist=dist+distancias(tour(1),tour(length(tour)));

end


%FUNCION PARA GENERAR EL SUCESOR RANDOM A TRAVES DE 2-OPT
function tour = randomsuccesor2_opt(best_tour)

    tour=best_tour;
    n = length(best_tour);
    i = randi([1, n]);
    j=  randi([1, n]);

    if i>j
       [i, j] = deal(j, i);
    end
    tour(i+1:j) = tour(j:-1:i+1);
end


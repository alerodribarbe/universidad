function [ best_tour , best_dist , log ] = solve_qap_tabu (F,D,max_time )
n = size(F, 1);  %numero de ciudedes


current_tour = randperm(n);   %camino aleatorio      
current_dist = fDist(current_tour,F,D);%calculamos distancia
best_tour = current_tour;                        
best_dist = current_dist; 

log(1) = best_dist;  %en cada iteracion guardamos la distancia de best_tour
cont_iteraciones=1; %contador de iteraciones
max_iteraciones=15; %maxima iteraciones
tabu = zeros(1,n);
tenancia=5;

tic;

while (max_time > toc) && cont_iteraciones < max_iteraciones

    list_succesor=obtenersucesores(current_tour,F,D); %generemaos todos los posibles sucesores
   
    
   for i=1:n*(n-1)/2

        new=list_succesor(i ,1:n);
        ciudad_i = list_succesor(i, n+1);
        ciudad_j = list_succesor(i, n+2);
        new_dist=list_succesor(i,n+3);%cogemos su coste
        
        if(new_dist<best_dist)  %si mejora la distancia lo cogemos aunque sea tabu
            current_tour = new;
            current_dist = new_dist;
            best_tour = new;
            best_dist = new_dist;
            tabu([ciudad_i ciudad_j]) = [tenancia tenancia];
            break;
     

        elseif( all(tabu([ciudad_i ciudad_j]) == 0))  %si no mejora miramos si esta en tabu
            current_tour=new;
            current_dist=new_dist;
            tabu([ciudad_i ciudad_j]) = [tenancia tenancia];
            break;
        end
    end
    cont_iteraciones = cont_iteraciones + 1; % 
    log(cont_iteraciones)=best_dist;
    tabu = max(tabu - 1, 0);
   
 end

end




%FUNCION PARA CALCULAR LA DISTANCIA DE UN RECORRIDO
function dist=fDist(tour,F,D)
dist=0;
n=length(tour);
for i=1:n
    for j=1:n
    dist=dist + F(i,j)*D(tour(1,i),tour(1,j));
    end
end
end



%FUNCION PARA GENERAR EL SUCESOR RANDOM A TRAVES DE 2-OPT
function tour_list = obtenersucesores(tour,F,D)

n=length(tour);
num_sucesores = (n * (n - 1)) / 2;
tour_list = zeros(num_sucesores, n + 3);
fila_actual=1;

for i = 1:n
        for j = (i+1):n

            sucesor=tour;

            aux=sucesor(i);
           sucesor(i)=sucesor(j);
            sucesor(j)=aux;

            cost=fDist(sucesor,F,D);
            tour_list(fila_actual, :) = [sucesor, i, j, cost]; %añadimos
            
      
            fila_actual = fila_actual + 1; %actualizamos fila
            
  
        end     
end
tour_list = sortrows(tour_list,n+3);% Ordenamos por coste
end

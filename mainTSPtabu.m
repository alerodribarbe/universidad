clc; clear; close all;
fclose('all');

%% 1. BUSCAR ARCHIVOS DE PRUEBA
carpeta_instancias = 'instances';
if ~exist(carpeta_instancias, 'dir')
    mkdir(carpeta_instancias);
end

archivos = dir(fullfile(carpeta_instancias, 'tsp_*.txt'));

% SALVACAÍDAS: Si no hay archivos, creamos 3 de prueba automáticamente
if isempty(archivos)
    warning('No se encontraron archivos en "instances/tsp_*.txt". ¡Creando casos de prueba aleatorios!');
    writematrix(rand(12,2)*100, fullfile(carpeta_instancias, 'tsp_12_ciudades.txt'), 'Delimiter', '\t');
    writematrix(rand(25,2)*100, fullfile(carpeta_instancias, 'tsp_25_ciudades.txt'), 'Delimiter', '\t');
    writematrix(rand(40,2)*100, fullfile(carpeta_instancias, 'tsp_40_ciudades.txt'), 'Delimiter', '\t');
    archivos = dir(fullfile(carpeta_instancias, 'tsp_*.txt'));
end

fprintf('Se han detectado %d archivos de prueba.\n\n', length(archivos));
nombres_archivos = cell(1, length(archivos));
costes_finales = zeros(1, length(archivos));

%% 2. TIEMPO SEGÚN TAMAÑO (Número de ciudades)
%% 2. TIEMPO SEGÚN TAMAÑO (Número de ciudades)
function t = get_tiempo(n)
    t = 10; % Limita cualquier mapa a 10 segundos exactos
end

%% 3. BUCLE PRINCIPAL
for i = 1:length(archivos)
    nombre = archivos(i).name;
    carpeta = archivos(i).folder;
    ruta_completa = fullfile(carpeta, nombre);
    nombres_archivos{i} = nombre;
    
    % Cargar coordenadas con nuestro lector a prueba de bombas
    coords = leer_coordenadas(ruta_completa);
    if isempty(coords)
        fprintf('Error grave: No se pudo leer %s o el archivo está vacío.\n', ruta_completa);
        continue;
    end
    
    n = size(coords, 1);
    tiempo_maximo = get_tiempo(n);
    
    fprintf('======================================================\n');
    fprintf('Procesando: %s (n=%d ciudades) durante %d segundos...\n', nombre, n, tiempo_maximo);
    
    % LLAMADA A TU FUNCIÓN TSP
    [best_tour, best_dist, log_dist] = solve_tsp_tabu(coords, tiempo_maximo);
    
    costes_finales(i) = best_dist;
    fprintf('-> ¡Completado! Mejor distancia: %.2f\n', best_dist);
    
    % DIBUJAR RESULTADOS
    figure('Name', sprintf('Resultados para %s', nombre), 'Color', 'w', 'Position', [100, 100, 1000, 450]);
    
    % --- Subplot 1: Evolución del coste ---
    subplot(1, 2, 1);
    plot(log_dist, 'b-', 'LineWidth', 2);
    xlabel('Iteraciones'); ylabel('Distancia (Coste)');
    title(sprintf('Evolución Tabú - %s', nombre));
    grid on;
    
    % --- Subplot 2: Mapa de la ruta ---
    subplot(1, 2, 2);
    
    % Reordenar las coordenadas según el mejor tour, añadiendo el origen al final para cerrar el ciclo
    tour_coords = coords([best_tour, best_tour(1)], :); 
    
    % Dibujar líneas de la ruta
    plot(tour_coords(:, 1), tour_coords(:, 2), 'k-', 'LineWidth', 1.5); 
    hold on;
    
    % Dibujar las ciudades
    plot(coords(:, 1), coords(:, 2), 'ro', 'MarkerSize', 4, 'MarkerFaceColor', 'r'); 
    
    % Resaltar la ciudad de inicio (verde)
    plot(coords(best_tour(1), 1), coords(best_tour(1), 2), 'gs', 'MarkerSize', 8, 'MarkerFaceColor', 'g'); 
    
    xlabel('Coordenada X'); ylabel('Coordenada Y');
    title(sprintf('Mejor Ruta - Distancia: %.2f', best_dist));
    legend('Ruta', 'Ciudades', 'Inicio/Fin', 'Location', 'best');
    axis equal; 
    grid on;
    hold off;
    
    drawnow;
end

%% 4. RESUMEN
fprintf('\n======================================================\n');
fprintf('                 RESUMEN DE EJECUCIÓN                 \n');
fprintf('======================================================\n');
for i = 1:length(archivos)
    % Verificamos si realmente se procesó (coste > 0)
    if costes_finales(i) > 0
        fprintf(' Archivo: %-20s | Mejor Distancia: %.2f\n', nombres_archivos{i}, costes_finales(i));
    else
        fprintf(' Archivo: %-20s | ERROR AL LEER\n', nombres_archivos{i});
    end
end
fprintf('======================================================\n');

%% --- FUNCIÓN AUXILIAR PARA LEER ARCHIVOS TSP IGNORANDO TEXTO ---
function coords = leer_coordenadas(ruta)
    coords = [];
    fid = fopen(ruta, 'r');
    if fid == -1
        return; 
    end
    
    while ~feof(fid)
        linea = fgetl(fid);
        
        % Ignorar líneas vacías
        if isempty(strtrim(linea))
            continue;
        end
        
        % Intentamos convertir la línea a números
        valores = str2num(linea); %#ok<ST2NM>
        
        % Si la línea tiene al menos 2 números, asumimos que tiene coordenadas
        if length(valores) >= 2
            % Nos quedamos con las dos últimas columnas (X e Y)
            coords = [coords; valores(end-1:end)]; 
        end
    end
    fclose(fid);
end
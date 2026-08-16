clc; clear; close all;
fclose('all');

%% 1. BUSCAR TODOS LOS ARCHIVOS DE PRUEBA
archivos = dir('instances/qap_*.txt');

if isempty(archivos)
    error('No se encontraron archivos. Asegúrate de que el script está en la misma carpeta que los .txt');
end

fprintf('Se han detectado %d archivos de prueba.\n\n', length(archivos));

nombres_archivos = {};
costes_finales = zeros(1, length(archivos));

%% 2. TIEMPO SEGÚN TAMAÑO
    function t = get_tiempo(n)
        if     n <= 15,  t = 10;
        elseif n <= 25,  t = 10;
        elseif n <= 40,  t = 10;
        elseif n <= 60,  t = 10;
        else,            t = 10;
        end
    end

%% 3. BUCLE PRINCIPAL
for i = 1:length(archivos)
    nombre = archivos(i).name;
    carpeta = archivos(i).folder;
    ruta_completa = fullfile(carpeta, nombre);
    nombres_archivos{i} = nombre;

    fid = fopen(ruta_completa, 'r');
    if fid == -1
        fprintf('Error grave: No se pudo abrir %s\n', ruta_completa);
        continue;
    end

    n = fscanf(fid, '%d', 1);
    F = fscanf(fid, '%f', [n, n])';
    D = fscanf(fid, '%f', [n, n])';
    fclose(fid);

    tiempo_maximo = get_tiempo(n);

    fprintf('======================================================\n');
    fprintf('Procesando: %s (n=%d) durante %d segundos...\n', nombre, n, tiempo_maximo);

    [best_perm, best_cost, log_costes] = solve_qap_tabu(F, D, tiempo_maximo);

    costes_finales(i) = best_cost;
    fprintf('-> ¡Completado! Mejor coste: %.2f\n', best_cost);

    figure('Name', sprintf('Resultados para %s', nombre), 'Color', 'w', 'Position', [100, 100, 1000, 450]);

    subplot(1, 2, 1);
    plot(log_costes, 'b-', 'LineWidth', 2);
    xlabel('Iteraciones'); ylabel('Coste');
    title(sprintf('Evolución Tabu - %s', nombre));
    grid on;

    subplot(1, 2, 2);
    % Matriz de coste por par: contribución de cada par (i,j) a la solución
    cost_matrix = zeros(n, n);
    for ii = 1:n
        for jj = 1:n
            cost_matrix(ii, jj) = F(ii, jj) * D(best_perm(ii), best_perm(jj));
        end
    end
    imagesc(cost_matrix);
    colorbar;
    colormap(gca, hot);
    xlabel('Facilidad j'); ylabel('Facilidad i');
    title(sprintf('Contribución al coste por par - Total: %.2f', best_cost));
    axis square;

    drawnow;
end

%% 4. RESUMEN
fprintf('\n======================================================\n');
fprintf('                 RESUMEN DE EJECUCIÓN                 \n');
fprintf('======================================================\n');
for i = 1:length(archivos)
    fprintf(' Archivo: %-15s | Mejor Coste: %.2f\n', nombres_archivos{i}, costes_finales(i));
end
fprintf('======================================================\n');
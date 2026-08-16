clc, clear all, close all;

% Limpia la consola, borra variables del workspace y cierra figuras

rand('seed', 0);    % Fija la semilla del generador aleatorio uniforme (reproducibilidad)
randn('seed', 0);   % Fija la semilla del generador aleatorio gaussiano



% a) Método LOO (Leave-One-Out). Para esta técnica, el código es prácticamente
% igual, ya que LOO es igual que CV de orden igual al número de datos


x = rand(1, 10);
% Vector de 1.000.000 puntos aleatorios 

y = exp(x.^3 - x.^2 + 0.01*x + 2) + 0.04 * randn(size(x));
% Variable dependiente: función no lineal de x + ruido gaussiano pequeño (σ=0.04)

Error = zeros(1, 5);
% Vector para acumular el error de cada uno de los 5 modelos

K_CV = 10;
% Número de particiones (folds) 


for k = 1:K_CV

    [xtrn, xtst, ytrn, ytst] = crossval(x, y, K_CV, k);
    for i = 1:5 %5modelos

        if i <= 3
            % MODELOS 1, 2, 3 → Polinomios de grado i 
            p = polyfit(xtrn, ytrn, i);       
            yestim = polyval(p, xtst);        

        elseif i == 4
            A = [sin(xtrn(:)), xtrn(:).^3, xtrn(:).^2, xtrn(:), ones(length(xtrn),1)];
            % Matriz de diseño: cada columna es una función base evaluada en xtrn
            coef1 = pinv(A) * ytrn';           % Pseudoinversa → mínimos cuadrados
            yestim = coef1(1)*sin(xtst(:)) + coef1(2)*xtst(:).^3 + coef1(3)*xtst(:).^2   + coef1(4)*xtst(:) + coef1(5);

        elseif i == 5
            B = [cos(xtrn(:)), sin(xtrn(:)), xtrn(:).^3, xtrn(:).^2, xtrn(:), ones(length(xtrn),1)];
            coef2 = pinv(B) * ytrn';           % Pseudoinversa → mínimos cuadrados
            yestim = coef2(1)*cos(xtst(:)) + coef2(2)*sin(xtst(:)) + coef2(3)*xtst(:).^3   + coef2(4)*xtst(:).^2 + coef2(5)*xtst(:)      + coef2(6);
        end

        % Acumula el error cuadrático (suma de (estimado - real)²) para este modelo
        Error(i) = Error(i) + sumsqr(yestim(:) - ytst(:));
    end
end

fprintf('Error de LOO:\n')
Error = Error / K_CV
% Promedia el error acumulado entre los 10 folds → error medio por modelo


% b) Random sampling. Para esta técnica usa un bucle que realice 1000 iteraciones de
% una validación simple al 75% (75% de los datos para entrenar el modelo, y el
% 25% restante para estimar el error)

N=100;
x = rand(1, N);
% Vector de X puntos aleatorios 

y = exp(x.^3 - x.^2 + 0.01*x + 2) + 0.04 * randn(size(x));
% Variable dependiente: función no lineal de x + ruido gaussiano pequeño (σ=0.04)

Error = zeros(1, 5);
% Vector para acumular el error de cada uno de los 5 modelos

Iterations = 1000;
% Número de particiones (folds) 


for k = 1:Iterations

    [x,y] = shuffle(x,y);

    xtrn = x(1:N*0.75); 
    ytrn=y(1:N*0.75);
    xtst = x(N*0.75+1:N); 
    ytst=y(N*0.75+1:N);

    for i = 1:5 %5modelos

        if i <= 3
            % MODELOS 1, 2, 3 → Polinomios de grado i 
            p = polyfit(xtrn, ytrn, i);       
            yestim = polyval(p, xtst);        

        elseif i == 4
            A = [sin(xtrn(:)), xtrn(:).^3, xtrn(:).^2, xtrn(:), ones(length(xtrn),1)];
            % Matriz de diseño: cada columna es una función base evaluada en xtrn
            coef1 = pinv(A) * ytrn';           % Pseudoinversa → mínimos cuadrados
            yestim = coef1(1)*sin(xtst(:)) + coef1(2)*xtst(:).^3 + coef1(3)*xtst(:).^2   + coef1(4)*xtst(:) + coef1(5);

        elseif i == 5
            B = [cos(xtrn(:)), sin(xtrn(:)), xtrn(:).^3, xtrn(:).^2, xtrn(:), ones(length(xtrn),1)];
            coef2 = pinv(B) * ytrn';           % Pseudoinversa → mínimos cuadrados
            yestim = coef2(1)*cos(xtst(:)) + coef2(2)*sin(xtst(:)) + coef2(3)*xtst(:).^3   + coef2(4)*xtst(:).^2 + coef2(5)*xtst(:)      + coef2(6);
        end

        % Acumula el error cuadrático (suma de (estimado - real)²) para este modelo
        Error(i) = Error(i) + sumsqr(yestim(:) - ytst(:));
    end
end

fprintf('Error de Random Sampling:\n')
Error = Error / Iterations

% a) Leer los datos de la base de datos de calidad del vino tinto almacenados
% en la base de datos "Wine Quality".

% b) Resolver el problema de regresión GLM que estima el valor de la calidad
% del vino en función del resto de parámetros.

% c) Calcular el error medio en la estimación de la calidad del vino que se
% comete sobre los datos disponibles.


datos = readtable('winequality-red.csv');

matriz_datos = table2array(datos);
 
y=datos.quality;

A = [matriz_datos(:, 1:11) (ones(size(matriz_datos, 1), 1))];

coefs = pinv(A)*y;
yestim = A*coefs;
yestim=round(yestim);

%ERROR

r=y-yestim;
E=r'*r;
E=E/length(matriz_datos)  %ERROR MEDIO

plot(y,'.r');hold on;
plot(yestim,'.b');hold off



clc, clear all, close all;

rand('seed', 0);
randn('seed', 0);
x = rand(1,100); %generamos los numeros
y = exp(x.^3 - x.^2 + 0.01*x + 2) + 0.04 * randn(size(x)); 

Error = zeros(1,5); %vector que contendra nuestro error

K_CV = 10;

  for k=1:K_CV
    [xtrn,xtst,ytrn,ytst] = crossval(x,y,K_CV,k);
    for i=1:5 %bucle para cada uno de los modelos
        if i<=3
      p=polyfit(xtrn,ytrn,i);     %para el modelo 1,2,3 usamos pplyfitt ya que son polinomicos       
      yestim = polyval(p,xtst);
        elseif i==4  %modelo 4 usamos sen(x) y sacamos los coeficientes
            A=[sin(xtrn(:)), xtrn(:).^3 ,xtrn(:).^2,xtrn(:),ones(length(xtrn),1)];
            coef1=pinv(A)*ytrn';
            yestim = coef1(1)*sin(xtst(:)) + coef1(2)*xtst(:).^3 + coef1(3)*xtst(:).^2 + coef1(4)*xtst(:) + coef1(5);

        elseif i==5  %modelo 5 tenemos sen y cos igual que el anterior
            B=[cos(xtrn(:)),sin(xtrn(:)), xtrn(:).^3 ,xtrn(:).^2,xtrn(:),ones(length(xtrn),1)];
            coef2=pinv(B)*ytrn';
            yestim = coef2(1)*cos(xtst(:)) + coef2(2)*sin(xtst(:)) + coef2(3)*xtst(:).^3 + coef2(4)*xtst(:).^2 + coef2(5)*xtst(:) + coef2(6);
        end
        Error(i)=Error(i)+sumsqr(yestim(:) - ytst(:));  %calculamos el error para cada uno de los modelos
    end 
    
  end
 
  
  Error=Error/K_CV  %dividimos el eerror medio del modelo y lo mostramos

function res = CalculateCorrelation( X,Y )

   mX = mean(X);
   vX = std(X);
   mY = mean(Y);
   vY = std(Y);
   
   res = ((X - ones(length(X),1)*mX).*(Y - ones(length(Y),1)*mY))/(vX*vY);
end


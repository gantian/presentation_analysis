function res = CalculateCorrelation_Seg( X,Y,sLen )    
    res=zeros(length(X),1);
    for i=1:(length(X)-sLen+1)
        res(i)=corr(X(i:i+sLen-1),Y(i:i+sLen-1));
    end
end
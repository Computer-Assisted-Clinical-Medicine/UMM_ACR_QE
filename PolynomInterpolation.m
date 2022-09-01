function [p, k] = PolynomInterpolation(x,y,pref)

    if size(x,2) ~= 1
       x = x'; 
    end
    if size(y,2) ~= 1
       y = y'; 
    end

    switch pref
        case 'linear' 
            f = @(x) [1 , x];
            n = 2;
        case 'quadratic' 
            f = @(x) [1 , x , x.^2];
            n = 3;
        case 'cubic' 
            f = @(x) [1 , x , x.^2 , x.^3];
            n = 4;
    end
        T = zeros(length(x),n);
        for i = 1 : length(x)
            T(i,:) = f(x(i));
        end
        k = (T'*T)\(T'*y);    
    switch pref
        case 'linear' 
            p = @(x) k(1) + k(2) .* x;
        case 'quadratic' 
            p = @(x) k(1) + k(2) .* x + k(3) .* x.^2;
        case 'cubic' 
            p = @(x) k(1) + k(2) .* x + k(3) .* x.^2 + k(4) .* x.^3;
    end        
end
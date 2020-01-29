function Model()
u = 0.5; % test the percentage of nuy here
fileID = fopen('para.txt','r');
                      %  n  m  aVo  M  a  T  e  B  y  ios  Zs Zv  
para = textscan(fileID,'%f %*f %*f %f %f %f %f %f %*f %*f %*f %*f','Delimiter',' ');
fclose(fileID);
fileID = fopen('nums1.txt','r');
                    % id  Su Vu con vout ch txid  
Di = textscan(fileID,'%*f %f %f %*f %*f %*f %*s','Delimiter',' ');
fclose(fileID);
fileID = fopen('nums2.txt','r');
                     % id  So Vo 
Do = textscan(fileID,'%*f %f %f','Delimiter',' ');
fclose(fileID);
% input
n = para{1};
M = para{2};
a = para{3};
T = para{4};
e = para{5};
B = para{6};
Su = Di{1}; Su = Su';
Vu = Di{2}; Vu = Vu';
So = Do{1}; So = So';
Vo = Do{2}; Vo = Vo';
Y = Model_1(n, M, a, T, e, B, Su, Vu, So, Vo);
% constraint of model 2
Zs = 1;
if sum(Vo) >= T
    f = zeros(n+1,1);
    A = zeros(2,n+1);
    b = zeros(2,1);
    Aeq = zeros(1,n+1);
    for i = 1:n
        f(i,1) = -1;
    end
    f(n+1,1) = 0;
    for i = 1:n
        A(1,i) = Su(1,i);
        A(2,i) = Su(1,i);
    end
    A(1,n+1) = 0;
    A(2,n+1) = 0;
    b(1,1) = M - sum(So) - B*Zs;
    b(2,1) = (1+u)*Y - sum(So) - B*Zs;
    for i = 1:n
        Aeq(1,i) = Vu(1,i) - a*Su(1,i);
    end
    Aeq(1,n+1) = -1;
    beq(1,1) = sum(Vo) + a*sum(So) + a*B;
    lb = zeros(n+1,1);
    ub = ones(n+1,1);
    lb(n+1,1) = -a*B*Zs;
    ub(n+1,1) = Inf;
    intcon = 1:n+1;
    [x,y] = intlinprog(f,intcon,A,b,Aeq,beq,lb,ub);
    x = round(x);
    Zv = x(n+1,1);
    x = x';
    x(:,n+1) = [];
    if Zv <= e
        y = y + Zs;
        y = round(y);
        Zs = 0;
        Zv = 0;
    end
    y = -y;
    Y1 = 0;
    for i = 1:n
        Y1 = Y1 + Vu(1,i)*x(1,i);
    end
    Y1 = (Y1 - sum(Vo) - Zv)/a;
    y = round(y);
else
    disp('Transaction outputs must be higher than the dust threshold');
end
disp('The Utxos are chosen (1): '); disp(x);
disp('Minimum tx size: '); disp(Y);
disp('Appropriate tx size: '); disp(Y1);
disp('maximum Utxos are chosen: '); disp(y);
disp('Change: '); disp(Zv);
end
% n is number of utxo in utxo pool
% Vo is set of value of output
% M is maximum data size
% a is alpha (fee rate)
% T is dust threshold
% e is minimum of change output that is set to avoid creating a very small output
% B is beta (Zs if Zv > e)
% Su is transaction input size
% So is transaction output size
function y = Model_1(n, M, a, T, e, B, Su, Vu, So, Vo)
% constraint of model 1
Zs = 1;
if sum(Vo) >= T
    f = zeros(n+1,1);
    A = zeros(1,n+1);
    Aeq = zeros(1,n+1);
    for i = 1:n
        f(i,1) = Su(1,i);
    end
    f(n+1,1) = 0;
    for i = 1:n
        A(1,i) = Su(1,i);
    end
    A(1,n+1) = 0;
    b(1,1) = M - sum(So) - B*Zs;
    for i = 1:n
        Aeq(1,i) = Vu(1,i) - a*Su(1,i);
    end
    Aeq(1,n+1) = -1;
    beq(1,1) = sum(Vo) + a*sum(So) + a*B;
    lb = zeros(n+1,1);
    ub = ones(n+1,1);
    lb(n+1,1) = -a*B*Zs;
    ub(n+1,1) = Inf;
    intcon = 1:n+1;
    [x,y] = intlinprog(f,intcon,A,b,Aeq,beq,lb,ub);
    x = round(x);
    Zv = x(n+1,1);
    y = y + sum(So) + B*Zs;
    x = x';
    x(:,n+1) = [];
    if Zv <= e
        Zs = 0;
        Zv = 0;
        y = 0;
        for i = 1:n
            y = y + Vu(1,i)*x(1,i);
        end
        y = (y - sum(Vo) - Zv)/a;
    end
else
    disp('Transaction outputs must be higher than the dust threshold');
end
disp('The Utxos are chosen (1): '); disp(x);
disp('Minimum tx size: '); disp(y);
disp('Change: '); disp(Zv);
end
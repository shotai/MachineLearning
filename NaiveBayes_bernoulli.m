function bernoulli()
A = load('spambase.txt');
re = zeros(11,3);
for i = 1:10
    f = K_FORLDER(A, 0);
    TR = f.Train;
    TS = f.Test;
    col = size(TR,2);
    row = size(TR,1);

    p =  PrepareTraining(TR, col, row);
    per = p.per;
    s = p.s;
    ns = p.ns;
    avgtr = p.Avgtr;

    tr = StartTraining(s,ns,avgtr');
    dis = tr.dis;
    ndis = tr.ndis;

    ts = StartTesting(avgtr',TS,dis,ndis,per);
    acc = ts.acc;
    auc = ts.auc;
    re(i,1) = ts.fp;
    re(i,2) = ts.fn;
    re(i,3) = 1-acc;
end

re(11,1) = sum(re(1:10,1))/10;
re(11,2) = sum(re(2:10,1))/10;
re(11,3) = sum(re(3:10,1))/10;

fprintf(2,'TEST ACC %g\n',acc);
fprintf(1,'TEST AUC %g\n',auc);
disp('end');



function f = K_FORLDER(A,ram)
n = 1;
t = 1;
row1 = 0;
row2 = 0;
A=  A(randperm(end),:);
row = size(A,1);
for i=1:row
    if(mod(i,10)==ram)
        TEST(n,:) = A(i,:);
        n = n+ 1;
        row2 = row2 + 1;
    
    else
        TRAIN(t,:) = A(i,:);
        t = t+1;
        row1 = row1 + 1;
    end
end
f.Test = TEST;
f.Train = TRAIN;

function p = PrepareTraining(TR, col, row)
Spams = TR(find(TR(:,col)==1),1:(col-1));
Nonspams = TR(find(TR(:,col)==0),1:(col-1));
Slen = size(Spams,1);
Nlen = size(Nonspams,1);
Avg_S = sum(Spams)/Slen;
Avg_NS = sum(Nonspams)/Nlen;
Avg_TR = sum(TR)/row;
p.Avgs = Avg_S';
p.Avgn = Avg_NS';
p.Avgtr = Avg_TR';
per = Slen/row;
p.per = per;
p.s = Spams;
p.ns = Nonspams;
    
function train = StartTraining(s,ns, avgtr)    
Slen = size(s,1);
Nlen = size(ns,1);
    
dis = zeros(2,57);

for i=1:57
    threshold = avgtr(1, i);
    %spam with smoothing
    dis(1,i) = (size(find(s(:,i)>threshold),1)+1)/(Slen+2);
    % non-spam with smoothing
    dis(2,i) = (size(find(ns(:,i)>threshold),1)+1)/(Nlen+2);
end
    
train.dis = dis;
train.ndis = ones(2,57) - dis;
    
function test = StartTesting(avgtr,TS, dis,ndis, per)   
res = zeros(size(TS,1),1);
rocres = zeros(size(TS,1),1);
X = TS(:,1:57);
Y = TS(:,58:58);
for i=1:size(X,1)
    ps = per;
    pns = 1-per;
    for j=1:57
        if X(i,j)>avgtr(1,j)
            %bigger than average
            ps = ps*dis(1,j);
            pns = pns*dis(2,j);
        else
            %smaller than average
            ps = ps*(ndis(1,j));
            pns = pns*(ndis(2,j)); 
        end
    end

    if ps/pns>1
        res(i) = 1;
       
    else
        res(i) = 0;
        %rocres(i) = p_spam;
    end
     rocres(i) = log(ps/pns);
end

n = 0;
fn = 0;
fp = 0;
for i = 1:size(X,1)
    if(res(i,1)==Y(i,1))
        n = n+1;
    end
    if(res(i,1) == 1 && Y(i,1)==0)
        fp = fp +1;
    end
    if(res(i,1)==0 && Y(i,1)==1)
        fn = fn +1;
    end
end
acc = n/size(X,1);
[B,C,thre, AUC] = perfcurve(res,Y,1);
plotroc(Y',rocres');
%plot(B,C);
test.res = res;
RES = [res,Y];
test.acc = acc;
test.auc = AUC;
test.fn = fn/length(find(TS(:,58)==0));
test.fp = fp/length(find(TS(:,58)==1));
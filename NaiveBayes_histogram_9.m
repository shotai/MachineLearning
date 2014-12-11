function histogram_9()
A = load('spambase.txt');
re = zeros(11,3);
for i = 1:10
    f = K_FORLDER(A, 0);
    TR = f.Train;
    TS = f.Test;
    col = size(TR,2);
    row = size(TR,1);

    p =  PrepareTraining(TR, col, row);
    bin = p.bin;
    sl = p.sl;
    nsl = p.nsl;
    spam = p.s;
    nonspam = p.ns;
    per = p.per;

    tr = StartTraining(spam,nonspam,bin, sl, nsl);
    sdis = tr.spamdis;
    ndis = tr.nonspamdis;

    ts = StartTesting(TS, bin, sdis,ndis,per);
    acc=ts.acc;
    auc = ts.auc;
    re(i,1) = ts.fp;
    re(i,2) = ts.fn;
    re(i,3) = 1-acc;
end
re(11,1) = sum(re(1:10,1))/10;
re(11,2) = sum(re(1:10,2))/10;
re(11,3) = sum(re(1:10,3))/10;
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
per = Slen/row;
bin = zeros(8,58);

sdtmp = std(TR);
sd = sdtmp(:,1:58);
bin(4,:) = Avg_TR - 0.5*sd;
bin(5,:) = Avg_TR+0.5*sd;
bin(3,:) = Avg_TR-1*sd;
bin(6,:) = Avg_TR+1*sd;
bin(2,:) = Avg_TR-1.5*sd;
bin(7,:) = Avg_TR+1.5*sd;
bin(1,:) = Avg_TR-2*sd;
bin(8,:) = Avg_TR+2*sd;

p.Avgs = Avg_S;
p.Avgn = Avg_NS;
p.Avgtr = Avg_TR;
p.per = per;
p.s = Spams;
p.ns = Nonspams;
p.sl = Slen;
p.nsl = Nlen;
p.bin = bin;

function train = StartTraining(spam,nonspam,bin, sl, nsl)

spamdis = zeros(9,57);
nonspamdis = zeros(9,57);
for i=1:57       
    % spam
    spamdis(1,i) = (length(find(spam(:,i)<=bin(1,i)))+1)/(sl+9);
    spamdis(2,i) = (length(find(spam(:,i)>bin(1,i) &spam(:,i)<=bin(2,i)))+1)/(sl+9);
    spamdis(3,i) = (length(find(spam(:,i)>bin(2,i) &spam(:,i)<=bin(3,i)))+1)/(sl+9);
    spamdis(4,i) = (length(find(spam(:,i)>bin(3,i) &spam(:,i)<=bin(4,i)))+1)/(sl+9);
    spamdis(5,i) = (length(find(spam(:,i)>bin(4,i) &spam(:,i)<=bin(5,i)))+1)/(sl+9);
    spamdis(6,i) = (length(find(spam(:,i)>bin(5,i) &spam(:,i)<=bin(6,i)))+1)/(sl+9);
    spamdis(7,i) = (length(find(spam(:,i)>bin(6,i) &spam(:,i)<=bin(7,i)))+1)/(sl+9);
    spamdis(8,i) = (length(find(spam(:,i)>bin(7,i) &spam(:,i)<=bin(8,i)))+1)/(sl+9);
    spamdis(9,i) = (length(find(spam(:,i)>bin(8,i)))+1)/(sl+9);
    % non-spam
    nonspamdis(1,i) = (length(find(nonspam(:,i)<=bin(1,i)))+1)/(nsl+9);
    nonspamdis(2,i) = (length(find(nonspam(:,i)>bin(1,i) &nonspam(:,i)<=bin(2,i)))+1)/(nsl+9);
    nonspamdis(3,i) = (length(find(nonspam(:,i)>bin(2,i) &nonspam(:,i)<=bin(3,i)))+1)/(nsl+9);
    nonspamdis(4,i) = (length(find(nonspam(:,i)>bin(3,i) &nonspam(:,i)<=bin(4,i)))+1)/(nsl+9);
    nonspamdis(5,i) = (length(find(nonspam(:,i)>bin(4,i) &nonspam(:,i)<=bin(5,i)))+1)/(nsl+9);
    nonspamdis(6,i) = (length(find(nonspam(:,i)>bin(5,i) &nonspam(:,i)<=bin(6,i)))+1)/(nsl+9);
    nonspamdis(7,i) = (length(find(nonspam(:,i)>bin(6,i) &nonspam(:,i)<=bin(7,i)))+1)/(nsl+9);
    nonspamdis(8,i) = (length(find(nonspam(:,i)>bin(7,i) &nonspam(:,i)<=bin(8,i)))+1)/(nsl+9);
    nonspamdis(9,i) = (length(find(nonspam(:,i)>bin(8,i)))+1)/(nsl+9);
end
train.spamdis = spamdis;
train.nonspamdis = nonspamdis;


function test = StartTesting(TS, bin, sdis,ndis,per)
res = ones(size(TS,1),1);
rocres = ones(size(TS,1),1);
X = TS(:,1:57);
Y = TS(:,58:58);

for i=1:size(X,1)
    ps = per;
    pns = 1-per;
    for j=1:57
        if X(i,j)<=bin(1,j)
            ps = ps*sdis(1,j);
            pns = pns*ndis(1,j);
        elseif X(i,j)<=bin(2,j)
            ps = ps*sdis(2,j);
            pns = pns*ndis(2,j);
        elseif X(i,j)<=bin(3,j)
            ps = ps*sdis(3,j);
            pns = pns*ndis(3,j);
        elseif X(i,j)<=bin(4,j)
            ps = ps*sdis(4,j);
            pns = pns*ndis(4,j);
        elseif X(i,j)<=bin(5,j)
            ps = ps*sdis(5,j);
            pns = pns*ndis(5,j);
        elseif X(i,j)<=bin(6,j)
            ps = ps*sdis(6,j);
            pns = pns*ndis(6,j);
        elseif X(i,j)<=bin(7,j)
            ps = ps*sdis(7,j);
            pns = pns*ndis(7,j);
        elseif X(i,j)<=bin(8,j)
            ps = ps*sdis(8,j);
            pns = pns*ndis(8,j);         
        else
            ps = ps*sdis(9,j);
            pns = pns*ndis(9,j);
        end
        if ps/pns>1
            res(i) = 1;
        else
            res(i) = 0;
        end
        rocres(i) = log(ps/pns);
    end
    
    
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
RES = [res,Y];
acc = n/size(X,1);
[B,C,thre, AUC] = perfcurve(Y,res,1);
plotroc(Y',rocres');
test.res = res;
test.acc = acc;
test.auc = AUC;
test.fn = fn/length(find(TS(:,58)==0));
test.fp = fp/length(find(TS(:,58)==1));

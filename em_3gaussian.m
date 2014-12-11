function em3()
A=load('3gaussian.txt');
r = initialization(A,3);
mean1 = r.mean1;
mean2 = r.mean2;
mean3 = r.mean3;

sigma1=r.sigma1;
sigma2 = r.sigma2;
sigma3 = r.sigma3;

pr1=r.p1;
pr2 = r.p2;
pr3 = r.p3;

k = r.k;

for i=1:58
    e = expectation(A, mean1,mean2,mean3,sigma1,sigma2,sigma3,pr1,pr2,pr3,k);
    z = e.z;
    m =maximization(A,z);
    mean1 = m.mean1;
    mean2 = m.mean2;
    mean3 = m.mean3;
    sigma1 = m.sigma1;
    sigma2 = m.sigma2;
    sigma3 = m.sigma3;
    pr1 = m.pr1;
    pr2 = m.pr2;
    pr3 = m.pr3;
end
fprintf(1,'mean1 = %g cov_1 = %g; n1= %g \n',mean1, sigma1, pr1*10000);
fprintf(1,'mean2 = %g cov_2 = %g; n2= %g \n',mean2, sigma2, pr2*10000);
fprintf(1,'mean3 = %g cov_3 = %g; n3= %g \n',mean3, sigma3, pr3*10000);
disp(mean1);
disp(sigma1);

function R = initialization(X, init)

k = init;
mean_tmp = sum(X)/size(X,1);
mean = zeros(3,2);
st = std(X);
mean(1,:) = mean_tmp - st;
mean(2,:) = mean_tmp + st;
mean(3,:) = mean_tmp;
R.mean1 = mean(1,:);
R.mean2 = mean(2,:);
R.mean3 = mean(3,:);

sigma_tmp = cov(X);
st_tmp = [st;st];
sigma_1 = sigma_tmp - st_tmp;
sigma_2 = sigma_tmp + st_tmp;
sigma_3 = sigma_tmp;
R.sigma1 = sigma_1;
R.sigma2 = sigma_2;
R.sigma3 = sigma_3;

R.p1 = 1/3;
R.p2 = 1/3;
R.p3 = 1/3;
R.k = k;


function e = expectation(X, mean1,mean2,mean3,sigma1,sigma2,sigma3,pr1,pr2,pr3,k)
z = zeros(10000,3);

for i = 1:10000
    total = 0;
    
    detsigma1 = det(sigma1);
    invsigma1 = inv(sigma1);
    detsigma2 = det(sigma2);
    invsigma2 = inv(sigma2);
    detsigma3 = det(sigma3);
    invsigma3 = inv(sigma3);
    x = X(i,:);
    p1 = pr1/((2*pi)^(k/2)*(detsigma1^0.5))*exp(-0.5*(x-mean1)*invsigma1*(x-mean1)');
    p2 = pr2/((2*pi)^(k/2)*(detsigma2^0.5))*exp(-0.5*(x-mean2)*invsigma2*(x-mean2)');
    p3 = pr3/((2*pi)^(k/2)*(detsigma3^0.5))*exp(-0.5*(x-mean3)*invsigma3*(x-mean3)');
    total = p1+p2 +p3;
 
    z(i,1) = p1/total;
    z(i,2) = p2/total;
    z(i,3) = p3/total;
end
e.z = z;



function m = maximization(X,z)
sum_z = sum(z);
pr1 = sum_z(1)/size(X,1);
pr2 = sum_z(2)/size(X,1);
pr3 = sum_z(3)/size(X,1);
mean_1 = z(:,1)'*X/sum_z(1);
mean_2 = z(:,2)'*X/sum_z(2);
mean_3 = z(:,3)'*X/sum_z(3);
sum_1 = zeros(2,2);
sum_2 = zeros(2,2);
sum_3 = zeros(2,2);
for i=1:size(X,1)
    sum_1=sum_1+z(i,1)*(bsxfun(@minus,X(i,:),mean_1)'*bsxfun(@minus,X(i,:),mean_1));
    sum_2=sum_2+z(i,2)*(bsxfun(@minus,X(i,:),mean_2)'*bsxfun(@minus,X(i,:),mean_2));
    sum_3=sum_3+z(i,3)*(bsxfun(@minus,X(i,:),mean_3)'*bsxfun(@minus,X(i,:),mean_3));
end
sigma_1=sum_1/sum_z(1);
sigma_2=sum_2/sum_z(2);
sigma_3=sum_3/sum_z(3);
m.sigma1 = sigma_1;
m.sigma2 = sigma_2;
m.sigma3 = sigma_3;
m.mean1 = mean_1;
m.mean2 = mean_2;
m.mean3 = mean_3;
%m.mean = [mean_1;mean_2];
m.pr1 = pr1;
m.pr2 = pr2;
m.pr3 = pr3;
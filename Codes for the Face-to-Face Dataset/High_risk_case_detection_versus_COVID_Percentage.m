function [COVID_Percetage, high_risk_percentage_AP_DP3T, high_risk_percentage_DP3T, high_risk_percentage_DPACT]=High_risk_case_detection_versus_COVID_Percentage(A2,K,B)

% Inputs:
%  A2 is the contact matrix containing  the time of contacts (first column) and the indexes of users who had contacts (second and third columns)
% K is the iteration number
% B is the Percentage of passive users


% Outputs:
% high_risk_percentage_DP3T is High-risk case detection Probabilities for DP-3T
% high_risk_percentage_AP_DP3T is High-risk case detection Probabilities for A/P DP-3T
% high_risk_percentage_DPACT is High-risk case detection Probabilities for DP-ACT
% COVID_Percetage is a vector containing the corresponding COVID percentages

% We replace the participant's numbers with 1 to the number of partcipants
A22=[A2(:,2); A2(:,3)];
[a,b]=sort(A22);
la22=numel(A22);A2prim=A2;
k=1;
for j=1:la22/2
    if A2(j,2)==a(1,1)
        A2prim(j,2)=k;
    end
    if A2(j,3)==a(1,1)
        A2prim(j,3)=k;
    end
end
for i=2:la22
    if a(i,1)~=a(i-1,1)
        k=k+1;
        for j=1:la22/2
            if A2(j,2)==a(i,1)
                A2prim(j,2)=k;
            end
            if A2(j,3)==a(i,1)
                A2prim(j,3)=k;
            end
        end
    end

end


l2= max([max(A2prim(:,2)), max(A2prim(:,3))]);
l22=size(A2prim,1);

X=cell(l2,1);

for i=1:l22
    X{A2prim(i,2)}=[X{A2prim(i,2)} [A2prim(i,1); A2prim(i,3)]];
    X{A2prim(i,3)}=[X{A2prim(i,3)} [A2prim(i,1); A2prim(i,2)]];
end

%First, we calculate the durations of the contacts and add them to X to achieve X_duration
X_duration=cell(l2,1);
for i=1:l2
    b=size(X{i},2);j=1;l=1;
    while j<=b
        res=1;
        for k=1:b
            [h1,h2]=find(X{i}(1,:)==(X{i}(1,j)+20*k));
            if sum(X{i}(2,h2)==X{i}(2,j))
                res=res+1;
            else
                break
            end
        end
        X_duration{i}=[X_duration{i} [res*20; X{i}(2,j); X{i}(1,j)]]; j=j+1;k=k+1;%no_i=1+no_i%c1=c
        if j>b
            break
        end
        ff=1;
        while ff==1
            if j+1>b
                break
            end
            [aaa,aaaa]=find(X{i}(2,j+1)==X_duration{i}(2,:));
            hh=X{i}(1,j);ff=0;
            for o=1:numel(aaaa)
                if ( X_duration{i}(3,aaaa(o))+X_duration{i}(1,aaaa(o)))>hh
                    ff=1;
                end
            end
            if ff==1
                j=j+1;
            end
        end
    end
end

% The minimum contact duration to get infected for the face-to-face contacts:
duration_threshold= 5*60;

P=7;
COVID_Percetage=2:15:(P-1)*15+2;
high_risk_percentage_DP3T=zeros(1,P);
high_risk_percentage_AP_DP3T=zeros(1,P);high_risk_percentage_DPACT=zeros(1,P);
Pfa=zeros(1,P);

%% Now, we should consider the delay E for the propagation; in other words, we divide the grap into some
% sub-graphs and consider it as the input of the dfsearch(G,covid_indexes(i))
%Let us consider a time frame for updating the covid_index. Lets updat
%every E min
E=60*60*24*1;
max_time=max( A2prim(:,1));
min_time= min( A2prim(:,1));
BB=(max_time-min_time)/E;


for  p=1:P
    C=(p-1)*15+2;
    high_risk_percentage3=0;high_risk_percentage4=0;high_risk_percentage5=0;
    high_risk_ref=0;pfa=0;
    for kk=1:K
        ss=randperm(l2);
        % Indexes of passive users:
        erased_indexes=ss(1:ceil(B/100*l2)); unerased_indexes=[];
        for i=1:l2
            if (i~=erased_indexes)
                % Indexes of active users:
                unerased_indexes=[unerased_indexes i];
            end
        end
        %If B percentage of users are not advertizing instead of X_duration we have  X_duration_advertize
        X_duration_advertize=cell(l2,1);
        for i=1:l2
            for j=1:size(X_duration{i},2)
                if (X_duration{i}(2,j)~=erased_indexes)
                    X_duration_advertize{i}=[ X_duration_advertize{i} [X_duration{i}(1,j); X_duration{i}(2,j); X_duration{i}(3,j)]];
                end
            end
        end
        vv=[];vv1=[];vv2=[];vv3=[];
        ss1=randperm(l2);
        covid_indexes=ss1(1:ceil(C/100*l2));covid_indexes1=covid_indexes;
        covid_indexes_array1={covid_indexes;covid_indexes;covid_indexes;covid_indexes};
        covid_indexes_array2={covid_indexes;covid_indexes;covid_indexes;covid_indexes};
        covid_indexes_array3={covid_indexes;covid_indexes;covid_indexes;covid_indexes};
        covid_indexes_array4={covid_indexes;covid_indexes;covid_indexes;covid_indexes};
        for K1=1:1:ceil(BB)
            covid_indexes1=covid_indexes_array1{rem(K1,4)+1};
            covid_indexes2=covid_indexes_array2{rem(K1,4)+1};
            covid_indexes3=covid_indexes_array3{rem(K1,4)+1};
            covid_indexes4=covid_indexes_array4{rem(K1,4)+1};
            X_duration_after_delay=cell(l2,1);
            X_duration_advertize_after_delay=cell(l2,1);
            for i=1:l2
                for j=1:size(X_duration{i},2)
                    if ((min_time+E*K1)>(X_duration{i}(3,j)))
                        if (X_duration{i}(3,j))>(min_time+(K1-1)*E)
                            X_duration_after_delay{i}=[ X_duration_after_delay{i} [X_duration{i}(1,j); X_duration{i}(2,j); X_duration{i}(3,j)]];
                        end
                    end
                end
                for j=1:size(X_duration_advertize{i},2)
                    if ((min_time+E*K1)>(X_duration_advertize{i}(3,j)))
                        if (X_duration_advertize{i}(3,j))>(min_time+(K1-1)*E)
                            X_duration_advertize_after_delay{i}=[ X_duration_advertize_after_delay{i} [X_duration_advertize{i}(1,j); X_duration_advertize{i}(2,j); X_duration_advertize{i}(3,j)]];
                        end
                    end
                end
            end
            [covid_indexes1]=high_risk_contact(X_duration_after_delay,duration_threshold,covid_indexes1,l2);
            vv=[vv; covid_indexes1'];

            [covid_indexes2]=AP_DP_3T_FtF(X_duration_advertize_after_delay,duration_threshold,covid_indexes2,l2,erased_indexes,unerased_indexes);
            vv1=[vv1; covid_indexes2'];

            [covid_indexes3]=DP_3T_FtF(X_duration_advertize_after_delay,duration_threshold,covid_indexes3,l2,erased_indexes,unerased_indexes);
            vv2=[vv2; covid_indexes3'];

            [covid_indexes4]=DP_ACT_FtF(X_duration_advertize_after_delay,duration_threshold,covid_indexes4,l2,erased_indexes,unerased_indexes);
            vv3=[vv3; covid_indexes4'];

            covid_indexes_array1{rem(K1,4)+1}=covid_indexes1;
            covid_indexes_array2{rem(K1,4)+1}=covid_indexes2;
            covid_indexes_array3{rem(K1,4)+1}=covid_indexes3;
            covid_indexes_array4{rem(K1,4)+1}=covid_indexes4;

        end
        v2_ref=[];
        for i=1:l2
            if sum(i==vv)
                if (i~=covid_indexes)
                    v2_ref=[v2_ref i];
                end
            end
        end
        high_risk_ref=high_risk_ref+numel(v2_ref);
        for i=1:l2
            if sum(i==vv1)
                if sum(i==vv)
                    if (i~=covid_indexes)
                        high_risk_percentage3=high_risk_percentage3+1;
                    end
                end
            end
        end
        for i=1:l2
            if sum(i==vv2)
                if sum(i==vv)
                    if (i~=covid_indexes)
                        high_risk_percentage4=high_risk_percentage4+1;
                    end
                end
            end
        end
        for i=1:l2
            if sum(i==vv3)
                if sum(i==vv)
                    if (i~=covid_indexes)
                        high_risk_percentage5=high_risk_percentage5+1;
                    end
                else
                    if (i~=covid_indexes)
                        pfa=pfa+1;
                    end
                end
            end
        end
    end
    high_risk_percentage_AP_DP3T(p)=high_risk_percentage3/high_risk_ref;
    high_risk_percentage_DP3T(p)=high_risk_percentage4/high_risk_ref;
    high_risk_percentage_DPACT(p)=high_risk_percentage5/high_risk_ref;
end

% M6=strcat("DP-3T (",num2str(B)," PU)");
% M5=strcat("A/P DP-3T (",num2str(B)," PU)");
% M66=strcat("DP-ACT (",num2str(B)," PU)");
% figure(),
% a5=plot(COVID_Percetage,high_risk_percentage_AP_DP3T,'-g');
% hold on
% a6=plot(COVID_Percetage,high_risk_percentage_DP3T, '-r');
% hold on
% a66=plot(COVID_Percetage,high_risk_percentage_DPACT, '-b');
% ylabel('High-Risk Case Detection Probability')
% xlabel('COVID-19 Precentage')
% legend([a5,a6,a66], [M5,M6,M66]);
% figure(),
% plot(COVID_Percetage,Pfa/100);
% ylabel('False Alarm Probability')
% xlabel('COVID-19 Precentage')
end

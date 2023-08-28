function [Passive_Percetage, high_risk_percentage_AP_DP3T, high_risk_percentage_DP3T, high_risk_percentage_DPACT]=High_risk_case_detection_versus_Passive_Percentage(A2,K,C)
% Inputs:
% A2 is the contact matrix containing the time of contacts (first column),  the indexes of users who had contacts (second and third columns) and the corresponding attenuations (fourth column)
% K is the iteration number
% C is the number of infected users


% Outputs:
% high_risk_percentage_DP3T is High-risk case detection Probabilities for DP-3T
% high_risk_percentage_AP_DP3T is High-risk case detection Probabilities for A/P DP-3T
% high_risk_percentage_DPACT is High-risk case detection Probabilities for DP-ACT
% Passive_Percetage is a vector containing the corresponding passive percentages

% We replace the participants' indexes with 1 to the number of participants:
HH=18;


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
A2prim(:,1)= A2prim(:,1)- A2prim(1,1);
l2= max([max(A2prim(:,2)), max(A2prim(:,3))]);
l22=size(A2prim,1);

X=cell(l2,1);

for i=1:l22
    X{A2prim(i,2)}=[X{A2prim(i,2)} [A2prim(i,1); A2prim(i,3); A2prim(i,4)]];
    X{A2prim(i,3)}=[X{A2prim(i,3)} [A2prim(i,1); A2prim(i,2); A2prim(i,4)]];
end

X1=cell(l2,1);
for i=1:l22
    X1{A2prim(i,2)}=[X1{A2prim(i,2)} [A2prim(i,1); A2prim(i,3); A2prim(i,4)]];
end


%First, we calculate the exposure score of the contacts and add them to X to achieve X_duration
duration_threshold= 15*60;max_attenuation=55;max_attenuation2=63; w1=1;w2=0.5;

X_duration2=cell(l2,1);
for i=1:l2
    for j=1:l2
        score=0;
        [h1,h2]=find(X1{i}(2,:)==j);
        bb=numel(h2);
        if bb>=2
            for k=1:bb-1
                res=X1{i}(1,h2(k+1))-X1{i}(1,h2(k));

                if X1{i}(3,h2(k))<=max_attenuation
                    score=score+res;
                elseif X1{i}(3,h2(k))<=max_attenuation2
                    score=score+0.5*res;
                end
            end
            if X1{i}(3,h2(bb))<=max_attenuation
                score=score+5*60;
            elseif X1{i}(3,h2(bb))<=max_attenuation2
                score=score+0.5*5*60;
            end
            X_duration2{i}=[X_duration2{i} [score; j;X1{i}(1,h2(1));X1{i}(1,h2(bb))]];

        end
    end
end

%%
Bmax=90;

high_risk_percentage_AP_DP3T=zeros(1,Bmax/5-1);
high_risk_percentage_DP3T=zeros(1,Bmax/5-1);
high_risk_percentage_DPACT=zeros(1,Bmax/5-1);

for  B=10:5:Bmax
    high_risk_percentage3=0;high_risk_percentage4=0;high_risk_percentage5=0;
    high_risk_ref=0;pfa=0;
    for kk=1:K
        X_duration_advertize=cell(l2,1);X_duration_advertize2=cell(l2,1);
        ss=randperm(l2);
        % Indexes of passive users:
        erased_indexes=ss(1:B/10*2);unerased_indexes=[];
        for i=1:l2
            if (i~=erased_indexes)
                % Indexes of active users:
                unerased_indexes=[unerased_indexes i];
            end
        end
        %If B percentage of users are not advertizing instead of X_duration we have  X_duration_advertize
        for i=1:l2
            for j=1:size(X_duration2{i},2)
                if (X_duration2{i}(2,j)~=erased_indexes)
                    X_duration_advertize2{i}=[ X_duration_advertize2{i} [X_duration2{i}(1,j); X_duration2{i}(2,j);X_duration2{i}(3,j);X_duration2{i}(4,j)]];
                end
            end
        end
        vv=[];vv1=[];vv2=[];vv3=[];
        ss1=randperm(l2);
        covid_indexes=ss1(1:C);covid_indexes1=covid_indexes;



        [covid_indexes1]=high_risk_contact(X_duration2,duration_threshold,covid_indexes,l2);
        vv=[vv; covid_indexes1'];

        [covid_indexes2]=AP_DP_3T(X_duration_advertize2,duration_threshold,covid_indexes,l2,erased_indexes,unerased_indexes);

        vv1=[vv1; covid_indexes2'];

        [covid_indexes3]=DP_3T(X_duration_advertize2,duration_threshold,covid_indexes,l2,erased_indexes,unerased_indexes);
        vv2=[vv2; covid_indexes3'];

        [covid_indexes4]=DP_ACT(X_duration_advertize2,duration_threshold,covid_indexes,l2,erased_indexes,unerased_indexes);
        vv3=[vv3; covid_indexes4'];


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
                    pfa=pfa+1;
                end
            end
        end
    end
    high_risk_percentage_AP_DP3T(B/5-1)=high_risk_percentage3/high_risk_ref;
    high_risk_percentage_DP3T(B/5-1)=high_risk_percentage4/high_risk_ref;
    high_risk_percentage_DPACT(B/5-1)=high_risk_percentage5/high_risk_ref;
end
Passive_Percetage=2*(1:0.5:9)*100/18;

% M6="DP-3T";
% M5="A/P DP-3T";
% M66="DP-ACT";
% figure(),
% a5=plot(Passive_Percetage,high_risk_percentage_AP_DP3T,'-g');
% hold on
% a6=plot(Passive_Percetage,high_risk_percentage_DP3T, '-r');
% hold on
% a66=plot(Passive_Percetage,high_risk_percentage_DPACT, '-b');
% ylabel('High Risk Case Detection Probability', 'FontSize', 13)
% xlabel('The Precentage of Passive Users', 'FontSize', 13)
% legend([a5,a6,a66], [M5,M6,M66]);
%
% figure(),
% plot(Passive_Percetage,Pfa./100, '-b');
% ylabel('False Alarm Probability', 'FontSize', 13)
% xlabel('The Precentage of Passive Users', 'FontSize', 13)

end

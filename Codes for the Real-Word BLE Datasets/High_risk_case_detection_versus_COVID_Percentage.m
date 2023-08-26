function [C_percentage, high_risk_percentage_AP_DP3T, high_risk_percentage_DP3T, high_risk_percentage_DPACT]=High_risk_case_detection_versus_COVID_Percentage(A2,K,B)
% Inputs:
% A2 is the contact matrix containing the time of contacts (first column),  the indexes of users who had contacts (second and third columns) and the corresponding attenuations (fourth column)
% K is the iteration number
% B is the number of passive users


% Outputs:
% high_risk_percentage_DP3T is High-risk case detection Probabilities for DP-3T
% high_risk_percentage_AP_DP3T is High-risk case detection Probabilities for A/P DP-3T
% high_risk_percentage_DPACT is High-risk case detection Probabilities for DP-ACT
% C_Percetage is a vector containing the corresponding COVID-19 percetages


% We replace the participants' indexes with 1 to the number of participants:
HH=18


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
A2prim(:,1)= A2prim(:,1)- A2prim(1,1)


l2= max([max(A2prim(:,2)), max(A2prim(:,3))])
l22=size(A2prim,1)

X=cell(l2,1);

for i=1:l22
    X{A2prim(i,2)}=[X{A2prim(i,2)} [A2prim(i,1); A2prim(i,3); A2prim(i,4)]];
    X{A2prim(i,3)}=[X{A2prim(i,3)} [A2prim(i,1); A2prim(i,2); A2prim(i,4)]];
end

X1=cell(l2,1);
for i=1:l22
    X1{A2prim(i,2)}=[X{A2prim(i,2)} [A2prim(i,1); A2prim(i,3); A2prim(i,4)]];
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

                %         if (res<=5.2*60) %If the time distance is less than 5 min
                %             du=du+res;
                %         else
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

P=floor(HH/2);
cc=(1:2:2*P)*100/l2;
high_risk_percentage_AP_DP3T=zeros(1,P);
high_risk_percentage_DP3T=zeros(1,P);
high_risk_percentage_DPACT=zeros(1,P);



for  p=1:P

    high_risk_percentage3=0;high_risk_percentage4=0;high_risk_percentage5=0;
    high_risk_ref=0;pfa=0;
    for kk=1:K
        ss=randperm(l2);
        % Indexes of passive users:
        erased_indexes=ss(1:B);
        unerased_indexes=[];
        for i=1:l2
            if (i~=erased_indexes)
                % Indexes of active users:
                unerased_indexes=[unerased_indexes i];
            end
        end
        %If B percentage of users are not advertizing instead of X_duration we have  X_duration_advertize
        X_duration_advertize=cell(l2,1);X_duration_advertize2=cell(l2,1);
        for i=1:l2

            for j=1:size(X_duration2{i},2)
                if sum(X_duration2{i}(2,j)==unerased_indexes)
                    X_duration_advertize2{i}=[ X_duration_advertize2{i} [X_duration2{i}(1,j); X_duration2{i}(2,j);X_duration2{i}(3,j); X_duration2{i}(4,j)]];
                end
            end
        end
        vv=[];vv1=[];vv2=[];vv3=[];
        ss1=randperm(l2);
        covid_indexes=ss1(1:2*p);covid_indexes1=covid_indexes;

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
    Pfa(p)=pfa/l2/K*100;
end

C_percentage=(B*100/l2)

%M6=strcat("DP-3T (",num2str(B)," PU)");
%M5=strcat("A/P DP-3T (",num2str(B)," PU)");
%M66=strcat("DP-ACT (",num2str(B)," PU)");
%figure(),
%a5=plot(cc,high_risk_percentage3_t,'-og');
%hold on
%a6=plot(cc,high_risk_percentage4_t, '-or');
%hold on
%a66=plot(cc,high_risk_percentage5_t, '-ob');
%ylabel('High-Risk Case Detection Probability', 'FontSize', 13)
%xlabel('COVID-19 Percentage','FontSize', 13)
%legend([a5,a6,a66], [M5,M6,M66]);%fontsize(gca,13,"pixels")

%figure(),
%a7=plot(cc,Pfa./100);
%ylabel('False Alarm Probability', 'FontSize', 13)
%xlabel('COVID-19 Precentage','FontSize', 13)

end

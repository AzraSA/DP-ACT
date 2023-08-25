function [high_risk_nodes2]=DP_ACT(X_duration_advertize,duration_threshold,covid_indexes,l2,erased_indexes,unerased_indexes)

% Inputs:
% X_duration_advertize is a cell conatning the contact information of each user when B percentage of users are passive.
% duration_threshold is the minimum contact duration to get infected for the face-to-face contacts:
% covid_indexes is COVID-19 infected users' indexes
%l2 is the number of users
% erased_indexes contains indexes of passive users
% unerased_indexes contains indexes of active users

% Outputs:

% high_risk_nodes2 is a vector containing the high-risk case indexes


high_risk_nodes3=[];h=[];
active_list=[];active_list_time1=[];active_list_time2=[];
for i=1:l2
    if sum(i==covid_indexes)
        if sum(i==unerased_indexes) %If it is active
            for i11=1:l2
                for j=1:size(X_duration_advertize{i11},2)
                    if (X_duration_advertize{i11}(2,j)== i)
                        if X_duration_advertize{i11}(1,j)>= duration_threshold
                            high_risk_nodes3=[ high_risk_nodes3 i11];
                        end
                    end
                end
            end

        else %If it is passive


            for j=1:size(X_duration_advertize{i},2)
                if X_duration_advertize{i}(1,j)>= duration_threshold
                    high_risk_nodes3=[high_risk_nodes3 X_duration_advertize{i}(2,j)];
                    active_list=[active_list X_duration_advertize{i}(2,j)];
                    active_list_time1=[active_list_time1 X_duration_advertize{i}(3,j)];
                    active_list_time2=[active_list_time2 X_duration_advertize{i}(4,j)];
                end
            end

        end
    end
end

l_passive=numel(erased_indexes);
l_active=numel(active_list);
for jj=1:l_passive
    for ii=1:l_active
        passive=erased_indexes(jj);
        for j=1:size(X_duration_advertize{passive},2)
            flag=0;
            if (X_duration_advertize{passive}(2,j)== active_list(ii))
                if (X_duration_advertize{passive}(1,j)~= 0)
                    if (X_duration_advertize{passive}(4,j)>= active_list_time1(ii))
                        if  ((X_duration_advertize{passive}(4,j))<= active_list_time2(ii))
                            if X_duration_advertize{passive}(1,j)>= duration_threshold
                                high_risk_nodes3=[high_risk_nodes3 passive];
                                flag=1;
                            end
                        end
                    end
                end
                if flag==0
                    if (X_duration_advertize{passive}(3,j)>= active_list_time1(ii))
                        if  ((X_duration_advertize{passive}(3,j))<= active_list_time2(ii))
                            if X_duration_advertize{passive}(1,j)>= duration_threshold
                                high_risk_nodes3=[high_risk_nodes3 passive];
                            end
                        end
                    end
                end
            end
        end
    end
end


high_risk_nodes2=[];
for i=1:l2
    if sum(i==high_risk_nodes3)
        high_risk_nodes2=[high_risk_nodes2 i];
        %     elseif sum(i==covid_indexes)
        %         high_risk_nodes2=[high_risk_nodes2 i];
        %     end
    end

end
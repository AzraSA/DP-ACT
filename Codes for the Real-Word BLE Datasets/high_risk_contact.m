function [high_risk_nodes2]=high_risk_contact(X_duration,duration_threshold,covid_indexes,l2)

% Inputs:
% X_duration is a cell conatning the contact information of each user when all users are active.
% duration_threshold is the minimum contact duration to get infected for the face-to-face contacts:
% covid_indexes is COVID-19 infected users' indexes
%l2 is the number of users


% Outputs:

% high_risk_nodes2 is a vector containing the high-risk case indexes


high_risk_nodes3=[];
for i=1:l2
    if sum(i==covid_indexes)
        for j=1:size(X_duration{i},2)
            if X_duration{i}(1,j)>= duration_threshold
                high_risk_nodes3=[ high_risk_nodes3 X_duration{i}(2,j)];
            end
        end
    end
end
high_risk_nodes2=[];
for i=1:l2
    if sum(i==high_risk_nodes3)
        high_risk_nodes2=[ high_risk_nodes2 i];
        %             elseif sum(i==covid_indexes)
        %         high_risk_nodes2=[high_risk_nodes2 i];
    end
end
end


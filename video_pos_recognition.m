clc; clear;
set(0,'DefaultFigureVisible','off')
% get video
% % vid_name = input('Enter Video ID: \n');
% % obj = strcat('Videos/', vid_name);
obj = VideoReader('Videos/ch07_20230426223040.mp4');
duration = input('Enter video duration in seconds: \n');
agg = input('Enter length of sub-periods of movement for mean activity measure in seconds (default 3s): \n');

if isempty(agg)
    agg = 3;
end

video = obj.read();
el = 1;

% grab image grabs from every 1 second of video and crop to just enclosure
for i = 1:floor(obj.NumFrames/duration):obj.NumFrames
    my_field = strcat('frame',num2str(el));
    variable.(my_field) = video(400:1500,400:900,:,i);
    el = el+1;
end

% binarize image to make it easier to locate the mouse
for a = 1:el-1
    figure(a)
    %image(imbinarize(variable.(strcat('frame',num2str(a))), 'adaptive', 'ForegroundPolarity','dark', 'Sensitivity', 0.3));

% find the mouse
    frame = imbinarize(variable.(strcat('frame',num2str(a))), 'adaptive', 'ForegroundPolarity','dark', 'Sensitivity', 0.3);
    found = 0;
    for i = 1:50:size(variable.frame1,1)-1
        for j = 1:50:size(variable.frame1,2)-1
            if sum(frame(i,j,:)) == 0
                fprintf('found a spot for frame %g\n', a);
                % make sure it's the mouse
                % make a line
                % if more than 50% is under threshold, it's the mouse
                count = 0;
                if i - 30 < 0
                    sub_number = 30-i;
                else 
                    sub_number = 30;
                end
                if i + 60 > size(frame, 1)
                    top_number = size(frame,1);
                else 
                    top_number = 60;
                end
                for ii = 1:top_number
                    if sum(frame(i-sub_number+ii,j,:)) == 0
                        count = count + 1;
                    end
                end
                if count >= 29
                    fprintf('certified spot for frame %g\n',a)
                    found = 1;
                    savey = i;
                    savex = j;
                    break
                end
            end
            if found == 1
                break
            end
        end
        if found == 1
            break
        end
    end

    my_field_pos = strcat('frame',num2str(a),'_pos');
    variable.(my_field_pos) = [savex,savey];

end

position_matrix = zeros(el-1,4);
for i = 1:el-1
    if i > 1 %% ASSUMES 1PX == 1MM!!
        distance = sqrt( ((variable.(strcat('frame',num2str(i),'_pos'))(1)) - (variable.(strcat('frame',num2str(i-1),'_pos'))(1))) ^2 +...
            ((variable.(strcat('frame',num2str(i),'_pos'))(2))-(variable.(strcat('frame',num2str(i-1),'_pos'))(2))) ^2 );
    else
        distance = 0;
    end
    % format: position #, x pos, y pos, movement from last
    position_matrix(i,:) = [i variable.(strcat('frame',num2str(i),'_pos'))(1)  variable.(strcat('frame',num2str(i),'_pos'))(2) distance];
end

groups = floor((el-1)/agg);
activity = zeros(groups,2);
for i = 1:groups
    activity(i,:) = [i (position_matrix((i*agg+1),4)+position_matrix((i*agg),4)+position_matrix((i*agg-1),4))];
end

% % mkdir(strcat('Videos/',vid_name,'_processed'));
mkdir('Videos/ch07_20230426223040_processed')
writematrix(position_matrix, 'processed2');
writematrix(activity, 'processed2','WriteMode','append');





% figure(1)
% plot(data_matrix(:,1),data_matrix(:,4))
% hold off
% figure(2)
% plot(activity)


    % % % frame(savey:savey+40,savex-3:savex+3,1) = 255;
    % % % frame(savey:savey-40,savex-3:savex+3,1) = 255;
    % % % frame(savey-3:savey+3,savex:savex+40,1) = 255;
    % % % frame(savey-3:savey+3,savex:savex-40,1) = 255;
    % % % 
    % % % frame(savey:savey+40,savex-3:savex+3,2) = 0;
    % % % frame(savey:savey-40,savex-3:savex+3,2) = 0;
    % % % frame(savey-3:savey+3,savex:savex+40,2) = 0;
    % % % frame(savey-3:savey+3,savex:savex-40,2) = 0;
    % % % 
    % % % frame(savey:savey+40,savex-3:savex+3,3) = 0;
    % % % frame(savey:savey-40,savex-3:savex+3,3) = 0;
    % % % frame(savey-3:savey+3,savex:savex+40,3) = 0;
    % % % frame(savey-3:savey+3,savex:savex-40,3) = 0;

% %     % find the edges
% %     for ii = savey:10:savey+200   % find top
% %         if sum(frame(ii,savex,:)) < 3
% %             top_y = ii-10;
% %             break
% %         end
% %     end
% %     for ii = savey:-10:savey-200   % find bottom
% %         if sum(frame(ii,savex,:)) < 3
% %             bottom_y = ii+10;
% %             break
% %         end
% %     end
% %     centery = top_y-((top_y-bottom_i)/2);
% %     for jj = savex-10:-10:savex-200   % find left
% %         if sum(frame(centery,jj,:)) < 3
% %             left_x = ii+10;
% %             break
% %         end
% %     end
% %     for jj = savex+10:10:savex+200   % find right
% %         if sum(frame(centery,jj,:)) < 3
% %             right_x = ii-10;
% %             break
% %         end
% %     end
% %     centerx = right_j-((right_j-left_j));
% % 
% %     % draw a box & center cross
% % 
% %     for kk = right_j:left_j
% %         frame(top_y,kk,1) = 255;
% %         frame(bottom_i,kk,1) = 255;
% %         frame(top_y,kk,2) = 0;
% %         frame(bottom_i,kk,2) = 0;
% %         frame(top_y,kk,3) = 0;
% %         frame(bottom_i,kk,3) = 0;
% %     end
% %     for kk = top_y:bottom_i
% %         frame(kk,left_j,1) = 255;
% %         frame(kk, right_j,1) = 255;
% %         frame(kk,left_j,2) = 0;
% %         frame(kk, right_j,2) = 0;
% %         frame(kk,left_j,3) = 0;
% %         frame(kk, right_j,3) = 0;
% %     end

    % % frame(centery:centery+40,centerx-3:centerx+3,1) = 255;
    % % frame(centery:centery-40,centerx-3:centerx+3,1) = 255;
    % % frame(centery-3:centery+3,centerx:centerx+40,1) = 255;
    % % frame(centery-3:centery+3,centerx:centerx-40,1) = 255;
    % % 
    % % frame(centery:centery+40,centerx-3:centerx+3,2) = 0;
    % % frame(centery:centery-40,centerx-3:centerx+3,2) = 0;
    % % frame(centery-3:centery+3,centerx:centerx+40,2) = 0;
    % % frame(centery-3:centery+3,centerx:centerx-40,2) = 0;
    % % 
    % % frame(centery:centery+40,centerx-3:centerx+3,3) = 0;
    % % frame(centery:centery-40,centerx-3:centerx+3,3) = 0;
    % % frame(centery-3:centery+3,centerx:centerx+40,3) = 0;
    % % frame(centery-3:centery+3,centerx:centerx-40,3) = 0;
% % 
    % image(frame)



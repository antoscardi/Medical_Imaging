clear all, close all, clc

%SAGITTAL SLICES 
%We perform the same operations but this time we use the sagittal slices of
%the MRI volume.
uiwait(msgbox('Now you are analysing the sagittal slices','ATTENTION','modal'));

% Load the file mri.mat
load MRIdata.mat

%Edge Detection kernel
hy =fspecial('prewitt'); % creates kernel along the y direction
hx = hy'; % x direction
hz=imrotate(hy,45);%rotates kernel of 45 degrees for edge detection along more than two directions 
%Average Filter kernel
h=fspecial('average',3);

%Creating first prompt asking if the user wants the image with noise or
%without
prompt1 = {'Enter 1 for clean image, 2 for salt&pepper noise, 3 for gaussian noise: '};
dlgtitle1 = 'SET THE NOISE';
dims = [1 80];
answer1 = inputdlg(prompt1,dlgtitle1,dims);
   
noise=str2num(answer1{1});

if noise==2
    prompt2 = {'Set the pepper&noise parameter: '};
    dlgtitle2 = 'SET PARAMETER';
    answer2 = inputdlg(prompt2,dlgtitle2,dims); %reads the density
    p=str2num(answer2{1}); %density of salt&pepper
end

if noise==3
    prompt3 = {'Set the M parameter: ', 'Set the V parameter: '};
    dlgtitle3 = 'SET PARAMETERS';
    answer3 = inputdlg(prompt3,dlgtitle3,dims); %reads M and V
    M=str2num(answer3{1}); %mean of gauss noise
    V=str2num(answer3{2}); %variance of gauss noise
end

T=figure(1);
T.Position=[20 20 1500 1500]; %sets the dimension of figure 1 (T) 

for u=65:192 %from previous analysis we saw that these are the slices in which
             %the lesion is visible.
    for i=111:-1:1
        if i==111 
           g=vol(u,:,i+1); 
        end 
        g=[g;vol(u,:,i)];
    end
    if noise==2
        g = imnoise(g,'salt & pepper',p); %applies salt&pepper noise
    end
    if noise==3
        g = imnoise(g,'gaussian',M,V); %applies gaussian noise
    end
    
    img_not_bin_tot(:,:,u)=g(:,:);
    
    %Filtering the noise if necessary.
    if noise==2 
        g=medfilt2(g,[6,6]);
    end
    if noise==3 
        g=imfilter(g,h,'conv');
    end
    
    %Edge detection
    t_img=im2double(g(:,:)); %converts image to double for imfilter() function
    
    %gradients on the different directions, using convolution
    Gx = imfilter(t_img, hx, 'conv'); 
    Gy = imfilter(t_img, hy, 'conv');
    Gz = imfilter(t_img, hz, 'conv');
    
    %final gradient
    gradient = abs(Gx)+abs(Gy)+abs(Gz);
    
    %edge detection through binarizing funtion
    ED = imbinarize(gradient,1);
    img(:,:,u)=ED;
    
    %plotting all the selected slices
    subplot(8,16,u-64), imshow(img(:,:,u),'InitialMagnification', 'fit'), title([u]);
end

%Opening second prompt to ask user which slices he wants to use for
%analysis and main slice which wants to visualize better.
prompt = {'Enter number of first usable slice:','Enter number of last usable slice:', 'Enter number of main usable slice:' };
dlgtitle = 'USABLE SLICE';
answer = inputdlg(prompt,dlgtitle,dims);
first= str2num(answer{1});
last= str2num(answer{2});
main= str2num(answer{3});

% Visualizing the main slice of the MRI
% Showing the main slice. 
%Here the user has to select the central points of the cropping rectangle
figure(2),imshow(img(:,:,main),'InitialMagnification', 'fit')

%Selecting 4 points of the image which are the midpoints of the sides of
%the rectangle that crops the image.
[xt,yt]=getpts;  
x1=round(xt(1)); %approximates the position of the pixel to the nearest integer value
x3=round(xt(3));
y2=round(yt(2));
y4=round(yt(4));

% The number of usable slices is set after 
num_of_usable_slices=last-first+1;
sub_number_int=round(sqrt(num_of_usable_slices))+1;

for f=1:num_of_usable_slices %f is a variable representing the slice number (1 corresponds to the first selected slice)
    g=img(:,:,first-1+f);
    
    %crops the image accordingly with the rectangle created before by the
    %user
    r = images.spatialref.Rectangle([x1 x3],[y4 y2]);
    cropped=imcrop(g,r);
    img_not_bin(:,:,f)=imcrop(img_not_bin_tot(:,:,first-1+f),r);
    
    for i=1:(y2-y4+1)
        for j=1:(x3-x1+1)
            tut_imm(i,j,f)=cropped(i,j);
        end
    end
end

%Opening one by one all the previously chosen slices to correct mistakes
%that could result from the automatic edge detection.
figure(3),
for f=1:num_of_usable_slices
    
    %The user performs some cuts in order to separate the white areas
    %outside the lesion, which are not to be considered in the
    %calculations, and the lesion itself.
    subplot(2,1,1), imshow(img_not_bin(:,:,f),'InitialMagnification', 'fit');
    subplot(2,1,2), imshow(tut_imm(:,:,f),'InitialMagnification', 'fit'), title('Isolate the lesion');
    [ai,bi]=getpts;
    x_iso=round(ai);
    y_iso=round(bi);
    if size(x_iso)~=0
        for i=1:size(x_iso)
            tut_imm(y_iso(i),x_iso(i),f)=0;
        end
    end
    
    %Using the function imfill() the user has to choose one or more points
    %inside the lesion in order to convert all the black adiacent ones to white, 
    %in order to be counted in the area.  
    subplot(2,1,2),imshow(tut_imm(:,:,f),'InitialMagnification', 'fit'), title('Identify a point inside the lesion');
    [a,b]=getpts;
    x=round(a);
    y=round(b);
    tut_imm(:,:,f)=imfill(tut_imm(:,:,f),[y x],4);
    subplot(2,1,2),imshow(tut_imm(:,:,f),'InitialMagnification', 'fit');
    pause(2) %showing the resulting image for 2 seconds.
    
    %Using the bwselect() function, that returns a binary image containing 
    %the objects that overlap the selected pixel. 
    %Objects are connected sets of on pixels, that is, pixels having a value of 1
    tut_imm(:,:,f)=bwselect(tut_imm(:,:,f), x, y, 4);
    subplot(2,1,2),imshow(tut_imm(:,:,f),'InitialMagnification', 'fit');
    pause(2) %showing the resulting image for 2 seconds.
end

% Showing the lesion zone of each slice after the primary recognition
figure(4)
for f=1:num_of_usable_slices
    num_slice=first-1+f;
    subplot(sub_number_int,sub_number_int,f), imshow(tut_imm(:,:,f),'InitialMagnification', 'fit'), title([num_slice]); 
end
    
%Opens a third prompt asking the user to insert the number of the slice
%that needs futher correction, 0 to exit.
num_to_cor=20;
while num_to_cor~=0
    cor=inputdlg("Insert the number of the slice you want to correct (insert 0 to end): ",'Corrector Tool', [1 50]);
    opts.Resize='on';
    num_to_cor = str2num(cor{1});
    if num_to_cor==0
        break   %when you insert 0 you exit from the while cycle and end the operation
    end
    
    %Otherwise, if you do not exit you will perform the same two steps you
    %performed before.
    slice=num_to_cor-first+1;
    figure(5)
    imshow(tut_imm(:,:,slice),'InitialMagnification', 'fit'), title('Select the pixels to convert in white (if none, select an already white one as last)');
    [xiw,yiw]=getpts;
    xw=round(xiw(:));
    yw=round(yiw(:));
    if size(xw)~=0
        for i=1:size(xw)
            tut_imm(yw(i),xw(i),slice)=1;
        end
    end
    figure(5)
    imshow(tut_imm(:,:,slice),'InitialMagnification', 'fit'), title('Select the pixels to convert in black (if none, select an already black one as last)');
    [xib,yib]=getpts;
    xb=round(xib(:));
    yb=round(yib(:));
    if size(xb)~=0
        for i=1:size(xb)
            tut_imm(yb(i),xb(i),slice)=0;
        end
    end
    figure(5)
    imshow(tut_imm(:,:,slice),'InitialMagnification', 'fit');
    
    pause(3); %shows the image for 3 sec in order to check if the lesion has been identified correctly
    close;
    
    figure(4)
    subplot(sub_number_int,sub_number_int,slice),imshow(tut_imm(:,:,slice),'InitialMagnification', 'fit'),title([num2str(num_to_cor),'#']);
end

%Calculations done on all the selected images in orther to calculate their
%areas.
for f=1:num_of_usable_slices
    cont(f)=0;
    for i=1:(y2-y4+1)
        for j=1:(x3-x1+1)
            if tut_imm(i,j,f)==1
                cont(f)=cont(f)+1;
            end
        end
    end
    cont(f)=cont(f)*0.9375*1.4; 
end

%Creating a table with the values of the areas of the different lesions of the different slices 
fig=figure(6);
volume=0
for i=1:num_of_usable_slices
    tab(i,1)=i+first-1;
    tab(i,2)=cont(i);
    
    %Calculates the total volume of the selected slices
    volume=volume + cont(i)*0.9375;
end

%Showing the table on a figure
uit=uitable(fig,'Data',tab);
uit.ColumnName={'Slice', 'Area'};
uit.RowName='';
pause(3);

%Showing the volume as a message that opens at the end of all operations
message = sprintf('The volume is %f mm^3', volume);
title = sprintf('Result');
uiwait(msgbox(message,title,'modal'));
pause(2); 





%AXIAL SLICES 
%We perform the same operations but this time we use the axial slices of
%the MRI volume.
uiwait(msgbox('Now you are analysing the axial slices','ATTENTION','modal'));
clear all, close all, clc

% Load the file mri.mat
load MRIdata.mat

%Edge Detection kernel
hy =fspecial('prewitt'); % creates kernel along the y direction
hx = hy'; % x direction
hz=imrotate(hy,45);%rotates kernel of 45 degrees for edge detection along more than two directions 
%Average Filter kernel
h=fspecial('average',3);

%Creating first prompt asking if the user wants the image with noise or
%without
prompt1 = {'Enter 1 for clean image, 2 for salt&pepper noise, 3 for gaussian noise: '};
dlgtitle1 = 'SET THE NOISE';
dims = [1 80];
answer1 = inputdlg(prompt1,dlgtitle1,dims);
   
noise=str2num(answer1{1});

if noise==2
    prompt2 = {'Set the pepper&noise parameter: '};
    dlgtitle2 = 'SET PARAMETER';
    answer2 = inputdlg(prompt2,dlgtitle2,dims); %reads the density
    p=str2num(answer2{1}); %density of salt&pepper
end

if noise==3
    prompt3 = {'Set the M parameter: ', 'Set the V parameter: '};
    dlgtitle3 = 'SET PARAMETERS';
    answer3 = inputdlg(prompt3,dlgtitle3,dims); %reads M and V
    M=str2num(answer3{1}); %mean of gauss noise
    V=str2num(answer3{2}); %variance of gauss noise
end

T=figure(7);
T.Position=[20 20 1500 1500]; %sets the dimension of figure 1 (T) 

for u=1:112 %from previous analysis we saw that these are the slices in which
             %the lesion is visible.
    g=vol(:,:,u);
    if noise==2
        g = imnoise(g,'salt & pepper',p); %applies salt&pepper noise
    end
    if noise==3
        g = imnoise(g,'gaussian',M,V); %applies gaussian noise
    end
    
    img_not_bin_tot(:,:,u)=g(:,:);
    
    %Filtering the noise if necessary.
    if noise==2 
        g=medfilt2(g,[6,6]);
    end
    if noise==3 
        g=imfilter(g,h, 'conv');
    end
    
    %Edge detection
    t_img=im2double(g(:,:)); %converts image to double for imfilter() function
    
    %gradients on the different directions, using convolution
    Gx = imfilter(t_img, hx, 'conv'); 
    Gy = imfilter(t_img, hy, 'conv');
    Gz = imfilter(t_img, hz, 'conv');
    
    %final gradient
    gradient = abs(Gx)+abs(Gy)+abs(Gz);
    
    %edge detection through binarizing funtion
    ED = imbinarize(gradient,1);
    img(:,:,u)=ED;
    
    %plotting all the selected slices
    subplot(8,16,u), imshow(img(:,:,u),'InitialMagnification', 'fit'), title([u]);
end

%Opening second prompt to ask user which slices he wants to use for
%analysis and main slice which wants to visualize better.
prompt = {'Enter number of first usable slice:','Enter number of last usable slice:', 'Enter number of main usable slice:' };
dlgtitle = 'USABLE SLICE';
answer = inputdlg(prompt,dlgtitle,dims);
first= str2num(answer{1});
last= str2num(answer{2});
main= str2num(answer{3});

% Visualizing the main slice of the MRI
% Showing the main slice. 
%Here the user has to select the central points of the cropping rectangle
figure(8),imshow(img(:,:,main),'InitialMagnification', 'fit')

%Selecting 4 points of the image which are the midpoints of the sides of
%the rectangle that crops the image.
[xt,yt]=getpts;  
x1=round(xt(1)); %approximates the position of the pixel to the nearest integer value
x3=round(xt(3));
y2=round(yt(2));
y4=round(yt(4));

% The number of usable slices is set after 
num_of_usable_slices=last-first+1;
sub_number_int=round(sqrt(num_of_usable_slices))+1;

for f=1:num_of_usable_slices %f is a variable representing the slice number (1 corresponds to the first selected slice)
    g=img(:,:,first-1+f);
    
    %crops the image accordingly with the rectangle created before by the
    %user
    r = images.spatialref.Rectangle([x1 x3],[y4 y2]);
    cropped=imcrop(g,r);
    img_not_bin(:,:,f)=imcrop(img_not_bin_tot(:,:,first-1+f),r);
    
    for i=1:(y2-y4+1)
        for j=1:(x3-x1+1)
            tut_imm(i,j,f)=cropped(i,j);
        end
    end
end

%Opening one by one all the previously chosen slices to correct mistakes
%that could result from the automatic edge detection.
figure(9),
for f=1:num_of_usable_slices
    
    %The user performs some cuts in order to separate the white areas
    %outside the lesion, which are not to be considered in the
    %calculations, and the lesion itself.
    subplot(2,1,1), imshow(img_not_bin(:,:,f),'InitialMagnification', 'fit');
    subplot(2,1,2), imshow(tut_imm(:,:,f),'InitialMagnification', 'fit'), title('Isolate the lesion');
    [ai,bi]=getpts;
    x_iso=round(ai);
    y_iso=round(bi);
    if size(x_iso)~=0
        for i=1:size(x_iso)
            tut_imm(y_iso(i),x_iso(i),f)=0;
        end
    end
    
    %Using the function imfill() the user has to choose one or more points
    %inside the lesion in order to convert all the black adiacent ones to white, 
    %in order to be counted in the area.  
    subplot(2,1,2),imshow(tut_imm(:,:,f),'InitialMagnification', 'fit'), title('Identify a point inside the lesion');
    [a,b]=getpts;
    x=round(a);
    y=round(b);
    tut_imm(:,:,f)=imfill(tut_imm(:,:,f),[y x],4);
    subplot(2,1,2),imshow(tut_imm(:,:,f),'InitialMagnification', 'fit');
    pause(2) %showing the resulting image for 2 seconds.
    
    %Using the bwselect() function, that returns a binary image containing 
    %the objects that overlap the selected pixel. 
    %Objects are connected sets of on pixels, that is, pixels having a value of 1
    tut_imm(:,:,f)=bwselect(tut_imm(:,:,f), x, y, 4);
    subplot(2,1,2),imshow(tut_imm(:,:,f),'InitialMagnification', 'fit');
    pause(2) %showing the resulting image for 2 seconds.
end

% Showing the lesion zone of each slice after the primary recognition
figure(10)
for f=1:num_of_usable_slices
    num_slice=first-1+f;
    subplot(sub_number_int,sub_number_int,f), imshow(tut_imm(:,:,f),'InitialMagnification', 'fit'), title([num_slice]); 
end
    
%Opens a third prompt asking the user to insert the number of the slice
%that needs futher correction, 0 to exit.
num_to_cor=20;
while num_to_cor~=0
    cor=inputdlg("Insert the number of the slice you want to correct (insert 0 to end): ",'Corrector Tool', [1 50]);
    opts.Resize='on';
    num_to_cor = str2num(cor{1});
    if num_to_cor==0
        break   %when you insert 0 you exit from the while cycle and end the operation
    end
    
    %Otherwise, if you do not exit you will perform the same two steps you
    %performed before.
    slice=num_to_cor-first+1;
    figure(11)
    imshow(tut_imm(:,:,slice),'InitialMagnification', 'fit'), title('Select the pixels to convert in white (if none, select an already white one as last)');
    [xiw,yiw]=getpts;
    xw=round(xiw(:));
    yw=round(yiw(:));
    if size(xw)~=0
        for i=1:size(xw)
            tut_imm(yw(i),xw(i),slice)=1;
        end
    end
    figure(11)
    imshow(tut_imm(:,:,slice),'InitialMagnification', 'fit'), title('Select the pixels to convert in black (if none, select an already black one as last)');
    [xib,yib]=getpts;
    xb=round(xib(:));
    yb=round(yib(:));
    if size(xb)~=0
        for i=1:size(xb)
            tut_imm(yb(i),xb(i),slice)=0;
        end
    end
    figure(11)
    imshow(tut_imm(:,:,slice),'InitialMagnification', 'fit');
    
    pause(3); %shows the image for 3 sec in order to check if the lesion has been identified correctly
    close;
    
    figure(10)
    subplot(sub_number_int,sub_number_int,slice),imshow(tut_imm(:,:,slice),'InitialMagnification', 'fit'),title([num2str(num_to_cor),'#']);
end

%Calculations done on all the selected images in orther to calculate their
%areas.
for f=1:num_of_usable_slices
    cont(f)=0;
    for i=1:(y2-y4+1)
        for j=1:(x3-x1+1)
            if tut_imm(i,j,f)==1
                cont(f)=cont(f)+1;
            end
        end
    end
    cont(f)=cont(f)*0.9375*0.9375; 
end

%Creating a table with the values of the areas of the different lesions of the different slices 
fig=figure(12);
volume=0
for i=1:num_of_usable_slices
    tab(i,1)=i+first-1;
    tab(i,2)=cont(i);
    
    %Calculates the total volume of the selected slices
    volume=volume + cont(i)*1.400;
end

%Showing the table on a figure
uit=uitable(fig,'Data',tab);
uit.ColumnName={'Slice', 'Area'};
uit.RowName='';
pause(3)

%Showing the volume as a message that opens at the end of all operations
message = sprintf('The volume is %f mm^3', volume);
title = sprintf('Result');
uuu=msgbox(message,title);

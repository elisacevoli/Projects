% Autore: Cevoli Elisa
% Politecnico di Torino - Teleriabilitazione
% Anno Accademico 2023/2024

clearvars
close all
clc

%% Import a pretrained network from an ONNX file
addpath('C:\Users\Elisa\Documents\MATLAB\Examples\R2023b\deeplearning_shared\EstimateBodyPoseUsingDeepLearningExample')
dataDir =  'C:\Users\Elisa\Documents\MATLAB\Examples\R2023b\deeplearning_shared\EstimateBodyPoseUsingDeepLearningExample'
%trainedOpenPoseNet_url = 'https://ssd.mathworks.com/supportfiles/vision/data/human-pose-estimation.zip'; 
%downloadTrainedOpenPoseNet(trainedOpenPoseNet_url,dataDir)
%unzip(fullfile(dataDir,'human-pose-estimation.zip'),dataDir);

% importo i layer di OpenPose
modelfile = fullfile(dataDir, 'human-pose-estimation.onnx');
layers = importONNXLayers(modelfile, "ImportWeights",true);
% rimuovo i layer di output che non uso
layers = removeLayers(layers,layers.OutputNames);
% mi creo la ver e propri rete
net = dlnetwork(layers);

%% Game's goal definition
score = 0;
TargetNumber = 10;
time = 0;
maxTime = 180;
time_end = 0;
load target_E2
    
%% load feedback
feedbackDir = "feedback";
[Y_countdown,Fs_countdown]=audioread(fullfile(feedbackDir, 'countdown.mp3')); %feedback countdown
[Y_gamestart,Fs_gamestart]=audioread(fullfile(feedbackDir, 'gamestart.mp3')); %feedback start game
[Y_scored,Fs_score]=audioread(fullfile(feedbackDir, 'target.mp3')); %feedback hit target

%% Game personalisation

% ACQUISIZIONE STATICA DEL SOGGETTO

% REAL TIME 
% cam = webcam(1); % Connection to the webcam  
% cam.Resolution = '640x480';
% 
% pause(3)
% sound(Y_countdown,Fs_countdown) % suono countdown
% countdown(3,'ACQUISIZIONE BACKGROUND', "bg.png")
% B = snapshot(cam); % BACKGROUND real-time
% 
% pause(3)
% sound(Y_countdown,Fs_countdown) % suono countdown
% countdown(3,'ACQUISIZIONE SOGGETTO', "sogg.png")
% I = snapshot(cam); % SOGGETTO real-time

outputFolder = 'E2'; % cartella in cui salvare le immagini acquisite

% OFFLINE
B = imread(fullfile(outputFolder, 'E2_0.bmp')); % BACKGROUND
I = imread(fullfile(outputFolder, 'E2_1.bmp')); % SOGGETTO


% Crea la cartella se non esiste
% if ~exist(outputFolder, 'dir')
%     mkdir(outputFolder);
% end
% imwrite(B,fullfile(outputFolder, 'E2_0.bmp')); % sfondo
% imwrite(I,fullfile(outputFolder, 'E2_1.bmp')); % frame iniziale

% è necessario rimuovere il mirror effect introdotto dalla webcam
I = INVERT_IMG(I); % Removal of mirror effect
B = INVERT_IMG(B);
% riduco le dimensioni dell'immagine di 1/3 per velocizzare il processo di
% joint identification --> imresize(immagine RGB, dimensione dell'immagine di output)
I = imresize(I, [round(size(I,1)/3) round(size(I,2)/3)]);
B = imresize(B, [round(size(B,1)/3) round(size(B,2)/3)]);

% Cambio range e shifto l'ordine dei canali (vendo rimosso mirror effect)
netInput = im2single(I)-0.5; % im2single mi trasforma in un range tra 0 e 1, togliendo 0,5 ottengo range da -0,5 a +0,5
netInput = netInput(:,:, [3 2 1]); % l'immagine tradizionle è rgb, ma la rete si aspetta bgr, quindi devo invertire l'ordine dei canali

% salvo l'immagine in un formato particolre: dlarray
% dlarray(Input Image, Data format )
netInput = dlarray(netInput, "SSC"); %SS: numero di righe e numero di colonne, C: numero di canali

% Predict heatmaps and part affinity fields (PAFs), which are output from
% the 2-D output convunational layers
% net è la rete, netInput è l'immagine modificata, 
% heatmaps: prob della presenza di una parte del corpo --> identificano i giunti
% pafs: vettori che connettono i giunti in modo coerente, assicurando che le connessioni seguano la struttura anatomica corretta.

[heatmaps, pafs] = predict(net, netInput);

% get the numeric heatmap data stored in the dlarry. The data has 19 channels.
% Each channels corresponds to a heatmap fo a unique body part, with one
% additional heatmap for the background
heatmaps = extractdata(heatmaps);
% rimuovo l'ultimo canale (background) poichè non è usato dall'algoritmo Openpose
heatmaps = heatmaps(:,:,1:end-1);

% get the numeric PAF data stored in the dlarry. The data has 38 channels.
% There are 2 channels for each type of body part pairing,, which represent
% the x- and y-component of the vector field
pafs = extractdata(pafs);

%%
params = getBodyPoseParameters;
minParts = 5; % mnimo numero di part da considerare per una valid pose
pafTh = 0.000000001; % quanto forte deve essere l'affinità tra due punti chiave per essere considerata valida.

params.MIN_PARTS = minParts;
params.PAF_THRESH = pafTh;

poses = getBodyPoses(heatmaps,pafs,params);
% fa il match tra l'immagine originale e pose
% skeleton è 1x18x2 in cui le righe sono i soggetti identificati, le
% colonne sono i joint e il x2 sono le coordinate (x,y)
renderBodyPoses(I,poses,size(heatmaps,1),size(heatmaps,2),params); % ho modificato la funzione renderBodyPoses perchè non aveva un output, e ho messo come output poses
% faccio un reshape per ottenere 18x2
skeleton = reshape(poses, [18, 2]); % sulle righe ho i joint e sulle colonne ho coordinata x e y
% Estrai le coordinate (x, y) dei joint non NaN
centroid = CoM_computation(skeleton,I,heatmaps);

%% GIUNTI OPENPOSE
% Naso (01), Collo (02), Spalla Destra (03), Gomito Destro (04), Polso Destro (05), 
% Spalla Sinistra (06), Gomito Sinistro (07), Polso Sinistro (08), Anca Destra (09), 
% Ginocchio Destro (10), Caviglia Destra (11), Anca Sinistra (12), Ginocchio Sinistro (13), 
% Caviglia Sinistra (14), Occhio Destro (15), Occhio Sinistro (16), Orecchio Destro (17), Orecchio Sinistro (18)

% polso destro --> 5° giunto
% polso sinistro --> 8° giunto

% spalla destro --> 3° giunto
% spalla sinistro --> 6° giunto

distanzaPolsi = 0;
distanzaSpalle = 0;
distanzaPolsi = joint_distance(skeleton,8,5,I,heatmaps);
distanzaSpalle = joint_distance(skeleton,3,6,I,heatmaps);

if ~isnan(distanzaPolsi), width = 6*distanzaPolsi; end
if(isnan(distanzaPolsi)), width = 12*distanzaSpalle; end
cen = centroid(1);

RW = [fix(1+width) fix(size(I,2)-width)]; %lower and upper limits
%target = [randi(RW, 1) centroid(2)]; %target random initialisation real-time
target = [targetE2(1,1) targetE2(1,2)]; % OFFLINE

%% Exergaming
level = [40, 30, 20];
%Graphic objects
set(gcf, 'Units', 'normalized', 'OuterPosition', [0 0 1 1]); % gcf = get current figure
h = imshow(I, 'InitialMagnification', 'fit'); %Image
hold on
g = plot(target(1), target(2),'Marker','o','LineWidth', 2, 'MarkerSize', level(3), 'MarkerEdgeColor', 'k', 'MarkerFaceColor','r'); %Target
hold on
centr = plot(centroid(1), centroid(2), 'Marker','o','LineWidth', 2, 'MarkerSize', level(3), 'MarkerEdgeColor', 'k', 'MarkerFaceColor','b'); %CoM

giro_while=1;
centr_iniziale = centroid;
CoM_start(1) = centr_iniziale(1); % coordinata x del centroide
time_start(1) = 0;

% sound(Y_countdown,Fs_countdown) % suono countdown
% countdown(3,'Il gioco inizia tra:', h)
sound(Y_gamestart,Fs_gamestart)

% offline
bmpFiles = dir(fullfile(outputFolder, '*.bmp'));
numBmpFiles = numel(bmpFiles); % Conta quanti file .bmp ci sono
% --------------

tic
for i = 1:numBmpFiles-1
    set(gcf, 'Units', 'normalized', 'OuterPosition', [0 0 1 1]); % gcf = get current figure
    sgtitle(['Score: ', num2str(score), '   Tempo (s): ', num2str(time)], 'FontSize', 30, 'FontWeight', 'bold', 'Color', 'blue');
    set(centr, 'Color', [0 0 1]) % blu
    
    % subject acquisition

    % I = snapshot(cam); %Static Subject Acquisition
    % imwrite(I, fullfile(outputFolder, ['E2_' num2str(giro_while) '.bmp'])); 
    I = imread(fullfile(outputFolder, ['E2_', num2str(i), '.bmp'])); % SOGGETTO offline
    target = [targetE2(i,1) targetE2(i,2)]; % OFFLINE
    I = INVERT_IMG(I);
    I = imresize(I, [round(size(I,1)/3) round(size(I,2)/3)]);
    netInput = im2single(I)-0.5; % im2single mi trasforma in un range tra 0 e 1, togliendo 0,5 ottengo range da -0,5 a +0,5
    netInput = netInput(:,:, [3 2 1]); % l'immagine tradizionle è rgb, ma la rete si aspetta bgr, quindi devo invertire l'ordine dei canali
    netInput = dlarray(netInput, "SSC"); %SS: numero di righe e numero di colonne, C: numero di canali
    
    % joint position identification

    [heatmaps, pafs] = predict(net, netInput);
    heatmaps = extractdata(heatmaps);
    heatmaps = heatmaps(:,:,1:end-1);
    pafs = extractdata(pafs);

    poses = getBodyPoses(heatmaps,pafs,params);
    renderBodyPoses(I,poses,size(heatmaps,1),size(heatmaps,2),params); % ho modificato la funzione renderBodyPoses perchè non aveva un output, e ho messo come output poses
    skeleton = reshape(poses, [18, 2]); % sulle righe ho i joint e sulle colonne ho coordinata x e y
    
    % COM computation
    centroid = CoM_computation(skeleton,I,heatmaps);
    
    h = imshow(I, 'InitialMagnification', 'fit'); % image
    hold on
    g = plot(target(1), target(2),'Marker','o','LineWidth', 2, 'MarkerSize', level(3), 'MarkerEdgeColor', 'k', 'MarkerFaceColor','r'); %Target
    hold on
    centr = plot(centroid(1), centroid(2), 'Marker','o','LineWidth', 2, 'MarkerSize', level(3), 'MarkerEdgeColor', 'k', 'MarkerFaceColor','b'); %CoM
    

    % Graphic objects update
    pause(0.005)
    set(h, 'CData', I) % aggiorno la proprietà CData dell'oggetto grafico h con l'immagine corrente I
    set(centr, 'XData', centroid(1), 'YData', centroid(2)) % aggiorno la proprietà XData dell'oggetto grafico centroid con la coordinata x del centro di massa (stessa cosa per y)
    set(g, 'XData', target(1), 'YData', target(2));
    
    TH = 3;
    if abs(centroid(1)-target(1))< TH % TARGET RAGGIUNTO!

        % feedback
        sound(Y_scored,Fs_score) % suono hit target
        set(centr,'MarkerFaceColor',[0 1 0]) % visivo
        pause(0.01)

        score = score+1; % aumento score (= somma dei target raggiunti)
        time_end(score) = toc;
        CoM_end(score) = centroid(1); % coordinata x del centroide
        speed(score)= abs(CoM_start(score)-CoM_end(score))/(time_end(score)-time_start(score));
        disp(['Target ' num2str(score) ' raggiunto'])

        % ri-inizializzo per un nuovo esercizio
        %target = ([randi(RW, 1) centroid(2)]); % target random initialisation real-time
        CoM_start(score+1) = CoM_end(score);
        time_start(score+1) = time_end(score);     
    else 
        time = toc;
    end
giro_while = giro_while +1;

end

disp('FINE')
clear cam


% soggetto ha raggiunto tutti (10) target
if score==TargetNumber
    gameOver(true)
end

% trascorso troppo tempo
if time>=maxTime
    gameOver(false)
   time=maxTime;
end

close(gcf);

%% Clinical report
if exist(fullfile(outputFolder, 'clinical_report_II.xls'), "file")
    delete('clinical_report_II.xls')
end

C = {'Type of excercise: IMPROVE YOUR MOTOR CONTROL','';...
     "RW (pixels)", RW(end)-RW(1);...
     'Speed (pixel/s)', speed;...
     'Total amount of time (s)', time_end(end);...
     'Number of target achived (out of 10)', score};
writecell(C,fullfile(outputFolder, 'clinical_report_II.xls'));


disp('FINE')


% ========================================================================




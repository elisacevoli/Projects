clc; clear; close all;

% Percorsi base

%base_path = 'C:\Users\erric\Politecnico di Torino\Cevoli Elisa - Lab SG3D condiviso\progetto\Bosphorus\Dataset';
%mesh_path = 'C:\Users\erric\Politecnico di Torino\Cevoli Elisa - Lab SG3D condiviso\progetto\Bosphorus\Surface z';
base_path = 'C:\Users\Tatiana Cordoba\OneDrive - Politecnico di Torino\Lab SG3D condiviso\progetto\Bosphorus\Dataset';
mesh_path = 'C:\Users\Tatiana Cordoba\OneDrive - Politecnico di Torino\Lab SG3D condiviso\progetto\Bosphorus\Surface z';

output_path = fullfile(base_path, 'lms_1');
if ~exist(output_path, 'dir')
    mkdir(output_path);
end

% Cerca tutti i file .lm3 nelle sottocartelle (train, val, test, ecc.)
lm3_files = dir(fullfile(base_path, '**', '*.lm3'));

% Definizione degli acronimi e nomi dei landmark
Acronym = {'oebsx', 'mebsx', 'iebsx', 'iebdx', 'mebdx', 'oebdx', ...
           'exsx', 'ensx', 'endx', 'exdx', ...
           'nossx', 'nosdx', 'alsx', 'prn', 'aldx', ...
           'chsx', 'ls', 'chdx', 'Sto', 'sl', 'li', ...
           'Men', 'elsx', 'eldx', ...
           'se'};
LandmarkName = {'Outer left eyebrow', 'Middle left eyebrow', 'Inner left eyebrow', ...
                'Inner right eyebrow', 'Middle right eyebrow', 'Outer right eyebrow', ...
                'Outer left eye corner', 'Inner left eye corner', 'Inner right eye corner', 'Outer right eye corner', ...
                'Nose saddle left', 'Nose saddle right', 'Left nose peak', 'Nose tip', 'Right nose peak', ...
                'Left mouth corner', 'Upper lip outer middle', 'Right mouth corner', 'Upper lip inner middle', ...
                'Lower lip inner middle', 'Lower lip outer middle', ...
                'Chin middle', 'Ear lobe left', 'Ear lobe right', ...
                'Sellion'};

for k = 1:length(lm3_files)
    try
        % --- Percorsi e nomi ---
        lm3_file = fullfile(lm3_files(k).folder, lm3_files(k).name);
        [~, name, ~] = fileparts(lm3_file);
        mesh_file = fullfile(mesh_path, [name, '.mat']);
        load(mesh_file)

        % Inizializza la tabella dei landmark
        cord_X = nan(size(Acronym)); cord_Y = nan(size(Acronym)); cord_Z = nan(size(Acronym));
        lm = table(Acronym', LandmarkName', cord_X', cord_Y', cord_Z', 'VariableNames', {'Acronym','LandmarkName','cord_X','cord_Y','cord_Z'});

        % --- Estrazione landmark noti dal file .lm3 ---
        fid = fopen(lm3_file, 'r');
        lines = textscan(fid, '%s', 'Delimiter', '\n'); fclose(fid);
        lines = lines{1};
        for i = 1:height(lm)
            idx = find(contains(lines, lm.LandmarkName{i}), 1, 'first');
            if ~isempty(idx)
                coordLine = strtrim(lines{idx+1});
                coords = sscanf(coordLine, '%f');
                if numel(coords) >= 3
                    lm.cord_X(i) = coords(1);
                    lm.cord_Y(i) = coords(2);
                    lm.cord_Z(i) = coords(3);
                end
            end
        end
        
        descr=geometric_descriptors(Z);
        K=descr.K;
        se=sellion_estimation(lm, X,Y,Z,K);
        %se=prova(lm, X,Y,Z,K);
        lm.cord_X(strcmp(lm.Acronym, 'se')) = se(1);
        lm.cord_Y(strcmp(lm.Acronym, 'se')) =se(2)-4;
        lm.cord_Z(strcmp(lm.Acronym, 'se')) = se(3);

        
        % --- Salva la tabella ---
        save(fullfile(output_path, ['lm_', name, '.mat']), 'lm');
        fprintf('Salvato: %s\n', ['lm_', name, '.mat']);

        % %VISUALIZZAZIONE
        figure()
        plot3(lm.cord_X, lm.cord_Y, lm.cord_Z,'r.', 'markers', 30);
        title('Landmarks 3D');
        xlabel('X');
        ylabel('Y');
        zlabel('Z');
        grid on;
        hold on;
        plot3(lm.cord_X(strcmp(lm.Acronym, 'se')), lm.cord_Y(strcmp(lm.Acronym, 'se')), lm.cord_Z(strcmp(lm.Acronym, 'se')), 'r.', 'MarkerSize', 25, 'LineWidth', 5);
        %legend({'Landmarks noti', 'Sellion'});
        %legend('Sellion')
        axis equal; grid on;
        xlabel('X'); ylabel('Y'); zlabel('Z');
        title('Sellion Estimation');
        mesh(X, Y, Z);
        %colormap gray;
        axis equal;
       

        
    catch ME
        warning('Errore con %s: %s', lm3_file, ME.message);
    end
end

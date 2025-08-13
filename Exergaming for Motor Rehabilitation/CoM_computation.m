function centroid = CoM_computation(skeleton,I,heatmaps)

% Rimuovi le righe contenenti NaN da skeleton
skeleton = skeleton(~any(isnan(skeleton), 2), :);

% Se non ci sono joint validi, ritorna un centroide vuoto
if isempty(skeleton)
    centroid = [NaN, NaN];
    return;
end

% Creazione dell'immagine vuota
imgSize = max(max(skeleton(:)), max(size(I))); % Dimensione massima tra tutte le coordinate e l'immagine
img = zeros(imgSize); % Dimensione massima tra tutte le coordinate (sia x che y)

% Disegno dei joint sull'immagine
for i = 1:size(skeleton, 1)
    x = skeleton(i, 1); % Coordinata x del joint
    y = skeleton(i, 2); % Coordinata y del joint
    img(y, x) = 1; % Imposta il valore del pixel a 1 per rappresentare il joint
end

% Utilizzo di regionprops per trovare il centroide
s = regionprops(img, 'Centroid');
centroid = s.Centroid;

% Calcolo del centroide manualmente
%x_coords = skeleton(:, 1);
%y_coords = skeleton(:, 2);

%centroid = [mean(x_coords), mean(y_coords)];


[centroid(1), centroid(2)] = convert_coords(centroid(1), centroid(2), size(I,1), size(I,2), size(heatmaps,1),size(heatmaps,2));

end
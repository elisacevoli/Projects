function countdown(duration, titleText, imageInput)
    % countdown - Mostra un countdown a schermo intero con immagine di sfondo
    %   duration - Durata del countdown in secondi
    %   titleText - Testo del titolo da mostrare
    %   imageInput - Percorso dell'immagine di sfondo o handle di immagine

    % Durata del countdown in secondi
    if nargin < 1
        duration = 10; % Default 10 secondi se non specificato
    end

    % Crea una figura a schermo intero per il countdown
    fig = figure('units', 'normalized', 'outerposition', [0 0 1 1], 'MenuBar', 'none', 'ToolBar', 'none', 'NumberTitle', 'off', 'Name', 'Countdown');

    % Imposta l'asse invisibile
    axis off;
    hold on;

    % Carica e mostra l'immagine di sfondo
    if ischar(imageInput) || isstring(imageInput)
        % Se l'input è un percorso di file
        img = imread(imageInput);
        image('CData', img, 'XData', [0 1], 'YData', [1 0], 'AlphaData', 0.5); % Inverti l'asse Y
    elseif ishandle(imageInput)
        % Se l'input è un handle di immagine
        imgHandle = imageInput;
        img = get(imgHandle, 'CData');
        image('CData', img, 'XData', [0 1], 'YData', [1 0], 'AlphaData', 0.5); % Inverti l'asse Y
    else
        error('imageInput deve essere un percorso di file o un handle di immagine.');
    end

    % Imposta il titolo e lo stile del testo
    sgtitle(titleText, 'FontSize', 30, 'FontWeight', 'bold', 'Color', 'blue', 'Interpreter', 'none');
    hText = text(0.5, 0.5, '', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'FontSize', 100, 'FontWeight', 'bold', 'Color', 'red');

    % Countdown loop
    for t = duration:-1:0
        set(hText, 'String', num2str(t));
        drawnow; % Aggiorna la figura
        pause(1); % Attendi 1 secondo
    end

    % % Countdown completato
    % set(hText, 'String', 'Time''s Up!');
    % drawnow;
    close(fig); % Chiude la figura
end

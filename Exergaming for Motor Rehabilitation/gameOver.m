function gameOver(victory)
    % gameOver - Mostra un messaggio di fine gioco a schermo intero
    %   victory - booleano, true per vittoria, false per perdita

    % Imposta il messaggio, il colore di sfondo  e il feedback sonoro in base al risultato
    feedbackDir = "feedback";
    if victory
        message = 'Hai completato tutti i target, complimenti!';
        symbol = '😊'; % smiley per vittoria
        bgColor = "#9ffa43"; % verde per vittoria
        [Y,Fs]=audioread(fullfile(feedbackDir, 'goodresult.mp3')); %feedback good result
    else
        message = 'Tempo scaduto, riprova!';
        symbol = '😊'; % smiley per vittoria
        bgColor = "#fde910"; % giallo per perdita
        [Y,Fs]=audioread(fullfile(feedbackDir, 'fail.mp3')); %feedback fail, try again
    end

    % Crea una figura a schermo intero
    fig = figure('units','normalized','outerposition',[0 0 1 1], 'MenuBar', 'none', 'ToolBar', 'none', 'NumberTitle', 'off', 'Name', 'Fine del Gioco');

    % Imposta il colore di sfondo
    set(fig, 'Color', bgColor);

    % Mostra il messaggio al centro dello schermo
    annotation('textbox', [0 0.4 1 0.2], 'String', [message, ' ', symbol], 'HorizontalAlignment', 'center', 'FontSize', 50, 'FontWeight', 'bold', 'EdgeColor', 'none', 'Color', 'black');

    % Rendi la figura a schermo intero
    set(fig, 'WindowState', 'fullscreen');
    
    % Feedback sonoro
    sound(Y,Fs); 

    % Imposta una funzione di chiusura della figura
    set(fig, 'CloseRequestFcn', @closeFigure);

    % Aspetta che l'utente prema un tasto per chiudere la figura
    waitforbuttonpress;

    % Chiudi la figura
    close(fig);
end

function closeFigure(~, ~)
    % Funzione di chiusura della figura
    delete(gcf);
end

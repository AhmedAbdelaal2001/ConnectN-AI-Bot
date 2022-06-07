%Ahmed Mohamed Ahmed Abdelaal, ID:1200486



clear
clc

%Welcome to connect_n! This game is similar to connect 4, but
%with some subtle differences. The number of rows and columns is not fixed
%to 6 and 7 (can be chosen by the user), and the number of pieces that
%accomplish a win when placed next to each others is not necessarily 4 and
%can be altered by the user, allowing the user to play connect_4,connect_5
%up until any number he wants. This program also makes use of the
%minimax algorithm in order to create a 'smart' AI
%which can very effectively play agains the user.

connect_n = input_check_num('Please enter the number of adjacent pieces required for winning: ',3);

fprintf('Welcome to connect%d!\n\n',connect_n);

ROW_COUNT = input_check_num('Please enter the desired number of rows: ',connect_n);

COLUMN_COUNT = input_check_num('Please enter the desired number of columns: ',connect_n);

opponent = input_check_string('Would you like to play against another human player or against an AI?\nType 0 if you want to play against a human:\nType 1 if you want to play agains an AI:\n',{'0','1'});
if opponent == 1
    depth = input_check_string('Please choose the desired difficulty.\nType 1 for easy:\nType 2 for medium:\nType 3 for hard:\nType 4 for very hard:\nType 5 for expert:\n',{'1','2','3','4','5'});
end


piece_color1 = input_check_string('Player 1, Would you like to play with a red piece or a yellow piece? Type "R" or "Y".\n(Note: R or Y must be placed between quotation marks ('''') to be accepted as valid inputs.):\n',{'R','Y'});
if upper(piece_color1) == 'R'
    piece_color2 = 'Y';
else
    piece_color2 = 'R';
end



if opponent==0
    turn = input_check_string('Choose who should play the first round:\nType 0 if you want Player 1 to play the first round:\nType 1 if you want player 2 to play the first round:\nType 2 if you want the choice to be random:\n',{'0','1','2'});
else
    turn = input_check_string('Choose who should play the first round:\nType 0 if you want to play the first round:\nType 1 if you want the AI to play the first round:\nType 2 if you want the choice to be random:\n',{'0','1','2'});
end
if turn==2
    turn = randi(0:1);
end


board_choice = input('Would you like to load a previous board?\nType 0 to load a previous board:\nType 1 to build a new board:\n');



game_over = 0;
board = create_board(ROW_COUNT, COLUMN_COUNT,board_choice);
display_board(board,ROW_COUNT, COLUMN_COUNT, piece_color1, piece_color2);
counter = 0;



while ~game_over
    %Ask for Player 1 Input.
    if turn==0
        fprintf('Player 1, Make your selection.\n(The chosen column must be between 1 and %d):\n',COLUMN_COUNT)
        col = input(' ');
        [board,win_move_check] = play_game(board,col,ROW_COUNT,COLUMN_COUNT,1,connect_n,piece_color1,piece_color2);
        if win_move_check
            [game_over,board] = replay_check('Player 1 Wins!',ROW_COUNT,COLUMN_COUNT,piece_color1, piece_color2);
            continue
        end
        
        
        
        %Ask for Player 2 Input.
    elseif ~opponent
        fprintf('Player 2, Make your selection.\n(The chosen column must be between 1 and %d):\n',COLUMN_COUNT)
        col = input(' ');
        [board,win_move_check] = play_game(board,col,ROW_COUNT,COLUMN_COUNT,2,connect_n,piece_color1,piece_color2);
        if win_move_check
            [game_over,board] = replay_check('Player 2 Wins!',ROW_COUNT,COLUMN_COUNT,piece_color1, piece_color2);
            continue
        end
    else
        
        
        
        %AI Plays.
        %col = pick_best_move(board,2,ROW_COUNT,COLUMN_COUNT,connect_n);
        col = pick_best_move(board,2,ROW_COUNT,COLUMN_COUNT,connect_n,depth,1,-inf,inf);
        [board,win_move_check] = play_game(board,col,ROW_COUNT,COLUMN_COUNT,2,connect_n,piece_color1,piece_color2);
        if win_move_check
            [game_over,board] = replay_check('AI Wins!',ROW_COUNT,COLUMN_COUNT,piece_color1, piece_color2);
            continue
        end
    end
    dc = draw_check(board,COLUMN_COUNT);
    if dc
        [game_over,board] = replay_check('Draw!',ROW_COUNT,COLUMN_COUNT,piece_color1, piece_color2);
        continue
    end
    turn = turn + 1;
    turn = rem(turn,2);
    counter = counter+1;
    if rem(counter,10)==0
        continue_choice = input('Would you like to continue the game or quit and save the current board?\nType 0 to quit and save the current board:\nType 1 to continue the game:\n');
        if ~continue_choice
            save_board_excel(board);
            break
        end
    end
end



function i_c_n = input_check_num(msg,low)

%Asks the user for an input, then checks if that input is lower than the
%value 'low'.

i_c_n = input(msg);
while i_c_n<low
    fprintf('Error! The number of pieces must be greater than %d.\n',low);
    i_c_n = input(msg);
    fprintf('\n');
end
fprintf('\n')
end



function i_c_s = input_check_string(msg,options)

%Asks the user for an input, then checks if that input can be found in the
%cell 'options.'

i_c_s = input(msg);
fprintf('\n');
while ~sum(strcmpi(string(i_c_s),options))
    fprintf('Error! Please enter a valid input within the options stated below:\n');
    fprintf('Available options: (')
    for i=1:length(options)-1
        fprintf('%s,',options{i});
    end
    fprintf('%s)',options{length(options)});
    fprintf('\n');
    i_c_s = input(' ');
end
end


function board = create_board(ROW_COUNT,COLUMN_COUNT,board_choice)

%Creates a matrix of zeros of dimensions (ROW_COUNT,COLUMN_COUNT), this
%will be the basis of the board.

if board_choice
    board = zeros(ROW_COUNT,COLUMN_COUNT);
else
    board = load_board_excel(ROW_COUNT,COLUMN_COUNT);
end
end




function display_border(COLUMN_COUNT)

%Displays borders in the form of dashes, to improve the appearance of the
%board to the user.

character = '-';
for num = 1:COLUMN_COUNT
    fprintf('%s',character);
end
fprintf('\n');
end



function display_board(board, ROW_COUNT, COLUMN_COUNT, piece_color1, piece_color2)

%Displays the board, separates elements by dashes from the function
%'display border' and displays numbers within the board matrix as suitable
%corresponding letters.

fprintf('\n')
for i = 1:ROW_COUNT
    fprintf('|     ')
    for j = 1:COLUMN_COUNT
        if board(i,j)==0
            symbol = ' ';
        elseif board(i,j)==1
            symbol = upper(piece_color1);
        else
            symbol = piece_color2;
        end
        location = symbol;
        fprintf('%s',location);
        fprintf('     |     ')
    end
    fprintf('\n');
    display_border(12*COLUMN_COUNT+1);
    fprintf('\n');
end
fprintf('      1');
for guide=2:COLUMN_COUNT
    fprintf('           %d',guide);
end
fprintf('\n');
end



function dp = drop_piece(board, row, col, piece)

%Creates a new board, where the position (row,col) is occupied by 'piece'.

board(row,col) = piece;
dp = board;
end



function ivl = is_valid_location(board, col, COLUMN_COUNT)

%Checks if the column is valid or not.

if col>0 && col<=COLUMN_COUNT && board(1,col)==0
    ivl = 1;
else
    ivl = 0;
end
end



function gnor = get_next_open_row(board,col,ROW_COUNT)

%Gets the lowest empty row withing the specified column.

for r=ROW_COUNT:-1:1
    if board(r,col) == 0
        gnor = r;
        return
    end
end
end



function wv = winning_move(board,piece,ROW_COUNT,COLUMN_COUNT,connect_n)

%Checks if any player has won the game.

wv = 0;
%Check Horizontal Locations for Win.
for c=1:COLUMN_COUNT-3
    for r=1:ROW_COUNT
        for wc = 0:connect_n-1
            if board(r,c+wc)==piece
                win_check = 1;
            else
                win_check = 0;
                break
            end
        end
        if win_check == 1
            wv = 1;
            return
        end
    end
end




%Check Vertical Locations for Win.
for c=1:COLUMN_COUNT
    for r=1:ROW_COUNT-3
        for wc = 0:connect_n-1
            if board(r+wc,c)==piece
                win_check = 1;
            else
                win_check = 0;
                break
            end
        end
        if win_check == 1
            wv = 1;
            return
        end
    end
end



%Check Negatively Sloped Diagonals for Win.
for c=1:COLUMN_COUNT-3
    for r=1:ROW_COUNT-3
        for wc = 0:connect_n-1
            if board(r+wc,c+wc)==piece
                win_check = 1;
            else
                win_check = 0;
                break
            end
        end
        if win_check == 1
            wv = 1;
            return
        end
    end
    
end



%Check Positively Sloped Diagonals for Win.
for c=1:COLUMN_COUNT-3
    for r=ROW_COUNT:-1:ROW_COUNT-2
        for wc = 0:connect_n-1
            if board(r-wc,c+wc)==piece
                win_check = 1;
            else
                win_check = 0;
                break
            end
        end
        if win_check == 1
            wv = 1;
            return
        end
    end
end
end



function c_e = count_element(array,element)

%Counts the number of elements having values equal to 'element' that are in
%the specified array.

c_e = 0;
for i=array
    if i==element
        c_e = c_e + 1;
    end
end
end



function score_w = evaluate_window(window,piece,connect_n)

%Gives a score to the window, this score reflects the quality of the
%window; the window receives a higher score if it can be filled to
%connect_n pieces easily by the player, and a lower score if it can be
%filled easily by the opponent.

score_w = 0;
window_piece_count = count_element(window,piece);
window_opponent_count = count_element(window,1);
window_empty_count = count_element(window,0);
for i=2:connect_n-1
    if window_piece_count == i && window_empty_count == connect_n-i
        score_w = score_w + 2^i;
    end
    if window_opponent_count == i && window_empty_count == connect_n-i
        score_w = score_w - 2^i + i;
    end
end
end



function score = score_position(board,piece,ROW_COUNT,COLUMN_COUNT,connect_n)

%Assigns a score to the entire board by calculating the scores of
%individual windows and summing those scores together. The output of this
%function reflects how desirable the board arrangement is; a higher score
%indicated higher chances of winning, and a lower score indicates lower
%chances of winning. Furthermore, the center column naturally boosts the
%score, since pieces placed at the center column open up more chances and
%opportunities for winning.

score = 0;
center_array_adj = zeros(1,COLUMN_COUNT);
%Score Center Column
if rem(COLUMN_COUNT,2)
    center_array = board(:,ceil(COLUMN_COUNT/2))';
else
    center_array = board(:,COLUMN_COUNT/2)';
    center_array_adj = board(:,COLUMN_COUNT/2+1)';
end
center_count = count_element(center_array,piece);
center_count_adj = count_element(center_array_adj,piece);
score = score + 3*(center_count + center_count_adj);

%Score Horizontal.
for r=1:ROW_COUNT
    row_array = board(r,:);
    for c = 1:COLUMN_COUNT-connect_n+1
        window = row_array(c:c+connect_n-1);
        score_w = evaluate_window(window,piece,connect_n);
        score = score + score_w;
    end
end

%Score Vertical.
for c=1:COLUMN_COUNT
    col_array = board(:,c)';
    for r=1:ROW_COUNT-connect_n+1
        window = col_array(r:r+connect_n-1);
        score_w = evaluate_window(window,piece,connect_n);
        score = score + score_w;
    end
end

%Score Positively Sloped Diagonal.
for r = ROW_COUNT:-1:connect_n
    for c = 1:COLUMN_COUNT-connect_n+1
        for i=0:connect_n-1
            window(i+1) = board(r-i,c+i);
        end
        score_w = evaluate_window(window,piece,connect_n);
        score = score + score_w;
    end
end

%Score Negatively Sloped Diagonal.
for r = 1:ROW_COUNT-connect_n+1
    for c = 1:COLUMN_COUNT-connect_n+1
        for i=0:connect_n-1
            window(i+1) = board(r+i,c+i);
        end
        score_w = evaluate_window(window,piece,connect_n);
        score = score + score_w;
    end
end
end



function [i_t_n,win_check1,win_check2] = is_terminal_node(board,ROW_COUNT,COLUMN_COUNT,connect_n)

%Checks the board for any piece arrangements that might end the game, so
%the function checks if the opponent has won, if the user has won, or if it
%is a draw, then outputs 3 ones/zeros corresponding to those 3 cases. This
%function will later be used in the 'minimax' function.

i_t_n = 0;
win_check1 = winning_move(board,1,ROW_COUNT,COLUMN_COUNT,connect_n);
win_check2 = winning_move(board,2,ROW_COUNT,COLUMN_COUNT,connect_n);
dc = draw_check(board,COLUMN_COUNT);
if win_check1 || win_check2 || dc
    i_t_n = 1;
end
end



function valid_locations = get_valid_locations(board,COLUMN_COUNT)

%Outputs an array of all the possible valid columns in which a piece can be
%dropped.

valid_locations = [];
for col=1:COLUMN_COUNT
    valid_column = is_valid_location(board, col, COLUMN_COUNT);
    if valid_column
        valid_locations = [valid_locations col];
    end
end
end



function dc = draw_check(board,COLUMN_COUNT)

%Checks if a draw has occured.

dc = 0;
valid_locations = get_valid_locations(board,COLUMN_COUNT);
if isempty(valid_locations)
    dc = 1;
end
end


function best_col = pick_best_move(board,piece,ROW_COUNT,COLUMN_COUNT,connect_n,depth,maximizingPlayer,alpha,beta)

%Uses the output of the minimax function to choose the best possible move
%for the AI.

valid_locations = get_valid_locations(board,COLUMN_COUNT);
best_score = -inf;
best_col = valid_locations(randi(length(valid_locations)));
for col=valid_locations
    row = get_next_open_row(board,col,ROW_COUNT);
    temp_board = board;
    temp_board = drop_piece(temp_board, row, col, piece);
    score = minimax(temp_board,depth-1,~maximizingPlayer,ROW_COUNT,COLUMN_COUNT,connect_n,alpha,beta);
    if score>best_score
        best_score = score;
        best_col = col;
    end
end
end



function new_score = minimax(board,depth,maximizingPlayer,ROW_COUNT,COLUMN_COUNT,connect_n,alpha,beta)

%The most interesting part of the program. This function allows the
%computer to look at all the possible future moves up to move 'depth'. in
%order to figure out which end arrangement yields the best score. The
%function uses recursion in order to accomplish this task, and it assumes
%that the opponent will always minimize the score as much as possible.
%Furthermore, alpha-beta pruning is used in order to optimize the process
%as much as possible.

valid_locations = get_valid_locations(board,COLUMN_COUNT);
[is_terminal,win_check_player,win_check_AI] = is_terminal_node(board,ROW_COUNT,COLUMN_COUNT,connect_n);
if depth == 0 || is_terminal
    if is_terminal
        if win_check_AI
            new_score = 1000000;
            return
        elseif win_check_player
            new_score = -1000000;
            return
        else %Game is over, no more valid moves.
            new_score = 0;
            return
        end
    else
        %Depth is zero.
        new_score = score_position(board,2,ROW_COUNT,COLUMN_COUNT,connect_n);
        return
    end
end
if maximizingPlayer
    new_score = -inf;
    for col=valid_locations
        row =  get_next_open_row(board,col,ROW_COUNT);
        b_copy = board;
        b_copy = drop_piece(board, row, col, 2);
        new_score = max(new_score,minimax(b_copy,depth-1,0,ROW_COUNT,COLUMN_COUNT,connect_n,alpha,beta));
        alpha = max(alpha,new_score);
        if alpha>=beta
            break
        end
    end
else %Minimizing Player
    new_score = inf;
    for col=valid_locations
        row =  get_next_open_row(board,col,ROW_COUNT);
        b_copy = board;
        b_copy = drop_piece(board, row, col, 1);
        new_score = min(new_score,minimax(b_copy,depth-1,1,ROW_COUNT,COLUMN_COUNT,connect_n,alpha,beta));
        beta = min(beta,new_score);
        if alpha>=beta
            break
        end
    end
end
end



function [pg1,pg2] = play_game(board,col,ROW_COUNT,COLUMN_COUNT,piece,connect_n,piece_color1,piece_color2)

%The function checks wether the column chosen by the user is valid or not,
%it the places the corresponding player's piece in the lowest empty row in
%that column, and checks for any winning arrangements.

ivl = is_valid_location(board,col,COLUMN_COUNT);
while ivl==0
    fprintf('Error! Column %d is not available. ',col);
    col = input('Please choose another suitable column: ');
    ivl = is_valid_location(board,col,COLUMN_COUNT);
end
row = get_next_open_row(board,col,ROW_COUNT);
pg1 = drop_piece(board,row,col,piece);
pg2 = winning_move(pg1,piece,ROW_COUNT,COLUMN_COUNT,connect_n);
display_board(pg1,ROW_COUNT, COLUMN_COUNT, piece_color1, piece_color2);
end



function [rc1,rc2] = replay_check(msg,ROW_COUNT,COLUMN_COUNT,piece_color1, piece_color2)

%Checks if the user wants to replay the game.

fprintf('%s\n',msg);
replay = input_check_string('Would you like to play again?\nType 1 to start a new game:\nType 0 to end the game:\n',{'0','1'});
if ~replay
    rc1 = 1;
    rc2 = 0;
else
    rc1 = 0;
    rc2 = create_board(ROW_COUNT,COLUMN_COUNT,1);
    display_board(rc2,ROW_COUNT, COLUMN_COUNT, piece_color1, piece_color2);
end
end



function save_board_excel(board)

%Saves board to an excel file.

xlswrite('board.xlsx',string(board));
end



function board = load_board_excel(ROW_COUNT,COLUMN_COUNT)

%Reads board from an excel file.

board = xlsread('board.xlsx');
for i=1:ROW_COUNT
    for j=1:COLUMN_COUNT
        board(i,j) = char(board(i,j));
    end
end
end
%%%%%%%%
% Heuristic that uses two criterias:
% Searches all empty slots where if a token was placed would make 4 in a row, each one of this free slots gives 100 points
% Searches all slots that are full and assigns a value depending on the distance to the center column, the values are:
% 0 1 2 3 2 1 0
% Points are always positive for x and negative for o


%returns the value based on the heuristic
value(Board, Value, heuristicJoan):-
	findall([Row, Column], areInBoard(Row, Column), Coords),
	sumValues(Coords,Board, Value).

%Sum the value of each slot
sumValues([],_,0).

sumValues([[Row, Column] | T], Board, Value) :-
	sumValues(T, Board, ValueRest),
	valueRowColumn(Row, Column, Board, ValueThis),
	Value is ValueRest + ValueThis.



%Returns the value of the slot defined by Row, Column
%Two different function depending on if its full or empty

%Case Empty:
%Searches if the placing a token there would make 4 in a row
%If it would for the 'x' it assigns 100 points
%If it would for the 'o' it assigns -100 points
%If it would for both the it assigns 0 points
valueRowColumn( Row, Column, Board, Value) :-
	%check if slot is empty
	nth0(Column, Board, ColumnElement),
	nth0(Row, ColumnElement, Element),
	var(Element), !,

	%Find connected tokens in all directions (up, right, down, left, right-up, right-down, left-up, left-down)
	nextColumnRow(Row, Column, [1,1], NextRow, NextColumn),
	nextColumnRow(Row, Column, [-1, -1], PreviousRow, PreviousColumn),

	%Horizontal
	countTokensDirection(Board, [1,0], TokenRight, Row, NextColumn, NbTokensRight),
	countTokensDirection(Board, [-1,0], TokenLeft, Row, PreviousColumn, NbTokensLeft),

	%vertical
	countTokensDirection(Board, [0,1], TokenUp, NextRow, Column, NbTokensUp),
	countTokensDirection(Board, [0,-1], TokenDown, PreviousRow, Column, NbTokensDown),

	%diagonal up
	countTokensDirection(Board, [1,1], TokenRightUp, NextRow, NextColumn, NbTokensRightUp),
	countTokensDirection(Board, [-1,1], TokenLeftUp, NextRow, PreviousColumn, NbTokensLeftUp),

	%diagonal down
	countTokensDirection(Board, [1,-1], TokenRightDown, PreviousRow, NextColumn, NbTokensRightDown),
	countTokensDirection(Board, [-1,-1], TokenLeftDown, PreviousRow, PreviousColumn, NbTokensLeftDown),

	%checks if the placing and x would make 4 connected tokens
	((has3Conected('x', TokenLeft, TokenRight, NbTokensLeft, NbTokensRight) ;
	has3Conected('x', TokenDown, TokenUp, NbTokensDown, NbTokensUp);
	has3Conected('x', TokenLeftUp, TokenRightUp, NbTokensLeftUp, NbTokensRightDown);
	has3Conected('x', TokenLeftDown, TokenRightDown, NbTokensLeftDown, NbTokensRightUp))->
		XHas3 is 1
		;
		XHas3 is 0
	),
	%checks if placing an o would make 4 connected tokens
	((has3Conected('o', TokenLeft, TokenRight, NbTokensLeft, NbTokensRight) ;
	has3Conected('o', TokenDown, TokenUp, NbTokensDown, NbTokensUp);
	has3Conected('o', TokenLeftUp, TokenRightUp, NbTokensLeftUp, NbTokensRightUp);
	has3Conected('o', TokenLeftDown, TokenRightDown, NbTokensLeftDown, NbTokensRightUp))->
		OHas3 is 1
		;
		OHas3 is 0
	),
	(OHas3 == XHas3->
		Value is 0
	;
	%Value depending on the rules
	OHas3 == 1 -> Value is -100
	;
	XHas3 == 1 -> Value is 100
	;
	Value is 0
	)
	.

%Value of row column if its full
%slots have a value depending on the distance to the center column (0,1,2,3,2,1,0)
%the value of the slot is multiplied by -1 if its an o
valueRowColumn( Row, Column, Board, Value) :-
	nth0(Column, Board, ColumnElement),
	nth0(Row, ColumnElement, Element),
	valueFullSlot(Row, Column, Element, Board, ValuePosSlot),
	modifier(Element, Modifier),
	Value is ValuePosSlot*Modifier,
	!.

%From the number of tokens connected in one side and the number connected of tokens to the other side
%(note that the other side of down is up and the other side of left is right, etc...)
%Finds if placing the TokenThatHas3 would make 4 connected tokens
has3Conected(TokenThatHas3,Token1, Token2, Nb1, Nb2) :-
	TokenThatHas3 == Token1,
	Nb1 > 2;
	TokenThatHas3 = Token2,
	Nb2 > 2;
	TokenThatHas3 == Token1,
	TokenThatHas3 == Token2,
	NewN is Nb1 + Nb2,
	NewN > 2.


modifier('o', -1).
modifier('x', 1).

%Values of the slots in the board when they are full
%the closer to the center the higher the value
valueFullSlot(_, 0, _, _, 0).
valueFullSlot(_, 1, _, _, 1).
valueFullSlot(_, 2, _, _, 2).
valueFullSlot(_, 3, _, _, 3).
valueFullSlot(_, 4, _, _, 2).
valueFullSlot(_, 5, _, _, 1).
valueFullSlot(_, 6, _, _, 0).





// Until there's metaprogramming, I have to do this.


Token_Kind :: enum {
	Invalid
	
	,EOF ,Comment ,_LiteralBegin ,Identifier ,Integer ,Float ,Char ,String ,_LiteralEnd ,_AbsoluteCapture ,_OperatorBegin ,_AssignOpBegin ,AddEq ,SubEq ,MulEq ,DivEq ,ModEq ,AndEq ,OrEq ,XorEq ,AndNotEq ,ShiftLeftEq ,ShiftRightEq ,Increment ,Decrement ,_AssignOpEnd ,ShiftLeft ,ShiftRight ,_ComparisonBegin ,CmpAnd ,CmpOr ,CmpEq ,CmpNotEq ,CmpLtEq ,CmpLt ,CmpGtEq ,CmpGt ,_ComparisonEnd ,Eq ,Not ,Hash ,Ampersand ,Arrow ,AndNot ,And ,Or ,Xor ,Caret ,Question ,_ArithmeticBegin ,Sub ,Add ,Mul ,Div ,Mod ,_ArithmeticEnd ,OpenParen ,CloseParen ,OpenBracket ,CloseBracket ,OpenBrace ,CloseBrace ,Colon ,Semicolon ,Period ,Comma ,Ellipsis ,NewLine ,_OperatorEnd ,_KeywordBegin ,Alias ,When ,If ,Else ,For ,In ,Switch ,Case ,Default ,Break ,Continue ,Fallthrough ,Defer ,Return ,Func ,Struct ,Class ,Union ,Enum ,Cast ,Load ,Import ,Static ,_KeywordEnd ,Count
	
};

TOKEN_NAMES := []string{
	"Invalid"
	
	,"EOF" ,"Comment" ,"" ,"Identifier" ,"Integer" ,"Float" ,"Char" ,"String" ,"" ,"" ,"" ,"" ,"+=" ,"-=" ,"*=" ,"/=" ,"%=" ,"&=" ,"|=" ,"~=" ,"&~=" ,"<<=" ,">>=" ,"++" ,"--" ,"" ,"<<" ,">>" ,"" ,"&&" ,"||" ,"==" ,"!=" ,"<=" ,"<" ,">=" ,">" ,"" ,"=" ,"!" ,"#" ,"@" ,"->" ,"&~" ,"&" ,"|" ,"~" ,"^" ,"?" ,"" ,"-" ,"+" ,"*" ,"/" ,"%" ,"" ,"(" ,")" ,"[" ,"]" ,"{" ,"}" ,":" ,";" ,"." ,"," ,"..." ,"\n" ,"" ,"" ,"alias" ,"when" ,"if" ,"else" ,"for" ,"in" ,"switch" ,"case" ,"default" ,"break" ,"continue" ,"fallthrough" ,"defer" ,"return" ,"func" ,"struct" ,"class" ,"union" ,"enum" ,"cast" ,"load" ,"import" ,"static" ,"" ,""
	
};




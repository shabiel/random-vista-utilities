KBANSAM ; VEN/SMH - Private utilities ;2014-07-16  2:04 PM
 ;;
S(INPUT) ; Summarize Routine
 X ^%ZOSF("RSEL")
 N R S R=$NA(^UTILITY($J))
 Q:'$L($O(@R@(""))) ; don't do anything if no routines present
 N RTN S RTN="" ; Routine holder
 N WM S WM=$C(27)_"[1;37;45m" ; Bright White on Magneta VT100 formatting
 N RES S RES=$C(27)_"[0m" ; Reset VT100 formatting
 F  S RTN=$O(@R@(RTN)) Q:'$L(RTN)  D
 . Q:'$L($T(+1^@RTN)) ; Quit if not present
 . W WM,$T(+1^@RTN),RES,! ; Print first line. Fancy!!
 . ; Loop, grab each line, grab first character, print line if char isn't space or tab
 . N I,L,A F I=2:1 S L=$T(+I^@RTN) Q:'$L(L)  D
 . . S A=$A($E(L)) 
 . . W:A'=32&(A'=9) $P(L,";"),?50,$$TRIM^XLFSTR($P(L,";",2)),!
 . W !! ; Make room for next
 QUIT

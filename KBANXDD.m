KBANXDD ; VEN/SMH - Export the DD for VCS;2013-12-31  4:37 PM
 ;;1.0;Sam's Local Utilities
 ;
DRIVER ; Interactive Driver
 N X,Y,DIRUT,DTOUT,DIROUT,DUOUT,DIR,DA ; Input and Output for ^DIC and ^DIR
 N DIC,DLAYGO,DINUM ; Ditto
 S DIC="^DIC(",DIC(0)="AEMQ",DIC("A")="Select File: " D ^DIC
 Q:Y<0
 N FN S FN=+Y
 N FLDS
 F  D  Q:Y<0
 . N DIRUT,DTOUT,DIROUT,DUOUT
 . N DIC S DIC="^DD("_+FN_",",DIC(0)="AEMQ",DIC("A")="Select Field: " D ^DIC
 . S:Y>0 FLDS(+Y)=""
 N DIRUT,DTOUT,DIROUT,DUOUT
 N OLDPATH S OLDPATH=$S($G(DUZ)>0:$G(^DISV(DUZ,"KBANXDD")),1:"")
 S DIR(0)="F",DIR("A")="Select Path: ",DIR("B")=$S($L(OLDPATH):OLDPATH,1:$$DEFDIR^%ZISH()) D ^DIR
 I $D(DIRUT) QUIT
 N PATH S PATH=Y
 S:$G(DUZ) ^DISV(DUZ,"KBANXDD")=PATH
 N DIRUT,DTOUT,DIROUT,DUOUT
 S DIR(0)="F",DIR("A")="Select File name: ",DIR("B")=$S($O(FLDS(""))>0:"F"_FN_"D"_$O(FLDS(""))_".ZWR",1:"F"_FN_".ZWR") D ^DIR
 I $D(DIRUT) QUIT
 N FILE S FILE=Y
 ;
 N POP
 D OPEN^%ZISH("FILE1",PATH,FILE,"W")
 I $G(POP) W "CANNOT WRITE TO FILE SYSTEM",! QUIT
 U IO
 D FH(FN)
 I '$O(FLDS("")) D X(FN) ; Whole File
 E  N I F I=0:0 S I=$O(FLDS(I)) Q:'I  D XF(FN,I) ; Just the fields selected
 D CLOSE^%ZISH("FILE1")
 QUIT
 ;
FH(FN) ; PEP - Print Header for ZWR file
 W $T(+0)," - ","FILE ",FN,!
 W $$NOW^XLFDT()," ","ZWR",!
 QUIT
 ;
X(FN) ; PEP ; Export A File Number's DD
 ; Input: File Number
 ; Output: DD printed to STDOUT
 N G S G=$NA(^DIC(FN)) I $D(@G) N S F S=0,"%","%D" D ZWRITE($NA(@G@(S))) ; Print DIC File Info if it exists
 S G=$NA(^DD(FN)) D ZWRITE(G) ; Print the DD; TODO: prints indexes too!
 N I F I=0:0 S I=$O(^DD("IX","B",FN,I)) Q:'I  D ZWRITE($NA(^DD("IX",I))) ; Print NS Indexes
 N I F I=0:0 S I=$O(^DD("KEY","B",FN,I)) Q:'I  D ZWRITE($NA(^DD("KEY",I))) ; Print Keys
 ;
 ; Print subfiles DDs etc
 I $D(^DD(FN,"SB")) N SB F SB=0:0 S SB=$O(^DD(FN,"SB",SB)) Q:'SB  D  ; For each Subfile
 . D ZWRITE($NA(^DD(SB))) ; Print Subfiles; TODO: prints indexes too!
 . N I F I=0:0 S I=$O(^DD("IX","B",SB,I)) Q:'I  D ZWRITE($NA(^DD("IX",I))) ; Print NS Indexes
 . N I F I=0:0 S I=$O(^DD("KEY","B",SB,I)) Q:'I  D ZWRITE($NA(^DD("KEY",I))) ; Print Keys
 ;
 QUIT
 ;
XF(FN,FLD) ; PEP ; Extract a field's DD
 ; Input: File Number and Field Number
 ; Don't print the ^DIC section
 D ZWRITE($NA(^DD(FN,FLD))) ; Print the DD for this field.
 N I F I=0:0 S I=$O(^DD("IX","F",FN,FLD,I)) Q:'I  D ZWRITE($NA(^DD("IX",I)))
 N I F I=0:0 S I=$O(^DD("KEY","F",FN,FLD,I)) Q:'I  D ZWRITE($NA(^DD("KEY",I)))
 QUIT
 ;
D(FN) ; PEP ; Extract Data from a file; ONLY WORKS FOR WHOLE FILES, NOT SUBFILES
 N G S G=$$CREF^DILF($$ROOT^DILFD(FN))
 N I F I=0:0 S I=$O(@G@(I)) Q:'I  D ZWRITE($NA(@G@(I)))
 QUIT
 ;
PT(FN,NS) ; PEP ; Extract Print Templates
 ; FN = File number
 ; NS = Namespace. Include these templates that start with these letters. Optional.
 ; ^DIPT("F11005","A1AE FULL SUMMARY BY DATE",1540)=1
 ; ^DIPT("F11005","A1AE PATCH COMPL/COMMENT RPT",1542)=1
 ; ^DIPT("F11005","A1AE PATCH COMPLIANCE PRT",1541)=1
 S NS=$G(NS)
 N S S S="F"_+FN ; Loop sub
 N PTN S PTN=""
 F  S PTN=$O(^DIPT(S,PTN)) Q:PTN=""  Q:($L(NS)&($E(NS,1,$L(NS))'=$E(PTN,1,$L(NS))))  D
 . N IEN S IEN=$O(^(PTN,"")) 
 . D ZWRITE($NA(^DIPT(IEN)),1,"IEN")
 QUIT
 ;
ZWRITE(NAME,QS,QSREP)	; Replacement for ZWRITE ; Public Proc
 ; Pass NAME by name as a closed reference. lvn and gvn are both supported.
 ; QS = Query Subscript to replace
 ; QSREP = Query Subscrpt replacement
 ; : syntax is not supported (yet)
 S QS=$G(QS),QSREP=$G(QSREP)
 I QS,'$L(QSREP) S $EC=",U-INVALID-PARAMETERS,"
 N INCEXPN S INCEXPN=""
 I $L(QSREP) S INCEXPN="S $G("_QSREP_")="_QSREP_"+1"
 N L S L=$L(NAME) ; Name length
 I $E(NAME,L-2,L)=",*)" S NAME=$E(NAME,1,L-3)_")" ; If last sub is *, remove it and close the ref
 N ORIGLAST S ORIGLAST=$QS(NAME,$QL(NAME))       ; Get last subscript upon which we can't loop further
 N ORIGQL S ORIGQL=$QL(NAME)         ; Number of subscripts in the original name
 I $D(@NAME)#2 W $S(QS:$$SUBNAME(NAME,QS,QSREP),1:NAME),"=",$$FORMAT(@NAME),!        ; Write base if it exists
 ; $QUERY through the name. 
 ; Stop when we are out.
 ; Stop when the last subscript of the original name isn't the same as 
 ; the last subscript of the Name. 
 F  S NAME=$Q(@NAME) Q:NAME=""  Q:$QS(NAME,ORIGQL)'=ORIGLAST  D
 . W $S(QS:$$SUBNAME(NAME,QS,QSREP),1:NAME),"=",$$FORMAT(@NAME),!
 QUIT
 ;
SUBNAME(N,QS,QSREP) ; Substitue subscript QS's value with QSREP in name reference N
 N VARCR S VARCR=$NA(@N,QS-1) ; Closed reference of name up to the sub we want to change
 N VAROR S VAROR=$S($E(VARCR,$L(VARCR))=")":$E(VARCR,1,$L(VARCR)-1)_",",1:VARCR_"(") ; Open ref
 N B4 S B4=$NA(@N,QS),B4=$E(B4,1,$L(B4)-1) ; Before sub piece, only used in next line
 N AF S AF=$P(N,B4,2,99) ; After sub piece
 QUIT VAROR_QSREP_AF
 ;
FORMAT(V)	; Add quotes, replace control characters if necessary; Public $$
 ;If numeric, nothing to do.
 ;If no encoding required, then return as quoted string.
 ;Otherwise, return as an expression with $C()'s and strings.
 I +V=V Q V ; If numeric, just return the value.
 N QT S QT="""" ; Quote
 I $F(V,QT) D     ;chk if V contains any Quotes
 . N P S P=0          ;position pointer into V
 . F  S P=$F(V,QT,P) Q:'P  D  ;find next "
 . . S $E(V,P-1)=QT_QT        ;double each "
 . . S P=P+1                  ;skip over new "
 I $$CCC(V) D  Q V  ; If control character is present do this and quit
 . S V=$$RCC(QT_V_QT)  ; Replace control characters in "V"
 . S:$E(V,1,3)="""""_" $E(V,1,3)="" ; Replace doubled up quotes at start
 . N L S L=$L(V) S:$E(V,L-2,L)="_""""" $E(V,L-2,L)="" ; Replace doubled up quotes at end
 Q QT_V_QT ; If no control charactrrs, quit with "V"
 ;
CCC(S)	;test if S Contains a Control Character or $C(255); Public $$
 Q:S?.E1C.E 1
 Q:$F(S,$C(255)) 1
 Q 0
 ;
RCC(NA)	;Replace control chars in NA with $C( ). Returns encoded string; Public $$
 Q:'$$CCC(NA) NA                         ;No embedded ctrl chars
 N OUT S OUT=""                          ;holds output name
 N CC S CC=0                             ;count ctrl chars in $C(
 N C255 S C255=$C(255)                   ;$C(255) which Mumps may not classify as a Control
 N C                                     ;temp hold each char
 N I F I=1:1:$L(NA) S C=$E(NA,I) D           ;for each char C in NA
 . I C'?1C,C'=C255 D  S OUT=OUT_C Q      ;not a ctrl char
 . . I CC S OUT=OUT_")_""",CC=0          ;close up $C(... if one is open
 . I CC D
 . . I CC=256 S OUT=OUT_")_$C("_$A(C),CC=0  ;max args in one $C(
 . . E  S OUT=OUT_","_$A(C)              ;add next ctrl char to $C(
 . E  S OUT=OUT_"""_$C("_$A(C)
 . S CC=CC+1
 . Q
 Q OUT
 ;
TEST D EN^XTMUNIT($T(+0),1) QUIT
T1 ; @TEST subscript substitutions
 D CHKEQ^XTMUNIT($$SUBNAME($NA(^DIPT(2332,0)),1,"IEN"),"^DIPT(IEN,0)")
 D CHKEQ^XTMUNIT($$SUBNAME($NA(^DIPT("A",123,0)),2,"IEN"),"^DIPT(""A"",IEN,0)")
 QUIT
T2 ; @TEST print templates
 D PT(11005)
 QUIT

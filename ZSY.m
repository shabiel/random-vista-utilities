ZSY     ;SIS/LM - Simple System Status and Related Utilities ;05/08/12  13:08
        ;;1.0;ZUTILITIES;
        ;
        ; This routine is free software / public domain.  Use it as you wish.
        ; The author makes no claim as to the accuracy or suitability of this
        ; computer program.  In no event will the author or Sea Island Systems, Inc.
        ; be liable for any damages, lost effort, inability to deploy, or anything
        ; else relating to a decision to use this routine.
        ;
SS      ;[public] - System Status display - Fall through to here
        I $$CACHE D CSS Q  ;If Cache
        I $$ENVCK() L +^ZSY(0):2 ;If GT.M
        E  W !,"Please try again." Q
        N I,SIGUSR1,ZPID,ZPS
        ; SIGUSR1 - http://www.comptechdoc.org/os/linux/programming/linux_pgsignals.html
        S SIGUSR1=10,^ZSY(0)=$J K ^ZSY($J)
        D PLIST($NA(ZPS)) ;Acquire process list
        F I=1:1 Q:'$D(ZPS(I))  D  ;Issue interrupts
        .; $ZSIGPROC - GT.M Programmer's Guide Version 4.4 Unix Edition - Page 325
        .S ZPID=$$PID(ZPS(I)) I ZPID>0,$ZSIGPROC(ZPID,SIGUSR1)
        .Q
        D HDR F I=1:1:5 H 1 Q:$D(^ZSY($J,$J))  ;Wait for interrupt of 'self' to complete
        D INDEX
        D DISPLAY
        K ^ZSY($J) L -^ZSY(0)
        Q
EXAMJOB ;[public] - Interactively examine a process
JOBEXAM ;[public] - Alias
        I $$CACHE D CJOBXAM Q
        I $$ENVCK(1) N DIR,DIRUT,X,Y
        E  W !,"Please try again." Q
        F  D  Q:$D(DIRUT)
        .W !
        .S DIR(0)="F^1:30",DIR("A")="Enter process ID"
        .S DIR("?")="Enter a process ID to examine or 'SY' to display System Status."
        .D ^DIR Q:$D(DIRUT)
        .I $$UC(Y)="SY" D ZSY Q
        .D ONEJOB(Y)
        .Q
        W !
        Q
KILLJOB ;[public] - Interactively kill a MUMPS process
RESJOB  ;[public] - Alias
        I $$CACHE D CRESJOB Q
        I $$ENVCK(1) N DIR,DIRUT,X,Y
        E  W !,"Please try again." Q
        F  D  Q:$D(DIRUT)
        .W !
        .S DIR(0)="F^1:30",DIR("A")="Enter process ID"
        .S DIR("?")="Enter the process ID you wish to kill or 'SY' for System Status."
        .D ^DIR Q:$D(DIRUT)
        .I $$UC(Y)="SY" D ZSY Q
        .D ONEKILL(Y)
        .Q
        W !
        Q
ENVCK(ZPARM)    ;[public] - Environment checks for this routine
        ;ZPARM=[Optional] Parameter specifying optional checks
        ;
        ; Returns '1' (TRUE) for environment OK, '0' (FALSE) for check failed.
        ;
        I $ZV?1"GT.M".E  ;GT.M
        E  W !,"This routine/option requires GT.M." Q:$Q 0 Q
        I $ZINTERRUPT["JOBEXAM^ZU"  ;$ZINTERRUPT
        E  W !,"Invalid value for Intrinsic Special Variable $ZINTERRUPT" Q:$Q 0 Q
        I $T(JOBEXAM+1^ZU)["NTRUPT^ZSY" ;JOBEXAM^ZU
        E  W !,"Missing or invalid configuration in JOBEXAM^ZU" Q:$Q 0 Q
        ;^DIR in JOBEXAM and JOBKILL contexts
        I $G(ZPARM)=1,'($T(^DIR)]"")!'($T(^DICD)]"") D  Q:$Q 0 Q
        .W !,"Missing required Fileman routine"
        .Q
        ;
        Q:$Q 1 Q
        ;
PLIST(ZNAM)     ;[private] - Generate relevant processes list
        ; ZNAM=[Optional] $NAME of results array
        ;
        S:'$L($G(ZNAM)) ZNAM=$NA(ZNAM) ;Default to call by reference
        N I,ZCMD,ZDEV,Z
        ; PIPE - http://tinco.pair.com/bhaskar/gtm/doc/books/pg/UNIX_manual/ch09s07.html
        S I=0,ZDEV="procs" O ZDEV:(command="ps -ef|grep $USER":readonly)::"PIPE"
        U ZDEV F  Q:$ZEOF=1  R Z:2 Q:'$T  D:Z]""  ;Do not wait more than two seconds
        .S ZCMD=$P($E(Z,49,999)," ")
        .S:ZCMD="mumps"!(ZCMD=($ZTRNLNM("gtm_dist")_"/mumps")) I=I+1,@ZNAM@(I)=Z
        .Q
        C ZDEV
        Q
INDEX   ;[private] - Create a cross-reference for the "V" (variables) subscript
        ;
        N I,J,V,X S J=0 F  S J=$O(^ZSY($J,J)) Q:'J  D
        .F I=1:1 Q:'$D(^ZSY($J,J,"V",I))  D
        ..S X=$G(^ZSY($J,J,"V",I)),V=$P(X,"="),^ZSY($J,J,"ZV",V)=$P(X,"=",2,99)
        ..Q
        .Q
        Q
HDR     ;[private] - Display header
        ; SIS/LM 5/8/2013 - Display environment (next 3 lines)
        N UCI,VOL,Y S (UCI,VOL,Y)=""
        I $T(GETENV^%ZOSV)]"" D GETENV^%ZOSV S UCI=$P(Y,"^"),VOL=$P(Y,"^",2)
        W:UCI]"" !?20,"System Status for UCI="_UCI_", VOL="_VOL,!
        ; SIS/LM 5/8/2013 - End insert
        W !," $JOB        Device[s]         Routine        Package            VistA User"
        W !,"======|======================|=========|===================|===================="
        Q
DISPLAY ;[private] - Display data for each process
        N I,J,ZCNT,ZD,ZPID,ZR,ZRTN S ZCNT=0
        F I=1:1 Q:'$D(ZPS(I))  D  ;For each mumps process
        .S ZPID=$$PID(ZPS(I)),ZR=$NA(^ZSY($J,ZPID))
        .W !,$G(ZPID) ;$JOB (Process ID), Col 1
        .I '$D(@ZR) W ?7,"<data unavailable>" Q  ;No interrupt data
        .S ZD=$P($G(@ZR@("D",1))," ") S:ZD=0 ZD=" no device"
        .W ?7,ZD ;First device, Col 8
        .S ZRTN=$P($P($G(@ZR@("S",4))," "),"^",2)
        .W ?30,ZRTN ;Routine, Col 31
        .W ?40,$$PKG(ZRTN) ;Package, Col 41
        .W ?60,$E($$USER($G(@ZR@("ZV","DUZ"))),1,20)
        .F J=2:1 Q:'$D(@ZR@("D",J))  S ZD="" D  ; Additional device(s)
        ..S:@ZR@("D",J)["REMOTE=" ZD=$P($P(@ZR@("D",J),"REMOTE=",2)," ")
        ..I ZD]"" W !?7,ZD S ZD=""
        .S ZCNT=ZCNT+1
        .Q
        W !!?2,ZCNT_" processes",!
        Q
PID(PS) ;[private] - Process ID from ps return
        ;PS=[Required] String containing process ID as second display column
        N I,L,Y S PS=$G(PS),L=$L(PS),Y="" Q:'L Y
        F I=1:1:L Q:$E(PS,I)=" "
        F I=I+1:1:L Q:'($E(PS,I)=" ")
        Q +$E(PS,I,L)
        ;
PKG(ZRTN)       ;[private] - VistA PACKAGE for named routine
        ; ZRTN=[Required] Name of routine
        ;
        Q:ZRTN="" ""
        Q:ZRTN="GTM$DMOD" "GT.M DIRECT MODE"
        Q:ZRTN="%ZTM" "TASKMAN"
        Q:ZRTN="%ZTM0" "TASKMAN STARTUP HANG"
        Q:ZRTN="%ZTMS1" "TASK SUB-MANAGER"
        Q:ZRTN="XMKPLQ" "MAILMAN (MOVER)"
        Q:ZRTN="XMTDT" "MAILMAN (TICKLER)"
        Q:ZRTN="%ZISTCPS" "TCP/IP SERVER"
        ; Insert additional custom names here
        N ZL,ZY,Z S Z=ZRTN S:$E(Z)="%" Z=$E(Z,2,99) S ZL=$L(Z)+1,ZY=""
        F  S ZL=ZL-1 Q:'ZL  S Z=$E(Z,1,ZL) I $D(^DIC(9.4,"C",Z)) S ZY=$O(^(Z,"")) Q
        I ZY Q $E($P($G(^DIC(9.4,ZY,0)),"^"),1,18)
        S ZY=$E($P($T(@("+2^"_ZRTN)),";",4),1,18)
        Q $S(ZY?1U.E:ZY,1:"")
        ;
USER(DUZ)       ;[private] - VistA User
        ; DUZ=[Required] File 200 IEN
        Q $P($G(^VA(200,+$G(DUZ),0)),"^")
        ;
ONEJOB(ZPID)    ;[private] - Display details of selected process
        I '$L($G(ZPID)) W !,"Missing process ID" Q
        L +^ZSY(0):2 E  W !,"Please try later." Q
        S ^ZSY(0)=$J K ^ZSY($J)
        I '$$VALIDATE(ZPID) W !,"Invalid process ID" Q
        N SIGUSR1 S SIGUSR1=10 ;http://www.comptechdoc.org/os/linux/programming/linux_pgsignals.html
        I $ZSIGPROC(ZPID,SIGUSR1) ;GT.M Programmer's Guide Version 4.4 Unix Edition - Page 325
        D WAIT^DICD
        N I,J,X,Z F I=1:1:5 Q:$D(^ZSY($J,ZPID))  H 1
        H 1     I '$D(^ZSY($J,ZPID)) W !,"Process '"_ZPID_"' details not found." Q
        D INDEX M Z=^ZSY($J,ZPID)
        K ^ZSY($J) L -^ZSY(0)
        ; Variable Z has process details
        W !!,"Process ID: "_ZPID I '(+$G(Z("D",1))=0) W ?20,$P(Z("D",1)," ")
        W !!,"Stack:",!
        S I="" F J=1:1 S I=$O(Z("S",I),-1) Q:'I  W !,J_".",?4,$P(Z("S",I)," ") Q:Z("S",I)["$ZINTERRUPT"
        I $L($G(Z("ZPOS"))) W !,">> ",Z("ZPOS"),!
        W !!,"Variables:",!
        S X="" F  S X=$O(Z("ZV",X)) Q:X=""  W !,X_"="_Z("ZV",X)
        Q
ONEKILL(ZPID)   ;[private] - Kill selected process
        I '$L($G(ZPID)) W !,"Missing process ID" Q
        I '$$VALIDATE(ZPID) W !,"Invalid process ID" Q
        I ZPID=$J W !,"Not permitted" Q
        I '$$SURE W !,"No action taken" Q
        ; SIGKILL - http://www.comptechdoc.org/os/linux/programming/linux_pgsignals.html
        N SIGKILL S SIGKILL=9
        I $ZSIGPROC(ZPID,SIGKILL)
        E  W !,"Kill signal issued",!
        Q
VALIDATE(ZPID)  ;[private] - Validate Process ID
        ;
        N Y S Y=0 Q:'$L(ZPID) Y
        N I,ZPS D PLIST(.ZPS)
        F I=1:1 Q:'$D(ZPS(I))  I $$PID(ZPS(I))=$G(ZPID) S Y=1
        Q Y
SURE(B) ;[private] - Confirm action
        ;B=[Optional] DIR("B") - Default is NO
        ;Return = 1 (YES) or 0 (NO or abort)
        ;
        N DIR,DIRUT,X,Y
        S DIR(0)="Y",DIR("A")="Are you sure",DIR("B")=$G(B,"NO")
        D ^DIR Q:$D(DIRUT) 0
        Q +Y
        ;
UC(X)   ;
        Q $TR($G(X),"abcdefghijklmnopqrstuvwxyz","ABCDEFGHIJKLMNOPQRSTUVWXYZ")
        ;
NTRUPT  ;[private] - Interrupt completion - Transfer data to ^ZSY
        N ZSY S ZSY=$G(^ZSY(0)) D:ZSY>0
        .S:%ZPOS["^" ^ZSY(ZSY,$J,"ZPOS")=$S(%ZPOS["GTM$DMOD":%ZPOS,1:$T(@%ZPOS))
        .ZSHOW "DSV":^ZSY(ZSY,$J)
        .Q
        Q
        ;*************************** ^ZSY for Cache ***************************
        ;
CSS     ;[public] - Cache/VistA System Status
        ; Cache environment assumed
        ;
        N ZPS
        D CPLIST($NA(ZPS)) ;Acquire process list for current namespace
        D CCLEAN ;Prune the JOB - VistA USER table in ^ZSY("C")
        D HDR,CDISPLAY ;Display VistA System Status for current namespace
        Q
CJOBXAM ; Cache continuation of JOBEXAM
        ;
        W !,"JOBEXAM is not supported in the Cache version of this routine."
        W !,"Use the System Management Portal or D ^JOBEXAM in %SYS namespace."
        W !
        Q
CRESJOB ; Cache continuation of RESJOB
        ;
        W !,"KILLJOB is not supported in the Cache version of this routine."
        W !,"Use the System Management Portal or D ^RESJOB in %SYS namespace."
        W !
        Q
CACHE() ;[public] - Environment check
        ; Return true if and only if this is Cache for Windows
        ;
        I $S($ZV?1"Cache".E:1,1:0) Q $ZVERSION(1)=2
        Q 0
        ;
CNMSP() ;[private] - Current Cache namespace
        ; Cache environment assumed
        ;
        I $$VERSION^%ZOSV()<2010 Q $ZU(5)
        Q $NAMESPACE
        ;
CPLIST(ZNAM) ;[private] - Generate relevant Cache processes list
        ; Return PIDs of current namespace only
        ; ZNAM=[Optional] $NAME of results array
        ;
        S:'$L($G(ZNAM)) ZNAM=$NA(ZNAM) ;Default to call by reference
        N I,NS,P,USER,X,Y
        S I=0,NS=$$CNMSP,X="" F  S X=$O(^$JOB(X)) Q:X=""  D
        .I X=$J D  Q  ;This process
        ..S Y=X_U_$I_U_$T(+0)_U_$G(DUZ) ;PID^Device^Routine^VistA User
        ..S I=I+1,@ZNAM@(I)=Y
        ..Q
        .S P=##CLASS(%SYS.ProcessQuery).%OpenId(X) Q:'(P.CanBeExamined)
        .Q:'(P.NameSpace=NS)!(P.IsGhost) ;Current namespace + Live only
        .S Y=X_U_P.CurrentDevice_U_P.Routine ;PID^Device^Routine
        .S USER=$G(^ZSY("C",X),$G(^XUTL("XQ",X,"DUZ")))
        .S Y=Y_U_USER ;VistA User
        .S I=I+1,@ZNAM@(I)=Y
        .Q
        Q
CDISPLAY ;[private] - Display data for each process
        N I,J,ZCNT,ZD,ZPID,ZR,ZRTN S ZCNT=0
        F I=1:1 Q:'$D(ZPS(I))  D  ;For each mumps process
        .S ZPID=$P(ZPS(I),U)
        .W !,$G(ZPID) ;$JOB (Process ID), Col 1
        .S ZD=$P(ZPS(I),U,2) I $L(ZD)>22 S ZD=$E(ZD,1,20)_".."
        .W ?7,ZD ;Current device, Col 8
        .S ZRTN=$P(ZPS(I),U,3)
        .W ?30,ZRTN ;Routine, Col 31
        .W ?40,$$PKG(ZRTN) ;Package, Col 41
        .W ?60,$E($$USER($P(ZPS(I),U,4)),1,20) ;Vista USER
        .S ZCNT=ZCNT+1
        .Q
        W !!?2,ZCNT_" processes",!
        Q
CDUZ	;[private] - Map From $JOB to USER
        ;
        S ^ZSY("C",$J)=$G(DUZ)
        Q
CCLEAN ;[private] - Prune the JOB - USER list -
        ; Delete non-current entries from ^ZSY("C")
        ;
        N X S X="" F  S X=$O(^ZSY("C",X)) Q:X=""  K:'$D(^$JOB(X)) ^ZSY("C",X)
        Q
        
.

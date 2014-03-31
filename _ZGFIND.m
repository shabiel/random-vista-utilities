%ZGFIND ; Timson's private collection ;2014-03-25  2:38 PM; 7/20/12 9:11am
 N S,X,Y
 I $G(DUZ) S S=$G(^DISV(DUZ,"%ZGFIND"))
 E  S S=""
 W !,"OPEN GLOBAL ROOT: "
 I $L(S) W S_"//"
 R S
 I S="" S S=$G(^DISV(DUZ,"%ZGFIND"))
 Q:S?.P
 I $G(DUZ) S ^DISV(DUZ,"%ZGFIND")=S
 S X=S_""""")" S X=$Q(@X)
R R !?9,"SEARCH FOR STRING: ",Y,!! Q:Y?.P
 F  Q:X'[S  D  S X=$Q(@X)
 .I @X[Y W !,X,"=",@X
 Q

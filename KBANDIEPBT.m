KBANDIEPBT ; OSE/SMH - Input, Print, and Sort Template Analysis;2018-01-29  10:10 AM
 ;;0.1;OSEHRA;
 ;
 ; This routine finds non-self files that are pointed to by a template
 ; 
DIBT ; [Public] Sort template analysis
 n outputData
 d DIBTCOL(.outputData)
 d DIBTOUT(.outputData,"/tmp/","DIBTOUT.csv")
 quit
 ;
DIET ; [Public] Input template analysis
 n outputData
 d DIETCOL(.outputData)
 d DIETOUT(.outputData,"/tmp/","DIETOUT.csv")
 quit
 ;
DIPT ; [Public] Print template analysis
 n outputData
 d DIPTCOL(.outputData)
 d DIPTOUT(.outputData,"/tmp/","DIPTOUT.csv")
 quit
 ; 
DIBTCOL(outputData) ; [Private] Sort Template Data Collection
 ; for each template
 n dibt f dibt=0:0 s dibt=$o(^DIBT(dibt)) q:'dibt  d
 . quit:'$data(^DIBT(dibt,0))                 ; get valid ones only
 . new name s name=$p(^DIBT(dibt,0),U)
 . new file s file=$p(^DIBT(dibt,0),U,4)
 . n isSort s isSort=$order(^DIBT(dibt,2,0))  ; make sure they are sort templates
 . if 'isSort quit
 . ;
 . ; walk through each field
 . n line f line=0:0 s line=$order(^DIBT(dibt,2,line)) quit:'line  do
 .. n lineData ; We have some variances on how the data is stored (lines below)
 .. i $d(^(line))#2   s lineData=^DIBT(dibt,2,line)
 .. i $d(^(line,0))#2 s lineData=^DIBT(dibt,2,line,0)
 .. ;
 .. ; some vital data
 .. n lineFile s lineFile=$piece(lineData,U)
 .. i '$data(^DD(lineFile)) quit  ; bad DD
 .. n lineField s lineField=$piece(lineData,U,2)
 .. n lineFieldSpec s lineFieldSpec=$p(lineData,U,3)
 .. ;
 .. ; if it's the same file, and not a relational field, we are not interested
 .. i lineFile=file,(lineFieldSpec'[":"&(lineFieldSpec'[" IN ")) quit
 .. ;
 .. ; if the parent is the same file, and ditto, we are still not interested
 .. i $$PARENT(lineFile)=file,(lineFieldSpec'[":"&(lineFieldSpec'[" IN ")) quit
 .. ;
 .. ; We are interested
 .. ; Do we have the field?
 .. i lineField="" do
 ... ;
 ... ; no we don't so get the fields using DICOMP
 ... n X
 ... d EXPR^DICOMP(lineFile,"dmFITSL",lineFieldSpec)
 ... i '$d(X) quit
 ... ; X("USED")="404.51^.07;404.57^.02"
 ... i X("USED")="" quit  ; not an expression that uses fields
 ... n pairs,pair f pairs=1:1:$l(X("USED"),";") d
 .... s pair=$p(X("USED"),";",pairs)
 .... n thisFile  s thisFile=$p(pair,U,1)
 .... n thisField s thisField=$p(pair,U,2)
 .... i thisFile=file quit
 .... s outputData(file,thisFile,thisField)=dibt_U_name
 .. ;
 .. ; we have a field. Take it at face value
 .. e  s outputData(file,lineFile,lineField)=dibt_U_name
 quit
 ;
DIBTOUT(outputData,outputPath,outputFile) ; [Private] Sort Template Data Output
 n POP
 d OPEN^%ZISH("file1",outputPath,outputFile,"W")
 i POP quit
 u IO
 n file,dstFile,dstField,dibtIEN,dibtName
 n c s c=","
 w "SORT TEMPLATE IEN,SORT TEMPLATE NAME,SOURCE FILE,DESTINATION FILE,DESTINATION FIELD",!
 f file=0:0 s file=$o(outputData(file)) q:'file  d
 . f dstFile=0:0 s dstFile=$o(outputData(file,dstFile)) q:'dstFile  d
 .. f dstField=0:0 s dstField=$o(outputData(file,dstFile,dstField)) q:'dstField  d
 ... n data s data=outputData(file,dstFile,dstField)
 ... s dibtIEN=$p(data,U,1)
 ... s dibtName=$p(data,U,2)
 ... w dibtIEN_c_dibtName_c_file_c_dstFile_c_dstField,!
 d CLOSE^%ZISH("file1")
 quit
 ;
DIETCOL(outputData) ; [Private] Input Template Data Collection
 ; for each template
 ; s outputData(file,thisFile,thisField)=dibt_U_name
 n diet f diet=0:0 s diet=$o(^DIE(diet)) q:'diet  do
 . quit:'$data(^DIE(diet,0))                 ; get valid ones only
 . new name s name=$p(^DIE(diet,0),U)
 . new file s file=$p(^DIE(diet,0),U,4)
 . ;
 . ; for each file in the input template
 . n line f line=0:0 s line=$o(^DIE(diet,"DR",line)) q:line>98  q:line=""  do  ; 99 is reserved for some compiled code
 .. n lineFile f lineFile=0:0 s lineFile=$o(^DIE(diet,"DR",line,lineFile)) q:'lineFile  q:(lineFile'=+lineFile)  do
 ... if lineFile=file quit  ; DR file same as our file; not interested
 ... if $$PARENT(lineFile)=file quit  ; ditto, for parent
 ... n fields s fields=^DIE(diet,"DR",line,lineFile)
 ... n fieldIndex,field f fieldIndex=1:1:$l(fields,";") do
 .... s field=$piece(fields,";",fieldIndex)
 .... ;
 .... ; various tests for the field
 .... i field="" quit       ; empty field. Can happen!
 .... ;
 .... n X s X=field d ^DIM  ; is it M code?
 .... i $d(X) quit          ; line is M code
 .... ;
 .... ; range like .01:5
 .... i $l(field,":")=2,(+$p(field,":"))=$p(field,":") do  quit
 ..... n start s start=$p(field,":",1)
 ..... n end     s end=$p(field,":",2)
 ..... i $data(^DD(lineFile,start)) s outputData(file,lineFile,start)=diet_U_name
 ..... n eachField s eachField=start
 ..... f  s eachField=$o(^DD(lineFile,eachField)) q:eachField>end  q:eachField=""  do
 ...... s outputData(file,lineFile,eachField)=diet_U_name
 .... ;
 .... i $e(field)="@" quit  ; jump to another place in the template. Not a field
 .... s field=+field
 .... i '$data(^DD(lineFile,field)) quit  ; field doesn't exist
 .... s outputData(file,lineFile,field)=diet_U_name
 quit
 ;
DIETOUT(outputData,outputPath,outputFile) ; [Private] Input Template Data Output
 n POP
 d OPEN^%ZISH("file1",outputPath,outputFile,"W")
 i POP quit
 u IO
 n file,dstFile,dstField,dietIEN,dietName
 n c s c=","
 w "INPUT TEMPLATE IEN,INPUT TEMPLATE NAME,SOURCE FILE,DESTINATION FILE,DESTINATION FIELD",!
 f file=0:0 s file=$o(outputData(file)) q:'file  d
 . f dstFile=0:0 s dstFile=$o(outputData(file,dstFile)) q:'dstFile  d
 .. f dstField=0:0 s dstField=$o(outputData(file,dstFile,dstField)) q:'dstField  d
 ... n data s data=outputData(file,dstFile,dstField)
 ... s dietIEN=$p(data,U,1)
 ... s dietName=$p(data,U,2)
 ... w dietIEN_c_dietName_c_file_c_dstFile_c_dstField,!
 d CLOSE^%ZISH("file1")
 quit
 ;
DIPTCOL(outputData) ; [Private] Print Template Data Collection
 ; for each template
 n dipt f dipt=0:0 s dipt=$o(^DIPT(dipt)) q:'dipt  d
 . quit:'$data(^DIPT(dipt,0))                 ; get valid ones only
 . new name s name=$p(^DIPT(dipt,0),U)
 . new file s file=$p(^DIPT(dipt,0),U,4)
 . ;
 . ; debug
 . ; b:name="ZBJM FEE BASIS LIST"
 . ; debug
 . ;
 . ; for each field
 . new fileNamePrint set fileNamePrint=1
 . new line f line=0:0 s line=$o(^DIPT(dipt,"F",line)) q:'line  do
 .. new lineContents s lineContents=^DIPT(dipt,"F",line)
 .. new fieldDataIndex for fieldDataIndex=1:1:$l(lineContents,"~") do
 ... new fieldData set fieldData=$p(lineContents,"~",fieldDataIndex)
 ... quit:fieldData=""
 ... n fields s fields=$p(fieldData,";")
 ... ;
 ... ; analyze the fields
 ... ;
 ... ; See if we have a multiple navigation. These are noted in the first piece
 ... ; as a series of numbers like 50,1,2,5...
 ... ; don't process these any further if we find them
 ... ; We don't process them as they mean we don't branch out to other files
 ... ; --we just trace our own file down.
 ... n fieldsUpright s fieldsUpright=1
 ... n fieldIndex f fieldIndex=1:1:$l(fields,",") do  q:'fieldsUpright
 .... n field s field=$p(fields,",",fieldIndex)
 .... i field'=+field!(field<0) s fieldsUpright=0
 ... i fieldsUpright quit
 ... ;
 ... ; Exclude transition lines
 ... ; We are not interested in the lines that switch files (e.g. in 52: 'PROVIDER:')
 ... n ignoreTransition s ignoreTransition=0
 ... n fieldIndex f fieldIndex=1:1:$l(fields,",") do  q:ignoreTransition
 .... n field s field=$p(fields,",",fieldIndex)
 .... n nextField s nextField=$p(fields,",",fieldIndex+1)
 .... i $e(nextField)=U set ignoreTransition=1 quit
 ... q:ignoreTransition
 ... ;
 ... ; exclude print only fields
 ... ; also find M code fields
 ... n printOnlyField s printOnlyField=0
 ... n fieldIsMCode s fieldIsMCode=0
 ... n fieldIndex f fieldIndex=1:1:$l(fields,",") do  q:printOnlyField  q:fieldIsMCode
 .... n field s field=$p(fields,",",fieldIndex)
 .... n extField s extField=$p(fields,",",fieldIndex,99)
 .... d  q:fieldIsMCode
 ..... n X s X=extField D ^DIM
 ..... i $D(X) s fieldIsMCode=1 d
 ...... s fieldIsMCode("MCode")=extField
 ...... s fieldIsMCode("nonMCode")=$p(fields,extField)
 ...... s $e(fieldIsMCode("nonMCode"),$l(fieldIsMCode("nonMCode")))="" ; remove comma
 .... ;
 .... i $e(field)="""",$e(field,$l(field))="""" s printOnlyField=1
 ... i printOnlyField quit
 ... ;
 ... ; Now, process non-M code fields
 ... ; Best template to test this with: MAGV-PAT-QUERY
 ... ; NB: This is a recursive search; each search updates the pointerFile variable
 ... ; We only want the last entry in the pointerFile chain to file the data if there
 ... ; is a field we want to grab
 ... n pointerFile s pointerFile=0
 ... if 'fieldIsMCode n fieldIndex f fieldIndex=1:1:$l(fields,",") do
 .... n field s field=$p(fields,",",fieldIndex)
 .... n nextField s nextField=$p(fields,",",fieldIndex+1)
 .... i field<0 s pointerFile=-field
 .... i field>0,'pointerFile quit
 .... i +field'=field w "WARNING: parsing error field: "_name," ",file," ",field,! quit
 .... i +pointerFile'=pointerFile w "WARNING: parsing error pointerFile: "_name," ",file," ",field,! quit
 .... i field>0,pointerFile s outputData(file,pointerFile,field)=dipt_U_name
 ... ;
 ... ;
 ... ; Now, process M code fields.
 ... new exitEarly set exitEarly=0
 ... if fieldIsMCode do
 .... ; debug
 .... ; b:name="ZBJM FEE BASIS LIST"
 .... ; debug
 .... ; The file number for the M code operation
 .... n mCodeContext s mCodeContext=file ; The default
 .... n fileField,fileFieldIndex
 .... i fieldIsMCode("nonMCode")]"" f fileFieldIndex=1:1:$l(fieldIsMCode("nonMCode"),",") do
 ..... s fileField=$p(fieldIsMCode("nonMCode"),",",fileFieldIndex)
 ..... ; 
 ..... ; Relational navigation
 ..... i fileField<0 s mCodeContext=-fileField quit
 ..... ; 
 ..... ; Subfile processing. Move context to subfile
 ..... q:mCodeContext=""
 ..... i '$d(^DD(mCodeContext,fileField,0)) set exitEarly=1 do  quit  ; doesn't exist!
 ...... w "^DD("_mCodeContext_","_fileField_",0) does not exist",!
 ..... i fileField>0,$P(^DD(mCodeContext,fileField,0),U,2) s mCodeContext=+$P(^DD(mCodeContext,fileField,0),U,2) quit
 .... q:exitEarly
 .... ; debug
 .... ; w mCodeContext,!
 .... ; debug
 .... 
 .... ; Grab the COMPUTED EXPRESSION using the Z piece Index + 1
 .... n Zpiece
 .... n i f i=1:1:$l(fieldData,";") i $p(fieldData,";",i)="Z" s Zpiece=i quit
 .... i '$get(Zpiece) quit  ; field does not have definition (e.g. CAPTIONED template)
 .... ;
 .... ; Get the potentially COMPUTED EXPRESSION code for this field
 .... n potComputedCode s potComputedCode=$p(fieldData,";",Zpiece+1)
 .... s potComputedCode=$e(potComputedCode,2,$l(potComputedCode)-1)
 .... ;
 .... ; Is it the same (after removing the quotes) as the MCode?
 .... ; If so, then this is not a computed expression
 .... ; We can abandon hope of finding what field it refers to.
 .... i potComputedCode=fieldIsMCode("MCode") quit
 ....
 .... ; At this point, we think it's a computed expression.
 .... ; Lets try to to see 
 .... n X
 .... d EXPR^DICOMP(mCodeContext,"dmFITSL",potComputedCode)
 .... i '$d(X) w "Can't resolve "_fieldData_" into fields (context "_mCodeContext_", name "_name_")",! quit
 .... i X("USED")="" quit  ; not an expression that uses fields (NOW, PAGE)
 .... ;
 .... n pairs,pair f pairs=1:1:$l(X("USED"),";") d
 ..... s pair=$p(X("USED"),";",pairs)
 ..... n thisFile  s thisFile=$p(pair,U,1)
 ..... n thisField s thisField=$p(pair,U,2)
 ..... i thisFile=file quit
 ..... s outputData(file,thisFile,thisField)=dipt_U_name
 ... ; 
 ... ; i fileNamePrint w file," ",name,! s fileNamePrint=0
 ... ; write fieldData,!
 . ; i 'fileNamePrint zwrite:$d(outputData) outputData(file,*) w !!
 quit
 ;
DIPTOUT(outputData,outputPath,outputFile) ; [Private] Print Template Data Output
 n POP
 d OPEN^%ZISH("file1",outputPath,outputFile,"W")
 i POP quit
 u IO
 n file,dstFile,dstField,dietIEN,dietName
 n c s c=","
 w "PRINT TEMPLATE IEN,PRINT TEMPLATE NAME,SOURCE FILE,DESTINATION FILE,DESTINATION FIELD",!
 f file=0:0 s file=$o(outputData(file)) q:'file  d
 . f dstFile=0:0 s dstFile=$o(outputData(file,dstFile)) q:'dstFile  d
 .. f dstField=0:0 s dstField=$o(outputData(file,dstFile,dstField)) q:'dstField  d
 ... n data s data=outputData(file,dstFile,dstField)
 ... s dietIEN=$p(data,U,1)
 ... s dietName=$p(data,U,2)
 ... w dietIEN_c_dietName_c_file_c_dstFile_c_dstField,!
 d CLOSE^%ZISH("file1")
 quit
 ;
PARENT(subfile) ; [Private] Find out who my parent is
 ; WARNING: Recursive algorithm
 if $data(^DD(subfile,0,"UP")) quit $$PARENT(^("UP"))
 quit subfile

$! LINK.COM
$!
$!  This procedure links the two WATCHER images.
$!
$ VMSVER = F$GETSYI("VERSION")
$ PREFIX = "V" + F$EXTRACT(1,1,VMSVER)
$ arch = F$EDIT(F$GETSYI("ARCH_NAME"),"TRIM,UPCASE")
$ IF arch .EQS. ""
$ THEN
$   WRITE SYS$OUTPUT "Cannot determine system architecture"
$   EXIT 1
$ ENDIF
$ IF arch .EQS. "ALPHA"
$ THEN
$   IF PREFIX .EQS. "V1" .AND. F$EXTRACT(3,1,VMSVER) .EQS. "5" THEN PREFIX = "V15"
$   IF PREFIX .EQS. "V8" THEN PREFIX = "V7"
$   IF F$SEARCH("''PREFIX'_WATCHER.ALPHA_OPT") .EQS. ""
$   THEN
$   	WRITE SYS$OUTPUT "You must recompile from sources for this version of VMS."
$   	EXIT
$   ENDIF
$   IF F$PARSE("[.BIN-ALPHA]") .EQS. ""
$   THEN DEFINE/USER BIN_DIR SYS$DISK:[]
$   ELSE DEFINE/USER BIN_DIR SYS$DISK:[.BIN-ALPHA]
$   ENDIF
$   LINK/EXE=WATCHER.EXE/SYSEXE 'PREFIX'_WATCHER.ALPHA_OPT/OPT,VERSION.OPT/OPT
$   IF F$PARSE("[.BIN-ALPHA]") .EQS. ""
$   THEN DEFINE/USER BIN_DIR SYS$DISK:[]
$   ELSE DEFINE/USER BIN_DIR SYS$DISK:[.BIN-ALPHA]
$   ENDIF
$   LINK/EXE=WCP.EXE/NOTRACE BIN_DIR:WCP.OLB/INCLUDE=WCP/LIB,SYS$DISK:[]VERSION.OPT/OPT
$   IF F$PARSE("[.BIN-ALPHA]") .EQS. ""
$   THEN DEFINE/USER BIN_DIR SYS$DISK:[]
$   ELSE DEFINE/USER BIN_DIR SYS$DISK:[.BIN-ALPHA]
$   ENDIF
$   LINK/EXE=FORCE_EXIT.EXE/NOTRACE BIN_DIR:FORCE_EXIT.OBJ
$ ENDIF
$ IF arch .EQS. "VAX"
$ THEN
$   IF PREFIX .EQS. "V7" .AND. F$EXTRACT(3,1,VMSVER) .LES. "1" THEN PREFIX = "V6"
$   IF F$SEARCH("''PREFIX'_WATCHER.OPT") .EQS. ""
$   THEN
$   	WRITE SYS$OUTPUT "You must recompile from sources for this version of VMS."
$   	EXIT
$   ENDIF
$   IF F$PARSE("[.BIN-VAX]") .EQS. ""
$   THEN DEFINE/USER BIN_DIR SYS$DISK:[]
$   ELSE DEFINE/USER BIN_DIR SYS$DISK:[.BIN-VAX]
$   ENDIF
$   LINK/EXE=WATCHER.EXE 'PREFIX'_WATCHER.OPT/OPT,VERSION.OPT/OPT
$   IF F$PARSE("[.BIN-VAX]") .EQS. ""
$   THEN DEFINE/USER BIN_DIR SYS$DISK:[]
$   ELSE DEFINE/USER BIN_DIR SYS$DISK:[.BIN-VAX]
$   ENDIF
$   LINK/EXE=WCP.EXE/NOTRACE BIN_DIR:WCP.OLB/INCLUDE=WCP/LIB,SYS$DISK:[]VERSION.OPT/OPT
$   IF F$PARSE("[.BIN-VAX]") .EQS. ""
$   THEN DEFINE/USER BIN_DIR SYS$DISK:[]
$   ELSE DEFINE/USER BIN_DIR SYS$DISK:[.BIN-VAX]
$   ENDIF
$   LINK/EXE=FORCE_EXIT.EXE/NOTRACE BIN_DIR:FORCE_EXIT.OBJ
$ ENDIF
$ IF arch .EQS. "IA64"
$ THEN
$   IF F$PARSE("[.BIN-IA64]") .EQS. ""
$   THEN DEFINE/USER BIN_DIR SYS$DISK:[]
$   ELSE DEFINE/USER BIN_DIR SYS$DISK:[.BIN-IA64]
$   ENDIF
$   LINK/EXE=WATCHER.EXE/SYSEXE WATCHER.IA64_OPT/OPT,VERSION.OPT/OPT
$   IF F$PARSE("[.BIN-IA64]") .EQS. ""
$   THEN DEFINE/USER BIN_DIR SYS$DISK:[]
$   ELSE DEFINE/USER BIN_DIR SYS$DISK:[.BIN-IA64]
$   ENDIF
$   LINK/EXE=WCP.EXE/NOTRACE BIN_DIR:WCP.OLB/INCLUDE=WCP/LIB,SYS$DISK:[]VERSION.OPT/OPT
$   IF F$PARSE("[.BIN-IA64]") .EQS. ""
$   THEN DEFINE/USER BIN_DIR SYS$DISK:[]
$   ELSE DEFINE/USER BIN_DIR SYS$DISK:[.BIN-IA64]
$   ENDIF
$   LINK/EXE=FORCE_EXIT.EXE/NOTRACE BIN_DIR:FORCE_EXIT.OBJ
$ ENDIF
$ EXIT

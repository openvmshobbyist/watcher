$ V = 'F$VERIFY (0)
$ SET NOON
$ WAIT 00:00:10
$ PRCNAM = F$EDIT (F$GETJPI ("", "PRCNAM"), "TRIM")
$ IF F$EXTRACT (0,7,PRCNAM) .EQS. "RESTART"
$ THEN
$   WSUNIT = PRCNAM - "RESTART_"
$   IF F$GETDVI ("WSA''WSUNIT'", "EXISTS")
$   THEN
$   	DEFINE DECW$DISPLAY WSA'WSUNIT'
$   	RUN SYS$SYSTEM:DECW$STARTLOGIN
$   ENDIF
$ ENDIF
$ EXIT 1+0*F$VERIFY(V)

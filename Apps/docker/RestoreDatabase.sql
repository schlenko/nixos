RESTORE FILELISTONLY
FROM DISK = N'/sql_import/FILENAME.bak';



RESTORE DATABASE [YOURDATABASENAME]
FROM DISK = N'/sql_import/FILENAME.bak
WITH
    MOVE N'TABLENAME1'
        TO N'/var/opt/mssql/data/TABLENAME1.mdf',
    MOVE N'TABLENAME2'
        TO N'/var/opt/mssql/data/TABLENAME2.ldf',
    RECOVERY,
    STATS = 5;


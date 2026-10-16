USE [master];
GO


RESTORE FILELISTONLY
FROM DISK = N'/sql_import/dico_sport_lsb_hessen-tc-2026-08-30_12-35-40.bak';





    RESTORE DATABASE [YOURDATABASENAME]
    FROM DISK = N'/sql_import/Filename.bak
    WITH
        MOVE N'TABLENAME'
            TO N'/var/opt/mssql/data/DB.mdf',
        MOVE N'TABLENAME'
            TO N'/var/opt/mssql/data/Log.ldf',
        RECOVERY,
        STATS = 5;


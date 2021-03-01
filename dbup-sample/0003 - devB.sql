EXEC sp_rename 'table_foo', 'table_bar'
GO

ALTER PROCEDURE myproc
AS
BEGIN
 SELECT col1
 FROM table_bar
END

USE [BlueDot]
GO
/****** Object:  UserDefinedFunction [dbo].[fnm_build_replace]    Script Date: 27/10/2016 11:52:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE FUNCTION [dbo].[fnm_build_replace] (@fieldname varchar(max), @replacedata varchar(max))
------------------------------------------------------------------------------------------------------------------
-- Name:        fnm_build_replace
-- Author:      <Micky>
-- Support:     micky@mbyoung.com
-- Created:     Sep 05 2016
-- Copyright:   (c) Michael Young 2016
------------------------------------------------------------------------------------------------------------------
RETURNS varchar(max)
AS
BEGIN
   DECLARE @replacestr varchar(max) = @fieldname
   DECLARE @replace TABLE (
      id      int,
      find    varchar(max),
      replace varchar(max)
   )
   DECLARE @temp TABLE (
      id   int,
      data varchar(max)
   )
   INSERT @temp (id, data)
      SELECT id, REPLACE(QUOTENAME(COALESCE(data, ''), ''''), ',', QUOTENAME(',', '''')) FROM dbo.fnm_split(@replacedata, '|')
   SELECT @replaceStr = 'REPLACE(' + @replaceStr + ',' + data + ')' FROM @TEMP
   RETURN @replaceStr
END





GO
/****** Object:  UserDefinedFunction [dbo].[fnm_col_name]    Script Date: 27/10/2016 11:52:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[fnm_col_name](@i int) RETURNS VARCHAR (100) 
------------------------------------------------------------------------------------------------------------------
-- Name:        fnm_col_name
-- Author:      <Micky>
-- Support:     micky@mbyoung.com
-- Created:     Sep 05 2016
-- Copyright:   (c) Michael Young 2016
------------------------------------------------------------------------------------------------------------------

AS 

BEGIN
RETURN  'Column'+RIGHT('000'+CAST(@i+1 AS varchar(3)), 3)
END





GO
/****** Object:  UserDefinedFunction [dbo].[fnm_filename_to_tablename]    Script Date: 27/10/2016 11:52:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[fnm_filename_to_tablename] (@filename varchar(255) )
------------------------------------------------------------------------------------------------------------------
-- Name:        fnm_filename_to_tablename
-- Author:      <Micky>
-- Support:     micky@mbyoung.com
-- Created:     Sep 05 2016
-- Modified:    Sep185 2016
-- Copyright:   (c) Michael Young 2016
------------------------------------------------------------------------------------------------------------------
RETURNS varchar (255)
AS
BEGIN
DECLARE @tablename varchar(255) 
DECLARE @suffix varchar(10) = ''

SET @filename = REPLACE(@filename, ' ', '_')

IF CHARINDEX('.', RIGHT(@filename,4)) <> 0  
	SET @tablename = LEFT(@filename, CHARINDEX('.', @filename) - 1)
ELSE
	SET @tablename = @filename

/*
IF EXISTS(SELECT * FROM _bd__Tables WHERE TableName = @tablename)
	SELECT @suffix = '_' + CAST (ISNULL(MAX(RIGHT(TableName,1)) + 1, 1) AS VARCHAR (10))
	FROM  _bd__Tables WHERE ISNUMERIC(RIGHT(@tablename, 1)) = 1 AND TableName LIKE '' + @tablename + '_%'  
*/
RETURN @tablename + @suffix
END






GO
/****** Object:  UserDefinedFunction [dbo].[fnm_get_setting]    Script Date: 27/10/2016 11:52:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[fnm_get_setting] (@name varchar(255) )
------------------------------------------------------------------------------------------------------------------
-- Name:        fnm_get_setting
-- Author:      <Micky>
-- Support:     micky@mbyoung.com
-- Created:     Sep 05 2016
-- Copyright:   (c) Michael Young 2016
------------------------------------------------------------------------------------------------------------------
RETURNS varchar(max) 
AS
BEGIN
DECLARE @return varchar(max)
SELECT @return = Value from _bd__Settings where Name = @name
RETURN @return
END





GO
/****** Object:  UserDefinedFunction [dbo].[fnm_wrap_try_catch]    Script Date: 27/10/2016 11:52:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fnm_wrap_try_catch] (
	@sql varchar(max), 
	@entityname varchar(128), 
	@action varchar(128), 
	@Silent bit)
------------------------------------------------------------------------------------------------------------------
-- Name:        fnm_wrap_try_catch
-- Author:      <Micky>
-- Support:     micky@mbyoung.com
-- Created:     Sep 05 2016
-- Modified:    Sep 17 2016
-- Copyright:   (c) Michael Young 2016
------------------------------------------------------------------------------------------------------------------
RETURNS varchar(max) 
AS

BEGIN
DECLARE @crlf varchar (10) = char(13) + char(10)

IF  @Silent = 0 
  BEGIN
	SET @sql =  'EXEC spm_bd__log 0, ''--- Start ----'', ' + QUOTENAME( @entityname,'''') + ', ' +  QUOTENAME( @action,'''') + @crlf +
		@sql + @crlf +  'EXEC spm_bd__log 0, ''--- Finish----'', ' + QUOTENAME( @entityname,'''') + ', ' + QUOTENAME( @action,'''') + ', @@ROWCOUNT' + @crlf
	SET @sql = 'BEGIN TRY' + @crlf + @sql + 'END TRY' + @crlf + 'BEGIN CATCH'+ @crlf + 'EXEC spm_bd__log 0' + @crlf + 'END CATCH' + @crlf
	SET @sql = @crlf + @crlf +
	'--=====================================================================================================--' + @crlf +
	'--  ' + @action + '---> ' + @entityname + @crlf +
	'--=====================================================================================================--' + @crlf + @sql
   END

RETURN @sql

END







GO
/****** Object:  Table [dbo].[_bd__Log]    Script Date: 27/10/2016 11:52:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[_bd__Log](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[Time] [datetime] NULL,
	[isError] [bit] NULL,
	[Info] [varchar](max) NULL,
	[RowCount] [int] NULL,
	[Entity] [varchar](4000) NULL,
	[Action] [varchar](max) NULL,
	[Number] [varchar](50) NULL,
	[Description] [varchar](4000) NULL,
	[ErrorProcedure] [varchar](100) NULL,
	[State] [int] NULL,
	[Severity] [int] NULL,
	[Line] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  UserDefinedFunction [dbo].[fnm_clean_date]    Script Date: 27/10/2016 11:52:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[fnm_clean_date] (@format int, @in varchar (max))
------------------------------------------------------------------------------------------------------------------
-- Name:        fnm_clean_date
-- Author:      <Micky>
-- Support:     micky@mbyoung.com
-- Created:     Sep 05 2016
-- Copyright:   (c) Michael Young 2016
------------------------------------------------------------------------------------------------------------------
RETURNS TABLE
AS
	RETURN SELECT CONVERT(date, @in, @format) value











GO
/****** Object:  UserDefinedFunction [dbo].[fnm_clean_float]    Script Date: 27/10/2016 11:52:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fnm_clean_float] (@format int, @in varchar (50))
------------------------------------------------------------------------------------------------------------------
-- Name:        fnm_clean_float
-- Author:      <Micky>
-- Support:     micky@mbyoung.com
-- Created:     Sep 05 2016
-- Copyright:   (c) Michael Young 2016
------------------------------------------------------------------------------------------------------------------
RETURNS TABLE
AS 
RETURN SELECT 
CASE WHEN RIGHT(REPLACE(REPLACE( @in , ',', ''), ' ', ''), 1) = '-' 
THEN '-' + SUBSTRING(REPLACE(REPLACE(@in, ',', ''), ' ', ''), 0, 
LEN(REPLACE(REPLACE(@in , ',', ''), ' ', '')) ) 
ELSE REPLACE(REPLACE( @in ,',', ''), ' ', '') END

 AS Value


GO
/****** Object:  UserDefinedFunction [dbo].[fnm_clean_str]    Script Date: 27/10/2016 11:52:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fnm_clean_str] (@format int, @in varchar (max))
------------------------------------------------------------------------------------------------------------------
-- Name:        fnm_clean_str
-- Author:      <Micky>
-- Support:     micky@mbyoung.com
-- Created:     Sep 14 2016
-- Copyright:   (c) Michael Young 2016
------------------------------------------------------------------------------------------------------------------
RETURNS TABLE 
AS
RETURN 

SELECT 
			CASE WHEN @format = -3 THEN UPPER(LTRIM(RTRIM(REPLACE(REPLACE(@in, CHAR(13), ' '), CHAR(10), ' ')))) 
				 WHEN @format = -4 THEN LOWER(LTRIM(RTRIM(REPLACE(REPLACE(@in, CHAR(13), ' '), CHAR(10), ' '))))
				 ELSE LTRIM(RTRIM(REPLACE(REPLACE(@in, CHAR(13), ' '), CHAR(10), ' '))) END AS Value















GO
/****** Object:  UserDefinedFunction [dbo].[fnm_get_log_process_end]    Script Date: 27/10/2016 11:52:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fnm_get_log_process_end] (@ID int, @Entity varchar(max), @Action varchar(max), @info varchar(max))
RETURNS TABLE 
AS
RETURN
SELECT  TOP 1
    ID [FinishID], 
	[Time] FinishTime, 
	[Rowcount] 
FROM _bd__Log F
WHERE Entity = @Entity
	AND Action = @Action
	AND LEFT(Info,8) = Left(@info,8)
	AND F.ID > @ID
ORDER BY ID ASC




GO
/****** Object:  UserDefinedFunction [dbo].[fnm_split]    Script Date: 27/10/2016 11:52:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE FUNCTION [dbo].[fnm_split]
(
    @String VARCHAR(8000),
    @Delimiter CHAR(1)
)
------------------------------------------------------------------------------------------------------------------
-- Name:        fnm_split
-- Author:      <Micky>
-- Support:     micky@mbyoung.com
-- Created:     Sep 05 2016
-- Copyright:   (c) Michael Young 2016
------------------------------------------------------------------------------------------------------------------
RETURNS TABLE
AS
RETURN
(
    WITH Split(stpos,endpos)
    AS(
        SELECT 0 AS stpos, CHARINDEX(@Delimiter,@String) AS endpos
        UNION ALL
        SELECT endpos+1, CHARINDEX(@Delimiter,@String,endpos+1)
            FROM Split
            WHERE endpos > 0
    )
    SELECT 'ID' = ROW_NUMBER() OVER (ORDER BY (SELECT 1)),
        'Data' = SUBSTRING(@String,stpos,COALESCE(NULLIF(endpos,0),LEN(@String)+1)-stpos)
    FROM Split
)






GO
/****** Object:  StoredProcedure [dbo].[spm_bd__export]    Script Date: 27/10/2016 11:52:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[spm_bd__export]
(
	@table_name varchar(776),  		-- The table/view for which the INSERT statements will be generated using the existing data
	@target_table varchar(776) = NULL, 	-- Use this parameter to specify a different table name into which the data will be inserted
	@include_column_list bit = 1,		-- Use this parameter to include/ommit column list in the generated INSERT statement
	@from varchar(800) = NULL, 		-- Use this parameter to filter the rows based on a filter condition (using WHERE)
	@include_timestamp bit = 0, 		-- Specify 1 for this parameter, if you want to include the TIMESTAMP/ROWVERSION column's data in the INSERT statement
	@debug_mode bit = 0,			-- If @debug_mode is set to 1, the SQL statements constructed by this procedure will be printed for later examination
	@owner varchar(64) = NULL,		-- Use this parameter if you are not the owner of the table
	@ommit_images bit = 0,			-- Use this parameter to generate INSERT statements by omitting the 'image' columns
	@ommit_identity bit = 0,		-- Use this parameter to ommit the identity columns
	@top int = NULL,			-- Use this parameter to generate INSERT statements only for the TOP n rows
	@cols_to_include varchar(8000) = NULL,	-- List of columns to be included in the INSERT statement
	@cols_to_exclude varchar(8000) = NULL,	-- List of columns to be excluded from the INSERT statement
	@disable_constraints bit = 0,		-- When 1, disables foreign key constraints and enables them after the INSERT statements
	@ommit_computed_cols bit = 0		-- When 1, computed columns will not be included in the INSERT statement
	
)
AS
BEGIN

/***********************************************************************************************************
Procedure:	sp_generate_inserts  (Build 22) 
		(Copyright © 2002 Narayana Vyas Kondreddi. All rights reserved.)
Renamed: spm_bd__export
                                          
Purpose:	To generate INSERT statements from existing data. 
		These INSERTS can be executed to regenerate the data at some other location.
		This procedure is also useful to create a database setup, where in you can 
		script your data along with your table definitions.

Written by:	Narayana Vyas Kondreddi
	        http://vyaskn.tripod.com

Acknowledgements:
		Divya Kalra	-- For beta testing
		Mark Charsley	-- For reporting a problem with scripting uniqueidentifier columns with NULL values
		Artur Zeygman	-- For helping me simplify a bit of code for handling non-dbo owned tables
		Joris Laperre   -- For reporting a regression bug in handling text/ntext columns

Tested on: 	SQL Server 7.0 and SQL Server 2000

Date created:	January 17th 2001 21:52 GMT

Date modified:	May 1st 2002 19:50 GMT

Email: 		vyaskn@hotmail.com

NOTE:		This procedure may not work with tables with too many columns.
		Results can be unpredictable with huge text columns or SQL Server 2000's sql_variant data types
		Whenever possible, Use @include_column_list parameter to ommit column list in the INSERT statement, for better results
		IMPORTANT: This procedure is not tested with internation data (Extended characters or Unicode). If needed
		you might want to convert the datatypes of character variables in this procedure to their respective unicode counterparts
		like nchar and nvarchar
		

Example 1:	To generate INSERT statements for table '_bd__Queries':
		
		EXEC spm_bd__export '_bd__Tables', 'test'

Example 2: 	To ommit the column list in the INSERT statement: (Column list is included by default)
		IMPORTANT: If you have too many columns, you are advised to ommit column list, as shown below,
		to avoid erroneous results
		
		EXEC spm_bd__export 'titles', @include_column_list = 0

Example 3:	To generate INSERT statements for 'titlesCopy' table from 'titles' table:

		EXEC spm_bd__export 'titles', 'titlesCopy'

Example 4:	To generate INSERT statements for 'titles' table for only those titles 
		which contain the word 'Computer' in them:
		NOTE: Do not complicate the FROM or WHERE clause here. It's assumed that you are good with T-SQL if you are using this parameter

		EXEC spm_bd__export 'titles', @from = "from titles where title like '%Computer%'"

Example 5: 	To specify that you want to include TIMESTAMP column's data as well in the INSERT statement:
		(By default TIMESTAMP column's data is not scripted)

		EXEC spm_bd__export 'titles', @include_timestamp = 1

Example 6:	To print the debug information:
  
		EXEC spm_bd__export 'titles', @debug_mode = 1

Example 7: 	If you are not the owner of the table, use @owner parameter to specify the owner name
		To use this option, you must have SELECT permissions on that table

		EXEC spm_bd__export Nickstable, @owner = 'Nick'

Example 8: 	To generate INSERT statements for the rest of the columns excluding images
		When using this otion, DO NOT set @include_column_list parameter to 0.

		EXEC spm_bd__export imgtable, @ommit_images = 1

Example 9: 	To generate INSERT statements excluding (ommiting) IDENTITY columns:
		(By default IDENTITY columns are included in the INSERT statement)

		EXEC spm_bd__export _bd__table, @ommit_identity = 1

Example 10: 	To generate INSERT statements for the TOP 10 rows in the table:
		
		EXEC spm_bd__export _bd__table, @top = 10

Example 11: 	To generate INSERT statements with only those columns you want:
		
		EXEC spm_bd__export titles, @cols_to_include = "'title','title_id','au_id'"

Example 12: 	To generate INSERT statements by omitting certain columns:
		
		EXEC spm_bd__export titles, @cols_to_exclude = "'title','title_id','au_id'"

Example 13:	To avoid checking the foreign key constraints while loading data with INSERT statements:
		
		EXEC spm_bd__export titles, @disable_constraints = 1

Example 14: 	To exclude computed columns from the INSERT statement:
		EXEC spm_bd__export _bd__Table, @ommit_computed_cols = 1
***********************************************************************************************************/

SET NOCOUNT ON

-- Micky
-- Calling code from delphi cannot deal with null string passing so empty strings are nulled here....
IF @target_table = '' SET @target_table = NULL
IF @from = '' SET @from = NULL
IF @owner = '' SET @owner = NULL
IF @cols_to_include = '' SET @cols_to_include = NULL
IF @cols_to_exclude = '' SET @cols_to_exclude = NULL



--Making sure user only uses either @cols_to_include or @cols_to_exclude
IF ((@cols_to_include IS NOT NULL) AND (@cols_to_exclude IS NOT NULL))
	BEGIN
		RAISERROR('Use either @cols_to_include or @cols_to_exclude. Do not use both the parameters at once',16,1)
		RETURN -1 --Failure. Reason: Both @cols_to_include and @cols_to_exclude parameters are specified
	END

--Making sure the @cols_to_include and @cols_to_exclude parameters are receiving values in proper format
IF ((@cols_to_include IS NOT NULL) AND (PATINDEX('''%''',@cols_to_include) = 0))
	BEGIN
		RAISERROR('Invalid use of @cols_to_include property',16,1)
		PRINT 'Specify column names surrounded by single quotes and separated by commas'
		PRINT 'Eg: EXEC sp_generate_inserts titles, @cols_to_include = "''title_id'',''title''"'
		RETURN -1 --Failure. Reason: Invalid use of @cols_to_include property
	END

IF ((@cols_to_exclude IS NOT NULL) AND (PATINDEX('''%''',@cols_to_exclude) = 0))
	BEGIN
		RAISERROR('Invalid use of @cols_to_exclude property',16,1)
		PRINT 'Specify column names surrounded by single quotes and separated by commas'
		PRINT 'Eg: EXEC sp_generate_inserts titles, @cols_to_exclude = "''title_id'',''title''"'
		RETURN -1 --Failure. Reason: Invalid use of @cols_to_exclude property
	END


--Checking to see if the database name is specified along wih the table name
--Your database context should be local to the table for which you want to generate INSERT statements
--specifying the database name is not allowed
IF (PARSENAME(@table_name,3)) IS NOT NULL
	BEGIN
		RAISERROR('Do not specify the database name. Be in the required database and just specify the table name.',16,1)
		RETURN -1 --Failure. Reason: Database name is specified along with the table name, which is not allowed
	END

--Checking for the existence of 'user table' or 'view'
--This procedure is not written to work on system tables
--To script the data in system tables, just create a view on the system tables and script the view instead

IF @owner IS NULL
	BEGIN
		IF ((OBJECT_ID(@table_name,'U') IS NULL) AND (OBJECT_ID(@table_name,'V') IS NULL)) 
			BEGIN
				RAISERROR('User table or view not found.',16,1)
				PRINT 'You may see this error, if you are not the owner of this table or view. In that case use @owner parameter to specify the owner name.'
				PRINT 'Make sure you have SELECT permission on that table or view.'
				RETURN -1 --Failure. Reason: There is no user table or view with this name
			END
	END
ELSE
	BEGIN
		IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = @table_name AND (TABLE_TYPE = 'BASE TABLE' OR TABLE_TYPE = 'VIEW') AND TABLE_SCHEMA = @owner)
			BEGIN
				RAISERROR('User table or view not found.',16,1)
				PRINT 'You may see this error, if you are not the owner of this table. In that case use @owner parameter to specify the owner name.'
				PRINT 'Make sure you have SELECT permission on that table or view.'
				RETURN -1 --Failure. Reason: There is no user table or view with this name		
			END
	END

--Variable declarations
DECLARE		@Column_ID int, 		
		@Column_List varchar(8000), 
		@Column_Name varchar(128), 
		@Start_Insert varchar(786), 
		@Data_Type varchar(128), 
		@Actual_Values varchar(8000),	--This is the string that will be finally executed to generate INSERT statements
		@IDN varchar(128)		--Will contain the IDENTITY column's name in the table

--Variable Initialization
SET @IDN = ''
SET @Column_ID = 0
SET @Column_Name = ''
SET @Column_List = ''
SET @Actual_Values = ''

IF @owner IS NULL 
	BEGIN
		SET @Start_Insert = 'INSERT INTO ' + '[' + Ltrim(RTRIM(COALESCE(@target_table, @table_name))) + ']' 
	END
ELSE
	BEGIN
		SET @Start_Insert = 'INSERT ' + '[' + LTRIM(RTRIM(@owner)) + '].' + '[' + RTRIM(COALESCE(@target_table,@table_name)) + ']' 		
	END


--To get the first column's ID

SELECT	@Column_ID = MIN(ORDINAL_POSITION) 	
FROM	INFORMATION_SCHEMA.COLUMNS (NOLOCK) 
WHERE 	TABLE_NAME = @table_name AND
(@owner IS NULL OR TABLE_SCHEMA = @owner)



--Loop through all the columns of the table, to get the column names and their data types
WHILE @Column_ID IS NOT NULL
	BEGIN
		SELECT 	@Column_Name = QUOTENAME(COLUMN_NAME), 
		@Data_Type = DATA_TYPE 
		FROM 	INFORMATION_SCHEMA.COLUMNS (NOLOCK) 
		WHERE 	ORDINAL_POSITION = @Column_ID AND 
		TABLE_NAME = @table_name AND
		(@owner IS NULL OR TABLE_SCHEMA = @owner)



		IF @cols_to_include IS NOT NULL --Selecting only user specified columns
		BEGIN
			IF CHARINDEX( '''' + SUBSTRING(@Column_Name,2,LEN(@Column_Name)-2) + '''',@cols_to_include) = 0 
			BEGIN
				GOTO SKIP_LOOP
			END
		END

		IF @cols_to_exclude IS NOT NULL --Selecting only user specified columns
		BEGIN
			IF CHARINDEX( '''' + SUBSTRING(@Column_Name,2,LEN(@Column_Name)-2) + '''',@cols_to_exclude) <> 0 
			BEGIN
				GOTO SKIP_LOOP
			END
		END

		--Making sure to output SET IDENTITY_INSERT ON/OFF in case the table has an IDENTITY column
		IF (SELECT COLUMNPROPERTY( OBJECT_ID(QUOTENAME(COALESCE(@owner,USER_NAME())) + '.' + @table_name),SUBSTRING(@Column_Name,2,LEN(@Column_Name) - 2),'IsIdentity')) = 1 
		BEGIN
			IF @ommit_identity = 0 --Determing whether to include or exclude the IDENTITY column
				SET @IDN = @Column_Name
			ELSE
				GOTO SKIP_LOOP			
		END
		
		--Making sure whether to output computed columns or not
		IF @ommit_computed_cols = 1
		BEGIN
			IF (SELECT COLUMNPROPERTY( OBJECT_ID(QUOTENAME(COALESCE(@owner,USER_NAME())) + '.' + @table_name),SUBSTRING(@Column_Name,2,LEN(@Column_Name) - 2),'IsComputed')) = 1 
			BEGIN
				GOTO SKIP_LOOP					
			END
		END
		
		--Tables with columns of IMAGE data type are not supported for obvious reasons
		IF(@Data_Type in ('image'))
			BEGIN
				IF (@ommit_images = 0)
					BEGIN
						RAISERROR('Tables with image columns are not supported.',16,1)
						PRINT 'Use @ommit_images = 1 parameter to generate INSERTs for the rest of the columns.'
						PRINT 'DO NOT ommit Column List in the INSERT statements. If you ommit column list using @include_column_list=0, the generated INSERTs will fail.'
						RETURN -1 --Failure. Reason: There is a column with image data type
					END
				ELSE
					BEGIN
					GOTO SKIP_LOOP
					END
			END

		--Determining the data type of the column and depending on the data type, the VALUES part of
		--the INSERT statement is generated. Care is taken to handle columns with NULL values. Also
		--making sure, not to lose any data from flot, real, money, smallmomey, datetime columns
		SET @Actual_Values = @Actual_Values  +
		CASE 
			WHEN @Data_Type IN ('char','varchar','nchar','nvarchar') 
				THEN 
					'COALESCE('''''''' + REPLACE(RTRIM(' + @Column_Name + '),'''''''','''''''''''')+'''''''',''NULL'')'
			WHEN @Data_Type IN ('datetime','smalldatetime') 
				THEN 
					'COALESCE('''''''' + RTRIM(CONVERT(char,' + @Column_Name + ',109))+'''''''',''NULL'')'
			WHEN @Data_Type IN ('uniqueidentifier') 
				THEN  
					'COALESCE('''''''' + REPLACE(CONVERT(char(255),RTRIM(' + @Column_Name + ')),'''''''','''''''''''')+'''''''',''NULL'')'
			WHEN @Data_Type IN ('text','ntext') 
				THEN  
					'COALESCE('''''''' + REPLACE(CONVERT(char(8000),' + @Column_Name + '),'''''''','''''''''''')+'''''''',''NULL'')'					
			WHEN @Data_Type IN ('binary','varbinary') 
				THEN  
					'COALESCE(RTRIM(CONVERT(char,' + 'CONVERT(int,' + @Column_Name + '))),''NULL'')'  
			WHEN @Data_Type IN ('timestamp','rowversion') 
				THEN  
					CASE 
						WHEN @include_timestamp = 0 
							THEN 
								'''DEFAULT''' 
							ELSE 
								'COALESCE(RTRIM(CONVERT(char,' + 'CONVERT(int,' + @Column_Name + '))),''NULL'')'  
					END
			WHEN @Data_Type IN ('float','real','money','smallmoney')
				THEN
					'COALESCE(LTRIM(RTRIM(' + 'CONVERT(char, ' +  @Column_Name  + ',2)' + ')),''NULL'')' 
			ELSE 
				'COALESCE(LTRIM(RTRIM(' + 'CONVERT(char, ' +  @Column_Name  + ')' + ')),''NULL'')' 
		END   + '+' +  ''',''' + ' + '
		
		--Generating the column list for the INSERT statement
		SET @Column_List = @Column_List +  @Column_Name + ','	

		SKIP_LOOP: --The label used in GOTO

		SELECT 	@Column_ID = MIN(ORDINAL_POSITION) 
		FROM 	INFORMATION_SCHEMA.COLUMNS (NOLOCK) 
		WHERE 	TABLE_NAME = @table_name AND 
		ORDINAL_POSITION > @Column_ID AND
		(@owner IS NULL OR TABLE_SCHEMA = @owner)


	--Loop ends here!
	END

--To get rid of the extra characters that got concatenated during the last run through the loop
SET @Column_List = LEFT(@Column_List,len(@Column_List) - 1)
SET @Actual_Values = LEFT(@Actual_Values,len(@Actual_Values) - 6)

IF LTRIM(@Column_List) = '' 
	BEGIN
		RAISERROR('No columns to select. There should at least be one column to generate the output',16,1)
		RETURN -1 --Failure. Reason: Looks like all the columns are ommitted using the @cols_to_exclude parameter
	END

--Forming the final string that will be executed, to output the INSERT statements
IF (@include_column_list <> 0)
	BEGIN
		SET @Actual_Values = 
			'SELECT ' +  
			CASE WHEN @top IS NULL OR @top < 0 THEN '' ELSE ' TOP ' + LTRIM(STR(@top)) + ' ' END + 
			'''' + RTRIM(@Start_Insert) + 
			' ''+' + '''(' + RTRIM(@Column_List) +  '''+' + ''')''' + 
			' +''VALUES(''+ ' +  @Actual_Values  + '+'')''' + ' ' + 
			COALESCE(@from,' FROM ' + CASE WHEN @owner IS NULL THEN '' ELSE '[' + LTRIM(RTRIM(@owner)) + '].' END + '[' + rtrim(@table_name) + ']' + '(NOLOCK)')
	END
ELSE IF (@include_column_list = 0)
	BEGIN
		SET @Actual_Values = 
			'SELECT ' + 
			CASE WHEN @top IS NULL OR @top < 0 THEN '' ELSE ' TOP ' + LTRIM(STR(@top)) + ' ' END + 
			'''' + RTRIM(@Start_Insert) + 
			' '' +''VALUES(''+ ' +  @Actual_Values + '+'')''' + ' ' + 
			COALESCE(@from,' FROM ' + CASE WHEN @owner IS NULL THEN '' ELSE '[' + LTRIM(RTRIM(@owner)) + '].' END + '[' + rtrim(@table_name) + ']' + '(NOLOCK)')
	END	

--Determining whether to ouput any debug information
IF @debug_mode =1
	BEGIN
		PRINT '/*****START OF DEBUG INFORMATION*****'
		PRINT 'Beginning of the INSERT statement:'
		PRINT @Start_Insert
		PRINT ''
		PRINT 'The column list:'
		PRINT @Column_List
		PRINT ''
		PRINT 'The SELECT statement executed to generate the INSERTs'
		PRINT @Actual_Values
		PRINT ''
		PRINT '*****END OF DEBUG INFORMATION*****/'
		PRINT ''
	END
		

PRINT ''
PRINT 'SET NOCOUNT ON'
PRINT ''

--Determining whether to print IDENTITY_INSERT or not
IF (@IDN <> '')
	BEGIN
		PRINT 'SET IDENTITY_INSERT ' + QUOTENAME(COALESCE(@owner,USER_NAME())) + '.' + QUOTENAME(RTRIM(COALESCE(@target_table,@table_name))) + ' ON'
		PRINT '-- GO'
		PRINT ''
	END


IF @disable_constraints = 1 AND (OBJECT_ID(QUOTENAME(COALESCE(@owner,USER_NAME())) + '.' + RTRIM(COALESCE(@target_table,@table_name)), 'U') IS NOT NULL)
	BEGIN
		IF @owner IS NULL
			BEGIN
				SELECT 	'ALTER TABLE ' + QUOTENAME(COALESCE(@target_table, @table_name)) + ' NOCHECK CONSTRAINT ALL' AS '--Code to disable constraints temporarily'
			END
		ELSE
			BEGIN
				SELECT 	'ALTER TABLE ' + QUOTENAME(@owner) + '.' + QUOTENAME(COALESCE(@target_table, @table_name)) + ' NOCHECK CONSTRAINT ALL' AS '--Code to disable constraints temporarily'
			END

		PRINT '-- GO'
	END

PRINT ''
PRINT 'PRINT ''Inserting values into ' + '[' + RTRIM(COALESCE(@target_table,@table_name)) + ']' + ''''



--All the hard work pays off here!!! You'll get your INSERT statements, when the next line executes!
EXEC (@Actual_Values)

PRINT 'PRINT ''Done'''
PRINT ''


IF @disable_constraints = 1 AND (OBJECT_ID(QUOTENAME(COALESCE(@owner,USER_NAME())) + '.' + RTRIM(COALESCE(@target_table,@table_name)), 'U') IS NOT NULL)
	BEGIN
		IF @owner IS NULL
			BEGIN
				SELECT 	'ALTER TABLE ' + QUOTENAME(COALESCE(@target_table, @table_name)) + ' CHECK CONSTRAINT ALL'  AS '--Code to enable the previously disabled constraints'
			END
		ELSE
			BEGIN
				SELECT 	'ALTER TABLE ' + QUOTENAME(@owner) + '.' + QUOTENAME(COALESCE(@target_table, @table_name)) + ' CHECK CONSTRAINT ALL' AS '--Code to enable the previously disabled constraints'
			END

		PRINT '-- GO'
	END

PRINT ''
IF (@IDN <> '')
	BEGIN
		PRINT 'SET IDENTITY_INSERT ' + QUOTENAME(COALESCE(@owner,USER_NAME())) + '.' + QUOTENAME(RTRIM(COALESCE(@target_table,@table_name))) + ' OFF'
		PRINT '-- GO'
	END

PRINT 'SET NOCOUNT OFF'


SET NOCOUNT OFF
RETURN 0 --Success. We are done!
END




GO
/****** Object:  StoredProcedure [dbo].[spm_bd__getdir]    Script Date: 27/10/2016 11:52:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[spm_bd__getdir] (@piFullPath VARCHAR(128))

------------------------------------------------------------------------------------------------------------------
-- Name:        spm_bd__getdir
-- Author:      <UNKNOWN>
-- Support:     micky@mbyoung.com
-- Modified:    Sep 05 2016
-- Modified By: <micky>
-- Copyright:   (c) Michael Young 2016
------------------------------------------------------------------------------------------------------------------
     AS

SET NOCOUNT ON

DECLARE @Counter          INT          --General purpose counter
DECLARE @CurrentName      VARCHAR(256) --Name of file currently being worked
DECLARE @DirTreeCount     INT          --Remembers number of rows for xp_DirTree
DECLARE @IsFile           BIT          --1 if Name is a file, 0 if not
DECLARE @ObjFile          INT          --File object
DECLARE @ObjFileSystem    INT          --File System Object  
DECLARE @Attributes       INT          --Read only, Hidden, Archived, etc, as a bit map
DECLARE @DateCreated      DATETIME     --Date file was created
DECLARE @DateLastAccessed DATETIME     --Date file was last read (accessed)
DECLARE @DateLastModified DATETIME     --Date file was last written to
DECLARE @Name             VARCHAR(128) --File Name and Extension
DECLARE @Path             VARCHAR(128) --Full path including file name
DECLARE @ShortName        VARCHAR(12)  --8.3 file name
DECLARE @ShortPath        VARCHAR(100) --8.3 full path including file name
DECLARE @Size             INT          --File size in bytes
DECLARE @Type             VARCHAR(100) --Long Windows file type 

 IF OBJECT_ID('TempDB..#DirTree','U') IS NOT NULL
 DROP TABLE #DirTree

 CREATE TABLE #DirTree
        (
        RowNum INT IDENTITY(1,1),
        Name   VARCHAR(256) PRIMARY KEY CLUSTERED, 
        Depth  BIT, 
        IsFile BIT
        )
 SELECT @piFullPath = @piFullPath+'\' WHERE RIGHT(@piFullPath,1)<>'\'

 INSERT INTO #DirTree (Name, Depth, IsFile)
   EXEC Master.dbo.xp_DirTree @piFullPath,1,1 -- Current diretory only, list file names

     -- Remember the row count
    SET @DirTreeCount = @@ROWCOUNT
 UPDATE #DirTree
    SET Name = @piFullPath + Name
   EXEC dbo.sp_OACreate 'Scripting.FileSystemObject', @ObjFileSystem OUT
    SET @Counter = 1
  WHILE @Counter <= @DirTreeCount
  BEGIN
         SELECT @CurrentName = Name,
                @IsFile = IsFile
           FROM #DirTree 
          WHERE RowNum = @Counter
             IF @IsFile = 1 AND @CurrentName LIKE '%%'
          BEGIN

                   EXEC dbo.sp_OAMethod @ObjFileSystem,'GetFile', @ObjFile OUT, @CurrentName
               
                   EXEC dbo.sp_OAGetProperty @ObjFile, 'Path',             @Path             OUT
                   EXEC dbo.sp_OAGetProperty @ObjFile, 'ShortPath',        @ShortPath        OUT
                   EXEC dbo.sp_OAGetProperty @ObjFile, 'Name',             @Name             OUT
                   EXEC dbo.sp_OAGetProperty @ObjFile, 'ShortName',        @ShortName        OUT
                   EXEC dbo.sp_OAGetProperty @ObjFile, 'DateCreated',      @DateCreated      OUT
                   EXEC dbo.sp_OAGetProperty @ObjFile, 'DateLastAccessed', @DateLastAccessed OUT
                   EXEC dbo.sp_OAGetProperty @ObjFile, 'DateLastModified', @DateLastModified OUT
                   EXEC dbo.sp_OAGetProperty @ObjFile, 'Attributes',       @Attributes       OUT
                   EXEC dbo.sp_OAGetProperty @ObjFile, 'Size',             @Size             OUT
                   EXEC dbo.sp_OAGetProperty @ObjFile, 'Type',             @Type             OUT
				         
                 INSERT INTO dbo._bd__DirInfo
                        (Path, ShortPath, Name, ShortName, DateCreated, 
                         DateLastAccessed, DateLastModified, Attributes, Size, Type)
                 SELECT @Path,@ShortPath,@Name,@ShortName,@DateCreated, 
                        @DateLastAccessed,@DateLastModified,@Attributes,@Size,@Type
            END
         SELECT @Counter = @Counter + 1
    END
   EXEC sp_OADestroy @ObjFileSystem
   EXEC sp_OADestroy @ObjFile








GO
/****** Object:  StoredProcedure [dbo].[spm_bd__init]    Script Date: 27/10/2016 11:52:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spm_bd__init] AS
------------------------------------------------------------------------------------------------------------------
-- Name:        spm_bd__init
-- Author:      <Micky>
-- Support:     micky@mbyoung.com
-- Created:     Sep 12 2016
-- Copyright:   (c) Michael Young 2016
-- Notes:       All functions in this proc to be not destructive but repeatable
------------------------------------------------------------------------------------------------------------------
  SET NOCOUNT ON
  --We will need xp_cmdshell
  EXEC sp_configure 'show advanced options', 1
  RECONFIGURE WITH OVERRIDE
  EXEC sp_configure 'xp_cmdshell',1
  RECONFIGURE WITH OVERRIDE
  EXEC sp_configure 'Ole Automation Procedures', 1  
  RECONFIGURE WITH OVERRIDE 
  EXEC sp_configure 'Ad Hoc Distributed Queries',1
  RECONFIGURE WITH OVERRIDE 

-- ALTER DATABASE BlueDot SET RECOVERY BULK_LOGGED 

-- ALTER DATABASE BlueDot SET RECOVERY SIMPLE

  DECLARE @path varchar(255) 
  SELECT @path = LEFT(filename,LEN(filename) - charindex('\',reverse(filename),1) + 1) 
  FROM sysdatabases s WHERE s.Name =   (SELECT  Value FROM _bd__Settings WHERE Name = 'BlueDotDBName')

  DECLARE @sql varchar(max)
  SELECT @sql = COALESCE(@sql, '') +
    '
	CREATE DATABASE [' + Value + '] ON  PRIMARY 
	( NAME = N''' + Value + '_Data'', FILENAME = N''' +  @path + Value + '.mdf' + ''' , SIZE = 167872KB , MAXSIZE = UNLIMITED, FILEGROWTH = 16384KB )
     LOG ON 
    ( NAME = N''' + Value + '_Log'', FILENAME = N''' +  @path + Value + '_log.ldf' + ''' , SIZE = 2048KB , MAXSIZE = 2048GB , FILEGROWTH = 16384KB )
    ;
	'
  FROM _bd__Settings a LEFT JOIN sysdatabases b ON a.Value = b.Name
  WHERE (a.Name IN ('BackupDBName1', 'BackupDBName2', 'RawDBName', 'StagingDBName', 'BlueDotDBName') OR a.Name LIKE ('HugeTableDB%')) AND b.Name IS NULL


  BEGIN TRY
     EXEC (@sql)
  END TRY
  BEGIN CATCH
     EXEC dbo.spm_bd__log 1,
                       'Failure: Cannot Create Extra Databases',
                       spm_bd__init,
					   @sql
  END CATCH
  






GO
/****** Object:  StoredProcedure [dbo].[spm_bd__install]    Script Date: 27/10/2016 11:52:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[spm_bd__install]
------------------------------------------------------------------------------------------------------------------
-- Name:        spm_bd__install
-- Author:      <Micky>
-- Support:     micky@mbyoung.com
-- Created:     Sep 05 2016
-- Modified:    Sep 09 2016
-- Copyright:   (c) Michael Young 2016
------------------------------------------------------------------------------------------------------------------
AS

SET NOCOUNT ON

/*

	DECLARE @sql varchar(max)
	SET @sql = ''
	SELECT @sql  = @sql + 'DROP ' + 
	CASE  [type]
	   WHEN  'P' THEN 'PROCEDURE' 
	   WHEN 'V' THEN 'VIEW' WHEN 'U' THEN 'TABLE' END + ' [' + name + '];' 
	FROM sys.objects where   type in ( 'P', 'V', 'U', 'DF')  
	AND NAME NOT LIKE '%spm_bd__%'
	PRINT( @sql)

	DECLARE @sql varchar(max)
	SET @sql = ''
	SELECT @sql  = @sql + 'TRUNCATE TABLE ' +  '[' + name + '];
	' 
	FROM sys.objects where   type in (  'U')  
	AND NAME NOT LIKE '_bd__%'
	exec ( @sql)

	dbo.spm_clean_up



ALTER TABLE _bd__Tables ADD DBBackup varchar(128) DEFAULT('BDStaBK1')
UPDATE _bd__Tables SET DBBackup = 'BDStaBK1'
	*/







	IF OBJECT_ID('dbo._bd__Queries', 'U') IS NOT NULL
	DROP TABLE _bd__Queries

	CREATE TABLE _bd__Queries(
		QueryName      varchar(128) NOT NULL PRIMARY KEY,
		QueryID        int default(0),
		Description    varchar(2048),
		CMRef          varchar(128),
		ManualEdit     bit DEFAULT(1),
		Active         bit DEFAULT(1),
		QuerySQL       varchar(max),
		[Order]        int DEFAULT(1),
    	[Type]         int DEFAULT(1)     -- 1=Output,2=Sub,3=inputsub,4=inputsubsub(not used)
	)




	IF OBJECT_ID('dbo._bd__ProcMaster', 'U') IS NOT NULL
    DROP TABLE _bd__ProcMaster;

	CREATE TABLE _bd__ProcMaster(
	    ProcID          INT identity(1,1),
		Active          bit DEFAULT (1),
		ProcName        varchar(128) PRIMARY KEY,
		Description     varchar(2048),
		Action          varchar(128),
		ExecOrder       int DEFAULT (0),
		CreateCode      varchar(max),
		ProcType        int DEFAULT (0) -- -2 quiet, -1 systeminit, 0 system, 1 user

	)

  --If using ProcTypes -1 and 0, they need to be implemented in main
  INSERT dbo._bd__ProcMaster (ProcName, Action, ExecOrder, CreateCode, ProcType, Active)
  VALUES
		  ('spm_bd__install',				 		    null,		   -1,  null,  null, 1),
		  ('spm_bd__main',			     	 		    null,		   -1,  null,  null, 1),
		  ('spm_bd__log',			                    null,		   -1,  null,  null, 1),
		  ('spm_bd__getdir',			                null,		   -1,  null,  null, 1),
		  ('spm_bd__init',                              null,          -1,  null,  null, 1),
		  ('spm_bd__export',                              null,          -1,  null,  null, 1),

  		  ('spm_update_master',						'Update Master',			0, '<To be generated>',  -1, 1) , -- think
		  ('spm_todo_phase_0',						'Todo procedures',			0,  '<To be generated>', -2, 1),
		  ('spm_create_raw_tables',					'Create Raw Table',			10, '<To be generated>', -2, 1),
		  ('spm_create_stage_tables',				'Create Stage Table',		20, '<To be generated>', -2, 1),
		  ('spm_rules_before_bulk_insert',			'Rules Before Bulk',		30, '<To be generated>',  1, 1),
		  ('spm_drop_raw_keys',					    'Drop Constraints',			35, '<To be generated>',  0, 1) ,
		  ('spm_bulk_insert',						'Bulk Insert',				40, '<To be generated>',  0, 1),
		  ('spm_query_to_raw',						'Query To Raw',				50, '<To be generated>',  0, 1),
		  ('spm_update_clean_raw',					'Update Clean Raw',			60, '<To be generated>',  0, 1),
		  ('spm_create_raw_keys',					'Add Constraints',			65,'<To be generated>',  0, 1) ,
		  ('spm_rules_after_bulk_insert',			'Rules After Bulk',			70, '<To be generated>',  0, 1) ,
		  ('spm_drop_stage_keys',					'Drop Constraints',			75,'<To be generated>',  0, 1) ,
		  ('spm_create_stage_keys',					'Add Constraints',			77,'<To be generated>',  0, 1) ,
		  ('spm_delete_from_staging',               'Delete',					80, '<To be generated>',  0, 1) , 
		  ('spm_insert_clean_into_staging',         'Insert Cleaned To Staging', 90, '<To be generated>',  0, 0) , 
		  ('spm_insert_raw_to_staging',				'Insert',					 100, '<To be generated>',  0, 1) , 
		  ('spm_update_clean_stage',				'Update Clean Stage',	     200, '<To be generated>',  0, 0),
		  ('spm_rules_after_staging_insert',		'Rules After Insert',	     300, '<To be generated>',  0, 1) , 
		  ('spm_backup_staging_tables',		        'Backup Staging Tables',     350, '<To be generated>',  0, 1) , 
		  ('spm_clean_up',							'Clean Up',					  400,'<To be generated>',  0, 1) 







	IF OBJECT_ID('dbo._bd__BatchFiles', 'U') IS NOT NULL
	DROP TABLE _bd__BatchFiles

	CREATE TABLE _bd__BatchFiles(
		Name             varchar(255) NOT NULL PRIMARY KEY,
		Active           bit,   
		InstallPath      varchar(255),   
		Content          varchar(max), 
	)

	IF OBJECT_ID('dbo._bd__Documents', 'U') IS NOT NULL
	DROP TABLE _bd__Documents

	CREATE TABLE _bd__Documents(
	    ID               int identity PRIMARY KEY,
		OrigFileName     varchar(255) NOT NULL,
		CMRef            varchar(100),
		Content          varbinary(max) 
	)

  
	IF OBJECT_ID('dbo._bd__Settings', 'U') IS NOT NULL
	DROP TABLE _bd__Settings

	CREATE TABLE _bd__Settings(
	    ID             int NOT NULL,
		Name           varchar(255) PRIMARY KEY NOT NULL,
		Value          varchar(1024),
		Description    varchar(512),

	)

	INSERT dbo._bd__Settings(ID, Name, Value, Description)
	VALUES

	(1, 'Raw Data Path', 'C:\_Phocas\RawData\','All extract files will be referenced from this value. Multiple directories are no longer supported.'),
	(2, 'Extract Paths', 'c:\path1\*.*|\\server\someotherfolder\*.csv','Pipe(|) delimited list of extract paths to be copied into the [Raw Data Path]'), 
	(3, 'Allowed File Types', '.txt|.csv|.psv','Pipe(|) delimited allowed file types to be parsed from [Raw Data Path]'),

	(4, 'Extracts Have Headers', 'Y','Default Value for new extract sources in [Raw Data Path]'),

	(5, 'System State', 'Dev','If this value is ''Prod'' staging tables will not be dropped '),
	(6, 'Allow Drop Staging Tables', 'Y', 'Set to ''N'' to retain data in staging development'),
	(7, 'Update Proc Name', 'spm_update_master','Main file to run in Batch file'),
	(8, 'Support Email', 'michael.young@phocassoftware.com',''),
	(9, 'Author', 'Micky',''),
	(10, 'Copyright',  '(c) Michael Young 2016',''),
	(11, 'Debug', '0',''),
	(12, 'Vebose Logging', 'N',''),
	(13, 'Init Complete', 'N','This will change itself to ''Y'' when done. Change back to reinitialise (especially changes to database locations)'),

	(14, 'PrefixRaw', 'dbo.raw_',''),
	(15, 'PrefixStage', 'dbo.sta_',''),

	(16, 'PrefixInputView', 'dbo.in_','Prefix for input views (these views will be renered as Raw tables)'),
	(17, 'PrefixSubInputView', 'dbo.sin_','Prefix for input sub views (to be referenced by input views)'),
	(18, 'PrefixRawView', 'vraw_','All veiws of Raw tables regardless of database location to be prefixed with this. Leave this value for consistency.'),
	(19, 'PrefixStaView', 'vsta_','All veiws of Staging tables regardless of database location to be prefixed with this. Leave this value for consistency.'),

	(20, 'PrefixSubOutputView', 'dbo.','Default is ''dbo.'' so output sub queries can be freely named'),
	(21, 'PrefixOutPutView', 'dbo.phocas_','Final output query prefix. Used by PhocasSync'),
	(22, 'OutputQueryCommandStart', 'SELECT','Good to set this as ''SELECT TOP 1000'' in development so PhocasSync Uploads and Designer Builds are fast. Remember to set back to ''SELECT'''),
	

	(23, 'RawFieldsDef', 'varchar(max)','Best leave as varchar(max)'),
	(24, 'StageFieldsDef', 'varchar(max)', 'Best leave as varchar(max)'),

	(25, 'BlueDotDBName', DB_Name() ,''),
	(26, 'StagingDBName', DB_Name() ,''),
	(27, 'RawDBName',     DB_Name() ,''),
	(28, 'BackupDBName1', DB_Name() ,'Staging Tables Backup Database1'),
	(29, 'BackupDBName2', DB_Name() ,'Staging Tables Backup Database2'),
	(30, 'HugeTableDB1', DB_Name() , ''),
	(31, 'HugeTableDB2', DB_Name() , ''),
	(32, 'HugeTableDB3', DB_Name() , ''),
	(33, 'HugeTableDB4', DB_Name() , ''),
	(34, 'HugeTableDB5', DB_Name() , ''),
	(35, 'HugeTableDB6', DB_Name() , '')




	IF OBJECT_ID('dbo._bd__Snippets', 'U') IS NOT NULL
	DROP TABLE _bd__Snippets

	CREATE TABLE _bd__Snippets(
		SnippetID      int identity(1,1) ,
		SnippetName    varchar(50) PRIMARY KEY,
		SnippetType    int DEFAULT(1),  -- 1 user, 0 system (to be rebuilt)
		Description    varchar(512),
		QuerySQL     varchar(max),
	)


	IF OBJECT_ID('dbo._bd__ProcedureCode', 'U') IS NOT NULL
	DROP TABLE _bd__ProcedureCode

	CREATE TABLE _bd__ProcedureCode(
		RuleID          int identity(1,1),
		Active          bit DEFAULT(1),
		SubProcName     varchar(128),
		Action          varchar(128),
		ProcName        varchar(128) NOT NULL ,  -- FK to ProcMaster
		TableName       varchar(100) NOT NULL,  -- FK to _bd__Tables
		Description     varchar(512),
		CMRef           varchar(128),
		ManualEdit      bit DEFAULT(1),
		ExecOrder       int DEFAULT (0),       
		RuleSQL         varchar(max),
		PRIMARY KEY (ProcName, TableName)
	)




  IF OBJECT_ID('dbo._bd__Columns', 'U') IS NOT NULL
    DROP TABLE _bd__Columns

  CREATE TABLE dbo._bd__Columns (
    TableName      varchar(100)   NOT NULL,
    ColumnOrder    [int]          DEFAULT (0) NOT NULL,
    Active         bit            DEFAULT(1) NOT NULL,
	ColumnName     varchar(100)   NOT NULL,
	OutColName     varchar(100)	  NOT NULL,
	Description    varchar(max)   NULL,
    IsDeleteKey    bit            DEFAULT (0) NOT NULL,

    DataType       int            DEFAULT (0) NOT NULL,   --0 string, 1 float, 2 date
	Format         int            DEFAULT (-1) NOT NULL, --FIRST 128 for dates, -1 for leave, -2 for Trim, -3 UPPER, -4 lower
	BIType         int            DEFAULT (0),
	Replacements   varchar(255)   NULL,                  -- find1,replace1|find2,replace2|find3,rep3
    ColFunction1   varchar(255)   NULL,                  -- To Be implemented
    ColFunction2   varchar(255)   NULL,
	DoTransforms   bit            DEFAULT(0)              --To Do: Add trigger


	CONSTRAINT un_bd_TableName_Column    UNIQUE (TableName, ColumnName),
    CONSTRAINT un_bd_TableName_ColumnOut UNIQUE (TableName, OutColName),
    PRIMARY KEY (TableName, ColumnOrder, ColumnName)

  )



  IF OBJECT_ID('dbo._bd__Tables', 'U') IS NOT NULL
    DROP TABLE _bd__Tables

  CREATE TABLE _bd__Tables (
    TableName                varchar(100) PRIMARY KEY,
	Active                   bit DEFAULT (1),
    PhaseLevel               int DEFAULT (0),               
	Type                     int DEFAULT (0),  -- 0 Table 1 Query -1 System
	QuerySQL                 varchar(max),     
	OutputTo                 int DEFAULT (0) , -- 0 Staging ,  1 OutputQuery
    IncLoadType              int DEFAULT(0),   -- 0 Full Load ,1 Delete using keys
    Description              varchar(max),
    FileName                 varchar(128),
    FilePath                 varchar(128),
    Extension                varchar(10),
    HasHeaders               varchar(1),
    FieldTerminator          varchar(10),
    RowTerminator            varchar(10),
    FirstRow                 int,
	TextQualifier            varchar(10),
	IgnoreRows               int, -- to be implemented
    NoColumns                int,
    LoadOrder                int DEFAULT (0),
    DataLine1                varchar(max),
--	MakeOutputView           int DEFAULT(1),   -- 0 Yes 1 No                           
	Modified                 datetime,
	FileSize                 int,
	PreviewWithHeaders       varchar(max),
	PreviewWithoutHeaders    varchar(max),
	SelectFromRaw            varchar(max),
	SelectFromStage          varchar(max),
	TableProblems            varchar(max),
	DBRaw                    varchar(128) DEFAULT(DB_Name() ),
	DBStage                  varchar(128) DEFAULT(DB_Name() ),
	DBBackup                 varchar(128) DEFAULT(DB_Name() )
  )

  INSERT _bd__Tables (TableName, Active, PhaseLevel, Type, Description, LoadOrder)
  VALUES ('OnEnterProc', 1, 2, -1, 'Entity placeholder for stored procedure entry point.', -1000),
   ('OnExitProc', 1, 2, -1, 'Entity placeholder for stored procedure exit point.', 1000)

  INSERT _bd__ProcedureCode (Active,SubProcName, Action, ProcName, TableName, Description,ManualEdit,ExecOrder,RuleSQL)
  VALUES (1, 'spm_clean_up.OnExitProc', 'Shrink Logs', 'spm_clean_up', 'OnExitProc', 'Generic Log Shrink Routine', 1, 1000,
  'ALTER DATABASE ' + DB_Name() + '
SET RECOVERY SIMPLE;
DBCC SHRINKFILE (' + DB_Name() +'_Log, 1);
ALTER DATABASE ' + DB_Name() + '
SET  RECOVERY BULK_LOGGED;
DBCC SHRINKDATABASE (' + DB_Name() + ' , 10);  
')


  IF OBJECT_ID('dbo._bd__Lookups', 'U') IS NOT NULL
  DROP TABLE dbo._bd__Lookups
  CREATE TABLE dbo._bd__Lookups (
  LookUpName            varchar(100),
  LookUpKey             int,
  LookUpText            varchar(100),
  PRIMARY KEY (LookupName, LookUpKey)
  )  
  
  IF OBJECT_ID('dbo._bd__DirInfo', 'U') IS NOT NULL
    DROP TABLE _bd__DirInfo
  CREATE TABLE _bd__DirInfo
        (
        RowNum           INT IDENTITY(1,1) PRIMARY KEY CLUSTERED,
        Name             VARCHAR(128), --File Name and Extension
        Path             VARCHAR(128), --Full path including file name
        ShortName        VARCHAR(12),  --8.3 file name
        ShortPath        VARCHAR(100), --8.3 full path including file name
        DateCreated      DATETIME,     --Date file was created
        DateLastAccessed DATETIME,     --Date file was last read
        DateLastModified DATETIME,     --Date file was last written to
        Attributes       INT,          --Read only, Compressed, Archived
        ArchiveBit       AS CASE WHEN Attributes&  32=32   THEN 1 ELSE 0 END,
        CompressedBit    AS CASE WHEN Attributes&2048=2048 THEN 1 ELSE 0 END,
        ReadOnlyBit      AS CASE WHEN Attributes&   1=1    THEN 1 ELSE 0 END,
        Size             INT,          --File size in bytes
        Type             VARCHAR(100)  --Long Windows file type (eg.'Text Document',etc)
        )


  ALTER TABLE _bd__Columns ADD CONSTRAINT fk__bd__Tables__bd__Columns FOREIGN KEY (TableName) REFERENCES _bd__Tables (TableName) ON UPDATE CASCADE ON DELETE CASCADE;
--  ALTER TABLE _bd__ProcedureCode ADD CONSTRAINT fk__bd__Tables__bd__ProcedureCode FOREIGN KEY (TableName) REFERENCES _bd__Tables (TableName) ON UPDATE CASCADE ON DELETE CASCADE; 
--  ALTER TABLE _bd__ProcedureCode ADD CONSTRAINT fk__bd__ProcMaster__bd__ProcedureCode FOREIGN KEY (ProcName) REFERENCES _bd__ProcMaster (Procname) ON UPDATE CASCADE ON DELETE CASCADE; 

  --Populate lookups
  DECLARE @christmas datetime = '2017-12-24 13:37:25:512'
  INSERT dbo._bd__Lookups (LookUpName, LookUpKey, LookUpText)
  SELECT 'Format', CONVERT(varchar, Cast(Data as INT)), CONVERT(varchar,@christmas,Cast(Data as int))
  --,CONVERT(datetime, CONVERT(varchar,getdate(),Cast(Data as int)), Cast(Data as int))
  FROM [dbo].[fnm_split]('0,1,2,3,4,5,6,7,9,10,11,12,13,20,21,100,101,102,103,104,105,106,107,109,110,111,112,113,120,121,126',',') 

  INSERT dbo._bd__Lookups (LookUpName, LookUpKey, LookUpText)
  VALUES
		  ('Format' , -1, 'Leave Alone'),
		  ('Format' , -2, 'Trim'),
		  ('Format' , -3, 'UPPERCASE') ,
		  ('Format' , -4, 'lowercase') ,

		  ('PhaseLevel' , 0, 'Initial'),
		  ('PhaseLevel' , 1, 'Fluid') ,
		  ('PhaseLevel' , 2, 'Do Not Alter') ,

		  ('IncLoadType' , 0, 'Full reload'),
		  ('IncLoadType' , 1, 'Delete using key fields'),

		  ('DataType' , 0, 'String'),
		  ('DataType' , 1, 'Float'),
		  ('DataType' , 2, 'Date') ,


		  ('BIType' , 0, '<not set>'),
		  ('BIType' , 1, 'Measure'),
		  ('BIType' , 2, 'Property') ,
		  ('BIType' , 3, 'Dimension') ,
		  ('BIType' , 4, 'Date') ,

		  ('OutputTo' , 0, 'Staging'),
		  ('OutputTo' , 1, 'Output Query'),

		  ('TableType' , 0, 'File'),
		  ('TableType' , 1, 'View'),

		  ('ColType' , 0, 'Normal'),
		  ('ColType' , 1, 'Calculated'),


		  ('YesNo' , 0, 'No'),
		  ('YesNo' , 1, 'Yes')




GO
/****** Object:  StoredProcedure [dbo].[spm_bd__log]    Script Date: 27/10/2016 11:52:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[spm_bd__log] (
	@IsError bit = 1,
	@Info varchar(max) = 'General SQL Error',
	@Entity varchar(100) = '',
	@Action varchar(max)='',
	@RowCount int = -1,
	@DoPrint bit = 1
	)
------------------------------------------------------------------------------------------------------------------
-- Name:        spm_bd__log
-- Author:      <Micky>
-- Support:     micky@mbyoung.com
-- Created:     Sep 05 2016
-- Modified:    Sep 09 2016
-- Copyright:   (c) Michael Young 2016
------------------------------------------------------------------------------------------------------------------
AS

SET NOCOUNT ON   

DECLARE @Message VARCHAR(4000)
DECLARE @RowCountStr VARCHAR(200)  
DECLARE @ErrorMessage NVARCHAR(4000)
DECLARE @ErrorProcedure NVARCHAR(4000)
DECLARE @ErrorSeverity INT
DECLARE @ErrorState INT
DECLARE @ErrorLine INT
DECLARE @ErrorNumber INT
DECLARE @ErrorTime VARCHAR(24)
DECLARE @crlf VARCHAR(10) = CHAR(13) + CHAR(10) 

    SELECT @ErrorMessage = ERROR_MESSAGE(),
           @ErrorSeverity = ERROR_SEVERITY(),
           @ErrorState = ERROR_STATE(),
		   @ErrorProcedure = ERROR_PROCEDURE(),
		   @ErrorLine = ERROR_LINE(),
		   @ErrorNumber = ERROR_NUMBER(),
		   @ErrorTime = CONVERT(VARCHAR(24),GETDATE(),121),
		   @RowCountStr =  CASE WHEN @RowCount <> -1 THEN  CAST(@RowCount AS VARCHAR) + ' row(s)' ELSE '' END

INSERT INTO [_bd__Log]  ( isError, Info, [RowCount], Entity, [Action], Number, Description, ErrorProcedure, State, Severity, Line, Time)
VALUES( @IsError, @Info, @RowCount, @Entity, @Action, @ErrorNumber, @ErrorMessage, @ErrorProcedure, @ErrorState, @ErrorSeverity, @ErrorLine, @ErrorTime ) 

IF @DoPrint = 1
	IF @IsError = 1
	BEGIN
		IF @Info = 'General SQL Error'
			BEGIN
			SET @Message = 
				'****************************************************************' + @crlf +
				'%s ********** SQL ERROR *******************'  + @crlf + 
				'****************************************************************' + @crlf + 
				'Error Number:    %d' + @crlf +
				'Error Procedure: %s' + @crlf +
				'Error In Line:   %d' + @crlf +
				'Error Severity:  %d' + @crlf +
				'Error State:     %d' + @crlf +
				'Error Message:   %s' + @crlf 

				RAISERROR (@Message, 9 , 1, @ErrorTime, @ErrorNumber, @ErrorProcedure, 
							@ErrorLine, @ErrorSeverity, @ErrorState, @ErrorMessage ) WITH NOWAIT
			END
		ELSE
		BEGIN
			RAISERROR ('%s	%s	%s	%s	%s', 9 , 1, @ErrorTime, @Info, @Entity , @Action, @RowCountStr) WITH NOWAIT
		END
	END
	ELSE --ERROR = 0
		RAISERROR ('%s	%s	%s	%s	%s', 0 , 1, @ErrorTime, @Info, @Entity, @Action, @RowCountStr) WITH NOWAIT
SET NOCOUNT OFF    








GO
/****** Object:  StoredProcedure [dbo].[spm_bd__main]    Script Date: 27/10/2016 11:52:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spm_bd__main]
------------------------------------------------------------------------------------------------------------------
-- Name:        spm_bd__main
-- Author:      <Micky>
-- Support:     micky@mbyoung.com
-- Created:     Aug 30 2016
-- Modified:    Oct 14 2016
-- Copyright:   (c) Michael Young 2016
------------------------------------------------------------------------------------------------------------------
AS


   SET NOCOUNT ON
   DECLARE @masterprocname varchar(100) =  (SELECT Value FROM _bd__Settings WHERE Name = 'Update Proc Name')
   DECLARE @prefixraw varchar(128) = (SELECT Value FROM _bd__Settings WHERE Name = 'PrefixRaw')
   DECLARE @prefixstage varchar(128) = (SELECT Value FROM _bd__Settings WHERE Name = 'PrefixStage')
   DECLARE @author varchar(255) = (SELECT Value FROM _bd__Settings WHERE Name = 'Author')
   DECLARE @copyright varchar(255) = (SELECT Value FROM _bd__Settings WHERE Name = 'Copyright')
   DECLARE @supportemail varchar(255) = (SELECT Value FROM _bd__Settings WHERE Name = 'Support Email')
   DECLARE @systemstate varchar(128) = (SELECT Value FROM _bd__Settings WHERE Name = 'System State')
   DECLARE @path varchar(255) = (SELECT Value FROM _bd__Settings WHERE Name = 'Raw Data Path')
   DECLARE @allowedfiletypes varchar(100) = (SELECT Value FROM _bd__Settings WHERE Name = 'Allowed File Types')
   DECLARE @hasheaders varchar(10) = (SELECT Value FROM _bd__Settings WHERE Name = 'Extracts Have Headers')
   DECLARE @verbose varchar(10) = (SELECT Value FROM _bd__Settings WHERE Name = 'Vebose Logging')
   DECLARE @rawdbname varchar(128) = (SELECT Value FROM _bd__Settings WHERE Name = 'RawDBName')
   DECLARE @stagedbname varchar(128) = (SELECT Value FROM _bd__Settings WHERE Name = 'StagingDBName')
   DECLARE @bluedotdbname varchar(128) = (SELECT Value FROM _bd__Settings WHERE Name = 'BlueDotDBName')
   DECLARE @stagefielddef varchar(128) = (SELECT Value FROM _bd__Settings WHERE Name = 'StageFieldsDef')
   DECLARE @rawfielddef varchar(128) = (SELECT Value FROM _bd__Settings WHERE Name = 'RawFieldsDef')
   DECLARE @initcomplete varchar(10) = 	(SELECT Value FROM _bd__Settings WHERE Name = 'Init Complete') 
   DECLARE @prefixrawview varchar(128) = (SELECT Value FROM _bd__Settings WHERE Name = 'PrefixRawView') 
   DECLARE @prefixstaview varchar(128) = (SELECT Value FROM _bd__Settings WHERE Name = 'PrefixStaView') 
   DECLARE @prefixinputview varchar(128) = (SELECT Value FROM _bd__Settings WHERE Name = 'PrefixInputView')
   DECLARE @prefixsubinputview varchar(128) = (SELECT Value FROM _bd__Settings WHERE Name = 'PrefixSubInputView')  
   DECLARE @allowstagingdrop varchar(10) = (SELECT Value FROM _bd__Settings WHERE Name = 'Allow Drop Staging Tables')  
  
   DECLARE @outquerycmdstart varchar(128) = (SELECT Value FROM _bd__Settings WHERE Name = 'OutputQueryCommandStart') + '  '  

   DECLARE @prefixoutputview varchar(128) = (SELECT Value FROM _bd__Settings WHERE Name = 'PrefixOutputView')    
   DECLARE @prefixsuboutview varchar(128) = (SELECT Value FROM _bd__Settings WHERE Name = 'PrefixSubOutputView') 


   DECLARE @debug bit = CASE WHEN @verbose = 'Y' THEN 1 ELSE 0 END
   DECLARE @inprod bit = CASE WHEN @systemstate = 'Prod' THEN 1 ELSE 0 END
   IF @inprod = 1 SET @allowstagingdrop = 'N'
   DECLARE @crlf varchar(10) = CHAR(13) + CHAR(10)


   DECLARE @genericHeader varchar(max) = '
------------------------------------------------------------------------------------------------------------------
-- Name:        $$$NAME$$$
-- Author:      $$$AUTHOR$$$
-- Support:     $$SUPPORTEMAIL$$$
-- Created:     $$$DATE$$$
-- Copyright:   $$$COPYRIGHT$$$
------------------------------------------------------------------------------------------------------------------'

   SET @genericHeader = REPLACE(@genericHeader, '$$$DATE$$$', CAST(GETDATE() AS varchar(11)))
   SET @genericHeader = REPLACE(@genericHeader, '$$$AUTHOR$$$', @author)
   SET @genericHeader = REPLACE(@genericHeader, '$$$COPYRIGHT$$$', @copyright)
   SET @genericHeader = REPLACE(@genericHeader, '$$SUPPORTEMAIL$$$', @supportemail)
 
   IF RIGHT(@path,1) <> '\' SET @path = @path + '\'
   DECLARE @logmessage varchar(4000)
   DECLARE @rowcount int
   DECLARE @tablename varchar(100)
   DECLARE @filename varchar(128)
   DECLARE @filepath varchar(128)
   DECLARE @filesize int
   DECLARE @modified datetime
   DECLARE @firstrow varchar(10)
   DECLARE @textqualifier varchar(10)
   DECLARE @textquals int
   DECLARE @rowterminator varchar(10)
   DECLARE @fieldterminator varchar(10)
   DECLARE @nocolumns int
   DECLARE @tblcursor CURSOR
   DECLARE @filecursor CURSOR
   DECLARE @sql varchar(max)
   DECLARE @str varchar(max)
   DECLARE @type int
   DECLARE @querysql varchar(max)
   DECLARE @dataline1 varchar(max)
   DECLARE @phaselevel int

   DECLARE @todoprocedure_0 varchar(max)
   DECLARE @tableproblems varchar(max) = ''
   DECLARE @dbraw varchar(128)
   DECLARE @dbstage varchar(128)
   DECLARE @dbback varchar(128)
   DECLARE @tablehasheaders varchar(1)

   IF @initcomplete = 'N' 
   BEGIN
     EXEC spm_bd__init
	 UPDATE _bd__Settings
	 SET Value = 'Y'
	 WHERE Name = 'Init Complete'
   END

-->Find files given multiple seach paths
   IF 1=1
   BEGIN
	   TRUNCATE TABLE _bd__DirInfo
	   EXEC dbo.spm_bd__getdir @path -- will populate _bd__DirIfo

	   DELETE FROM _bd__Tables WHERE phaselevel = 0 AND QuerySQL IS NULL  -- delete where not worked on by humans

	   DELETE FROM _bd__DirInfo
	   WHERE Path IN (SELECT @path + filename FROM _bd__Tables WHERE Active = 0) --ignore some marked files 

	   DELETE FROM _bd__DirInfo
	   WHERE Path IN (SELECT @path + filename FROM _bd__Tables WHERE PhaseLevel <> 0) --ignore some marked files 

	   SET @filecursor = CURSOR FOR
			   SELECT dbo.fnm_filename_to_tablename(name), name, DateLastModified , Size
			   FROM _bd__DirInfo 
			   

	   OPEN @filecursor;
	   FETCH NEXT FROM @filecursor INTO @tablename, @filename, @modified, @filesize
	   WHILE @@fetch_status = 0
	   BEGIN
	      DECLARE @Extension varchar(10) = CASE WHEN (CHARINDEX('.', @filename, 1) <> 0) 
	                                       THEN SUBSTRING(@filename, CHARINDEX('.', @filename), LEN(@filename)) ELSE '<none>' END
 
		  IF  EXISTS (SELECT Data FROM dbo.fnm_split (@allowedfiletypes,'|') WHERE Data=@Extension)
		  BEGIN
		      IF NOT EXISTS(SELECT * FROM _bd__Tables WHERE TableName = @tablename)
			  BEGIN
				  INSERT INTO _bd__Tables (TableName)
					 SELECT @tablename

				  UPDATE _bd__Tables
				  SET PhaseLevel = 0,
					  Active = 1,
					  FileName = @filename,
					  FilePath = @path + @filename,
					  Extension = @Extension,
					  HasHeaders = @hasheaders,
					  FirstRow = 1,
					  IgnoreRows = 0,
					  FileSize = @filesize,
					  Modified = @modified,
					  DBRaw = @rawdbname,
					  DBStage = @stagedbname
				  WHERE TableName = @tablename
			   END

		  END
	   FETCH NEXT FROM @filecursor INTO @tablename, @filename, @modified, @filesize
	   END
	   CLOSE @filecursor;
	   DEALLOCATE @filecursor;
   END

   SET @tblcursor = CURSOR FOR
   SELECT
      tablename,
      @path + filename,
      phaselevel,
      querysql,
	  Type,
	  '[' + DBRaw + '].',
	  '[' + DBStage + '].',
	  '[' + DBBackup + '].',
	  HasHeaders,
	  CASE WHEN TextQualifier = '"' THEN 1 ELSE 0 END textquals


   FROM dbo._bd__tables
   WHERE Active = 1
   --AND Type <> -1 -- System Entities

   DECLARE @delims TABLE (
      delimname varchar(10),
      delim     varchar(10),
      delims    int
   )
  OPEN @tblcursor;
  FETCH NEXT FROM @tblcursor INTO @tablename, @filepath, @phaselevel, @querysql, @type, @dbraw, @dbstage, @dbback, @tablehasheaders, @textquals
  WHILE @@fetch_status = 0
  BEGIN
    DECLARE @isQuery bit = CASE WHEN @type=1 THEN 1 ELSE 0 END
    IF 	 @type <> -1 AND (@phaselevel in (0,1) or (@isQuery = 1 and @phaselevel <> 2) ) --> 2 is 'Do not alter'

      BEGIN

         IF @isQuery = 0
         BEGIN
			IF OBJECT_ID('tempdb..#tmp', 'U') IS NOT NULL
			DROP TABLE #tmp;
			CREATE TABLE #tmp (
				[line] varchar(max)
			);
			SET @sql = 'bulk insert #tmp from ''' + @filepath + '''
						with (FirstRow =  1 , LastRow = 1, RowTerminator = ''0x0A'')'
			EXEC (@sql)
			DELETE FROM @delims
			INSERT @delims
				VALUES	('Pipe', '|', (SELECT LEN(line) - LEN(REPLACE(line, '|', '')) FROM #tmp)),
						('Comma', ',', (SELECT LEN(line) - LEN(REPLACE(line, ',', '')) FROM #tmp)),
						('Tab', '	', (SELECT LEN(line) - LEN(REPLACE(line, '	', '')) FROM #tmp)),
						('Carret', '^', (SELECT LEN(line) - LEN(REPLACE(line, '^', '')) FROM #tmp))
			SET @fieldterminator = (SELECT TOP (1) delim FROM @delims ORDER BY delims DESC)
			SET @nocolumns = (SELECT MAX(delims) FROM @delims)
			SET @dataline1 = (SELECT TOP (1) line FROM #tmp)
			SET @rowterminator = (SELECT CASE WHEN (RIGHT(line, 1) = CHAR(13)) THEN '\n' ELSE '0x0A' END FROM #tmp)
			SET @dataline1 = REPLACE(@dataline1, CHAR(13), '')
			SET @textquals = 0
			IF CHARINDEX('"', @dataline1) <> 0 
			BEGIN
				SET @textqualifier = '"'
				SET @dataline1 = REPLACE(@dataline1, '"', '')
				SET @textquals = 1
				
				SET @sql = ' IF OBJECT_ID(''tempdb..#colcount'', ''U'') IS NOT NULL DROP TABLE #colcount; 
				SELECT * INTO #colcount 
				FROM OPENROWSET (''MSDASQL'',''Driver={Microsoft Access Text Driver (*.txt, *.csv)}''
                ,''SELECT TOP 10 * FROM ' + @filepath + '''); UPDATE _bd__Tables  SET NoColumns = (SELECT 
				COUNT(*) FROM tempdb.sys.columns WHERE object_id = object_id(''tempdb..#colcount''))
				WHERE TableName = ''' + @tablename + ''';
				IF OBJECT_ID(''tempdb..#colcount'', ''U'') IS NOT NULL DROP TABLE #colcount; '
				

			--	EXEC(@sql)
			--	SELECT @nocolumns = NoColumns FROM _bd__Tables  WHERE TableName = @tablename
				
			    BEGIN TRY
	                EXEC(@sql)
					SELECT @nocolumns = NoColumns-1 FROM _bd__Tables  WHERE TableName = @tablename
	            END TRY
	            BEGIN CATCH
	              EXEC dbo.spm_bd__log
	            END CATCH
			
			    
			END


			SET @firstrow = 1

            ----> ATTEMPT CREATE TABLE..

            DECLARE @createwithheader varchar(max)
            SELECT @createwithheader = COALESCE(@createwithheader + ',', '') + '[' + data + '] varchar(max)' + @crlf 
			FROM dbo.fnm_split(@dataline1, @fieldterminator)

            DECLARE @createcolumnxxx varchar(max)
            SELECT @createcolumnxxx = COALESCE(@createcolumnxxx + ',', '') + dbo.fnm_col_name(sv.number) + ' varchar(max)' + @crlf 
	        FROM [master].dbo.spt_values sv 
			WHERE sv.[type] = 'P'
            AND sv.number BETWEEN 0 AND @nocolumns

            DECLARE @sqlcreatetable varchar(max) = 'CREATE TABLE #tmp ( ' + @crlf + @createwithheader + ')'

         BEGIN TRY
            IF OBJECT_ID('tempdb..#tmp', 'U') IS NOT NULL
               DROP TABLE #tmp;
            EXEC (@sqlcreatetable)
            IF @debug = 1
            BEGIN
               SET @logmessage = 'Success: Auto create table with headers for --> ' + @filepath + ' with ' + @crlf + @sqlcreatetable + @crlf
               EXEC dbo.spm_bd__log 0,
                                @logmessage,
                                @tablename
            END
         END TRY
         BEGIN CATCH
            SET @logmessage = 'Failure: Cannot auto create table with headers for --> ' + @filepath + ' with ' + @crlf + @sqlcreatetable + @crlf
            EXEC dbo.spm_bd__log 1,
                             @logmessage,
                             @tablename
            SET @tableproblems = @crlf + @tableproblems + @logmessage + @crlf
         END CATCH

         BEGIN TRY
            IF OBJECT_ID('tempdb..#tmp', 'U') IS NOT NULL
               DROP TABLE #tmp;
            SET @sqlcreatetable = 'CREATE TABLE #tmp ( ' + @crlf + @createcolumnxxx + ')'
            EXEC (@sqlcreatetable)
            IF @debug = 1
            BEGIN
               SET @logmessage = 'Success: Auto create table without headers for --> ' + @filepath + ' with ' + @crlf + @sqlcreatetable + @crlf
               EXEC dbo.spm_bd__log 0,
                                @logmessage,
                                @tablename
            END
         END TRY
         BEGIN CATCH
            SET @logmessage = 'Failure: Cannot auto create table without headers for --> ' + @filepath + ' with ' + @crlf + @sqlcreatetable + @crlf
            EXEC dbo.spm_bd__log 1,
                             @logmessage,
                             @tablename
            SET @tableproblems = @crlf + @tableproblems + @logmessage + @crlf
         END CATCH

            DECLARE @sqlbulkinsert varchar(max) =
            'IF OBJECT_ID(''tempdb..#tmp'', ''U'') IS NOT NULL DROP TABLE #tmp; ' + @crlf +
            'CREATE TABLE #tmp ( ' + @crlf + @createcolumnxxx + ');' + @crlf +
            'BULK INSERT #tmp FROM ''' + @filepath + '''
		     with (FirstRow =  1 , LastRow = 1000, FieldTerminator = ''' + @fieldterminator + ''', RowTerminator  = ''' + @rowterminator + ''')' + @crlf --+ ';PRINT @@ROWCOUNT'

		    IF @textquals = 1
			BEGIN
			SET @sqlbulkinsert = 'IF OBJECT_ID(''tempdb..#tmp'', ''U'') IS NOT NULL DROP TABLE #tmp; ' + @crlf +
                                 'CREATE TABLE #tmp ( ' + @crlf + @createcolumnxxx + ');' + @crlf +
								 'INSERT #tmp ' + @crlf +
								 'SELECT * FROM OPENROWSET (''MSDASQL'', ''Driver={Microsoft Access Text Driver (*.txt, *.csv)}'', ' + @crlf +
								 '''SELECT TOP 1000 * FROM ' + @filepath + '''' + ')'
			END


         BEGIN TRY
            EXEC (@sqlbulkinsert)
            IF @debug = 1
            BEGIN
               SET @logmessage = 'Success: Bulk Insert --> ' + @filepath + ' with ' + @crlf + @sqlbulkinsert + @crlf
               EXEC dbo.spm_bd__log 0,
                                @logmessage,
                                @tablename
            END
         END TRY
         BEGIN CATCH
            SET @logmessage = 'Failure: Bulk Insert --> ' + @filepath + ' with ' + @crlf + @sqlbulkinsert + @crlf
            EXEC dbo.spm_bd__log 1,
                             @logmessage,
                             @tablename
            SET @tableproblems = @crlf + @tableproblems + @logmessage + @crlf
         END CATCH

         BEGIN TRY
--->  Detect new columns. Add the new cols to _bd__Columns
            DECLARE @newColumns TABLE (ColumnOrder int, TableName varchar(128), ColumnName varchar(128), OutColName varchar(128))
			DELETE FROM @newColumns
            IF @tablehasheaders = 'Y'
			BEGIN
			   INSERT @newColumns (ColumnOrder, TableName, ColumnName, OutColName)
			      SELECT Id ColumnOrder, @tablename TableName, data ColumnName, data OutColName
			      FROM dbo.fnm_split(@dataline1, @fieldterminator)
			END
            ELSE
			BEGIN
			   INSERT @newColumns (ColumnOrder, TableName, ColumnName, OutColName)
                  SELECT sv.Number + 1 ColumnOrder, @tablename TableName, dbo.fnm_col_name(sv.number) 
				  ColumnName,  dbo.fnm_col_name(sv.number) OutColName 
				  FROM master.dbo.spt_values sv WHERE sv.type = 'P'
                  AND sv.number BETWEEN 0 AND @nocolumns
			END

			INSERT _bd__Columns (ColumnOrder, TableName, ColumnName, OutColName)
				SELECT nc.ColumnOrder, nc.TableName, nc.ColumnName, nc.OutColName
				FROM  @newColumns nc
				WHERE ColumnName NOT IN (SELECT ColumnName FROM _bd__Columns WHERE TableName = @TableName)
		
			UPDATE _bd__Columns  SET
				ColumnOrder = nc.ColumnOrder
			FROM @newColumns nc
			JOIN _bd__Columns 
			ON _bd__Columns.TableName = nc.TableName
			AND _bd__Columns.ColumnName = nc.ColumnName

			UPDATE _bd__Columns SET
			   Active = 0
			WHERE ColumnName NOT IN (SELECT ColumnName FROM @newColumns)
			AND TableName = @TableName

            IF @debug = 1
            BEGIN
               SET @logmessage = 'Success:  --> Add Columns to ' + @tablename
               EXEC dbo.spm_bd__log 0,
                                @logmessage,
                                @tablename
            END
         END TRY
         BEGIN CATCH
            SET @logmessage = 'Failure:  --> Add Columns to ' + @tablename
            EXEC dbo.spm_bd__log 1,
                             @logmessage,
                             @tablename
            SET @tableproblems = @crlf + @tableproblems + @logmessage + @crlf
         END CATCH
         END
         ELSE IF @isQuery = 1 -->> Query 
         BEGIN
			-->Create Raw Table From Query
			EXEC ('IF OBJECT_ID('''+ @dbraw + @prefixraw + @tablename+''', ''U'') IS NOT NULL DROP TABLE ' + @dbraw + @prefixraw + @tablename)
			SET @sql='SELECT TOP 1 * INTO ' + @dbraw + @prefixraw + @tablename + @crlf + ' FROM ('  + @querysql  + ') a'
            BEGIN TRY
			   EXEC(@sql)
			   IF @debug = 1
				   BEGIN
					  -- SET @logmessage = 'Success:  --> Create Query ' + @tablename
					   SET @logmessage = 'Success:  --> Create RAW Table From Query ' + @tablename
					   EXEC dbo.spm_bd__log 0,
										@logmessage,
										@tablename
					END
				
			END TRY
			BEGIN CATCH
				EXEC dbo.spm_bd__log 1,
								 @logmessage,
								 @tablename,
								 @sql
				SET @tableproblems = @crlf + @tableproblems + @logmessage + @crlf
			END CATCH
			SET @fieldterminator = ''
			SET @nocolumns = (SELECT COUNT(*)-1 FROM sys.columns where object_id = object_id(@dbraw + @prefixraw + @tablename))
			SET @dataline1 = NULL
			SET @rowterminator = NULL
			SET @firstrow = 1
			SET @filepath = NULL
			DELETE FROM _bd__Columns where TableName = @tablename
			INSERT _bd__Columns (ColumnOrder, TableName, ColumnName, OutColName)
			SELECT column_id, @tablename, name, name
			FROM sys.columns where object_id = object_id(@dbraw + @prefixraw + @tablename)
         END

		 SET @nocolumns = @nocolumns + 1
		 UPDATE _bd__tables SET    
		        FieldTerminator = @fieldterminator,
                NoColumns = @nocolumns,
                RowTerminator = @rowterminator,
                DataLine1 = @dataline1,
                TextQualifier = @textqualifier
              --  IncLoadType = 0
         WHERE tablename = @tablename

         DECLARE @problem varchar(max) = '--<WARNING - SOME ERROR HAS OCCURED IN AUTO CREATE PROCEDURE CODE>' + @crlf
         DECLARE @linecreatewith varchar(max) = COALESCE((SELECT value from dbo.fnm_clean_str(0, @createwithheader)), @problem)
         DECLARE @linecreatewithout varchar(max) = COALESCE((SELECT value from dbo.fnm_clean_str(0, @createcolumnxxx)), @problem)
         DECLARE @linewithhead varchar(max) = REPLACE(@linecreatewith, ' VARCHAR(MAX)', '')
         DECLARE @linenohead varchar(max) = REPLACE(@linecreatewithout, ' VARCHAR(MAX)', '')

		 DECLARE @previewwithheaders varchar(max) = 'SET NOCOUNT ON;IF OBJECT_ID(''tempdb..#tmp'', ''U'') IS NOT NULL DROP TABLE #tmp; CREATE TABLE #tmp ( ' + @linecreatewith + ');' +
			 'BULK INSERT #tmp FROM ' + QUOTENAME(@filepath, '''') +
			 ' with (FirstRow =  2 , LastRow = 1000, FieldTerminator = ''' + @fieldterminator + ''', RowTerminator  = ''' + @rowterminator + ''');' + @crlf +
			 'SELECT TOP 1000 * FROM #tmp; DROP TABLE #tmp; ' + @crlf


		 DECLARE @previewwithoutheaders varchar(max) = 'SET NOCOUNT ON;IF OBJECT_ID(''tempdb..#tmp2'', ''U'') IS NOT NULL DROP TABLE #tmp2; CREATE TABLE #tmp2 ( ' + @linecreatewithout + ');' +
			 'BULK INSERT #tmp2 FROM ' + QUOTENAME(@filepath, '''') +
			 ' with (FirstRow =  1 , LastRow = 1000, FieldTerminator = ''' + @fieldterminator + ''', RowTerminator  = ''' + @rowterminator + ''');' + @crlf +
			 'SELECT TOP 1000 * FROM #tmp2; DROP TABLE #tmp2; ' +@crlf

		
		IF @textquals = 1 
		BEGIN
		    SET @previewwithheaders = 'SELECT * FROM OPENROWSET (''MSDASQL'', ''Driver={Microsoft Access Text Driver (*.txt, *.csv)}'', ' + @crlf +
								 '''SELECT TOP 1000 * FROM ' + @filepath + '''' + ')'
            SET @previewwithoutheaders = 'SET NOCOUNT ON;IF OBJECT_ID(''tempdb..#tmp2'', ''U'') IS NOT NULL DROP TABLE #tmp2; ' + 
			                             'CREATE TABLE #tmp2 ( ' + @linecreatewithout + '); ' +
			                             'INSERT tempdb..#tmp2' + @crlf + @previewwithheaders +
										 'SELECT TOP 1000 * FROM #tmp2; DROP TABLE #tmp2; ' +@crlf
		END

         SET @todoprocedure_0 = COALESCE(@todoprocedure_0, '')

		 IF @isQuery = 1
		 BEGIN 
		  SET @todoprocedure_0 = @todoprocedure_0 + COALESCE(
			 '--==========================================================================================================================================' + @crlf +
			 '--	Enitiy   ' + @tablename +
			 '--    Path      This entity is a view. Please edit this view in _bd__Tables.QuerySQL'+ @crlf +
			 '--    Preview   SELECT TOP 1000 * FROM ' + @dbraw + @prefixraw + @tablename + @crlf +
			 '--    Col Count ' + CAST(@nocolumns AS varchar)  + @crlf +
			 '-----------------------------------------------------------------------------' + @crlf , @problem)
		 END
		 ELSE IF @isQuery = 0
		 BEGIN

			 SET @todoprocedure_0 = @todoprocedure_0 + COALESCE(
			 '--==========================================================================================================================================' + @crlf +
			 '--	Enitiy   ' + @tablename + @crlf +
			 '--	Path     ' + @filepath + @crlf +
			 '-----------------------------------------------------------------------------' + @crlf +
			 '--	Line1	 ' + @dataline1 + @crlf +
			 '--	Cols1(Y) ' + @linewithhead + @crlf +
			 '--	Cols2(N) ' + @linenohead + @crlf, @problem)

			 SET @todoprocedure_0 = @todoprocedure_0 + COALESCE('/* -- Data Previews' + @crlf + @previewwithheaders + @previewwithoutheaders + '*/' + @crlf
			 , @problem)

			 SET @todoprocedure_0 = @todoprocedure_0 + COALESCE(
			 CASE WHEN @tableproblems = '' THEN '----> Phase_0 Status: OK' ELSE '----> This enity has problems that need to be addressed see below: ' + @crlf + '/*' + @tableproblems + '*/' + @crlf END, @problem)

			 SET @todoprocedure_0 = @todoprocedure_0 +
			 COALESCE('----> Please determine and set the variables below ' + @crlf + @crlf +
			 'UPDATE _bd__Tables SET ' + @crlf + CASE WHEN @tableproblems = '' THEN '	PhaseLevel = 1,				-- set back to 0 if not working and try phase 0 again or -1 to ignore the file' 
			 ELSE '	PhaseLevel = 1,				-- you will have to address the issues above somehow! or Active=0 to ignore the file' END + @crlf +
			 '	TableName = ''' + @tablename + ''' ,	-- can be changed not the best idea though' + @crlf +
			 '	Description = ''' + @tablename + ''',	-- should add a description to enrich the meta-data' + @crlf +
			 '	HasHeaders = ''' + @hasheaders + ''',			-- set to Y or N' + @crlf +
			 '	TextQualifier = ''' + @textqualifier + ''',			-- gotta love em' + @crlf +
			 '	FirstRow = ''' + @firstrow + ''',				-- set to 1 for no header, 2 if headers. or there may be titles at the head' + @crlf +
			 '	FieldTerminator = ''' + @fieldterminator + ''',		-- should be OK' + @crlf +
			 '	RowTerminator = ''' + @rowterminator + ''',		-- should be OK' + @crlf +
			 '	NoColumns = ' + CAST(@nocolumns  AS varchar) + '				-- change phase level or panic if incorrect' + @crlf +
			 'WHERE TableName = ''' + @tablename + ''''
			 , @problem) + @crlf + @crlf
		 END
		 UPDATE _bd__Tables SET 
			PreviewWithOutHeaders = @previewwithoutheaders,
			PreviewWithHeaders= @previewwithheaders,
			TableProblems = @tableproblems
		  WHERE TableName = @tablename

         SET @createcolumnxxx = NULL
         SET @createwithheader = NULL
         SET @tableproblems = ''

    END -->> PhaseLevel 0
    IF @phaselevel > 0 or @isQuery = 1
      BEGIN
         DECLARE @createstagetable varchar(max) 
         DECLARE @beforeappenddelete varchar(max)
         DECLARE @insertfromraw varchar(max)
		 DECLARE @inserttostage varchar(max)
         DECLARE @createoutputview varchar(max)
		 DECLARE @createpreoutview varchar(max)
         DECLARE @bulkinsertstatement varchar(max)
		 DECLARE @querytoraw varchar(max)
         DECLARE @createrawtable varchar(max)
		 DECLARE @updatecleanraw varchar(max)
		 DECLARE @updatecleanstage varchar(max)
		 DECLARE @selectfromraw varchar(max)
		 DECLARE @selectfromstage varchar(max)
		 DECLARE @cleanintostage varchar(max)
		 DECLARE @deletejoins varchar(max)
		 DECLARE @backupstage varchar(max)

		 DECLARE @selectcols      varchar(max)
		 DECLARE @selectcleancols varchar(max)

		 DECLARE @deleteindexes varchar(max)
		 DECLARE @keylist varchar(max)
		 DECLARE @createstagekeys varchar(max)
		 DECLARE @createrawkeys varchar(max)
		 DECLARE @dropstagekeys varchar(max)
		 DECLARE @droprawkeys varchar(max)

	IF @type <> -1 
	BEGIN
/*
TODO - create synonyms for each object
		 select 'create synonym syn_' + t.name + ' for [' + DB_NAME() + '].[' + s.name + '].[' + t.name + ']' 
    from sys.tables t
        inner join sys.schemas s
            on t.schema_id = s.schema_id
    where t.type = 'U'
*/
         --> This Phase have manually adjusted the PhaseLevel Table Field and checked is there are header rows
         --> We have also checked the _bd__Columns table out
         SELECT @createrawtable = COALESCE(@createrawtable + ',', '') + '[' + OutColName + '] ' + @rawfielddef + @crlf 
		 FROM _bd__Columns 
		 WHERE TableName = @tablename 
         ORDER BY ColumnOrder

         SELECT @createstagetable = COALESCE(@createstagetable + ',', '') + '[' + OutColName + '] ' + @stagefielddef + @crlf 
		 FROM _bd__Columns WHERE TableName = @tablename
		 AND Active = 1
         ORDER BY ColumnOrder


         SELECT @createoutputview = COALESCE(@createoutputview + ',', '') +	'[' + OutColName + ']	' +'[' + OutColName + ']'+ @crlf 
		 FROM _bd__Columns WHERE TableName = @tablename
		 AND Active = 1
         ORDER BY ColumnOrder
		 SET @createoutputview = REPLACE(@createoutputview, '''', '''''')

         SELECT @insertfromraw = COALESCE(@insertfromraw + ',', '') + '[' + OutColName + ']' + @crlf 
		 FROM dbo._bd__Columns WHERE TableName = @tablename
		 AND Active = 1
         ORDER BY ColumnOrder

         SELECT @inserttostage= COALESCE(@inserttostage + ',', '') + '[' + OutColName + ']' + @crlf  		 
		 FROM dbo._bd__Columns WHERE TableName = @tablename
		 AND Active = 1
         ORDER BY ColumnOrder


		 SELECT  @selectfromraw =  COALESCE(@selectfromraw + ',', '') + '[' + OutColName + ']' + @crlf  		 
		 FROM dbo._bd__Columns WHERE TableName = @tablename
		 AND Active = 1
         ORDER BY ColumnOrder

		 SELECT @selectfromstage  = COALESCE(@selectfromstage + ',', '') + '[' + OutColName + ']' + @crlf  		 
		 FROM dbo._bd__Columns WHERE TableName = @tablename
		 AND Active = 1
         ORDER BY ColumnOrder

		 SELECT @selectcols  = COALESCE(@selectcols + ',', '') + '[' + OutColName + ']' + @crlf  		 
		 FROM dbo._bd__Columns WHERE TableName = @tablename
		 AND Active = 1
         ORDER BY ColumnOrder

		 SELECT @selectcleancols = COALESCE(@selectcleancols + ',', '') +
+
		 	    CASE   
				        WHEN DataType=0 AND Format <> -1 THEN '(SELECT value FROM dbo.fnm_clean_str(' + CAST(Format as varchar) + ', '
						WHEN DataType=1 THEN 'CASE WHEN ISNUMERIC((SELECT value FROM dbo.fnm_clean_float(' + CAST(Format as varchar) + ', '
						WHEN DataType=2 AND Format <> - 1 THEN '(SELECT value FROM dbo.fnm_clean_date(' + CAST(Format as varchar) + ', '
                        ELSE ''
				 END + 
				 CASE WHEN len(Replacements) > 0 THEN [dbo].[fnm_build_replace] (' ['+OutColName+'] ', Replacements) 
				 ELSE  ' ['+OutColName+'] ' END +

				 CASE 
				        WHEN DataType=0 AND Format <> -1 THEN '))'
						WHEN DataType=1 THEN ')))=1 THEN CAST((SELECT value FROM dbo.fnm_clean_float(' + CAST(Format as varchar) + ', ' + '['+OutColName+'] )) AS FLOAT) ELSE 0 END '
						WHEN DataType=2 AND Format <> - 1 THEN '))'
                        ELSE ''
						END +

				 '  AS [' + OutColName + ']'+ @crlf 
		 FROM dbo._bd__Columns WHERE TableName = @tablename
		 AND Active = 1
		 --AND DoTransforms = 1
         ORDER BY ColumnOrder

		 --SET @updatecleanraw = 'UPDATE ' + @dbraw + @prefixraw + @tablename + ' SET ' + @crlf  + @updatecleanraw
		 SET @updatecleanraw = 'IF OBJECT_ID(''temp..#tempclean_' + @tablename + ''', ''U'') IS NOT NULL DROP TABLE #tempclean_' + @tablename  + @crlf +
		 'SELECT ' + @crlf + @selectcleancols + ' INTO #tempclean_' + @tablename +   + @crlf + ' FROM ' +   @dbraw + @prefixraw + @tablename + @crlf +
		 'TRUNCATE TABLE ' + @dbraw + @prefixraw + @tablename + @crlf +
		 'INSERT ' + @dbraw + @prefixraw + @tablename + @crlf +
		 'SELECT ' + @selectcols + @crlf + ' FROM #tempclean_' + @tablename + @crlf +
		 'DROP TABLE #tempclean_' + @tablename + @crlf

		 SET @updatecleanstage = 'IF OBJECT_ID(''temp..#tempclean2_' + @tablename + ''', ''U'') IS NOT NULL DROP TABLE #tempclean2_' + @tablename  + @crlf +
		 'SELECT ' + @crlf + @selectcleancols + ' INTO #tempclean2_' + @tablename +   + @crlf + ' FROM ' +   @dbstage + @prefixstage + @tablename + @crlf +
		 'TRUNCATE TABLE ' +  @dbstage + @prefixstage + @tablename + @crlf +
		 'INSERT ' +  @dbstage + @prefixstage + @tablename + @crlf +
		 'SELECT ' + @selectcols + @crlf + ' FROM #tempclean2_' + @tablename + @crlf +
		 'DROP TABLE #tempclean2_' + @tablename + @crlf	 

		 SELECT @deletejoins = COALESCE(@deletejoins  + 'AND ', '    ') + ' a.[' + OutColName + '] = b.[' + OutColName + ']' + @crlf 
		 --SELECT @deletejoins = COALESCE(@deletejoins  + 'AND ', '    ') + ' ISNULL(a.[' + OutColName + '], ''NULL'') =  ISNULL(b.[' + OutColName + '], ''NULL'')' + @crlf 

		 FROM _bd__Columns C JOIN _bd__Tables T ON C.TableName = T.Tablename AND T.TableName = @tablename 
		 WHERE C.IsDeleteKey = 1 AND C.Active = 1 AND IncLoadType = 1 AND T.Type <> -1 AND T.Active = 1
		 ORDER BY ColumnOrder	

		
		SELECT @keylist =COALESCE(@keylist + ',', '') + '[' + OutColName + '] ' 
		FROM _bd__Columns C JOIN _bd__Tables T ON C.TableName = T.Tablename AND T.TableName = @tablename 
		WHERE C.IsDeleteKey = 1 AND C.Active = 1  AND T.Type <> -1 AND T.Active = 1
		ORDER BY ColumnOrder 

		SET @dropstagekeys ='IF EXISTS(SELECT * FROM ' + @dbstage + 'sys.indexes WHERE name = ''idx_keys_' + Replace(@prefixstage, '.','_') + @tablename + ''')' + @crlf +
        'DROP INDEX idx_keys_' + Replace(@prefixstage, '.','_') + @tablename +  ' ON ' + @dbstage + @prefixstage + @tablename + ';' + @crlf + @crlf +

        'IF OBJECT_ID(''' + @dbstage + '.PK_' + Replace(@prefixstage, '.','_')  + @tablename + ''') IS NOT NULL ' + @crlf +
		'ALTER TABLE ' + @dbstage + @prefixstage + @tablename + ' DROP CONSTRAINT ' + 'PK_' + Replace(@prefixstage, '.','_') + @tablename + ';' + @crlf + @crlf +

		'IF COL_LENGTH(''' + @dbstage + @prefixstage + @tablename + ''' , ''row_key'') IS NOT NULL' + @crlf +
		'ALTER TABLE ' + @dbstage + @prefixstage + @tablename  + ' DROP COLUMN row_key ;' + @crlf 



		SET @createstagekeys ='IF COL_LENGTH(''' + @dbstage + @prefixstage + @tablename + ''', ''row_key'') IS  NULL' + @crlf +
		'ALTER TABLE ' + @dbstage + @prefixstage + @tablename + ' ADD row_key BIGINT IDENTITY(1,1) NOT NULL;' + @crlf + @crlf +

        'IF OBJECT_ID(''' + @dbstage + '.PK_' + Replace(@prefixstage, '.','_')  + @tablename + ''') IS  NULL ' + @crlf +
		'ALTER TABLE ' + @dbstage + @prefixstage + @tablename + @crlf +
		'ADD CONSTRAINT PK_'  + Replace(@prefixstage, '.','_') + @tablename  + ' PRIMARY KEY  ' + '( row_key );' + @crlf + @crlf +

 
        'IF NOT EXISTS(SELECT * FROM ' + @dbstage + 'sys.indexes WHERE name = ''idx_keys_' + Replace(@prefixstage, '.','_') + @tablename + ''')' + @crlf +
        'CREATE NONCLUSTERED INDEX idx_keys_' + Replace(@prefixstage, '.','_') + @tablename +  ' ON ' + @dbstage + @prefixstage + @tablename + ' ( row_key )'  + @crlf +
        'INCLUDE (' + @keylist + ')' + @crlf  
	--	'WITH ( DATA_COMPRESSION = ROW )' + @crlf 


---[dbo].[spm_bd__main]


        SET @droprawkeys = 'IF EXISTS(SELECT * FROM ' + @dbraw + 'sys.indexes WHERE name = ''idx_keys_' + Replace(@prefixraw, '.','_') + @tablename + ''')' + @crlf +
        'DROP INDEX idx_keys_' + Replace(@prefixraw, '.','_') + @tablename +  ' ON ' + @dbraw + @prefixraw + @tablename + ';' + @crlf + @crlf +

        'IF OBJECT_ID(''' + @dbraw + '.PK_' + Replace(@prefixraw, '.','_')  + @tablename + ''') IS NOT NULL ' + @crlf +
		'ALTER TABLE ' + @dbraw + @prefixraw + @tablename + ' DROP CONSTRAINT ' + 'PK_' + Replace(@prefixraw, '.','_') + @tablename + ';' + @crlf + @crlf +

		'IF COL_LENGTH(''' + @dbraw + @prefixraw + @tablename + ''' , ''row_key'') IS NOT NULL' + @crlf +
		'ALTER TABLE ' + @dbraw + @prefixraw + @tablename  + ' DROP COLUMN row_key ;' + @crlf

		SET @createrawkeys = 'IF COL_LENGTH(''' + @dbraw + @prefixraw + @tablename + ''', ''row_key'') IS  NULL' + @crlf +
		'ALTER TABLE ' + @dbraw + @prefixraw + @tablename + ' ADD row_key BIGINT IDENTITY(1,1) NOT NULL;' + @crlf + @crlf +

        'IF OBJECT_ID(''' + @dbraw + '.PK_' + Replace(@prefixraw, '.','_')  + @tablename + ''') IS  NULL ' + @crlf +
		'ALTER TABLE ' + @dbraw + @prefixraw + @tablename + @crlf +
		'ADD CONSTRAINT PK_'  + Replace(@prefixraw, '.','_') + @tablename  + ' PRIMARY KEY  ' + '( row_key );' + @crlf + @crlf +

 
        'IF NOT EXISTS(SELECT * FROM ' + @dbraw + 'sys.indexes WHERE name = ''idx_keys_' + Replace(@prefixraw, '.','_') + @tablename + ''')' + @crlf +
        'CREATE NONCLUSTERED INDEX idx_keys_' + Replace(@prefixraw, '.','_') + @tablename +  ' ON ' + @dbraw + @prefixraw + @tablename + ' ( row_key )'  + @crlf +
        'INCLUDE (' + @keylist + ')' + @crlf  
	--	'WITH ( DATA_COMPRESSION = ROW )' + @crlf 
	
/*
IF EXISTS(SELECT * FROM [BlueDot].sys.indexes WHERE name = 'idx_keys_dbo_sta_branch')
print 'hello'
DROP INDEX idx_keys_dbo_sta_branch ON [BlueDot].dbo.sta_branch

SELECT *  
FROM dev1.information_schema.table_constraints  
WHERE constraint_type = 'PRIMARY KEY'   
AND table_name = @Your_Table_Name`

				-- drop current primary key constraint
ALTER TABLE dbo.persion 
DROP CONSTRAINT PK_persionId;
GO

-- add new auto incremented field
ALTER TABLE dbo.persion 
ADD pmid BIGINT IDENTITY;
GO

-- create new primary key constraint
ALTER TABLE dbo.persion 
ADD CONSTRAINT PK_persionId PRIMARY KEY NONCLUSTERED (pmid, persionId);
GO
		*/

		SET @deletejoins =   @crlf + 'INNER JOIN ' + @dbraw + @prefixraw + @tablename + ' b ON ' + @crlf +  @deletejoins 
		SET @beforeappenddelete = 'DELETE a FROM ' + @dbstage + @prefixstage + @tablename + ' a ' + COALESCE (@deletejoins, '')


		SET @backupstage = 'IF OBJECT_ID('''+ @dbback + @prefixstage + @tablename + '_BAK' + ''', ''U'') IS NOT NULL' + @crlf +
		'DROP TABLE ' + @dbback + @prefixstage + @tablename + '_BAK' + @crlf +
		'SELECT * INTO ' + @crlf + @dbback + @prefixstage + @tablename  + '_BAK' +  @crlf +
		' FROM  ' + @dbstage + @prefixstage + @tablename
		

         SELECT @bulkinsertstatement = 'TRUNCATE TABLE ' + @dbraw + @prefixraw + TableName + @crlf + 'BULK INSERT ' + 
		 @dbraw + @prefixraw + TableName + @crlf + 'FROM ''' + @filepath + '''' + @crlf + 
		 'WITH ( FIRSTROW = ' + CASE WHEN HasHeaders = 'Y' THEN '2' ELSE '1' END + 
		 ', FIELDTERMINATOR = ''' + [FieldTerminator] + ''', ROWTERMINATOR = ''' + [RowTerminator] + ''')'
		 FROM _bd__Tables 
		 WHERE TableName = @tablename

		 IF @textquals = 1
		 BEGIN
		    SELECT @bulkinsertstatement = 'TRUNCATE TABLE ' + @dbraw + @prefixraw + TableName + @crlf + 
			'INSERT ' + @dbraw + @prefixraw + TableName + @crlf + 
			'SELECT * FROM OPENROWSET (''MSDASQL'', ''Driver={Microsoft Access Text Driver (*.txt, *.csv)}'', ' + @crlf +
								 '''SELECT * FROM ' + @filepath + '''' + ')'
			FROM _bd__Tables 
			WHERE TableName = @tablename



		 END

         SET @createrawtable = 
		 --'IF EXISTS (SELECT TableName FROM _bd__Tables WHERE PhaseLevel < 2 AND TableName = ' + QUOTENAME(@tablename, '''') + ')' + @crlf + 
		 'BEGIN' + @crlf +  
		 'IF OBJECT_ID(''' + @dbraw + @prefixraw + +@tablename + ''', ''U'') IS NOT NULL  DROP TABLE ' + @dbraw + @prefixraw + @tablename + ';' + @crlf +
         'CREATE TABLE ' + @dbraw + @prefixraw + @tablename + '(' + @crlf + @createrawtable + ')' + @crlf + 'END' + @crlf

         SET @createstagetable = --'IF EXISTS (SELECT TableName FROM _bd__Tables WHERE PhaseLevel < 2 AND TableName = ' + QUOTENAME(@tablename, '''') + ')' + @crlf + 
		 'BEGIN' + @crlf +  
         'IF OBJECT_ID(''' + @dbstage + @prefixstage + +@tablename + ''', ''U'') IS NOT NULL  DROP TABLE ' + @dbstage + @prefixstage+ @tablename + ';' + @crlf + 
		 'CREATE TABLE ' + @dbstage + @prefixstage + @tablename + '(' + @crlf + @createstagetable + ')' + @crlf + 'END'  + @crlf

         IF @isQuery=1
		 SELECT @querytoraw =  'INSERT INTO ' + @dbraw +  @prefixraw + @tablename + '(' + @crlf + @insertfromraw + ')' + @crlf +
         'SELECT ' + @insertfromraw + ' FROM ' + '(' + @crlf + @QuerySQL + @crlf + ') __sourceqry'

         SET @insertfromraw = 'INSERT INTO ' + @dbstage + @prefixstage + @tablename + '(' + @crlf + @insertfromraw + ')' + @crlf +
         'SELECT ' + @inserttostage + 'FROM ' + @dbraw + @prefixraw + @tablename + @crlf + @crlf

		  SET @cleanintostage = 'INSERT INTO ' + @dbstage + @prefixstage + @tablename + '(' + @crlf + @selectcols + ')' + @crlf +
         'SELECT ' + @selectcleancols + 'FROM ' + @dbraw + @prefixraw + @tablename + @crlf + @crlf

		 SET @createoutputview = @outquerycmdstart + @crlf + @createoutputview + 'FROM ' + @dbstage + @prefixstage + @tablename + @crlf

   
		 
--> Output
		 IF NOT EXISTS(SELECT * FROM _bd__Queries WHERE QueryName=@TableName AND [Type]=1)
		 INSERT _bd__Queries (QueryName, Description, ManualEdit, QuerySQL, [Type])
			VALUES  (@tablename,
			         'Default Ouput View Direct From Staging',
			         0,  
					 @createoutputview,
					 1)
 
         IF EXISTS(SELECT * FROM _bd__Queries WHERE QueryName=@TableName AND ManualEdit = 0 AND [Type]=1)
			UPDATE _bd__Queries 
		    SET QuerySQL = @createoutputview
			WHERE QueryName = @TableName AND [Type] = 1

---> Raw
         IF NOT EXISTS(SELECT * FROM _bd__Queries WHERE QueryName=@PrefixRawView + @TableName AND [Type]=2)
		 INSERT _bd__Queries (QueryName, Description, ManualEdit, QuerySQL, [Type])
			VALUES  (@PrefixRawView + @TableName,
			         'View From Raw',
			         0,  
					  'SELECT ' + @crlf + @selectcols + 'FROM ' + @dbraw + @prefixraw + @tablename + @crlf,
					  2)

         IF EXISTS(SELECT * FROM _bd__Queries WHERE QueryName=@PrefixRawView + @TableName AND ManualEdit = 0 AND [Type]=2)
			UPDATE _bd__Queries 
		    SET QuerySQL = 'SELECT ' + @crlf + @selectcols + 'FROM ' + @dbraw + @prefixraw + @tablename + @crlf
			WHERE QueryName = @PrefixRawView + @TableName AND [Type]=2

---> Stage

		 IF NOT EXISTS(SELECT * FROM _bd__Queries WHERE QueryName=@PrefixStaView + @TableName AND [Type]=2)
		 INSERT _bd__Queries (QueryName, Description, ManualEdit, QuerySQL, [Type])
			VALUES  (@PrefixStaView + @TableName,
			         'View From Stage',
			         0,  
					  'SELECT ' + @crlf + @selectcols + 'FROM ' + @dbstage + @prefixstage + @tablename + @crlf,
					  2)

         IF EXISTS(SELECT * FROM _bd__Queries WHERE QueryName=@PrefixStaView + @TableName AND ManualEdit = 0 AND [Type]=2)
			UPDATE _bd__Queries 
		    SET QuerySQL = 'SELECT ' + @crlf + @selectcols + 'FROM ' + @dbstage + @prefixstage + @tablename + @crlf
			WHERE QueryName = @PrefixStaView + @TableName AND [Type]=2
----->

			
		UPDATE _bd__Tables
		SET SelectFromRaw = 'SELECT TOP 1000 ' +  @selectfromraw  +  @crlf + 'FROM ' + @dbraw + @prefixraw + @tablename ,
		    SelectFromStage = 'SELECT TOP 1000 ' +  @selectfromstage  +  @crlf + 'FROM ' +  @dbstage + @prefixstage + @tablename
        WHERE TableName = @TableName

	END -->IF @type <> -1 BEGIN

		--The idea is to populate _bd__ProcedureCode table.
		DECLARE @procedurename varchar(128)
		DECLARE @procType int
		DECLARE @action varchar(128)
		DECLARE @rulesql varchar(max)



		DECLARE @subproccursor CURSOR
		SET @subproccursor = CURSOR FOR 
							SELECT ProcName, ProcType, Action 
							FROM _bd__ProcMaster 
							WHERE Active = 1 AND ProcType < 1
							ORDER BY ExecOrder

		OPEN @subproccursor;
		FETCH NEXT FROM @subproccursor INTO @procedurename, @procType, @action
		WHILE @@fetch_status = 0
		BEGIN
			SET @rulesql  = 
							CASE 
								WHEN @procedurename = 'spm_create_raw_tables'       THEN  @createrawtable
								WHEN @procedurename = 'spm_create_stage_tables'     THEN  @createstagetable
								WHEN @procedurename = 'spm_bulk_insert'			    THEN  @bulkinsertstatement
								WHEN @procedurename = 'spm_insert_raw_to_staging'   THEN  @insertfromraw
								WHEN @procedurename = 'spm_delete_from_staging'     THEN  @beforeappenddelete
								WHEN @procedurename = 'spm_update_clean_raw'        THEN  @updatecleanraw
								WHEN @procedurename = 'spm_update_clean_stage'      THEN  @updatecleanstage
								WHEN @procedurename = 'spm_query_to_raw'            THEN  @querytoraw
								WHEN @procedurename = 'spm_insert_clean_into_staging'         THEN  @cleanintostage
								WHEN @procedurename = 'spm_create_stage_keys'        THEN @createstagekeys
								WHEN @procedurename = 'spm_create_raw_keys'          THEN @createrawkeys
								WHEN @procedurename = 'spm_drop_stage_keys'          THEN @dropstagekeys
								WHEN @procedurename = 'spm_drop_raw_keys'            THEN @droprawkeys
								WHEN @procedurename = 'spm_rules_after_bulk_insert'           THEN  NULL
								WHEN @procedurename = 'spm_rules_after_staging_insert'        THEN  NULL
								WHEN @procedurename = 'spm_clean_up'                          THEN  NULL
								WHEN @procedurename = 'spm_backup_staging_tables'    THEN  @backupstage
								
							END

            SET @str=  @procedurename + '.' + @tablename
			IF NOT EXISTS(SELECT * FROM _bd__ProcedureCode WHERE TableName=@tablename AND ProcName = @procedurename )
				INSERT _bd__ProcedureCode (SubProcName, Action, ProcName, TableName, Description, ManualEdit, RuleSQL)
				VALUES  (   @procedurename+'.'+@tablename,
				            @action,
							@procedurename,
							@tablename,
							@str,
							0,  
							@rulesql)
			IF  EXISTS(SELECT * FROM _bd__ProcedureCode WHERE TableName = @tablename AND ProcName=@procedurename AND ManualEdit = 0)
				UPDATE _bd__ProcedureCode 
				SET RuleSQL = @ruleSQL
				WHERE TableName = @TableName
				AND ProcName=@procedurename

		FETCH NEXT FROM @subproccursor INTO @procedurename, @procType, @action
	  SET @ruleSQL = NULL
   END
   CLOSE @subproccursor;
   DEALLOCATE @subproccursor;
	   

		 SET @updatecleanraw = NULL
		 SET @updatecleanstage = NULL
         SET @createoutputview = NULL
         SET @createpreoutview = NULL
         SET @createstagetable = NULL
         SET @insertfromraw = NULL
		 SET @inserttostage = NULL
         SET @bulkinsertstatement = NULL
         SET @beforeappenddelete = NULL
         SET @createrawtable = NULL
		 SET @updatecleanraw = NULL
		 SET @querytoraw = NULL
		 SET @selectfromraw = NULL
		 SET @selectfromstage = NULL
		 SET @selectcols = NULL
		 SET @selectcleancols = NULL
		 SET @cleanintostage = NULL
		 SET @deletejoins = NULL
		 SET @keylist = NULL
		 SET @createstagekeys = NULL
		 SET @sql=NULL


    END -->> PhaseLevel 1

     FETCH NEXT FROM @tblcursor INTO @tablename, @filepath, @phaselevel, @querysql, @type, @dbraw, @dbstage, @dbback, @tablehasheaders, @textquals
   END
   CLOSE @tblcursor;
   DEALLOCATE @tblcursor;

   
   UPDATE _bd__ProcMaster SET CreateCode = @todoprocedure_0 WHERE ProcName = 'spm_todo_phase_0'

   DECLARE @procSQL varchar (max)
   DECLARE @procName varchar (128)
   DECLARE @proccursor CURSOR

   DECLARE @masterupdate varchar(max) = 'CREATE PROCEDURE ' + @masterprocname  + @crlf + 
		                REPLACE(@genericheader, '$$$Name$$$', @masterprocname) + @crlf + 
						 'AS' + @crlf + 'SET NOCOUNT ON' 
   SET @proccursor = CURSOR FOR 
								SELECT ProcName, CreateCode, ProcType 
								FROM _bd__ProcMaster 
								WHERE Active = 1 AND ProcType IS NOT NULL
								ORDER BY ExecOrder
   OPEN @proccursor;
   FETCH NEXT FROM @proccursor INTO @procName, @procSQL, @procType
   WHILE @@fetch_status = 0
   BEGIN
        
		 IF @procType > -1
		 BEGIN
	        SET @masterupdate = @masterupdate + dbo.fnm_wrap_try_catch('EXEC ' + @procname, @procname, 'Master Proc', 0)
		    UPDATE _bd__ProcMaster SET CreateCode = @masterupdate WHERE ProcName = @masterprocname
		 END
		 
	     SET @sql = NULL
         SELECT @sql = COALESCE(@sql,'') +  CASE WHEN RuleSQL IS NULL THEN ''  ELSE 
	    '/*---------------------------------------------------------------------------------------------' + @crlf +
		'Rule Name       :  ' + COALESCE (SubProcName,'<none>') + @crlf +
		'Rule Action     :  ' + COALESCE (Action,'<none>') + @crlf +
	    'Rule Description:  ' + COALESCE (Description,'<none>') + @crlf +
	    'Related Enity   :  ' + COALESCE (TableName,'<none>') + @crlf +
	    'CM References   :  ' + COALESCE (CMRef,'<none>') + @crlf +
	    'Rule ID         :  ' + CAST(RuleID as varchar) + @crlf +
	    '----------------------------------------------------------------------------------------------*/'  + 
		 COALESCE(dbo.fnm_wrap_try_catch(RuleSQL, SubProcName, Action, CASE WHEN @procType = -2 THEN 1 ELSE 0 END),'--No Code Here ):') + @crlf  END
		 FROM  (
			SELECT TOP 10000 _bd__ProcedureCode.* 
			FROM _bd__ProcedureCode 
			JOIN  _bd__Tables
			ON _bd__Tables.TableName = _bd__ProcedureCode.TableName
			WHERE ProcName = @procName 
			AND _bd__Tables.Active = 1
			ORDER BY ExecOrder asc) a
	
	
	     SET @procSQL =  'CREATE PROCEDURE ' + @procname  + @crlf + 
		                REPLACE(@genericheader, '$$$Name$$$', @procName) + @crlf + 'AS' + @crlf + 'SET NOCOUNT ON' + @crlf + @crlf + COALESCE(@sql, '--Placeholder--')
         

	 UPDATE _bd__ProcMaster SET CreateCode = @procSQL WHERE ProcName = @procName

	 BEGIN TRY
	    EXEC('IF (OBJECT_ID(''' + @procName + ''', ''P'') IS NOT NULL) DROP PROCEDURE ' + @procName )
	 END TRY
	 BEGIN CATCH
	    EXEC dbo.spm_bd__log
	 END CATCH
     BEGIN TRY
       EXEC (@procSQL)
	   
     END TRY
     BEGIN CATCH
     SET @logmessage = 'Failure: Cannot create ' + @procName
     EXEC dbo.spm_bd__log 1,
                       @logmessage,
                       @procName,
					   @procSQL
      END CATCH
      FETCH NEXT FROM @proccursor INTO @procName, @procSQL, @procType
	  SET @sql = NULL
   END
   CLOSE @proccursor;
   DEALLOCATE @proccursor;


    exec( @todoprocedure_0)
---> just try to create the objects here. Whats the worst that could happen...? 
   ---> Delete all the info from the historical staging tables?

	--PRINT 'TODO: REMEMBER TO CONTROL THIS'
	SET @sql = 'spm_create_raw_tables'
	BEGIN TRY
		EXEC (@sql)
	END TRY
	BEGIN CATCH
	--  EXEC dbo.spm_bd__log 
	END CATCH

	SET @sql = 'spm_create_stage_tables'
	BEGIN TRY
		IF @allowstagingdrop = 'Y' 
			EXEC (@sql)
		
        --UPDATE _bd__Tables SET PhaseLevel = 2 WHERE PhaseLevel = 1 and Type = 0
	END TRY
	BEGIN CATCH
	--  EXEC dbo.spm_bd__log 
	END CATCH



	 BEGIN TRY
        EXEC('IF (OBJECT_ID(''' + @masterprocname + ''', ''P'') IS NOT NULL) DROP PROCEDURE ' + @masterprocname )
		EXEC (@masterupdate)

     END TRY
     BEGIN CATCH
     SET @logmessage = 'Failure: Cannot create '+ @masterprocname
     EXEC dbo.spm_bd__log 1,
                       @logmessage,
                       @masterprocname,
					   @masterupdate
      END CATCH

	

	




   DECLARE @queryname varchar(100)
   DECLARE @qrysql varchar(max)
   DECLARE @cmref varchar(max)
   DECLARE @queryID int
   DECLARE @qrydesc varchar(max)
   DECLARE @visible bit
   DECLARE @queryType int
   DECLARE @vprefix varchar(128)
   DECLARE @manualedit bit
   DECLARE @qrycursor CURSOR

   SET @qrycursor = CURSOR FOR
                    SELECT QueryName, QueryID, Description, CMRef, QuerySQL, ManualEdit, Active, [Type]
                    FROM   _bd__Queries 
					ORDER BY [Order]
   OPEN @qrycursor;
   FETCH NEXT FROM @qrycursor INTO @queryname, @queryID, @qrydesc, @cmref, @qrySQL, @manualedit, @visible, @queryType
   WHILE @@fetch_status = 0
   BEGIN
         SET @vprefix = CASE WHEN @queryType= 1 THEN @prefixoutputview
		                     WHEN @queryType = 2 THEN @prefixsuboutview
							 WHEN @queryType = 3 THEN @prefixInputview
							 WHEN @queryType = 4 THEN @prefixsubinputview
						END
	     SELECT @qrySQL =  'CREATE VIEW ' + @vprefix + @queryname  + ' AS ' + @crlf +
		 REPLACE(@genericheader, '$$$Name$$$',  @vprefix + @queryname) + @crlf +
	    '/*---------------------------------------------------------------------------------------------' + @crlf +
		'Rule Name       :  ' + COALESCE (@queryname,'<none>') + @crlf +	    
		'Rule Description:  ' + COALESCE (@qrydesc,'<none>') + @crlf +
	    'CM References   :  ' + COALESCE (@cmref,'<none>') + @crlf +
	    'Query ID        :  ' + COALESCE (CAST(@queryID as varchar), '<none>') + @crlf +
	    '----------------------------------------------------------------------------------------------*/' + @crlf +
	      + @qrySQL
	 BEGIN TRY
	    EXEC('IF (OBJECT_ID(''' +  @vprefix + @queryname  + ''', ''V'') IS NOT NULL) DROP VIEW ' +  @vprefix + @queryname )
	 END TRY
	 BEGIN CATCH
	    EXEC dbo.spm_bd__log
	 END CATCH
     BEGIN TRY
       IF @visible = 1 EXEC (@qrySQL)
     END TRY
     BEGIN CATCH
     SET @logmessage = 'Failure: Cannot create '+ @vprefix + @queryname
     EXEC dbo.spm_bd__log 1,
                       @logmessage,
                       @queryname,
					   @qrySQL
      END CATCH

     SET @qrySQL =NULL
   FETCH NEXT FROM @qrycursor INTO @queryname, @queryID, @qrydesc, @cmref, @qrySQL, @manualedit, @visible, @queryType
   END
   CLOSE @qrycursor;
   DEALLOCATE @qrycursor;






GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[api_custom_GetPocketPlatformSeries]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[api_custom_GetPocketPlatformSeries] AS' 
END
GO



-- =============================================
-- api_Custom_GetPocketPlatformSeries
-- =============================================
-- Description:		This stored procedure returns a list of Pocket Platform sermon series'
-- Last Modified:	5/14/2025
-- JD Blackman
-- Updates:
-- =============================================
ALTER PROCEDURE [dbo].[api_custom_GetPocketPlatformSeries] 
	@DomainID int,
	@Username nvarchar(75) = null,
    @Page int = 1,
    @Path nvarchar(100) = ''
AS
BEGIN
    DECLARE @PageSize int = 12;
    
    SELECT 
        SS.Sermon_Series_ID
        , SS.Title
        , SS.Display_Title
        , SS.Subtitle
        , SS.Position
        , SS.Sermon_Series_Type_ID
        , ST.Sermon_Series_Type
        , SS.Series_UUID
        , SS.Series_Start_Date
        , (SELECT TOP 1 PS.Sermon_Date FROM Pocket_Platform_Sermons PS WHERE PS.Series_ID = SS.Sermon_Series_ID AND PS.Status_ID = 3 ORDER BY PS.Sermon_Date DESC) AS Series_End_Date
        , (SELECT COUNT(PS.Sermon_ID) FROM Pocket_Platform_Sermons PS WHERE PS.Series_ID = SS.Sermon_Series_ID AND PS.Status_ID = 3) AS Series_Sermon_Count
        , @Path + '?SeriesID=' + CAST(SS.Sermon_Series_ID AS nvarchar(10)) AS Series_URL
        , SS.Congregation_ID
        , C.Congregation_Name
        , F.Unique_Name AS UniqueFileId
    FROM Pocket_Platform_Sermon_Series SS
    LEFT JOIN Pocket_Platform_Sermon_Series_Types ST ON ST.Sermon_Series_Type_ID = SS.Sermon_Series_Type_ID
    LEFT JOIN Congregations C ON C.Congregation_ID = SS.Congregation_ID
    LEFT JOIN dp_Files F ON F.Page_ID = 516 AND F.Record_ID = SS.Sermon_Series_ID AND F.Default_Image = 1
    WHERE SS.Status_ID = 3
    ORDER BY SS.Position DESC
    OFFSET (@Page - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;

    -- Get total count for pagination
    SELECT
          @Page AS CurrentPage
        , COUNT(*) AS TotalCount
    FROM Pocket_Platform_Sermon_Series SS
    WHERE SS.Status_ID = 3;
END
GO

-- ========================================================================================
-- SP MetaData Install
-- ========================================================================================
DECLARE @spName nvarchar(128) = 'api_custom_GetPocketPlatformSeries'
DECLARE @spDescription nvarchar(500) = 'This stored procedure returns a list of Pocket Platform sermon series'

IF NOT EXISTS (SELECT API_Procedure_ID FROM dp_API_Procedures WHERE Procedure_Name = @spName)
BEGIN
	INSERT INTO dp_API_Procedures
	(Procedure_Name, Description)
	VALUES
	(@spName, @spDescription)	
END


DECLARE @AdminRoleID INT = (SELECT Role_ID FROM dp_Roles WHERE Role_Name='Administrators')
IF NOT EXISTS (SELECT * FROM dp_Role_API_Procedures RP INNER JOIN dp_API_Procedures AP ON AP.API_Procedure_ID = RP.API_Procedure_ID WHERE AP.Procedure_Name = @spName AND RP.Role_ID=@AdminRoleID)
BEGIN
	INSERT INTO dp_Role_API_Procedures
	(Domain_ID,  API_Procedure_ID, Role_ID)
	VALUES
	(1, (SELECT API_Procedure_ID FROM dp_API_Procedures WHERE Procedure_Name = @spName), @AdminRoleID)
END
GO
-- ========================================================================================
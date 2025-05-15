SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[api_custom_GetPocketPlatformSeriesDetails]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[api_custom_GetPocketPlatformSeriesDetails] AS' 
END
GO



-- =============================================
-- api_Custom_GetPocketPlatformSeriesDetails
-- =============================================
-- Description:		This stored procedure returns a list of Pocket Platform sermon series details'
-- Last Modified:	5/14/2025
-- JD Blackman
-- Updates:
-- =============================================
ALTER PROCEDURE [dbo].[api_custom_GetPocketPlatformSeriesDetails] 
	@DomainID int,
	@Username nvarchar(75) = null,
    @SeriesID int = 0,
    @Path nvarchar(100) = '',
    @ReturnPath nvarchar(100) = ''
AS
BEGIN
    -- https://my.pureheart.org/ministryplatformapi/files/{F.Unique_Name}
    DECLARE @FileBaseURL nvarchar(254) = CONCAT('https://', (SELECT TOP 1 External_Server_Name FROM dp_Domains), '/ministryplatformapi/files/');
    DECLARE @PageSize int = 12;
    
    SELECT 
        SS.Sermon_Series_ID
        , SS.Title
        , SS.Display_Title
        , SS.Subtitle
        , SS.[Position]
        , SS.Sermon_Series_Type_ID
        , ST.Sermon_Series_Type
        , SS.Series_UUID
        , SS.Series_Start_Date
        , (SELECT TOP 1 PS.Sermon_Date FROM Pocket_Platform_Sermons PS WHERE EXISTS(SELECT TOP 1 1 FROM Pocket_Platform_Sermon_Links SL WHERE SL.Sermon_ID = PS.Sermon_ID AND SL.Link_Type_ID = 5 AND SL.Status_ID = 3) AND PS.Series_ID = SS.Sermon_Series_ID AND PS.Status_ID = 3 ORDER BY PS.Sermon_Date DESC) AS Series_End_Date
        , (SELECT COUNT(PS.Sermon_ID) FROM Pocket_Platform_Sermons PS WHERE EXISTS(SELECT TOP 1 1 FROM Pocket_Platform_Sermon_Links SL WHERE SL.Sermon_ID = PS.Sermon_ID AND SL.Link_Type_ID = 5 AND SL.Status_ID = 3) AND PS.Series_ID = SS.Sermon_Series_ID AND PS.Status_ID = 3) AS Series_Sermon_Count
        , @ReturnPath AS Return_Path
        , SS.Congregation_ID
        , C.Congregation_Name
        , CONCAT(@FileBaseURL, F.Unique_Name) AS Image_URL
    FROM Pocket_Platform_Sermon_Series SS
    LEFT JOIN Pocket_Platform_Sermon_Series_Types ST ON ST.Sermon_Series_Type_ID = SS.Sermon_Series_Type_ID
    LEFT JOIN Congregations C ON C.Congregation_ID = SS.Congregation_ID
    LEFT JOIN dp_Files F ON F.Page_ID = 516 AND F.Record_ID = SS.Sermon_Series_ID AND F.Default_Image = 1
    WHERE SS.Status_ID = 3
    AND SS.Sermon_Series_ID = @SeriesID

    SELECT
        PS.Sermon_ID
        , PS.Series_ID
        , PS.Congregation_ID
        , C.Congregation_Name
        , PS.Service_Type_ID
        , ST.Service_Type
        , PS.Title
        , PS.Subtitle
        , PS.Sermon_Date
        , PS.Speaker_ID
        , PPS.Display_Name AS Speaker_Name
        , PS.Scripture_Links
        , PS.[Position]
        , PS.Notes_Form_ID
        , PS.Sermon_UUID
        , CONCAT(@FileBaseURL, F.Unique_Name) AS Image_URL
        , CONCAT(@Path, '?SermonID=', PS.Sermon_ID) AS Sermon_URL
    FROM Pocket_Platform_Sermons PS
    LEFT JOIN Pocket_Platform_Service_Types ST ON ST.Service_Type_ID = PS.Service_Type_ID
    LEFT JOIN Congregations C ON C.Congregation_ID = PS.Congregation_ID
    LEFT JOIN dp_Files F ON F.Page_ID = 517 AND F.Record_ID = PS.Sermon_ID AND F.Default_Image = 1
    LEFT JOIN Pocket_Platform_Speakers PPS ON PPS.Speaker_ID = PS.Speaker_ID
    WHERE PS.Series_ID = @SeriesID
    AND PS.Status_ID = 3
    AND EXISTS(SELECT TOP 1 SL.Sermon_Link_ID FROM Pocket_Platform_Sermon_Links SL WHERE SL.Sermon_ID = PS.Sermon_ID AND SL.Link_Type_ID = 5 AND SL.Status_ID = 3)
    ORDER BY PS.[Position]

END
GO

-- ========================================================================================
-- SP MetaData Install
-- ========================================================================================
DECLARE @spName nvarchar(128) = 'api_custom_GetPocketPlatformSeriesDetails'
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

USE [VH2_DB]
GO
/****** Object:  StoredProcedure [dbo].[updateTerritory]    Script Date: 1/5/2019 11:15:20 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[updateTerritory]
AS
BEGIN
	DECLARE 
		@UpdateTerritoryID int,
		@ChildTerritoryID int,
		@POSID int,
		@queryString varchar(max)
	
	alter table territory disable trigger all
	DECLARE territoryUpdate CURSOR local FAST_FORWARD FOR 
		SELECT ID from dbo.Territory
	
	
	OPEN territoryUpdate 
	
	FETCH NEXT FROM territoryUpdate INTO @UpdateTerritoryID
	WHILE @@FETCH_STATUS = 0
	BEGIN
		--territory
		
		execute getChildTerritory @UpdateTerritoryID
		select * from TerritoryListTemp
		DECLARE territorychild CURSOR local FAST_FORWARD FOR 
		SELECT distinct ID from dbo.TerritoryListTemp
		set @queryString = 'DealerPosID in ('
		
			OPEN territorychild
			FETCH NEXT FROM territorychild INTO @ChildTerritoryID
			WHILE @@FETCH_STATUS = 0
			BEGIN
				--territory child
					DECLARE POS CURSOR local FAST_FORWARD FOR 
							SELECT ID from dealerPOS where territoryID = @ChildTerritoryID
					Open POS
						FETCH NEXT FROM POS INTO @POSID
						WHILE @@FETCH_STATUS = 0
						BEGIN
							set @queryString = @queryString + convert(varchar,@POSID)+','
							FETCH NEXT FROM POS INTO @POSID
						END
					CLOSE POS
					DEALLOCATE POS
					FETCH NEXT FROM territorychild INTO @ChildTerritoryID
			END
			
			CLOSE territorychild
			DEALLOCATE territorychild
			
			Update territory set querystring = @queryString+'0)' where id = @UpdateTerritoryID
			
			select * from territory
			delete dbo.TerritoryListTemp
		FETCH NEXT FROM territoryUpdate INTO @UpdateTerritoryID
	END  	
	
	
	
	CLOSE territoryUpdate
	DEALLOCATE territoryUpdate		
	alter table territory enable trigger all
END

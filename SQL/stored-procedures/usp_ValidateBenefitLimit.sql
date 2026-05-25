CREATE PROCEDURE usp_ValidateBenefitLimit
    @i_ClaimID INT
AS
BEGIN

    BEGIN TRY

        BEGIN TRAN

        -- ====================================
        -- Declare Variables
        -- ====================================

        DECLARE
            @l_ErrorMessage VARCHAR(1000),
            @l_MemberID INT,
            @l_MedicalPlanID INT,
            @l_ClaimAmount DECIMAL(10,2),
            @l_BenefitCategory VARCHAR(100),
            @l_BenefitLimit DECIMAL(12,2),
            @l_Historical_ClaimAmount DECIMAL(10,2)


        -- ====================================
        -- Validate Claim Exists
        -- ====================================

        IF NOT EXISTS (
            SELECT 1
            FROM Claims
            WHERE ClaimID = @i_ClaimID
        )
        BEGIN
            RAISERROR('Claim does not exist.',16,1)
        END


        -- ====================================
        -- Retrieve Claim Information
        -- ====================================

        SELECT
            @l_MemberID = c.MemberID,
            @l_ClaimAmount = c.ClaimAmount,
            @l_MedicalPlanID = m.MedicalPlanID
        FROM Claims c
        INNER JOIN Members m
            ON c.MemberID = m.MemberID
        WHERE c.ClaimID = @i_ClaimID


        -- ====================================
        -- Retrieve Benefit Category
        -- ====================================

        SELECT TOP 1
            @l_BenefitCategory = t.BenefitCategory
        FROM ClaimLines cl
        INNER JOIN Tariffs t
            ON cl.TariffID = t.TariffID
        WHERE cl.ClaimID = @i_ClaimID


        -- ====================================
        -- Retrieve Benefit Limit
        -- ====================================

        SELECT
            @l_BenefitLimit = b.BenefitLimit
        FROM Benefits b
        WHERE b.MedicalPlanID = @l_MedicalPlanID
        AND b.BenefitCategory = @l_BenefitCategory
        AND b.IsCovered = 1


        -- ====================================
        -- Validate Benefit Coverage
        -- ====================================

        IF @l_BenefitLimit IS NULL
        BEGIN
            RAISERROR('Benefit is not covered for this medical plan.',16,1)
        END


        -- ====================================
        -- Retrieve Historical Approved Claims
        -- ====================================

        SELECT
            @l_Historical_ClaimAmount = ISNULL(SUM(c.ClaimAmount),0)
        FROM Claims c
        INNER JOIN ClaimLines cl
            ON c.ClaimID = cl.ClaimID
        INNER JOIN Tariffs t
            ON cl.TariffID = t.TariffID
        WHERE c.MemberID = @l_MemberID
        AND c.ClaimID <> @i_ClaimID
        AND c.ClaimStatus = 'Approved'
        AND t.BenefitCategory = @l_BenefitCategory


        -- ====================================
        -- Validate Benefit Limit
        -- ====================================

        IF (@l_Historical_ClaimAmount + @l_ClaimAmount) > @l_BenefitLimit
        BEGIN

            -- Reject Claim Line
            UPDATE ClaimLines
            SET LineStatus = 'Rejected'
            WHERE ClaimID = @i_ClaimID


            -- Reject Claim
            UPDATE Claims
            SET ClaimStatus = 'Rejected'
            WHERE ClaimID = @i_ClaimID

        END


        COMMIT

    END TRY

    BEGIN CATCH

        ROLLBACK

        SET @l_ErrorMessage = ERROR_MESSAGE()

        RAISERROR(@l_ErrorMessage,16,1)

    END CATCH

END
GO

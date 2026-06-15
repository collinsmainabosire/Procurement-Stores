namespace BCTRAINING.BCTRAINING;

codeunit 50107 "Role Centre Setup"
{
    trigger OnRun()
    begin
        SetupRoleCentre();
    end;
    
    procedure SetupRoleCentre()
    var
        AllProfile: Record System.Reflection."All Profile";
    begin
        // Assign to admin profile
        if AllProfile.Get('LOAN-ADMIN') then begin
            AllProfile."Role Center ID" := 50117;
            AllProfile.Modify();
        end;
        
        // Assign to approver profile
        if AllProfile.Get('LOAN-APPROVER') then begin
            AllProfile."Role Center ID" := 50117;
            AllProfile.Modify();
        end;
        
        // Assign to employee profile
        if AllProfile.Get('LOAN-EMPLOYEE') then begin
            AllProfile."Role Center ID" := 50117;
            AllProfile.Modify();
        end;
    end;
}
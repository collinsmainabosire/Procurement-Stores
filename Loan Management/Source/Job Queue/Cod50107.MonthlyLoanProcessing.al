namespace BCTRAINING.BCTRAINING;

codeunit 50107 "Monthly Loan Processing"
{
    trigger OnRun()
    begin
        ProcessMonthlyLoans();
    end;

    local procedure ProcessMonthlyLoans()
    var
        LoanManagement: Codeunit "Loan Management";
    begin
        //LoanManagement.ProcessMonthlyDeductions();
    end;
}

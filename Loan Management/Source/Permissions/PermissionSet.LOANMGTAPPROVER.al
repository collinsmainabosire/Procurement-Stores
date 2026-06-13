namespace BCTRAINING.BCTRAINING;

permissionset 50101 "LOAN MGT - APPROVER"
{
    Assignable = true;
    Caption = 'Loan Management - Approver';

    Permissions =
        table "Employee Loan Header" = X,
        table "Employee Loan Schedule" = X,
        //page "Employee Loan List" = X,
       // page "Employee Loan Card" = X,
        page "Loan Schedule List" = X,
        page "Loan Management Role Centre" = X,
        codeunit "Loan Approval Management" = X,
        report "Loan Register" = X,
        report "Outstanding Loans" = X,
        report "Repayment Schedule" = X;
}
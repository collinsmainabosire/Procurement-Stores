namespace BCTRAINING.BCTRAINING;

permissionset 50103 "LOAN MGT - PAYROLL"
{
    Assignable = true;
    Caption = 'Loan Management - Payroll Officer';

    Permissions =
        table "Employee Loan Header" = X,
        table "Employee Loan Schedule" = X,
       // page "Employee Loan List" = X,
        page "Loan Schedule List" = X,
        page "Loan Management Role Centre" = X,
        codeunit "Loan Management" = X,
       // codeunit "Loan Monthly Processing" = X,
        report "Loan Register" = X,
        report "Outstanding Loans" = X;
       // report "Employee Loan Summary" = X;
}
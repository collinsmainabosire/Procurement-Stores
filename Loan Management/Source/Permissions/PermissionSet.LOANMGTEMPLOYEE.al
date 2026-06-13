namespace BCTRAINING.BCTRAINING;

permissionset 50102 "LOAN MGT - EMPLOYEE"
{
    Assignable = true;
    Caption = 'Loan Management - Employee';

    Permissions =
        table "Employee Loan Header" = X,
        table "Employee Loan Schedule" = X,
       // page "Employee Loan List" = X,
       // page "Employee Loan Card" = X,
        page "Loan Schedule List" = X,
        page "Loan Management Role Centre" = X;
}
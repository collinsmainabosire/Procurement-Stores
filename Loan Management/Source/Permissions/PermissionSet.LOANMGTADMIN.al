namespace BCTRAINING.BCTRAINING;

permissionset 50100 "LOAN MGT - ADMIN"
{
    Assignable = true;
    Caption = 'Loan Management - Administrator';

    Permissions =
        table "Employee Loan Type" = X,
        table "Employee Loan Header" = X,
        table "Employee Loan Schedule" = X,
        table "Employee Loan Setup" = X,
        table "Employee Loan Ledger Entry" = X,
      //  page "Loan Type List" = X,
        page "Loan Type Card" = X,
      //  page "Employee Loan List" = X,
      //  page "Employee Loan Card" = X,
        page "Loan Schedule List" = X,
     //   page "Loan Setup Card" = X,
      //  page "Loans Management Role Centre" = X,
        codeunit "Loans Management" = X,
        codeunit "Loan Approval Management" = X,
        codeunit "Loan Notification Management" = X,
       // codeunit "Loan Monthly Processing" = X,
        codeunit "Role Centre Initialization" = X,
        report "Loan Register" = X,
        report "Outstanding Loans" = X,
        report "Repayment Schedule" = X;
       // report "Employee Loan Summary" = X,
       // report "Loan Ledger Report" = X;
}
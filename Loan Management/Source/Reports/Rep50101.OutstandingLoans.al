namespace BCTRAINING.BCTRAINING;
using Microsoft.HumanResources.Employee;

report 50101 "Outstanding Loans"
{
    ApplicationArea = All;
    Caption = 'Outstanding Loans Report';
    DefaultLayout = RDLC;
    RDLCLayout = './Reports/OutstandingLoans.rdl';
    UsageCategory = ReportsAndAnalysis;
    
    dataset
    {
        dataitem(Employee; Employee)
        {
            RequestFilterFields = "No.", "First Name", "Last Name", "Global Dimension 2 Code";
            
            column(Employee_No; "No.")
            {
                IncludeCaption = true;
            }
            column(Employee_Name; "First Name" + ' ' + "Last Name")
            {
            }
            column(Department_Code; "Global Dimension 2 Code")
            {
                IncludeCaption = true;
            }
            column(Email; "E-Mail")
            {
                IncludeCaption = true;
            }
            
            dataitem(LoanHeader; "Employee Loan Header")
            {
                DataItemLink = "Employee No." = field("No.");
                RequestFilterFields = "Loan Type";
                
                column(Loan_No; "Loan No.")
                {
                    IncludeCaption = true;
                }
                column(Loan_Type; "Loan Type")
                {
                    IncludeCaption = true;
                }
                column(Approved_Amount; "Approved Amount")
                {
                    IncludeCaption = true;
                }
                column(Outstanding_Balance; "Outstanding Balance")
                {
                    IncludeCaption = true;
                }
                column(Total_Paid; "Total Paid")
                {
                    IncludeCaption = true;
                }
                column(Status; Status)
                {
                    IncludeCaption = true;
                }
                column(Disbursement_Date; "Disbursement Date")
                {
                    IncludeCaption = true;
                }
                column(Term_Months; "Term Months")
                {
                    IncludeCaption = true;
                }
                
                column(EmployeeTotalOutstanding; EmployeeTotalOutstanding)
                {
                }
                column(GrandTotalOutstanding; GrandTotalOutstanding)
                {
                }
                
                trigger OnPreDataItem()
                begin
                    // Only show active loans
                    SetRange("Status", "Status"::Disbursed);
                    SetCurrentKey("Loan No.");
                    EmployeeTotalOutstanding := 0;
                end;
                
                trigger OnAfterGetRecord()
                begin
                    // Add to employee total
                    EmployeeTotalOutstanding += "Outstanding Balance";
                    GrandTotalOutstanding += "Outstanding Balance";
                end;
            }
            
            trigger OnPreDataItem()
            begin
                // Only employees with loans
                SetCurrentKey("No.");
            end;
        }
    }
    
    requestpage
    {
        SaveValues = true;
        
        layout
        {
            area(Content)
            {
                group(Options)
                {
                    Caption = 'Report Options';
                    
                    field(MinBalanceThreshold; MinBalanceThresholdVar)
                    {
                        Caption = 'Minimum Outstanding Balance';
                        ApplicationArea = All;
                        ToolTip = 'Show only loans with balance above this amount';
                    }
                    
                    field(IncludeZeroBalance; IncludeZeroBalanceVar)
                    {
                        Caption = 'Include Zero Balance Loans';
                        ApplicationArea = All;
                        ToolTip = 'Include loans that have been fully paid?';
                    }
                }
            }
        }
    }
    
    var
        EmployeeTotalOutstanding: Decimal;
        GrandTotalOutstanding: Decimal;
        MinBalanceThresholdVar: Decimal;
        IncludeZeroBalanceVar: Boolean;
}
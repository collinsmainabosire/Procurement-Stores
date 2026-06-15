namespace BCTRAINING.BCTRAINING;

report 50103 "Employee Loan Summary"
{
    ApplicationArea = All;
    Caption = 'Employee Loan Summary';
    DefaultLayout = RDLC;
    RDLCLayout = './Reports/EmployeeLoanSummary.rdl';
    UsageCategory = ReportsAndAnalysis;
    
    dataset
    {
        dataitem(LoanType; "Employee Loan Type")
        {
            RequestFilterFields = "Code", "Active";
            
            column(LoanType_Code; Code)
            {
                IncludeCaption = true;
            }
            column(LoanType_Description; Description)
            {
                IncludeCaption = true;
            }
            column(LoanType_MaxAmount; "Maximum Amount")
            {
                IncludeCaption = true;
            }
            column(LoanType_InterestRate; "Interest Rate")
            {
                IncludeCaption = true;
            }
            column(LoanType_Active; Active)
            {
                IncludeCaption = true;
            }
            
            dataitem(LoanHeader; "Employee Loan Header")
            {
                DataItemLink = "Loan Type" = field("Code");
                
                column(LoanCount; 1)
                {
                }
                column(Loan_No; "Loan No.")
                {
                    IncludeCaption = true;
                }
                column(Employee_No; "Employee No.")
                {
                    IncludeCaption = true;
                }
                column(Employee_Name; "Employee Name")
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
                column(Status; Status)
                {
                    IncludeCaption = true;
                }
                
                column(LoanTypeTotalCount; LoanTypeTotalCount)
                {
                }
                column(LoanTypeTotalAmount; LoanTypeTotalAmount)
                {
                }
                column(LoanTypeTotalOutstanding; LoanTypeTotalOutstanding)
                {
                }
                column(GrandTotalCount; GrandTotalCount)
                {
                }
                column(GrandTotalAmount; GrandTotalAmount)
                {
                }
                column(GrandTotalOutstanding; GrandTotalOutstanding)
                {
                }
                
                trigger OnPreDataItem()
                begin
                    LoanTypeTotalCount := 0;
                    LoanTypeTotalAmount := 0;
                    LoanTypeTotalOutstanding := 0;
                end;
                
                trigger OnAfterGetRecord()
                begin
                    LoanTypeTotalCount += 1;
                    LoanTypeTotalAmount += "Approved Amount";
                    LoanTypeTotalOutstanding += "Outstanding Balance";
                    
                    GrandTotalCount += 1;
                    GrandTotalAmount += "Approved Amount";
                    GrandTotalOutstanding += "Outstanding Balance";
                end;
            }
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
                    
                    field(IncludeInactive; IncludeInactiveVar)
                    {
                        Caption = 'Include Inactive Loan Types';
                        ApplicationArea = All;
                        ToolTip = 'Include loan types that are no longer active?';
                    }
                }
            }
        }
    }
    
    var
        LoanTypeTotalCount: Integer;
        LoanTypeTotalAmount: Decimal;
        LoanTypeTotalOutstanding: Decimal;
        GrandTotalCount: Integer;
        GrandTotalAmount: Decimal;
        GrandTotalOutstanding: Decimal;
        IncludeInactiveVar: Boolean;
}

namespace BCTRAINING.BCTRAINING;

page 50110 "Employee Loan List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Employee Loan Header";
    Caption = 'Employee Loans';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Loan No."; Rec."Loan No.")
                {
                    ApplicationArea = All;
                }
                field("Employee No."; Rec."Employee No.")
                {
                    ApplicationArea = All;
                }
                field("Employee Name"; Rec."Employee Name")
                {
                    ApplicationArea = All;
                }
                field("Loan Type"; Rec."Loan Type")
                {
                    ApplicationArea = All;
                }
                field("Requested Amount"; Rec."Requested Amount")
                {
                    ApplicationArea = All;
                }
                field("Approved Amount"; Rec."Approved Amount")
                {
                    ApplicationArea = All;
                }
                field("Outstanding Balance"; Rec."Outstanding Balance")
                {
                    ApplicationArea = All;
                }
                field("Status"; Rec."Status")
                {
                    ApplicationArea = All;
                }
                field("Application Date"; Rec."Application Date")
                {
                    ApplicationArea = All;
                }
            }
        }

        area(FactBoxes)
        {
            part(LoanDetails; "Loan Details FactBox")
            {
                ApplicationArea = All;
                SubPageLink = "Loan No." = field("Loan No.");
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(OpenLoan)
            {
                Caption = 'Open';
                Image = Open;
                Promoted = true;
                PromotedCategory = Process;
                Enabled = Rec."Loan No." <> '';

                trigger OnAction()
                begin
                    Page.Run(Page::"Employee Loan Card", Rec);
                end;
            }

            action(ApprovalAction)
            {
                Caption = 'Send for Approval';
                Image = Approve;
                Promoted = true;
                PromotedCategory = Process;
                Visible = Rec."Status" = Rec."Status"::Open;

                trigger OnAction()
                var
                    LoanApprovalMgmt: Codeunit "Loan Approval Management";
                begin
                    LoanApprovalMgmt.SendForApproval(Rec);
                    Rec.Modify();
                    CurrPage.Update(false);
                end;
            }

            action(RefreshBalance)
            {
                Caption = 'Refresh Balance';
                Image = Refresh;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    LoanManagement: Codeunit "Loan Management";
                begin
                    Rec."Outstanding Balance" := LoanManagement.CalculateBalance(Rec."Loan No.");
                    Rec.Modify();
                    CurrPage.Update(false);
                end;
            }
        }
    }
}
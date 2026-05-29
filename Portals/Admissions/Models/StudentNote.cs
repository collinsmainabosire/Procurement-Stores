namespace Admissions.Models
{
    //This class represents a student note. It will be used to store the notes for each student in the application.
    public class StudentNote
    {
        public int EntryNo { get; set; }

        public string Title { get; set; }

        public string Description { get; set; }

        public string UserEmail { get; set; }

        public DateTime CreatedDate { get; set; }
    }
}

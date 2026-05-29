namespace Admissions.Models
{
    // this maps to BC JSON value for student notes.
    // It will be used to deserialize the JSON response from business central into a C# object.
    public class StudentNoteResponse
    {
        public List<StudentNote> Value { get; set; }
    }
}

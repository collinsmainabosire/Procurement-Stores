using Newtonsoft.Json;

namespace Admissions.DTOs
{
    //this class is used to send the data from page to the controller when creating a new note.
    //It will be used in the CreateNote method in the StudentNotesController.
    public class CreateNoteDto
    {
        [JsonProperty("title")]
        public string Title { get; set; }

        [JsonProperty("description")]
        public string Description { get; set; }

        [JsonProperty("userEmail")]
        public string UserEmail { get; set; }
    }
}

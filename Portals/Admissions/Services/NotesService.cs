using Admissions.Clients;
using Admissions.DTOs;
using Admissions.Models;
using Newtonsoft.Json;

namespace Admissions.Services
{
    /// This service will be used to get notes from business central.
  
    public class NotesService
    {
        private readonly BusinessCentralClient _client;

        public NotesService()
        {
            _client = new BusinessCentralClient();
        }

        public async Task<List<StudentNote>> GetNotes()
        {
            var json = await _client.Get(ApiUrls.StudentNotes);

            var result = JsonConvert.DeserializeObject<StudentNoteResponse>(json);

            return result.Value;
        }
        public async Task CreateNote(CreateNoteDto dto)
        {
            var json = JsonConvert.SerializeObject(dto);

            await _client.Post(ApiUrls.StudentNotes, json);
        }
    }
}

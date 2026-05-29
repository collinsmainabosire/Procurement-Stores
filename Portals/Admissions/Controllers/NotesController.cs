using Admissions.DTOs;
using Admissions.Services;
using Microsoft.AspNetCore.Mvc;

namespace Admissions.Controllers
{
    // This controller will be used to display notes from business central.
    public class NotesController : Controller
    {
        private readonly NotesService _service;

        public NotesController()
        {
            _service = new NotesService();
        }

        public async Task<IActionResult> Index()
        {
            var notes = await _service.GetNotes();

            return View(notes);
        }
        [HttpGet]
        public IActionResult Create()
        {
            return View();
        }

        [HttpPost]
        public async Task<IActionResult> Create(CreateNoteDto dto)
        {
            await _service.CreateNote(dto);

            return RedirectToAction("Index");
        }
    }
}

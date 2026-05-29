using System.Net.Http.Headers;
using System.Text;


//This is my business central communication helper class.
//It will be used to send requests to business central and get responses back.
//It will be used in the controllers to communicate with business central.
//Only this class should communicate with BC APIs.
namespace Admissions.Clients
{
    public class BusinessCentralClient
    {
        private readonly HttpClient _httpClient;
        public BusinessCentralClient()
        {
            _httpClient = new HttpClient();

            var username = "COLLINS";
            var password = "Bosire@2030";

            var auth = Convert.ToBase64String(
                Encoding.UTF8.GetBytes($"{username}:{password}")
            );

            _httpClient.DefaultRequestHeaders.Authorization =
                new AuthenticationHeaderValue("Basic", auth);
        }
        public async Task<string> Get(string url)
        {
            var response = await _httpClient.GetAsync(url);

            return await response.Content.ReadAsStringAsync();
        }

        public async Task<string> Post(string url, string json)
        {
            var content = new StringContent(
                json,
                Encoding.UTF8,
                "application/json"
            );

            var response = await _httpClient.PostAsync(url, content);

            var result = await response.Content.ReadAsStringAsync();

            if (!response.IsSuccessStatusCode)
            {
                throw new Exception(
                    $"BC API Error: {response.StatusCode}\n{result}"
                );
            }

            return result;
        }
    }
}

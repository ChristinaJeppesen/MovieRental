namespace MessageService.Service
{
    public interface IMessageService
    {
        public void GetAllMovieList();
        public void GetAllCostumers();
        public void GetFilteredMovieList(string pattern);
        public string GetResults();
    }
}

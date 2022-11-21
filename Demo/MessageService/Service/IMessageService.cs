namespace MessageService.Service
{
    public interface IMessageService
    {
        public void GetAllMovieList();
        public void GetAllCostumers();
        public void GetFilteredMovieList(string filter, string match);
        public string GetResults();
    }
}

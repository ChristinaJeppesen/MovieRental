using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.Json.Serialization;
using System.Threading.Tasks;

namespace SharedModelLibrary
{
    public class CustomerMovieList
    {
        public Guid CustomerId { get; set; }

        public List<int> MovieIdList { get; set; }

        [JsonConstructor]
        public CustomerMovieList()
        {
        }

        public CustomerMovieList(Guid customerId, List<int> movieIdList)
        {
            CustomerId = customerId;
            MovieIdList = movieIdList;
        }
    }
}

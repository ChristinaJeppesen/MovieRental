using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace CustomerWebApi.Models
{

    public class Customer
    {

        public Guid id { get; set; }

        public string name { get; set; }

        public string email { get; set; }

    }
}


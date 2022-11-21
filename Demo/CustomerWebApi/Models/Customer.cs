using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace CustomerWebApi.Models
{

    public class Customer
    {

        public Guid Id { get; set; }

        public string Name { get; set; }

        public string Email { get; set; }

        public Customer(Guid _id, string _name, string _email) {
            Id = _id;
            Name = _name;
            Email = _email;
        }

    }
}


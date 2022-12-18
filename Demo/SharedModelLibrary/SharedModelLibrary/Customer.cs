using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace SharedModelLibrary
{

    public class Customer
    {
        public Guid Id { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public string Email { get; set; }

        public Customer(Guid id, string firstName, string lastName, string email) {
            Id = id;
            FirstName = firstName;
            LastName = lastName;
            Email = email;
        }

        public Customer()
        {
        }
    }
}


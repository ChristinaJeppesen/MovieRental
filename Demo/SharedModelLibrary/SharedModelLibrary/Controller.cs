using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;

namespace SharedModelLibrary
{
    public class Controller : IController 
    {
        public (string, string) MessageRecieved(string inMessage)
        {
            Console.WriteLine(" - Message Recieved");
            return ("", "");
        }
    }
}

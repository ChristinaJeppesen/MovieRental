using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;

namespace SharedModelLibrary
{
    public abstract class Controller : IController
    {
        public abstract (string, string) MessageReceived(string inMessage);
        
  
    }

}
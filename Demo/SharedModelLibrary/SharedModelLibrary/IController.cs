using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SharedModelLibrary
{
    public interface IController
    {
        public (string, string) MessageReceived(string inMessage);
    }
}

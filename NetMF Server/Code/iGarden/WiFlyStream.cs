using System;
using System.Text;
using Microsoft.SPOT;
using Toolbox.NETMF.Hardware;

namespace iGarden
{
    public class WiFlyStream
    {
        WiFlyGSX _wifly;
        string _buffer;
        int _bufferPos = 0;
        int _bufferLen = 0;
        bool _isClosed = true;

        private string _socketCloseString = "*CLOS*";
        private string _socketOpenString = "*OPEN*";

        public WiFlyStream(WiFlyGSX wifly)
        {
            this._wifly = wifly;

            SetBuffer("");
            WaitForCloseOrData();
        }

        public char Read()
        {
            if (_isClosed)
                throw new ApplicationException("Socket Closed");

            // Read at least one more char into the buffer if we have run out of chars
            if (_bufferPos == _bufferLen)
            {
                string str;
                do
                {
                    str = _wifly.SocketRead();
                } while (str == "");

                // We reset the buffer back to the start
                SetBuffer(str);
            }

            // Check for end of stream
            var i = _buffer.IndexOf(_socketCloseString, _bufferPos);
            if (i == _bufferPos)
            {
                Debug.Print("\r\nDetected End Of Stream\r\n");

                // We reached the end of the stream
                SetBuffer(_buffer.Substring(i + _socketCloseString.Length));

                _isClosed = true;
                throw new ApplicationException("Socket Closed");
            }

            // Consume a char from the buffer
            var result = _buffer[_bufferPos];
            _bufferPos++;
            return result;
        }

        private void SetBuffer(string buffer) {
            _buffer = buffer;
            _bufferPos = 0;
            _bufferLen = _buffer.Length;
        }

        public void WaitForCloseOrData()
        {
            int i;

            if (!_isClosed)
            {
                i = _buffer.IndexOf(_socketCloseString, _bufferPos);
                if (i != -1)
                {
                    Debug.Print("Already have close in buffer");

                    _isClosed = true;

                    SetBuffer(_buffer.Substring(i + _socketCloseString.Length));
                }
                else
                {

                    Debug.Print("Waiting for close");

                    // Wait until we are told the socket is closed
                    // Read and discard anything up until the open nottification
                    string s = _wifly.SocketRead();

                    // Read the close notification and any more data after than
                    while (s == "")
                    {
                        s = _wifly.SocketRead();
                    }

                    if (s.IndexOf(_socketCloseString) == 0)
                    {
                        // Remove the open notification
                        s = s.Substring(_socketCloseString.Length);
                    }
                    else
                    {
                        // We did not get a close.  Assume that this is a continuation on the same connection
                        Debug.Print("Socket Kept Alive");
                        SetBuffer(s);
                        return;
                    }

                    SetBuffer(s);

                    Debug.Print("Close notification received");
                    _isClosed = true;
                }
            }
            
            Debug.Print("\r\n Re-opening socket \r\n");
            i = _buffer.IndexOf(_socketOpenString, _bufferPos);
            if (i != -1)
            {
                Debug.Print("Already have Open in buffer");

                _isClosed = false;

                SetBuffer(_buffer.Substring(i + _socketOpenString.Length));
            }
            else
            {
                Debug.Print("Waiting for open");
                // Wait until we are told the socket is open
                // Read and discard anything up until the open notification
                string str;
                do
                {
                    str = _wifly.SocketRead();
                    i = str.IndexOf(_socketOpenString);
                } while (i == -1);

                // Remove the open notification
                str = str.Substring(i + _socketOpenString.Length);

                Debug.Print("got open");

                SetBuffer(str);

                _isClosed = false;
            }
        }

        public string ReadLine()
        {
            if (_isClosed)
                throw new ApplicationException("Socket Closed");

            char c1;
            char c2;
            var buffer = new StringBuilder();

            c2 = Read();
            buffer.Append(c2);
            do
            {
                c1 = c2;

                c2 = Read();
                buffer.Append(c2);
            } while ((c1 != '\r') && (c2 != '\n'));

            return buffer.ToString();
        }
    }
}

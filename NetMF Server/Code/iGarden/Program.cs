using System;
using System.Collections;
using System.Threading;
using Microsoft.SPOT;
using Microsoft.SPOT.Presentation;
using Microsoft.SPOT.Presentation.Controls;
using Microsoft.SPOT.Presentation.Media;
using Microsoft.SPOT.Touch;

using Gadgeteer.Networking;
using GT = Gadgeteer;
using GTM = Gadgeteer.Modules;
using Gadgeteer.Modules.Seeed;
using System.Net.Sockets;
using System.Net;
using System.Text;
using Toolbox.NETMF.Hardware;
using Toolbox.NETMF.NET;
using Microsoft.SPOT.Hardware;
using System.IO;
using NJson;

namespace iGarden
{
    public partial class Program
    {

        private WiFlyGSX _wifi = new WiFlyGSX();

        private Clock _clock;

        private ArrayList _schedule = new ArrayList();

        // This method is run when the mainboard is powered up or reset.   
        void ProgramStarted()
        {
            Mainboard.SetDebugLED(true);

            // Clear all relays
            for (int i = 0; i < 8; i++)
                SetRelay(i, false);

            var volumes = Microsoft.SPOT.IO.VolumeInfo.GetVolumes();

            var fs = Microsoft.SPOT.IO.VolumeInfo.GetFileSystems();


            // Read the settings file
            if (System.IO.File.Exists("\\Settings.json"))
            {
                var reader = JsonReader.Create("\\Settings.json");

                reader.ReadArray();

                while (reader.Type == JsonType.Object) {

                    reader.ReadObject();
                    int switchNumber = 0;
                    int onTime = 0;
                    int offTime = 0;

                    while (reader.IsValue) {

                        switch (reader.ReadName()) {
                            case "switchNumber":
                                switchNumber = (int)reader.ReadValueAsDouble();
                                break;

                            case "onTime":
                                onTime = (int)reader.ReadValueAsDouble();

                                break;

                            case "offTime":
                                offTime = (int)reader.ReadValueAsDouble();
                                break;
                        }
                    }

                    _schedule.Add(new ScheduleItem(switchNumber, onTime, offTime));

                    reader.ReadEnd();
                }

                reader.ReadEnd();
            }

            // Init Wifi module comms
            StartCommunications();

            SetTime();

            _schedule.Add(new ScheduleItem(0, (18 * 60 + 38) * 60, (18 * 60 + 42) * 16 ));

            SaveSchedule();

            // Run the schedule immediately
            RunSchedule();

            _clock.SetInterval(1, RunSchedule);

            Mainboard.SetDebugLED(false);

            // Run the server listen thread
            var t = new Thread(new ThreadStart(() =>
            {
                while (true)
                {
                    try
                    {
                        // Listen for a connect
                        var socket = this._wifi.ListenSocket(2000);

                        // The first line is the method and the URL
                        var line = socket.ReadLine();
                        Debug.Print(line);

                        var parts = line.Split(' ');
                        var method = parts[0];
                        var url = parts[1];

                        // Read the headers until we get to the empty line
                        var headers = new Hashtable();
                        line = socket.ReadLine();
                        while (line != "\r\n")
                        {
                            var index = line.IndexOf(':');
                            var key = line.Substring(0, index);
                            var value = line.Substring(index + 1).Trim();

                            headers.Add(key, value);
                            line = socket.ReadLine();
                        }

                        // Find the content length
                        var contentLength = 0;
                        if (headers.Contains("Content-Length"))
                        {
                            contentLength = int.Parse((string)headers["Content-Length"]);
                        }

                        // Read the body
                        var buffer = new StringBuilder();
                        while (buffer.Length < contentLength)
                        {
                            buffer.Append(socket.Read());
                        }

                        switch (method)
                        {
                            case "GET":
                                {
                                    var pathParts = url.Split('/');
                                    if (pathParts.Length == 3)
                                    {
                                        if (pathParts[1] == "relays")
                                        {
                                            if (pathParts[2] == "all")
                                            {
                                                // Return all relay states
                                                SendResponse(GetAllRelayStates());
                                            }
                                            else
                                            {
                                                // We expect a number
                                                var relayNum = Int32.Parse(pathParts[1]);

                                                SendResponse(GetRelay(relayNum).ToString());
                                            }

                                        }
                                    }

                                    break;
                                }

                            case "POST":
                                {
                                    var pathParts = url.Split('/');
                                    if (pathParts.Length == 3)
                                    {
                                        if (pathParts[1] == "relays")
                                        {
                                            if (pathParts[2] == "all")
                                            {
                                                // Set all relay states
                                                // Body is a JSON string array of boolean values to set
                                                var relayStates = buffer.ToString().Trim('[', ']').Split(',');

                                                for (var i = 0; i < relayStates.Length; i++)
                                                {
                                                    SetRelay(i, relayStates[i].Trim() == "true");
                                                }

                                                SendResponse("");
                                            }
                                            else
                                            {
                                                // We expect a number
                                                var relayNum = Int32.Parse(pathParts[1]);

                                                // Body is a single bool value
                                                var relayState = buffer.ToString() == "true";

                                                SetRelay(relayNum, relayState);

                                                SendResponse("");
                                            }

                                        }
                                    }

                                    break;
                                }

                            default:
                                {
                                    SendError("Unknown method " + parts[0]);
                                    break;
                                }
                        }
                    }
                    catch (ApplicationException e)
                    {
                        Debug.Print(e.Message);
                    }
                }
            }));

            t.Start();
        }

        private void SendResponse(String response) {
            _wifi.SocketWrite("HTTP/1.1 200 OK\r\n");
            _wifi.SocketWrite("Content-Type: application/json\r\n");
            _wifi.SocketWrite("Content-Length: " + response.Length + "\r\n");
            _wifi.SocketWrite("\r\n");
            _wifi.SocketWrite(response);
        }

        private void SendError(String error)
        {
            _wifi.SocketWrite("HTTP/1.1 500 Server Error\r\n\r\n" + error + "\r\n");
        }

        private void StartCommunications()
        {
            _wifi.DebugMode = true;

            Debug.Print("Initializing WiFi");

            _wifi.EnableStaticIP("192.168.1.252", "255.255.255.0", "192.168.1.254", "192.168.1.254");

            _wifi.JoinNetwork("LITTLENET", 0, WiFlyGSX.AuthMode.WPA2_PSK, "bed3053bed");

            bool noIP = true;
            while (noIP)
            {
                noIP = _wifi.LocalIP == "0.0.0.0";
                System.Threading.Thread.Sleep(250);
            }

            Debug.Print("WiFly IP  :" + _wifi.LocalIP);
            Debug.Print("WiFly MAC :" + _wifi.MacAddress);
        }

        private void SetTime()
        {
            double ntpSeconds = _wifi.NtpLookup("173.230.149.23");
            _clock = new Clock(ntpSeconds);

            if (System.Diagnostics.Debugger.IsAttached)
            {
                _clock.SetInterval(1, () =>
                {
                    Debug.Print(_clock.Now.ToString());
                });
            }
        }


        private string GetAllRelayStates() {

            StringBuilder builder = new StringBuilder();

            builder.Append('[').Append(GetRelay(0) ? "true": "false");

            for (int i = 1; i < 9; i++) {
                builder.Append(", ").Append(GetRelay(i) ? "true" : "false");
            }

            return builder.Append(']').ToString();
        }

        private bool GetRelay(int number)
        {
            switch (number)
            {
                case 0:
                    return relays1.Relay1;

                case 1:
                    return relays1.Relay2;

                case 2:
                    return relays1.Relay3;

                case 3:
                    return relays1.Relay4;

                case 4:
                    return relays2.Relay1;

                case 5:
                    return relays2.Relay2;

                case 6:
                    return relays2.Relay3;

                case 7:
                    return relays2.Relay4;
            }

            return false;
        }

        private void SetRelay(int number, bool state)
        {
            Debug.Print("SetRelay " + number + " " + state);

            switch (number)
            {
                case 0:
                    relays1.Relay1 = state;
                    break;
                case 1:
                    relays1.Relay2 = state;
                    break;
                case 2:
                    relays1.Relay3 = state;
                    break;
                case 3:
                    relays1.Relay4 = state;
                    break;
                case 4:
                    relays2.Relay1 = state;
                    break;
                case 5:
                    relays2.Relay2 = state;
                    break;
                case 6:
                    relays2.Relay3 = state;
                    break;
                case 7:
                    relays2.Relay4 = state;
                    break;
            }
        }

        private void RunSchedule()
        {
            var now = _clock.Now;

            foreach (ScheduleItem item in _schedule)
            {
                DateTime onDateTime = ToDateTime(now, item.onTime);
                DateTime offDateTime = ToDateTime(now, item.offTime);

                SetRelay(item.relayNumber, now >= onDateTime && now <= offDateTime);
            }

        }

        private DateTime ToDateTime(DateTime now, int seconds)
        {
            return now.Date.AddSeconds(seconds);
        }


        private void SaveSchedule() {
            using (JsonWriter writer = JsonWriter.Create("\\Settings.json")) {

                writer.WriteStartArray();

                foreach (ScheduleItem item in _schedule) {
                    writer.WriteStartObject();

                    writer.WriteName("relayNumber").WriteValue(item.relayNumber);
                    writer.WriteName("onTime").WriteValue(item.onTime);
                    writer.WriteName("offTime").WriteValue(item.offTime);

                    writer.WriteEnd();
                }

                writer.WriteEnd();
            }
        }
    }
}

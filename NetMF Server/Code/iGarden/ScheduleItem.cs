using System;
using Microsoft.SPOT;

namespace iGarden
{
    class ScheduleItem
    {
        public int relayNumber;
        public int onTime;
        public int offTime;

        public ScheduleItem(int relayNumber, int onTime, int offTime)
        {
            this.relayNumber = relayNumber;
            this.onTime = onTime;
            this.offTime = offTime;
        }

      
    }
}

using System;
using Microsoft.SPOT;
using System.Threading;
using System.Collections;

namespace iGarden
{
    public delegate void Action();

    abstract class ScheduledItem
    {
        public abstract bool TimeStep(DateTime now);
    }

    class Interval : ScheduledItem
    {
        private double _basis;
        private double _triggerTime;
        public double interval;
        public Action callback;

        public Interval(DateTime now, double interval, Action callback)
        {
            this.interval = interval;
            this.callback = callback;

            _basis = now.Ticks / TimeSpan.TicksPerSecond;
            _triggerTime = _basis + interval;
        }

        public override bool TimeStep(DateTime now) {
            var nowSecs = now.Ticks / TimeSpan.TicksPerSecond;

            if (nowSecs > _triggerTime)
            {
                callback();
                _triggerTime = System.Math.Floor((nowSecs - _basis) / interval) * interval + interval;
            }

            return false;
        }
    }

    class Clock
    {
        private Thread _thread;
        private long _clockOffset;
        private readonly object _syncObj = new Object();
        private ArrayList _waitList = new ArrayList();

        public Clock(double ntpSeconds)
        {
            var ntpTime = new DateTime(1900, 1, 1).AddSeconds(ntpSeconds);

            _clockOffset = (ntpTime - DateTime.Now).Ticks;

            _thread = new Thread(ThreadCallback);
            _thread.Start();
        }

        public DateTime Now
        {
            get
            {
                return DateTime.Now.AddTicks (_clockOffset);
            }
        }

        public void SetAlarm(DateTime dateTime, object callback) {


        }

        public void SetInterval(double timeout, Action callback)
        {
            lock (_syncObj)
            {
                _waitList.Add(new Interval(this.Now, timeout, callback));
            }
        }

        private void ThreadCallback()
        {
            while (true)
            {
                Thread.Sleep(1000);

                lock (_syncObj)
                {
                    var i = 0;
                    while (i < _waitList.Count) {
                        var item = (ScheduledItem)_waitList[i];

                        if (item.TimeStep(this.Now))
                        {
                            _waitList.Remove(item);
                        }
                        else
                        {
                            i++;
                        }
                    }
                }
            }
        }
    }
}

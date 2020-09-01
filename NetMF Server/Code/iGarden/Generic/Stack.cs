using System;
using Microsoft.SPOT;

namespace System.Collections.Generic
{
    class Stack<T> {
        private int _count;
        private T[] _array = new T[8];

        public void Push(T value)
        {
            if (_array.Length == _count)
            {
                var newArray = new T[_array.Length * 2];
                Array.Copy(_array, newArray, _array.Length);
                _array = newArray;
            }

            _array[_count] = value;
            _count++;
        }

        public T Peek()
        {
            if (_count > 0)
            {
                return _array[_count - 1];
            }
            else
            {
                return default(T);
            }
        }

        public T Pop()
        {
            if (_count > 0)
            {
                _count--;
                return _array[_count];
            }
            else
            {
                return default(T);
            }
        }

        public int Count
        {
            get
            {
                return _count;
            }
        }
    }
}
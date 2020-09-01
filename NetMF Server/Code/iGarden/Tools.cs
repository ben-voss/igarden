using System;

using Microsoft.SPOT;

/*
 * Copyright 2011-2013 Stefan Thoolen (http://www.netmftoolbox.com/)
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
namespace Toolbox.NETMF
{
    /// <summary>
    /// Generic, useful tools
    /// </summary>
    public static class Tools
    {
        /// <summary>Escapes all non-visible characters</summary>
        /// <param name="Input">Input text</param>
        /// <returns>Output text</returns>
        public static string Escape(string Input)
        {
            if (Input == null) return "";

            char[] Buffer = Input.ToCharArray();
            string RetValue = "";
            for (int i = 0; i < Buffer.Length; ++i)
            {
                if (Buffer[i] == 13)
                    RetValue += "\\r";
                else if (Buffer[i] == 10)
                    RetValue += "\\n";
                else if (Buffer[i] == 92)
                    RetValue += "\\\\";
                else if (Buffer[i] < 32 || Buffer[i] > 126)
                    RetValue += "\\" + Tools.Dec2Hex((int)Buffer[i], 2);
                else
                    RetValue += Buffer[i];
            }

            return RetValue;
        }

        /// <summary>
        /// Converts a byte array to a char array
        /// </summary>
        /// <param name="Input">The byte array</param>
        /// <returns>The char array</returns>
        public static char[] Bytes2Chars(byte[] Input)
        {
            char[] Output = new char[Input.Length];
            for (int Counter = 0; Counter < Input.Length; ++Counter)
                Output[Counter] = (char)Input[Counter];
            return Output;
        }

        /// <summary>
        /// Converts a char array to a byte array
        /// </summary>
        /// <param name="Input">The char array</param>
        /// <returns>The byte array</returns>
        public static byte[] Chars2Bytes(char[] Input)
        {
            byte[] Output = new byte[Input.Length];
            for (int Counter = 0; Counter < Input.Length; ++Counter)
                Output[Counter] = (byte)Input[Counter];
            return Output;
        }

        /// <summary>
        /// Converts a number to a Hex string
        /// </summary>
        /// <param name="Input">The number</param>
        /// <param name="MinLength">The minimum length of the return string (filled with 0s)</param>
        /// <returns>The Hex string</returns>
        public static string Dec2Hex(int Input, int MinLength = 0)
        {
#if MF_FRAMEWORK_VERSION_V4_2 || MF_FRAMEWORK_VERSION_V4_3
            // Since NETMF 4.2 int.toString() exists, so we can do this:
            return Input.ToString("x" + MinLength.ToString());
#else
                // Contains all Hex posibilities
                string ConversionTable = "0123456789ABCDEF";
                // Starts the conversion
                string RetValue = "";
                int Current = 0;
                int Next = Input;
                do
                {
                    if (Next >= ConversionTable.Length)
                    {
                        // The current digit
                        Current = (Next / ConversionTable.Length);
                        if (Current * ConversionTable.Length > Next) --Current;
                        // What's left
                        Next = Next - (Current * ConversionTable.Length);
                    }
                    else
                    {
                        // The last digit
                        Current = Next;
                        // Nothing left
                        Next = -1;
                    }
                    RetValue += ConversionTable[Current];
                } while (Next != -1);

                return Tools.ZeroFill(RetValue, MinLength);
#endif
        }

        /// <summary>A generic event handler when receiving a string</summary>
        /// <param name="text">The actual string</param>
        /// <param name="time">Timestamp of the event</param>
        public delegate void StringEventHandler(string text, DateTime time);
    }
}
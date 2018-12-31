using System;
using System.Diagnostics;
using System.Runtime.InteropServices;

namespace Test
{
    struct RGB
    {
        public RGB(byte r, byte g, byte b) { this.r = r; this.b = b; this.g = g; }
        private byte r;
        private byte g;
        private byte b;
    }

    class Program
    {
        static void Main(string[] args)
        {
            BasicTest(true, false, true);
            BasicTest('a','b','c');
            BasicTest<byte>(10, 20, 30);
            BasicTest<sbyte>(-10, -20, -30);
            BasicTest<short>(1001, 2002, 3003);
            BasicTest<ushort>(1001, 2002, 3003);
            BasicTest(1001, 2002, 3003);
            BasicTest<uint>(1001, 2002, 3003);
            BasicTest(1001L, 2002L, 3003L);
            BasicTest<ulong>(1001L, 2002L, 3003L);
            BasicTest(1.1f, 2.2f, 3.3f);
            BasicTest(1.1d, 2.2d, 3.3d);
            BasicTest(1.1m, 2.2m, 3.3m); // decimal
            BasicTest(new RGB(0, 0, 0), new RGB(128, 128, 128), new RGB(255, 100, 255));
            PerfTest(iterations : 1000000);

            Console.WriteLine("All tests passed.");
        }


        // to see inlining results when running this method, enable DumpStack in GenericMemoryAccess.il
        public static void BasicTest<T>(T value1, T value2, T value3) 
            where T : struct
        {
            Console.Write($"Executing ReadWriteTest<{typeof(T).Name}> ... ");

            // allocate some unmanaged memory
            int size = GenericMemoryAccess.SizeOf<T>();
            var unmanagedBytes = Marshal.AllocHGlobal(size * 4);

            // treat it as an int and set a value
            GenericMemoryAccess.WriteValue<T>(value1, unmanagedBytes);

            // read back the value to make sure it got set correctly
            var x = GenericMemoryAccess.ReadValue<T>(unmanagedBytes);
            if (!x.Equals(value1))
            {
                throw new Exception($"Unexpected value {x}");
            }

            // create a managed array of ints, and fill it with content from the unmanaged buffer
            var managedTs = new T[4];
            GenericMemoryAccess.CopyToArray(unmanagedBytes, managedTs, 0, 4);
            if (!managedTs[0].Equals(value1))
            {
                throw new Exception($"Unexpected value {managedTs[0]}");
            }

            // make a change in the managed array and copy it back to unmanaged memory
            managedTs[0] = value2;
            GenericMemoryAccess.CopyFromArray(managedTs, 0, unmanagedBytes, size * 4, 4);
            x = GenericMemoryAccess.ReadValue<T>(unmanagedBytes);
            if (!x.Equals(value2))
            {
                throw new Exception($"Unexpected value {x}");
            }

            // get a reference to the memory buffer
            ref var y = ref GenericMemoryAccess.ReadRef<T>(unmanagedBytes);
            if (!y.Equals(value2))
            {
                throw new Exception($"Unexpected value {y}");
            }

            // changing y should change the underlying memory buffer, since y is a ref
            y = value3;
            x = GenericMemoryAccess.ReadValue<T>(unmanagedBytes);
            if (!x.Equals(value3))
            {
                throw new Exception($"Unexpected value {x}");
            }

            Marshal.FreeHGlobal(unmanagedBytes);
            Console.WriteLine(" Done.");
        }

        // run in release mode
        public static unsafe void PerfTest(int iterations)
        {
            var count = 256;
            var unmanagedBytes = Marshal.AllocHGlobal(count * 16);
            long value = 1;

            Console.WriteLine($"Executing PerfTest with {iterations} iterations. Smaller numbers (times) are better.");

#if DEBUG
            Console.WriteLine($"\t Skipped. This test must be run in RELEASE mode.");
            return;
#endif

            // warm-up
            var size = GenericMemoryAccess.SizeOf<int>();
            value = GenericMemoryAccess.ReadValue<int>(unmanagedBytes);

            var sw = Stopwatch.StartNew();
            for (var i = 0; i < iterations; i++)
            {
                for (int j = 0; j < count; j++)
                {
                    value += GenericMemoryAccess.ReadValue<int>(unmanagedBytes + j * size);
                }
            }

            sw.Stop();
            Console.WriteLine("\t time reading int elements from unmanaged buffer using GenericMemoryAccess.ReadValue: 1 (baseline)");
            double baseline = sw.ElapsedTicks;

            sw = Stopwatch.StartNew();
            for (var i = 0; i < iterations; i++)
            {
                for (int j = 0; j < count; j++)
                {
                     value += *(int*)(unmanagedBytes + j * size);
                }
            }

            sw.Stop();
            Console.WriteLine($"\t time reading int elements from unmanaged buffer using *(int*)(unmanagedBytes + i * size):  {sw.ElapsedTicks / baseline:G5}");

            var items = new int[count];
            value = items[0];
            sw = Stopwatch.StartNew();
            for (var i = 0; i < iterations; i++)
            {
                for (int j = 0; j < count; j++)
                {
                    value += items[j] * size; // keep a multiplication in the inner loop to have the same number of operations as in the other two, even though here it's not needed
                }
            }

            sw.Stop();
            Console.WriteLine($"\t time reading int elements from managed array using int[i]: {sw.ElapsedTicks / baseline:G5}");


            if (value != 0) // access value just to make sure the for loops don't get optimized away
            {
                throw new Exception("Huh?"); 
            }
            Console.WriteLine("Done.");
        }
    }
}

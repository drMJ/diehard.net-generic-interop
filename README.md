# .Net generic-typed access to unmanaged memory
A .Net class providing typed access to unmanaged memory using generics.
This is particularly useful when writing generic code (that is, code that uses .Net generics) which needs to interoperate with unmanaged code. However, the class can be used whenever interop is required, since there is no performance penalty in using this library compared to hand-written code (and in fact accessing unmanaged memory arrays using this class is faster than accessing managed arrays). 

## Details:
Given a memory pointer, the various methods can read/write any simple value type or array of simple value types, 
where "simple value type" means any simple type or any user defined struct containing only simple value types.
Simple types are the built-in types defined in the System namespace (byte, char, int etc.) except object and string (see https://docs.microsoft.com/en-us/dotnet/csharp/language-reference/keywords/built-in-types-table) 

Important: the code does not check for alignment or field packing. It simply assumes that the data layout matches the struct layout. 

## Installation:
Download GenericMemoryAccess.il.
Compile using ilasm.exe, e.g.:
c:\Windows\Microsoft.NET\Framework64\v4.0.30319\ilasm.exe GenericMemoryAccess.il /dll /output=GenericMemoryAccess.dll /PDB"

Alternatively, clone the whole repo and load and build the test solution. It will build GenericMemoryAccess.dll in its output directory.

## Examples:
```c#
IntPtr unmanagedBytes = System.Runtime.InteropServices.Marshal.AllocHGlobal(64*64*3);

// read/write values to/from unmanaged memory
GenericMemoryAccess.WriteValue(1234, unmanagedBytes); // writes an int
var i = GenericMemoryAccess.ReadValue<int>(unmanagedBytes); // reads an int

GenericMemoryAccess.WriteValue(1234.56d, unmanagedBytes); // writes a double
var d = GenericMemoryAccess.ReadValue<double>(unmanagedBytes); // reads a double
  
GenericMemoryAccess.WriteValue(new RGB(128, 128, 128), unmanagedBytes); // writes a user-defined struct
var rgb = GenericMemoryAccess.ReadValue<RGB>(unmanagedBytes); // reads a user-defined struct
 
// copy arrays of custom structs to/from unmanaged memory
var image = new RGB[64*64];
GenericMemoryAccess.CopyFromArray(image, 0, unmanagedBytes, image.Length * 3,  image.Length); 
GenericMemoryAccess.CopyToArray(unmanagedBytes, image, 0, image.Length);

// get a reference to an element located in unmanaged memory
ref var x = ref GenericMemoryAccess.ReadRef<T>(unmanagedBytes);
```


// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT license.

.assembly extern netstandard as mscorlib // see: https://github.com/dotnet/coreclr/issues/10590
{
  .publickeytoken = (CC 7B 13 FF CD 2D DD 51 )            
  .ver 2:0:0:0
}

.assembly GenericMemoryAccess {}
.module GenericMemoryAccess.dll

/// <summary>
/// This class provides static methods for strong-typed access to unmanaged memory.
/// Given a memory pointer, the various methods can read/write any simple value type or array of simple value types, 
/// where "simple value type" means any simple type or any user defined struct containing only simple value types.
/// Simple types are the built-in types defined in the System namespace (byte, char, int etc.) except object and string (see https://docs.microsoft.com/en-us/dotnet/csharp/language-reference/keywords/built-in-types-table) 
/// Important: this class does not check for alignment or field packing. It simply assumes that the memory layout matches the struct layout. 
/// </summary>
.class public abstract auto ansi sealed GenericMemoryAccess
       extends [mscorlib]System.Object
{
	/// Returns the size in bytes of the given generic value type
	.method public hidebysig static int32  SizeOf<valuetype .ctor ([mscorlib]System.ValueType) T>() cil managed aggressiveinlining
	{
	  // Code size       18 (0x12)
	  .maxstack  8
	  // call       void GenericMemoryAccess::DumpStack()
	  sizeof     !!T
	  ret
	}
	
	/// Casts the IntPtr to a T* and returns the T value
	.method public hidebysig static !!T  ReadValue<valuetype .ctor ([mscorlib]System.ValueType) T>(native int source) cil managed aggressiveinlining
	{
	  // Code size       18 (0x12)
	  .maxstack  8
	  //call       void MGenericMemoryAccess::DumpStack()
	  ldarg.0
	  call       void* [mscorlib]System.IntPtr::op_Explicit(native int)
	  ldobj      !!T
	  ret
	} // end of method GenericMemoryAccess`1::ReadValue

	
	/// Casts the IntPtr to a T* and returns a ref T (use like this: ref var x = ref GenericMemoryAccess.ReadRef<MyType>(ptr);)
	/// This flavor doesn't appear to get inlined (because of the return type)
	.method public hidebysig static !!T&  ReadRef<valuetype .ctor ([mscorlib]System.ValueType) T>(native int source) cil managed aggressiveinlining
	{
	  // Code size       18 (0x12)
	  .maxstack  8
	  //call       void GenericMemoryAccess::DumpStack()
	  ldarg.0
	  call       void* [mscorlib]System.IntPtr::op_Explicit(native int)
	  ret
	} // end of method GenericMemoryAccess`1::ReadValue
		
	/// Casts the IntPtr to a T* and copies it into the specified T reference
	.method public hidebysig static void  ReadValue<valuetype .ctor ([mscorlib]System.ValueType) T>(!!T& target, native int source) cil managed aggressiveinlining
	{
	  // Code size       18 (0x12)
	  .maxstack  8
	  ldarg.0
	  ldarg.1
	  //call       void* [mscorlib]System.IntPtr::op_Explicit(native int)
	  ldobj      !!T
	  stobj      !!T	
	  // call       void GenericMemoryAccess::DumpStack()
	  ret

	} // end of method GenericMemoryAccess`1::ReadValue

	/// Stores the T value to the memory address specified by IntPtr.
	.method public hidebysig static void  WriteValue<valuetype .ctor ([mscorlib]System.ValueType) T>(!!T source,
													 native int target) cil managed aggressiveinlining
	{
		// Code size       18 (0x12)
	  .maxstack  8
	  IL_0000:  ldarg.1
	  IL_0001:  call       void* [mscorlib]System.IntPtr::op_Explicit(native int)
	  IL_0006:  ldarg.0
	  IL_000c:  stobj      !!T
	  //call       void GenericMemoryAccess::DumpStack()
	  IL_0011:  ret
	} // end of method GenericMemoryAccess`1::WriteValue

	/// Copies elementCount*sizeof(T) bytes from the source IntPtr to the target array starting at the targetIndex element
	.method public hidebysig static void  CopyToArray<valuetype .ctor ([mscorlib]System.ValueType) T>(native int src,
													  !!T[] dest,
													  int32 targetIndex,
													  int32 elementCount) cil managed
	{
	  // Code size       69 (0x45)
	  .maxstack  5
	  .locals init (!!T& pinned V_0,
			   !!T[] V_1)
	  IL_0000:  ldarg.1
	  IL_0001:  dup
	  IL_0002:  stloc.1
	  IL_0003:  brfalse.s  IL_000a
	  IL_0005:  ldloc.1
	  IL_0006:  ldlen
	  IL_0007:  conv.i4
	  IL_0008:  brtrue.s   IL_000f
	  IL_000a:  ldc.i4.0
	  IL_000b:  conv.u
	  IL_000c:  stloc.0
	  IL_000d:  br.s       IL_0017
	  IL_000f:  ldloc.1
	  IL_0010:  ldc.i4.0
	  IL_0011:  ldelema    !!T
	  IL_0016:  stloc.0
	  IL_0017:  ldarga.s   src
	  IL_0019:  call       instance void* [mscorlib]System.IntPtr::ToPointer()
	  IL_001e:  ldloc.0
	  IL_001f:  conv.i
	  IL_0020:  ldarg.2
	  IL_0021:  conv.i
	  IL_0022:  sizeof     !!T
	  IL_0028:  mul
	  IL_0029:  add
	  IL_002a:  ldarg.1
	  IL_002b:  ldlen
	  IL_002c:  conv.i4
	  IL_002d:  sizeof     !!T
	  IL_0032:  mul
	  IL_0033:  conv.i8
	  IL_0034:  ldarg.3
	  IL_0035:  sizeof     !!T
	  IL_003a:  mul
	  IL_003b:  conv.i8
	  // more efficient then Array.Copy or cpblk IL instruction because it handles small sizes explicitly
      // http://referencesource.microsoft.com/#mscorlib/system/buffer.cs,c2ca91c0d34a8f86
	  IL_003c:  call       void [mscorlib]System.Buffer::MemoryCopy(void*,
																	   void*,
																	   int64,
																	   int64)
	  IL_0041:  ldc.i4.0
	  IL_0042:  conv.u
	  IL_0043:  stloc.0
	  IL_0044:  ret

	} // end of method GenericMemoryAccess`1::CopyToArray

	/// Copies elementCount*sizeof(T) bytes from the source array starting at element intex srcIndex to the destination IntPtr
	.method public hidebysig static void  CopyFromArray<valuetype .ctor ([mscorlib]System.ValueType) T>(!!T[] src,
														int32 srcIndex,
														native int dest,
														int32 destSizeInBytes,
														int32 elementCount) cil managed
	{
	  // Code size       62 (0x3e)
	  .maxstack  5
	  .locals init (!!T& pinned V_0,
			   !!T[] V_1)
	  IL_0000:  ldarg.0
	  IL_0001:  dup
	  IL_0002:  stloc.1
	  IL_0003:  brfalse.s  IL_000a
	  IL_0005:  ldloc.1
	  IL_0006:  ldlen
	  IL_0007:  conv.i4
	  IL_0008:  brtrue.s   IL_000f
	  IL_000a:  ldc.i4.0
	  IL_000b:  conv.u
	  IL_000c:  stloc.0
	  IL_000d:  br.s       IL_0017
	  IL_000f:  ldloc.1
	  IL_0010:  ldc.i4.0
	  IL_0011:  ldelema    !!T
	  IL_0016:  stloc.0
	  IL_0017:  ldloc.0
	  IL_0018:  conv.i
	  IL_0019:  ldarg.1
	  IL_001a:  conv.i
	  IL_001b:  sizeof     !!T
	  IL_0021:  mul
	  IL_0022:  add
	  IL_0023:  ldarga.s   dest
	  IL_0025:  call       instance void* [mscorlib]System.IntPtr::ToPointer()
	  IL_002a:  ldarg.3
	  IL_002b:  conv.i8
	  IL_002c:  ldarg.s    elementCount
	  IL_002e:  sizeof     !!T
	  IL_0033:  mul
	  IL_0034:  conv.i8
	  // more efficient then Array.Copy or cpblk IL instruction because it handles small sizes explicitly
	  // http://referencesource.microsoft.com/#mscorlib/system/buffer.cs,c2ca91c0d34a8f86
	  IL_0035:  call       void [mscorlib]System.Buffer::MemoryCopy(void*,
																	   void*,
																	   int64,
																	   int64)
	  IL_003a:  ldc.i4.0
	  IL_003b:  conv.u
	  IL_003c:  stloc.0
	  IL_003d:  ret

	} // end of method GenericMemoryAccess`1::CopyFromArray

	// Debug helper function
	.method assembly hidebysig static void  DumpStack() cil managed
	{
	  // Code size       11 (0xb)
	  .maxstack  8
	  IL_0000:  newobj     instance void [mscorlib]System.Diagnostics.StackTrace::.ctor()
	  IL_0005:  call       void [mscorlib]System.Console::WriteLine(object)
	  IL_000a:  ret
	} // end of method GenericMemoryAccess::DumpStack

} // end of class GenericMemoryAccess`1

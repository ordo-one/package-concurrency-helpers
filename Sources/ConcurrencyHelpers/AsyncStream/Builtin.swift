
@_silgen_name("swift_allocObject")
func swift_allocObject(_ typeMetadata: UnsafeRawPointer, _ size: Int, _ align: Int) -> UnsafeRawPointer

@_silgen_name("swift_allocWithTailElems_1")
func builtin_allocWithTailElems_1(
    _ typeMetadata: UnsafeRawPointer,
    _ numberOfElements: Int,
    _ elementType: UnsafeRawPointer
) -> UnsafeMutableRawPointer

enum Builtin {
    static func projectTailElems<C, E>(_: C, _: E.Type) -> UnsafeRawPointer {
        fatalError()
    }

    static func allocWithTailElems_1<C, E>(_: C.Type, _ count: Int, _: E.Type) -> C {
        let typeMetadata = unsafeBitCast(C.self, to: UnsafeRawPointer.self)
        let requiredSize = MemoryLayout<C>.stride + MemoryLayout<E>.stride * count
        let requiredAlignmentMask = MemoryLayout<C>.alignment - 1
        let ptr = swift_allocObject(typeMetadata, requiredSize+128, requiredAlignmentMask)
        print("allocated ptr=\(ptr)")
        return ptr.assumingMemoryBound(to: C.self).pointee
    }

    static func addressof<T>(_ value: inout T) -> UnsafeMutablePointer<T> {
        withUnsafeMutablePointer(to: &value) {
            return $0
        }
    }
}

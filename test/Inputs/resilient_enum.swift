import resilient_struct

// Fixed-layout enum with resilient members
@_fixed_layout public enum SimpleShape {
  case KleinBottle
  case Triangle(Size)
}

// Fixed-layout enum with resilient members
@_fixed_layout public enum Shape {
  case Point
  case Rect(Size)
  case RoundedRect(Size, Size)
}

// Fixed-layout enum with indirect resilient members
@_fixed_layout public enum FunnyShape {
  indirect case Parallelogram(Size)
  indirect case Trapezoid(Size)
}

// The enum payload has fixed layout inside this module, but
// resilient layout outside. Make sure we emit the payload
// size in the metadata.

public struct Color {
  public let r: Int, g: Int, b: Int

  public init(r: Int, g: Int, b: Int) {
    self.r = r
    self.g = g
    self.b = b
  }
}

@_fixed_layout public enum CustomColor {
  case Black
  case White
  case Custom(Color)
  case Bespoke(Color, Color)
}

// Resilient enum
public enum Medium {
  // Empty cases
  case Paper
  case Canvas

  // Indirect case
  indirect case Pamphlet(Medium)

  // Case with resilient payload
  case Postcard(Size)
}

// Indirect resilient enum
public indirect enum IndirectApproach {
  case Angle(Double)
}

// Resilient enum with resilient empty payload case
public struct EmptyStruct {
  public init() {}
}

public enum ResilientEnumWithEmptyCase {
  case A // should always be case 1
  case B // should always be case 2
  case Empty(EmptyStruct) // should always be case 0
}

public func getResilientEnumWithEmptyCase() -> [ResilientEnumWithEmptyCase] {
  return [.A, .B, .Empty(EmptyStruct())]
}

// Specific enum implementations for executable tests
public enum ResilientEmptyEnum {
  case X
}

public enum ResilientSingletonEnum {
  case X(AnyObject)
}

public enum ResilientSingletonGenericEnum<T> {
  case X(T)
}

public enum ResilientNoPayloadEnum {
  case A
  case B
  case C
}

public enum ResilientSinglePayloadEnum {
  case A
  case B
  case C
  case X(AnyObject)
}

public enum ResilientSinglePayloadGenericEnum<T> {
  case A
  case B
  case C
  case X(T)
}

public class ArtClass {
  public init() {}
}

public enum ResilientMultiPayloadEnum {
  case A
  case B
  case C
  case X(Int)
  case Y(Int)
}

public func makeResilientMultiPayloadEnum(n: Int, i: Int)
    -> ResilientMultiPayloadEnum {
  switch i {
  case 0:
    return .A
  case 1:
    return .B
  case 2:
    return .C
  case 3:
    return .X(n)
  case 4:
    return .Y(n)
  default:
    while true {}
  }
}

public enum ResilientMultiPayloadEnumSpareBits {
  case A
  case B
  case C
  case X(ArtClass)
  case Y(ArtClass)
}

public func makeResilientMultiPayloadEnumSpareBits(o: ArtClass, i: Int)
    -> ResilientMultiPayloadEnumSpareBits {
  switch i {
  case 0:
    return .A
  case 1:
    return .B
  case 2:
    return .C
  case 3:
    return .X(o)
  case 4:
    return .Y(o)
  default:
    while true {}
  }
}

public typealias SevenSpareBits = (Bool, Int8, Int8, Int8, Int8, Int8, Int8, Int8)

public enum ResilientMultiPayloadEnumSpareBitsAndExtraBits {
  // On 64-bit little endian, 7 spare bits at the LSB end
  case P1(SevenSpareBits)
  // On 64-bit, 8 spare bits at the MSB end and 3 at the LSB end
  case P2(ArtClass)
  case P3(ArtClass)
  case P4(ArtClass)
  case P5(ArtClass)
  case P6(ArtClass)
  case P7(ArtClass)
  case P8(ArtClass)
}

public enum ResilientMultiPayloadGenericEnum<T> {
  case A
  case B
  case C
  case X(T)
  case Y(T)
}

public enum ResilientIndirectEnum {
  case Base
  indirect case A(ResilientIndirectEnum)
  indirect case B(ResilientIndirectEnum, ResilientIndirectEnum)
}

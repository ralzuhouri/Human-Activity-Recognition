// Copyright (c) 2014–2015 Mattt Thompson (http://mattt.me)
// Copyright (c) 2015-2016 Remy Prechelt
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Accelerate

// MARK: Convolution

// Convolution of a signal [x], with a kernel [k]. The signal must be at least as long as the kernel.
public func conv<X: ContinuousCollection, K: ContinuousCollection>(_ x: X, _ k: K) -> [Float] where X.Iterator.Element == Float, K.Iterator.Element == Float {
    precondition(x.count >= k.count, "Input vector [x] must have at least as many elements as the kernel,  [k]")

    let resultSize = numericCast(x.count) + numericCast(k.count) - 1
    var result = [Float](repeating: 0, count: resultSize)
    result.withUnsafeMutableBufferPointer { rbp in
        withUnsafePointersAndCountsTo(k) { kp, kc in
            let kEnd = kp.advanced(by: kc - 1)
            let xPad = repeatElement(0 as Float, count: kc - 1)

            var xPadded = [Float]()
            xPadded.reserveCapacity(xPad.count + numericCast(x.count) + xPad.count)
            xPadded.append(contentsOf: xPad)
            xPadded.append(contentsOf: x)
            xPadded.append(contentsOf: xPad)

            vDSP_conv(xPadded, 1, kEnd, -1, rbp.baseAddress!, 1, vDSP_Length(resultSize), vDSP_Length(kc))
        }
    }
    return result
}

// Convolution of a signal [x], with a kernel [k]. The signal must be at least as long as the kernel.
public func conv<X: ContinuousCollection, K: ContinuousCollection>(_ x: X, _ k: K) -> [Double] where X.Iterator.Element == Double, K.Iterator.Element == Double {
    precondition(x.count >= k.count, "Input vector [x] must have at least as many elements as the kernel,  [k]")

    let resultSize = numericCast(x.count) + numericCast(k.count) - 1
    var result = [Double](repeating: 0, count: resultSize)
    result.withUnsafeMutableBufferPointer { rbp in
        withUnsafePointersAndCountsTo(k) { kp, kc in
            let kEnd = kp.advanced(by: kc - 1)
            let xPad = repeatElement(0 as Double, count: kc - 1)

            var xPadded = [Double]()
            xPadded.reserveCapacity(xPad.count + numericCast(x.count) + xPad.count)
            xPadded.append(contentsOf: xPad)
            xPadded.append(contentsOf: x)
            xPadded.append(contentsOf: xPad)

            vDSP_convD(xPadded, 1, kEnd, -1, rbp.baseAddress!, 1, vDSP_Length(resultSize), vDSP_Length(kc))
        }
    }
    return result
}

// MARK: Cross-Correlation

// Cross-correlation of a signal [x], with another signal [y]. The signal [y]
// is padded so that it is the same length as [x].
public func xcorr<X: ContinuousCollection, Y: ContinuousCollection>(_ x: X, _ y: Y) -> [Float] where X.Iterator.Element == Float, Y.Iterator.Element == Float {
    precondition(x.count >= y.count, "Input vector [x] must have at least as many elements as [y]")
    var yPadded = [Float](y)
    if x.count > y.count {
        let padding = repeatElement(0 as Float, count: numericCast(x.count) - numericCast(y.count))
        yPadded.append(contentsOf: padding)
    }

    let resultSize = numericCast(x.count) + yPadded.count - 1
    var result = [Float](repeating: 0, count: resultSize)
    let xPad = repeatElement(0 as Float, count: yPadded.count-1)

    var xPadded = [Float]()
    xPadded.reserveCapacity(xPad.count + numericCast(x.count) + xPad.count)
    xPadded.append(contentsOf: xPad)
    xPadded.append(contentsOf: x)
    xPadded.append(contentsOf: xPad)

    result.withUnsafeMutableBufferPointer { rbp in
        vDSP_conv(xPadded, 1, yPadded, 1, rbp.baseAddress!, 1, vDSP_Length(resultSize), vDSP_Length(yPadded.count))
    }

    return result
}

// Cross-correlation of a signal [x], with another signal [y]. The signal [y]
// is padded so that it is the same length as [x].
public func xcorr<X: ContinuousCollection, Y: ContinuousCollection>(_ x: X, _ y: Y) -> [Double] where X.Iterator.Element == Double, Y.Iterator.Element == Double {
    precondition(x.count >= y.count, "Input vector [x] must have at least as many elements as [y]")
    var yPadded = [Double](y)
    if x.count > y.count {
        let padding = repeatElement(0 as Double, count: numericCast(x.count) - numericCast(y.count))
        yPadded.append(contentsOf: padding)
    }

    let resultSize = numericCast(x.count) + yPadded.count - 1
    var result = [Double](repeating: 0, count: resultSize)
    let xPad = repeatElement(0 as Double, count: yPadded.count-1)

    var xPadded = [Double]()
    xPadded.reserveCapacity(xPad.count + numericCast(x.count) + xPad.count)
    xPadded.append(contentsOf: xPad)
    xPadded.append(contentsOf: x)
    xPadded.append(contentsOf: xPad)

    result.withUnsafeMutableBufferPointer { rbp in
        vDSP_convD(xPadded, 1, yPadded, 1, rbp.baseAddress!, 1, vDSP_Length(resultSize), vDSP_Length(yPadded.count))
    }

    return result
}

// MARK: Auto-correlation

// Auto-correlation of a signal [x]
public func xcorr<X: ContinuousCollection>(_ x: X) -> [Float] where X.Iterator.Element == Float {
    let resultSize = 2*numericCast(x.count) - 1
    var result = [Float](repeating: 0, count: resultSize)
    let xPad = repeatElement(0 as Float, count: numericCast(x.count) - 1)

    var xPadded = [Float]()
    xPadded.reserveCapacity(xPad.count + numericCast(x.count) + xPad.count)
    xPadded.append(contentsOf: xPad)
    xPadded.append(contentsOf: x)
    xPadded.append(contentsOf: xPad)

    withUnsafePointersAndCountsTo(x) { xp, xc in
        result.withUnsafeMutableBufferPointer { rbp in
            vDSP_conv(xPadded, 1, xp, 1, rbp.baseAddress!, 1, vDSP_Length(resultSize), vDSP_Length(xc))
        }
    }

    return result
}

// Auto-correlation of a signal [x]
public func xcorr<X: ContinuousCollection>(_ x: X) -> [Double] where X.Iterator.Element == Double {
    let resultSize = 2*numericCast(x.count) - 1
    var result = [Double](repeating: 0, count: resultSize)
    let xPad = repeatElement(0 as Double, count: numericCast(x.count) - 1)

    var xPadded = [Double]()
    xPadded.reserveCapacity(xPad.count + numericCast(x.count) + xPad.count)
    xPadded.append(contentsOf: xPad)
    xPadded.append(contentsOf: x)
    xPadded.append(contentsOf: xPad)

    withUnsafePointersAndCountsTo(x) { xp, xc in
        result.withUnsafeMutableBufferPointer { rbp in
            vDSP_convD(xPadded, 1, xp, 1, rbp.baseAddress!, 1, vDSP_Length(resultSize), vDSP_Length(xc))
        }
    }

    return result
}

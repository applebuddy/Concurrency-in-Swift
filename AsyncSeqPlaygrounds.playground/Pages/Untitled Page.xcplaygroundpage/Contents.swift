// MARK: - Section 10: AsyncSequence
// MARK: 54. Loop Over Sequence Without AsyncSequence
// - AsyncSequence를 활용해보기에 앞서서 먼저 일반 Sequence를 사용해보자.
// MARK: 55. Loop Over AsyncSequence Using Await

import SwiftUI
import PlaygroundSupport

extension URL {
  func allLines() async -> Lines {
    Lines(url: self)
  }
}

struct Lines: Sequence {
  
  let url: URL
  
  func makeIterator() -> some IteratorProtocol {
    let lines = (try? String(contentsOf: url))?.split(separator: "\n") ?? []
    return LinesIterator(lines: lines)
  }
}

// IteratorProtocol을 conform하기 위해서는 next() 메서드를 구현해야 한다.
struct LinesIterator: IteratorProtocol {
  typealias Element = String
  var lines: [String.SubSequence]
  
  // struct 내부 메서드에 멤버 변경이 있으므로 mutating을 명시한다.
  mutating func next() -> Element? {
    if lines.isEmpty {
      return nil
    }
    return String(lines.removeFirst())
  }
}

let endPointURL = URL(string: "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_month.csv")!

// Task { ... } -> unstructured concurrency
Task {
  // endPointURL.lines는 AsyncLineSequence<URL.AsyncBytes> 타입
  // AsyncSequence를 사용하면 for await - in / for try await - in loop를 사용할 수 있다.
  // Sequence를 사용했을때에는 endPointURL.allLines()에 대한 모든 작업이 끝나고 나서야 순회를 했지만....
  // -> AsyncSequence와 for try await를 사용하면 big pauce할 필요없이 순회를 하며 각 line에 대한 try await 작업을 진행한다.
  for try await line in endPointURL.lines {
    print(line)
  }
}

/*
Task {
  // Sequene에 대한 await 동작을 하고 있다. -> allLines()에서 모든 line들을 처리하고 난 이후에야 loop의 각 line이 출력된다.
  // 아래 라인은 endPointURL.allLines()가 먼저 실행되어 모든 동작이 완료되면 -> 그때서야 iterate 하게 된다.
  for line in await endPointURL.allLines() {
    // endPointURL.allLines() 작업이 끝나기 전까진 아래 라인은 시작도 못한다... allLines() 작업이 매우 크다면 매우 비효율적으로 처리 될 수 있다.
    print("line : \(line)")
  }
}
*/

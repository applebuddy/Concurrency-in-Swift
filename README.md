# Concurrency-in-Swift
Let's learn about Concurrency in Swift with udemy lecture.



## Concurrency

Concurrency란, 동시에 다수의 작업을 진행하는 것.

- serial하게 동작하는 Main thread에서 UI Event, Downloading Images task등을 모두 동작시킨다면?… 멈춤현상이 발생할 수 있음 => 매우 나쁜 user experience를 만들 수 있음

- 작업 특성에 맞게 각기 thread에서 동작하도록 할 수 있음 (ex) downloading images를 main thread 대신 background thread에서 동작)

- - DispatchQueue.global().async { let _ = try? Data(contentOf: imageURL }

- 이후 main thread에서 UI를 업데이트 시킬 수 있음

- - DispatchQueue.main.async { // update the ui }

- 이처럼 GCD를 이용해 상황에 따라 main, background thread에서 비동기로 작업을 수행할 수 있음



## GCD



## Main Queue (serial queue)

- Main thread는 serial queue로 동작한다. 하나씩 순차적으로 작업이 진행 된다. 하나의 작업이 진행되는동안 다른 이벤트는 처리할 수가 없다.



## Global Queue (Concurrent)

- Global Queue는 QoS(Quality of Service)를 설정할 수 있다.
  - User Interactive
    - animation, event handling, updating user interface 등 사용자와 직업 상호작용하는 작업
    - 메인 스레드에서 처리하면 많은 로드가 걸릴 수 있는 작업들은 userInteractive에서 처리해서 바로 동작하는 것처럼 보이게 할 수 있음
  - User Initiated
    - 저장된 문서 열기 등 클릭 시 작업을 수행할 때 처럼 즉각적인 결과가 필요한 작업, 
    - userInteractive보다는 조금 오래걸릴 수 있지만 유저가 이를 인지하고 있음
  - Utility
    - 데이터 다운로드 처럼 보통 progress bar와 함께 길게 실행되는 작업
  - Background
    - 동기화 및 백업 처럼 유저가 직접적으로 인지할 필요성이 적은 작업
  - Default
    - 일반적인 작업
  - Unspecified
    - 명확히 지정된 QoS가 없음



### Creating a global Background Queue

~~~swift
DispatchQueue.global().async {
  // download the image
  
  // refresh the UI (background queue 에서 UI를 업데이트 하면 안됨)
}

DispatchQueue.global().async {
  // download the image
  DispatchQueue.main.async {
    // refresh the UI (UI 관련 작업은 Main thread에서 동작시켜야 함)
  }
}
~~~





### Creating a my Serial Queue

~~~swift
// Serial Queue는 Concurrent Queue와 달리 순차적으로 작업이 진행되므로 작업 순서가 보장된다.
let queue = DispatchQueue(label: "SerialQueue")

queue.async {
  // this task is executed first
}

queue.async {
  // this task is executed second
}
~~~



### Creating a my Concurrent Queue

~~~swift
// Concurrent Queue는 Serial Queue와 달리 작업 순서가 보장되지 않는다.
let queue = DispatchQueue(label: "ConcurrentQueue", attributes: .concurrent)

queue.async {
  // ...
}

queue.async {
  // ...
}

// Tasks will start in the order they are added but they can finish in any order (시작은 순서대로 진행되지만, 작업이 종료되는 순서는 보장되지 않음)
~~~

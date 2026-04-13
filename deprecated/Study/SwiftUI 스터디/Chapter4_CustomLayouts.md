
## 🎯 핵심 개념 - Layout 프로토콜

### Layout 프로토콜이란

Layout 프로토콜은 **서브뷰들의 크기를 결정하고 위치를 배치하는 커스텀 컨테이너**를 만드는 인터페이스다.

HStack, VStack, ZStack 같은 내장 레이아웃으로 해결되지 않는 배치가 필요할 때 사용한다:
- 원형 배치 (RadialLayout)
- 균등 너비 배치 (EqualWidthHStack)
- 비율 기반 배치 (RelativeHStack)
- 핀터레스트 스타일 (MasonryLayout)

---

### 레이아웃 프로세스

SwiftUI의 3단계 레이아웃 시스템에서 Layout 프로토콜이 동작하는 순서:

```
Parent가 크기 제안 (ProposedViewSize)
    ↓
sizeThatFits() → 제안을 받고 원하는 크기 반환
    ↓
Parent가 공간 할당 (CGRect)
    ↓
placeSubviews() → 할당된 공간에 서브뷰 배치
```

구현해야 하는 필수 메서드는 딱 2개다:

```swift
struct MyLayout: Layout {
    // 1. "이만큼 공간을 줄 건데, 얼마나 필요해?"
    func sizeThatFits(
        proposal: ProposedViewSize,    // Parent의 크기 제안
        subviews: Subviews,            // 서브뷰 프록시 컬렉션
        cache: inout Void              // 캐시 (기본: Void)
    ) -> CGSize

    // 2. "이 공간(bounds) 안에 서브뷰들을 배치해"
    func placeSubviews(
        in bounds: CGRect,             // 할당된 공간
        proposal: ProposedViewSize,    // 원래 제안
        subviews: Subviews,
        cache: inout Void
    )
}
```

---

### ProposedViewSize 특수값

| 값 | 의미 | 용도 |
|---|---|---|
| `nil` (각 축별) | "이상적인 크기를 알려줘" | 서브뷰의 자연 크기 측정 |
| `.zero` | "최소 크기를 알려줘" | 최소 공간 확인 |
| `.infinity` | "최대 크기를 알려줘" | 최대 확장 가능 크기 확인 |
| `.unspecified` | 양쪽 모두 nil | 자연 크기 요청의 축약형 |

`replacingUnspecifiedDimensions()`는 nil을 **10pt**로 대체한다. 레이아웃의 `sizeThatFits()`에서 제안된 크기를 안전하게 CGSize로 변환할 때 자주 사용한다:

```swift
func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
    proposal.replacingUnspecifiedDimensions()  // nil → 10pt
}
```

---

## 🔀 AnyLayout - 동적 레이아웃 전환

### AnyLayout vs AnyView

둘 다 타입을 지우는(type-erasing) 래퍼이지만, 동작이 근본적으로 다르다:

| | AnyView | AnyLayout |
|---|---|---|
| 뷰 상태 | ❌ 파괴됨 (새 뷰로 교체) | ✅ 보존됨 (같은 뷰 유지) |
| 애니메이션 | ❌ 전환 효과만 가능 | ✅ 위치 이동 애니메이션 |
| Identity | 뷰 자체가 바뀜 | 뷰는 그대로, 배치만 변경 |

AnyLayout은 **뷰는 동일하게 유지하면서 배치 전략만 교체**하기 때문에, 레이아웃 전환 시 상태가 보존되고 자연스러운 애니메이션이 가능하다.

---

### Layout 접미사 타입들

`AnyLayout`에 넣으려면 `Layout` 프로토콜을 준수하는 타입이 필요하다. SwiftUI는 이를 위해 별도 타입을 제공한다:

| 뷰 타입 | Layout 타입 |
|---------|------------|
| `HStack` | `HStackLayout` |
| `VStack` | `VStackLayout` |
| `ZStack` | `ZStackLayout` |
| `Grid` | `GridLayout` |

이렇게 분리된 이유: `HStack`은 `@ViewBuilder` 클로저를 받는 **제네릭 뷰**다. `Layout` 프로토콜의 `Subviews` 프록시 기반 인터페이스와 호환되지 않기 때문에 별도 타입이 필요하다.

---

### 사용 예시

```swift
let layouts = [AnyLayout(VStackLayout()), AnyLayout(HStackLayout()),
               AnyLayout(ZStackLayout()), AnyLayout(GridLayout())]
@State private var currentLayout = 0

var body: some View {
    layouts[currentLayout] {
        ExampleView(color: .red)    // 상태 보존됨!
        ExampleView(color: .green)
    }

    Button("Change Layout") {
        withAnimation {
            currentLayout = (currentLayout + 1) % layouts.count
        }
    }
}
```

> `GridRow`는 Grid 외부에서 사용하면 `Group`처럼 동작한다. 따라서 AnyLayout으로 Grid ↔ 다른 레이아웃을 전환해도 안전하다.

📁 `ExampleCode/ProSwiftUI/CustomLayouts/AdaptiveLayouts.swift`

---

## 🔧 커스텀 레이아웃 4가지

### 한 줄 알고리즘 요약

| 레이아웃 | 알고리즘 |
|---------|---------|
| **RadialLayout** | 서브뷰를 360°/n 간격으로 원 위에 배치 |
| **EqualWidthHStack** | 가장 넓은 서브뷰의 너비를 모든 서브뷰에 적용 |
| **RelativeHStack** | layoutPriority 비율대로 가용 너비를 분배 |
| **MasonryLayout** | 항상 가장 짧은 열에 다음 뷰를 배치 |

---

### 1. RadialLayout - 원형 배치

서브뷰들을 원 위에 균등하게 배치한다. 핵심은 삼각함수로 각 뷰의 x, y 좌표를 계산하는 것이다.

**핵심 패턴:**

```swift
func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
    let radius = min(bounds.size.width, bounds.size.height) / 2
    let angle = Angle.degrees(360 / Double(subviews.count)).radians

    for (index, subview) in subviews.enumerated() {
        let viewSize = subview.sizeThatFits(.unspecified)

        // -π/2 보정: 12시 방향(위쪽)부터 시작
        let xPos = cos(angle * Double(index) - .pi / 2) * (radius - viewSize.width / 2)
        let yPos = sin(angle * Double(index) - .pi / 2) * (radius - viewSize.height / 2)

        let point = CGPoint(x: bounds.midX + xPos, y: bounds.midY + yPos)
        subview.place(at: point, anchor: .center, proposal: .unspecified)
    }
}
```

**주의할 점:**
- `- .pi / 2` 보정이 없으면 3시 방향(오른쪽)부터 시작한다. 수학 좌표계에서 0°가 오른쪽이기 때문
- `radius - viewSize.width / 2`로 뷰 크기만큼 반지름을 줄여서 뷰가 경계 밖으로 나가지 않도록 한다

📁 `ExampleCode/ProSwiftUI/CustomLayouts/ImplementingARadialLayout.swift`

---

### 2. EqualWidthHStack - 균등 너비

모든 서브뷰를 **가장 넓은 서브뷰의 너비**로 통일한다. 버튼 그룹이나 탭 바처럼 균등한 너비가 필요할 때 유용하다.

**핵심 패턴 - 헬퍼 메서드:**

```swift
// 1. 가장 큰 서브뷰의 크기를 구한다
private func maximumSize(across subviews: Subviews) -> CGSize {
    var maximumSize = CGSize.zero
    for view in subviews {
        let size = view.sizeThatFits(.unspecified)
        if size.width > maximumSize.width { maximumSize.width = size.width }
        if size.height > maximumSize.height { maximumSize.height = size.height }
    }
    return maximumSize
}

// 2. 서브뷰 간 spacing을 시스템에 위임한다
private func spacing(for subviews: Subviews) -> [Double] {
    var spacing = [Double]()
    for index in subviews.indices {
        if index == subviews.count - 1 {
            spacing.append(0)
        } else {
            // 각 서브뷰 쌍 사이의 기본 간격을 시스템에서 가져온다
            let distance = subviews[index].spacing.distance(to: subviews[index + 1].spacing, along: .horizontal)
            spacing.append(distance)
        }
    }
    return spacing
}
```

**배치 로직:**

```swift
func placeSubviews(in bounds: CGRect, ...) {
    let maxSize = maximumSize(across: subviews)
    let spacing = spacing(for: subviews)

    // 모든 서브뷰에 동일한 ProposedViewSize를 제안
    let proposal = ProposedViewSize(width: maxSize.width, height: maxSize.height)
    var x = bounds.minX + maxSize.width / 2

    for index in subviews.indices {
        subviews[index].place(at: CGPoint(x: x, y: bounds.midY), anchor: .center, proposal: proposal)
        x += maxSize.width + spacing[index]
    }
}
```

📁 `ExampleCode/ProSwiftUI/CustomLayouts/ImplementingAnEqualWidthLayout.swift`

---

### 3. RelativeHStack - 비율 기반 너비

각 서브뷰의 `layoutPriority`를 **비율**로 해석하여 가용 너비를 분배한다. HStack의 priority(먼저 공간을 받을 순서)와는 의미가 다르다.

**핵심 패턴 - frames() 헬퍼:**

```swift
func frames(for subviews: Subviews, in totalWidth: Double) -> [CGRect] {
    let totalSpacing = spacing * Double(subviews.count - 1)
    let availableWidth = totalWidth - totalSpacing
    let totalPriorities = subviews.reduce(0) { $0 + $1.priority }

    var viewFrames = [CGRect]()
    var x = 0.0

    for subview in subviews {
        // priority를 비율로 변환하여 너비 계산
        let subviewWidth = availableWidth * subview.priority / totalPriorities
        let proposal = ProposedViewSize(width: subviewWidth, height: nil)
        let size = subview.sizeThatFits(proposal)
        let frame = CGRect(x: x, y: 0, width: size.width, height: size.height)
        viewFrames.append(frame)
        x += size.width + spacing
    }
    return viewFrames
}
```

**사용 예시:**

```swift
RelativeHStack {
    Text("First").frame(maxWidth: .infinity).background(.red)
        .layoutPriority(1)   // 1/6 = 16.7%
    Text("Second").frame(maxWidth: .infinity).background(.green)
        .layoutPriority(2)   // 2/6 = 33.3%
    Text("Third").frame(maxWidth: .infinity).background(.blue)
        .layoutPriority(3)   // 3/6 = 50%
}
```

📁 `ExampleCode/ProSwiftUI/CustomLayouts/ImplementingARelativeWidthLayout.swift`

---

### 4. MasonryLayout - 벽돌쌓기

Pinterest 스타일의 다중 열 레이아웃. 핵심은 **항상 높이가 가장 짧은 열에 다음 뷰를 배치**하는 것이다.

**핵심 패턴 - 최단 열 선택 알고리즘:**

```swift
func frames(for subviews: Subviews, in totalWidth: Double) -> [CGRect] {
    let columnWidth = (totalWidth - spacing * Double(columns - 1)) / Double(columns)
    let proposedSize = ProposedViewSize(width: columnWidth, height: nil)

    var viewFrames = [CGRect]()
    var columnHeights = Array(repeating: 0.0, count: columns)  // 각 열의 현재 높이

    for subview in subviews {
        // 가장 짧은 열을 찾는다
        var selectedColumn = 0
        var selectedHeight = Double.greatestFiniteMagnitude

        for (columnIndex, height) in columnHeights.enumerated() {
            if height < selectedHeight {
                selectedColumn = columnIndex
                selectedHeight = height
            }
        }

        let x = Double(selectedColumn) * (columnWidth + spacing)
        let y = columnHeights[selectedColumn]
        let size = subview.sizeThatFits(proposedSize)
        let frame = CGRect(x: x, y: y, width: size.width, height: size.height)

        columnHeights[selectedColumn] += size.height + spacing
        viewFrames.append(frame)
    }
    return viewFrames
}
```

**`layoutProperties`로 스크롤 방향 힌트:**

```swift
static var layoutProperties: LayoutProperties {
    var properties = LayoutProperties()
    properties.stackOrientation = .vertical  // ScrollView에게 세로 스크롤임을 알림
    return properties
}
```

📁 `ExampleCode/ProSwiftUI/CustomLayouts/ImplementingAMasonryLayout.swift`

---

## 📦 Layout 캐싱

### 왜 필요한가

Layout의 `sizeThatFits()`와 `placeSubviews()`는 **한 번의 레이아웃 패스에서 모두 호출**된다. 둘 다 같은 계산(예: `frames()`)을 수행하면 중복 작업이 발생한다.

---

### 구현 방법

**Step 1: Cache 타입 정의**

```swift
struct MasonryLayout: Layout {
    struct Cache {
        var frames: [CGRect]
        var width = 0.0
    }
}
```

**Step 2: makeCache() 구현**

```swift
func makeCache(subviews: Subviews) -> Cache {
    Cache(frames: [])
}
```

**Step 3: sizeThatFits()에서 캐시 저장**

```swift
func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) -> CGSize {
    let width = proposal.replacingUnspecifiedDimensions().width
    let viewFrames = frames(for: subviews, in: width)

    cache.frames = viewFrames   // 계산 결과 캐시
    cache.width = width

    let height = viewFrames.max { $0.maxY < $1.maxY } ?? .zero
    return CGSize(width: width, height: height.maxY)
}
```

**Step 4: placeSubviews()에서 캐시 재사용**

```swift
func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) {
    // width가 달라졌을 때만 재계산 (기기 회전 대응)
    if cache.width != bounds.width {
        cache.frames = frames(for: subviews, in: bounds.width)
        cache.width = bounds.width
    }

    for index in subviews.indices {
        let frame = cache.frames[index]
        let position = CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY)
        subviews[index].place(at: position, proposal: ProposedViewSize(frame.size))
    }
}
```

---

### 캐시 무효화 시점

| 시점 | 자동/수동 | 설명 |
|------|----------|------|
| 서브뷰 추가/제거 | 자동 | `makeCache()` 다시 호출됨 |
| 레이아웃 프로퍼티 변경 | 자동 | `makeCache()` 다시 호출됨 |
| bounds 크기 변경 (회전 등) | **수동** | `cache.width != bounds.width` 비교 필요 |

> **원칙: Instruments로 프로파일링 후 필요할 때만 캐싱을 추가하라.** 단순한 레이아웃에서는 캐싱 없이도 충분히 빠르다.

📁 `ExampleCode/ProSwiftUI/CustomLayouts/LayoutCaching.swift`

---

## 🎬 Layout 애니메이션

### 기본 동작 (animatableData 없이)

Layout은 기본적으로 **시작/끝 위치만 계산**한다. SwiftUI가 두 위치 사이를 직선 보간(interpolation)하여 애니메이션한다.

```
[시작 위치] --------직선--------> [끝 위치]
```

---

### animatableData로 경로 커스터마이징

Layout이 `Animatable`을 준수하면, **모든 중간값에서 레이아웃을 재계산**할 수 있다.

```swift
struct RadialLayout: Layout {
    var rollOut = 0.0  // 0: 모두 중앙, 1: 원형 배치

    var animatableData: Double {
        get { rollOut }
        set { rollOut = newValue }
    }

    func placeSubviews(in bounds: CGRect, ...) {
        let angle = Angle.degrees(360 / Double(subviews.count)).radians * rollOut
        //                                                               ^^^^^^^^
        //                         rollOut이 0→1로 변하면서 angle이 0→최종값으로 변한다
        // ...
    }
}
```

**animatableData 유무에 따른 차이:**

| | 없을 때 | 있을 때 |
|---|---|---|
| 계산 횟수 | 2회 (시작 + 끝) | 프레임마다 재계산 |
| 이동 경로 | 직선 | 곡선 (원호 등) |
| 성능 | 가벼움 | sizeThatFits + placeSubviews 호출 급증 |
| 용도 | 대부분의 경우 충분 | 경로가 중요한 애니메이션 |

**사용 예시:**

```swift
RadialLayout(rollOut: isExpanded ? 1 : 0) {
    ForEach(0..<count, id: \.self) { _ in
        Circle().frame(width: 32, height: 32)
    }
}

Button("Expand") {
    withAnimation(.easeInOut(duration: 1)) {
        isExpanded.toggle()
    }
}
```

> `rollOut`이 0에서 1로 애니메이션될 때, 각 프레임마다 `placeSubviews()`가 호출되어 서브뷰들이 중앙에서 원형으로 펼쳐지는 애니메이션이 만들어진다.

📁 `ExampleCode/ProSwiftUI/CustomLayouts/CustomizingLayoutAnimations.swift`

---

## 💡 주의사항 & 팁

1. **`sizeThatFits()`와 `placeSubviews()`는 같은 결과를 내야 한다** - sizeThatFits에서 보고한 크기와 placeSubviews에서의 배치가 불일치하면 레이아웃이 깨진다
2. **서브뷰의 `sizeThatFits()`에 적절한 제안을 전달하라** - `.unspecified`(자연 크기), 특정 너비, nil 등 목적에 맞게 선택
3. **`spacing.distance(to:along:)`으로 시스템 기본 간격을 존중하라** - 하드코딩된 spacing보다 시스템 간격이 더 자연스럽다
4. **AnyLayout으로 전환하면 상태가 보존된다** - if/else로 다른 Stack을 사용하면 상태가 파괴됨
5. **캐싱은 프로파일링 후 필요할 때만** - 단순 레이아웃에서는 오버엔지니어링
6. **animatableData는 성능 비용이 크다** - 프레임마다 레이아웃 전체를 재계산하므로 서브뷰가 많으면 주의

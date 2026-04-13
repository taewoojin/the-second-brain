
## 🎯 핵심 개념

### Environment란 무엇인가

Environment는 SwiftUI에서 **부모 뷰가 자식 뷰에게 데이터를 전달하는 시스템**이다.

일반적인 initializer를 통한 데이터 전달과는 다른 특징이 있다:

- **암시적 전달**: 자식 뷰가 명시적으로 파라미터를 받지 않아도 데이터에 접근할 수 있다
- **계층 전파**: 한 번 설정하면 모든 하위 뷰에 자동으로 전파된다
- **선택적 구독**: 자식 뷰는 관심 있는 값만 읽으면 된다. 나머지는 무시해도 된다

---

### 🤔 왜 필요한가

Environment가 없다면 어떤 문제가 생길까?

```swift
// ❌ Environment 없이 테마를 전달한다면
struct App: View {
    let theme = Theme()
    var body: some View {
        RootView(theme: theme)
    }
}

struct RootView: View {
    let theme: Theme
    var body: some View {
        MiddleView(theme: theme)
    }
}

struct MiddleView: View {
    let theme: Theme  // 자신은 안 쓰지만 자식에게 전달하려고 보유
    var body: some View {
        LeafView(theme: theme)
    }
}

struct LeafView: View {
    let theme: Theme  // 실제로 사용하는 뷰
}
```

`MiddleView`는 `theme`을 사용하지 않는다. 그런데도 자식인 `LeafView`에게 전달하기 위해 프로퍼티로 들고 있어야 한다. 

이런 문제를 **Prop Drilling**이라고 한다.

Environment를 사용하면 이 문제가 깔끔하게 해결된다:

```swift
// ✅ Environment 사용
struct App: View {
    var body: some View {
        RootView()
            .environment(\.theme, Theme())  // 한 번만 설정
    }
}

struct LeafView: View {
    @Environment(\.theme) var theme  // 필요한 곳에서 직접 접근
}
```

중간 뷰들은 theme에 대해 전혀 알 필요가 없다. 🎉

---

### ⚙️ 어떻게 동작하는가

**모디파이어는 항상 새 뷰를 만들까?**

SwiftUI에서 모디파이어를 사용하면 대부분 새로운 뷰로 래핑된다. 하지만 **항상 그런 것은 아니다.**

`Text`가 대표적인 예외다:

```swift
Text("Tap")
    .font(.title)
    .foregroundColor(.red)
    .fontWeight(.black)
    .onTapGesture {
        print(type(of: self.body))
    }
```

이 코드를 실행하고 탭하면 타입이 그냥 `Text`로 출력된다. 😮

Text는 모디파이어를 **흡수**한다. 내부적으로 enum 배열에 모디파이어 정보를 저장하기 때문이다. SwiftUI 인터페이스 파일에서 `internal var modifiers`를 검색하면 이 구조를 확인할 수 있다.

이 특성 덕분에 여러 Text를 `+` 연산자로 합칠 때 각각 다른 스타일을 유지할 수 있다:

```swift
Text("Hello ").bold() + Text("World").foregroundColor(.red)
```

---

**SwiftUI 내장 모디파이어와 Environment의 관계**

많은 SwiftUI 모디파이어가 내부적으로 `environment()`를 호출한다. 

SwiftUI 인터페이스 파일에서 `View.font()`의 실제 구현을 보면:

```swift
@inlinable public func font(_ font: SwiftUI.Font?) -> some SwiftUI.View {
    return environment(\.font, font)
}
```

즉, `.font(.title)`은 `.environment(\.font, .title)`의 syntactic sugar이다.

---

**Text.font() vs View.font()**

같은 `font()` 모디파이어인데 왜 다르게 동작할까?

Swift의 오버로드 해석 규칙 때문이다: **"가장 구체적인 타입이 우선한다"**

SwiftUI 인터페이스 파일에 `func font`가 두 번 정의되어 있다:
- `Text.font()` - Text 전용
- `View.font()` - 모든 View 대상

```swift
// Text에 직접 호출하면
Text("Hello").font(.title)  // → Text.font() 호출, 내부 배열에 저장

// VStack 등 다른 뷰에 호출하면
VStack { ... }.font(.title)  // → View.font() 호출, environment 설정
```

`Text`는 `View`보다 구체적이므로, Text에 `font()`를 호출하면 `Text.font()`가 선택된다.

---

**전파 메커니즘**

```swift
VStack {
    Text("A")  // .title 적용됨
    HStack {
        Text("B")  // .title 적용됨
        Text("C").font(.body)  // .body로 덮어씀
    }
}
.font(.title)  // 여기서 설정
```

Environment 값은 뷰 계층을 따라 아래로 흐른다. 하위에서 같은 키를 다시 설정하면 그 지점부터 새 값이 적용된다.


---

## 🔧 커스텀 Environment Key 만들기

### 왜 필요한가

SwiftUI가 기본 제공하는 environment 값(`\.colorScheme`, `\.font` 등) 외에 앱 고유의 데이터를 전파해야 할 때 사용한다.

**사용 예시:**
- 앱 테마 시스템 (커스텀 색상, 간격, 폰트 조합)
- 폼 필드의 필수 여부 표시
- 디버그 모드 플래그
- 사용자 설정값

---

### 동작 원리

커스텀 Environment Key는 두 프로토콜로 구성된다:

1. **EnvironmentKey**: 키 자체를 정의하고 기본값 제공
2. **EnvironmentValues**: 키에 접근하는 인터페이스 제공

EnvironmentValues의 구조를 트리로 표현하면 이렇다:

```
EnvironmentValues (저장소)
├── font: Font?
├── colorScheme: ColorScheme
├── locale: Locale
├── ... (기타 기본 제공 키)
└── required: Bool  ← 커스텀 키 추가
```

---

### 구현 방법

**Step 1: EnvironmentKey 정의**

```swift
struct FormElementIsRequiredKey: EnvironmentKey {
    static var defaultValue = false
}
```

`defaultValue`는 필수다. 이 값 덕분에 environment가 설정되지 않아도 crash가 발생하지 않는다.

**Step 2: EnvironmentValues 확장**

```swift
extension EnvironmentValues {
    var required: Bool {
        get { self[FormElementIsRequiredKey.self] }
        set { self[FormElementIsRequiredKey.self] = newValue }
    }
}
```

실제로 값을 읽고 쓰는 인터페이스를 제공한다. subscript를 통해 내부 저장소에 접근한다.

**Step 3 (선택): View 확장으로 편의 메서드 추가**

```swift
extension View {
    func required(_ makeRequired: Bool = true) -> some View {
        environment(\.required, makeRequired)
    }
}
```

`.environment(\.required, true)` 대신 `.required()`로 사용할 수 있다. SwiftUI 기본 모디파이어와 일관된 API를 제공하게 된다.

---

### 사용 예시

```swift
struct RequirableTextField: View {
    @Environment(\.required) var required  // 값 읽기
    
    let title: String
    @Binding var text: String
    
    var body: some View {
        HStack {
            TextField(title, text: $text)
            
            if required {
                Image(systemName: "asterisk")
                    .imageScale(.small)
                    .foregroundColor(.red)
            }
        }
    }
}
```

개별 적용도 가능하고:

```swift
RequirableTextField(title: "Name", text: $name)
    .required()
```

그룹 적용도 가능하다:

```swift
// Form 전체의 필드가 required 상태가 됨
Form {
    RequirableTextField(title: "First Name", text: $firstName)
    RequirableTextField(title: "Last Name", text: $lastName)
}
.required(isFormRequired)
```

---

### ⚠️ 주의사항

1. **defaultValue는 반드시 제공해야 한다** - `EnvironmentKey` 프로토콜의 필수 요구사항이다
2. **키 이름과 프로퍼티 이름은 다를 수 있다** - `FormElementIsRequiredKey`와 `required`처럼
3. **값 타입에 제한은 없다** - struct, enum, class, 클로저 등 모두 가능하다

---

## ⚔️ @Environment vs @EnvironmentObject

### 근본적인 차이

둘 다 "상위에서 주입한 데이터를 하위에서 읽는다"는 점은 같다. 하지만 설계 목적이 다르다.

| | @Environment | @EnvironmentObject |
|---|---|---|
| **설계 목적** | 설정값, 테마 등 **값 전달** | 공유 상태 **객체 전달** |
| **대상 타입** | Any (주로 값 타입) | ObservableObject (참조 타입) |
| **변경 감지** | 해당 키의 값이 바뀔 때 | 객체의 **모든** @Published가 바뀔 때 |

---

### 📊 비교

| 항목 | @Environment | @EnvironmentObject |
|------|--------------|-------------------|
| 기본값 | ✅ 필수 (EnvironmentKey) | ❌ 없음 |
| 누락 시 | 기본값 사용 | **런타임 crash** 💥 |
| 부분 구독 | ✅ 가능 (키패스) | ❌ 전체 객체 |
| 주입 방법 | `.environment(\.key, value)` | `.environmentObject(object)` |
| 읽기 방법 | `@Environment(\.key)` | `@EnvironmentObject var obj` |

---

### 🔍 차이가 발생하는 이유

**1. 기본값 유무**

```swift
// EnvironmentKey 프로토콜
protocol EnvironmentKey {
    static var defaultValue: Self.Value { get }  // 필수!
}

// ObservableObject 프로토콜
protocol ObservableObject: AnyObject {
    var objectWillChange: ObservableObjectPublisher { get }
    // 기본값 요구사항 없음
}
```

`@EnvironmentObject`에서 crash가 발생하는 이유는 프로토콜 수준에서 기본값을 요구하지 않기 때문이다.

**2. 변경 감지 범위**

이 차이가 성능에 큰 영향을 미친다.

```swift
class ThemeManager: ObservableObject {
    @Published var strokeWidth = 1.0   // 속성 A
    @Published var titleFont = Font.largeTitle  // 속성 B
}

struct CirclesView: View {
    @EnvironmentObject var theme: ThemeManager
    
    var body: some View {
        print("CirclesView.body 호출됨")
        return Circle().stroke(.red, lineWidth: theme.strokeWidth)
    }
}
```

위 코드에서 `titleFont`를 변경해도 `CirclesView.body`가 다시 호출된다. 😱

`CirclesView`는 `strokeWidth`만 사용하지만, `@EnvironmentObject`는 객체 전체를 구독하기 때문이다.

**ObservableObject의 동작 원리:**

```
@Published 프로퍼티 변경
    ↓
objectWillChange.send() 발행
    ↓
이 객체를 구독하는 모든 뷰의 body 재호출
```

SwiftUI 입장에서는 "객체가 변경됨"이라는 신호만 받는다. 어떤 프로퍼티가 변경되었는지는 알 수 없다.

**3. @Environment의 부분 구독**

```swift
struct CirclesView: View {
    @Environment(\.theme.strokeWidth) var strokeWidth  // 특정 값만 구독
    
    var body: some View {
        print("CirclesView.body 호출됨")
        return Circle().stroke(.red, lineWidth: strokeWidth)
    }
}
```

이 경우 `titleFont`가 변경되어도 `CirclesView.body`는 호출되지 않는다. ✅

`@Environment`는 키패스로 특정 값만 구독할 수 있기 때문이다.

---

### 🧭 선택 기준

| 상황 | 권장 | 이유 |
|------|------|------|
| 단순 설정값 (색상, 크기, 플래그) | `@Environment` | 값 전달에 최적화, 기본값 보장 |
| 누락 시 crash 방지가 중요 | `@Environment` | defaultValue 필수 |
| 여러 뷰에서 동일 객체 **수정** | `@EnvironmentObject` | 참조 공유 필요 |
| 특정 프로퍼티만 구독 (성능) | `@Environment` | 키패스로 부분 구독 |
| 객체의 메서드 호출 필요 | `@EnvironmentObject` | 객체 자체가 필요 |

---

### 🎨 하이브리드 패턴: 둘의 장점 결합

객체로 상태를 관리하면서, Environment의 안전성과 부분 구독 기능을 함께 사용하는 방법이 있다.

**Step 1: 테마 프로토콜 정의**

```swift
protocol Theme {
    var strokeWidth: Double { get set }
    var titleFont: Font { get set }
}

struct DefaultTheme: Theme {
    var strokeWidth = 1.0
    var titleFont = Font.largeTitle
}
```

**Step 2: 싱글톤 매니저**

```swift
class ThemeManager: ObservableObject {
    @Published var activeTheme: any Theme = DefaultTheme()
    
    static var shared = ThemeManager()
    private init() { }
}
```

**Step 3: Environment Key 정의**

```swift
struct ThemeKey: EnvironmentKey {
    static var defaultValue: any Theme = ThemeManager.shared.activeTheme
}

extension EnvironmentValues {
    var theme: any Theme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}
```

**Step 4: Environment에 주입하는 모디파이어**

```swift
struct ThemeModifier: ViewModifier {
    @ObservedObject var themeManager = ThemeManager.shared
    
    func body(content: Content) -> some View {
        content.environment(\.theme, themeManager.activeTheme)
    }
}

extension View {
    func themed() -> some View {
        modifier(ThemeModifier())
    }
}
```

**사용 예시:**

```swift
// 루트에서 설정
ContentView()
    .themed()

struct CirclesView: View {
    @Environment(\.theme.strokeWidth) var strokeWidth  // 특정 값만 구독
    
    var body: some View {
        print("CirclesView.body 호출됨")
        return Circle().stroke(.red, lineWidth: strokeWidth)
    }
}
```

이 경우 `titleFont`가 변경되어도 `CirclesView.body`는 호출되지 않는다. ✅

`@Environment`는 키패스로 특정 값만 구독할 수 있기 때문이다.

**이 패턴의 장점:**
- ✅ 기본값 보장 (crash 방지)
- ✅ 부분 구독 가능 (성능)
- ✅ 필요 시 객체 수정 가능

---

## 🔄 transformEnvironment

### 언제 필요한가

`environment()`는 값을 **덮어쓴다**. 하지만 기존 값을 기반으로 **수정**만 하고 싶을 때가 있다.

```swift
struct WelcomeView: View {
    var body: some View {
        VStack {
            Image(systemName: "sun.max")
            Text("Welcome!")
        }
    }
}

// 외부에서 폰트 설정
WelcomeView()
    .font(.largeTitle)
```

만약 이미지의 폰트만 bold로 만들고 싶다면?

```swift
// ❌ 문제: 부모의 .largeTitle을 무시하고 덮어씀
Image(systemName: "sun.max")
    .font(.largeTitle.weight(.black))
```

부모가 `.headline`으로 바뀌면 여기도 수정해야 한다. 유지보수 지옥이다. 😵

---

### 동작 방식

`transformEnvironment`는 현재 environment 값을 `inout` 파라미터로 받아 수정한다:

```swift
// ✅ 해결: 부모 font가 무엇이든 weight만 변경
Image(systemName: "sun.max")
    .transformEnvironment(\.font) { font in
        font = font?.weight(.black)
    }
```

**동작 순서:**

```
부모로부터 \.font 값을 받음 (예: .largeTitle)
    ↓
클로저에서 해당 값을 수정 (.largeTitle.weight(.black))
    ↓
수정된 값이 이 뷰와 하위 뷰에 적용됨
```

---

### 📝 사용 예시

```swift
// 1. 폰트 weight만 변경 (size는 유지)
.transformEnvironment(\.font) { font in
    font = font?.weight(.bold)
}

// 2. 색상 scheme 반전
.transformEnvironment(\.colorScheme) { scheme in
    scheme = scheme == .dark ? .light : .dark
}

// 3. 커스텀 키에도 적용 가능
.transformEnvironment(\.theme) { theme in
    theme.strokeWidth *= 2
}
```

---

### environment vs transformEnvironment

| | environment | transformEnvironment |
|---|---|---|
| 동작 | 값을 **대체** | 기존 값을 **변형** |
| 기존 값 접근 | ❌ | ✅ (inout) |
| 사용 시점 | 완전히 새 값 설정 | 기존 값 기반 조정 |

---

## 💡 주의사항 & 팁

1. **@EnvironmentObject 누락은 런타임 crash** → 가능하면 @Environment 사용
2. **@EnvironmentObject는 모든 @Published 변경에 반응** → 성능 민감한 뷰에서 주의
3. **@Environment 키패스로 부분 구독 가능** → `@Environment(\.theme.strokeWidth)`
4. **transformEnvironment는 기존 값 수정용** → 덮어쓰기가 아닌 조정이 필요할 때
5. **View extension으로 API 정리** → `.required()` 처럼 SwiftUI 네이티브처럼 사용


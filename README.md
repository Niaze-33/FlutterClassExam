# Quizzical — Flutter Trivia & Quiz Application

Quizzical is a multi-platform trivia application built with **Flutter** and the **Provider** state management pattern. It interfaces directly with the public **Open Trivia Database (OpenTDB)** REST API to dynamically fetch real-world trivia questions across dozens of categories, ranging from Science and Computers to History, Art, and Pop Culture.

The application is engineered with a strict separation of concerns, featuring reactive state management, asynchronous data fetching with automatic retry banners, HTML entity decoding, real-time countdown timers, interactive answer verification, persistent user settings, and detailed end-of-session performance analytics.

---

## Table of Contents

1. [Project Overview & Exam Objectives](#1-project-overview--exam-objectives)
2. [Key Features & Capabilities](#2-key-features--capabilities)
3. [System Architecture & Design Patterns](#3-system-architecture--design-patterns)
4. [File & Directory Structure](#4-file--directory-structure)
5. [User Flow & Screen-by-Screen Breakdown](#5-user-flow--screen-by-screen-breakdown)
   - [5.1 Welcome Screen](#51-welcome-screen)
   - [5.2 Category Selection Screen](#52-category-selection-screen)
   - [5.3 Quiz Configuration Screen](#53-quiz-configuration-screen)
   - [5.4 Interactive Quiz Screen](#54-interactive-quiz-screen)
   - [5.5 Results & Performance Screen](#55-results--performance-screen)
6. [State Management Architecture (Provider)](#6-state-management-architecture-provider)
   - [6.1 Quiz Phase Lifecycle & State Machine](#61-quiz-phase-lifecycle--state-machine)
   - [6.2 Category Load Lifecycle](#62-category-load-lifecycle)
7. [API Integration (Open Trivia Database)](#7-api-integration-open-trivia-database)
   - [7.1 Endpoints Specification](#71-endpoints-specification)
   - [7.2 API Response Codes & Error Mapping](#72-api-response-codes--error-mapping)
   - [7.3 Sample API Payloads](#73-sample-api-payloads)
8. [Data Models & HTML Entity Decoding](#8-data-models--html-entity-decoding)
9. [Local Persistence (SharedPreferences)](#9-local-persistence-sharedpreferences)
10. [Design System, Colors & Typography](#10-design-system-colors--typography)
11. [Error Handling & Edge Cases](#11-error-handling--edge-cases)
12. [Prerequisites & Development Environment](#12-prerequisites--development-environment)
13. [Installation & Build Instructions](#13-installation--build-instructions)
14. [Testing & Quality Assurance](#14-testing--quality-assurance)
15. [Configuration & Customization Guide](#15-configuration--customization-guide)
16. [Dependencies Reference](#16-dependencies-reference)
17. [Project Metadata & Author Information](#17-project-metadata--author-information)

---

## 1. Project Overview & Exam Objectives

This application was developed as a comprehensive Flutter project exam submission demonstrating mastery of modern Flutter development practices. 

### Key Technical Competencies Demonstrated:
- **Clean Architecture & Separation of Concerns**: Complete isolation of Presentation (Screens/Widgets), Domain/State (Providers), Data Models, and Remote Services (REST API).
- **Asynchronous Programming**: Effective use of Dart `async`/`await`, `Future`, Streams, and periodic timers (`Timer.periodic`).
- **State Management**: Scalable reactive state management using `MultiProvider`, `ChangeNotifier`, `context.watch`, `context.read`, and listener callbacks.
- **RESTful API Integration**: Direct communication with external endpoints using `package:http`, handling HTTP status codes, parsing complex JSON structures, and gracefully handling API-level error responses.
- **Data Sanitization**: Handling character encoding quirks in raw API responses using custom regex-based HTML entity decoders (converting entities like `&quot;`, `&#039;`, and hexadecimal encodings to readable UTF-8 text).
- **Persistent Storage**: Utilizing `shared_preferences` to persist user configuration between sessions.
- **UX/UI Polish**: Smooth transitions, loading skeletons, error banners with retry triggers, countdown timers with visual urgency warnings, and exit confirmation dialogs.

---

## 2. Key Features & Capabilities

- **Live Category Discovery**:
  - Automatically queries the OpenTDB categories endpoint on startup.
  - Caches categories in memory to minimize network bandwidth and prevent rate limiting.
  - Maps 24+ trivia categories into distinct pastel cards with category-specific Material icons (e.g., Books, Science, Sports, Mythology, Video Games, Geography).
- **Tailored Quiz Configuration**:
  - **Question Count Slider**: Choose anywhere between 1 and 50 questions (default: 10).
  - **Difficulty Filter**: Select between Any, Easy, Medium, or Hard.
  - **Question Type**: Choose between 4-Option Multiple Choice (`multiple`) or True/False Boolean questions (`boolean`).
- **Real-Time 30-Second Question Timer**:
  - Real-time countdown timer tracking each individual question.
  - Visual color shift to red when remaining time drops to 5 seconds or less.
  - Automatic timeout handler: when time expires, the correct answer is revealed, user input is locked, and the app auto-advances.
- **Instant Visual Feedback & Shuffled Answers**:
  - Options are dynamically randomized upon fetching so the correct answer never appears in a fixed position.
  - Instant selection feedback:
    - **Correct selection**: Highlighted in soft mint green (`#B2DFDB`) with a checkmark.
    - **Incorrect selection**: Highlighted in coral red (`#FFA1A1`) with an error indicator, while simultaneously highlighting the correct answer in green.
    - **Timeout state**: Highlights the correct answer in green to provide educational feedback.
- **Performance Evaluation & Analytics**:
  - Live score counter updated in real-time.
  - Linear progress bar visualizing completion percentage through the quiz.
  - Session stopwatch tracking total elapsed time from first question to completion.
  - Accuracy calculation (`(score / total) * 100`).
  - Dynamic result states:
    - High Score ($\ge 70\%$): Celebration theme with soft green badge and congratulatory feedback.
    - Needs Practice ($< 70\%$): Motivational workout theme with orange badge and encouraging message.
- **Exit Protection**:
  - Mid-quiz confirmation dialog alerting users that in-progress session data will be cleared if they exit early.
- **Preference Persistence**:
  - Last-used settings (question amount, difficulty, question type, category) are automatically persisted and restored on future launches.

---

## 3. System Architecture & Design Patterns

The application adopts a **Layered MVVM Architecture** combined with the **Provider** pattern:

```
+------------------------------------------------------------------+
|                        PRESENTATION LAYER                        |
|                                                                  |
|   +-----------------------+            +---------------------+   |
|   |        Screens        |            |   Custom Widgets    |   |
|   |  - WelcomeScreen      |            |  - RetryBanner      |   |
|   |  - CategoryScreen     | <--------> |  - SkeletonGrid     |   |
|   |  - QuizConfigScreen   |            |  - LoadingSkeleton  |   |
|   |  - QuizScreen         |            |  - AnswerTile       |   |
|   |  - ResultsScreen      |            +---------------------+   |
+------------------------------------------------------------------+
                                 |
                          (State Observers)
                                 v
+------------------------------------------------------------------+
|                    STATE MANAGEMENT (PROVIDERS)                  |
|                                                                  |
|   +--------------------------+      +------------------------+   |
|   |     CategoryProvider     |      |      QuizProvider      |   |
|   |  - Manages categories    |      |  - Active session      |   |
|   |  - In-memory cache       |      |  - 30s Countdown timer |   |
|   |  - Load state & errors   |      |  - Scoring & progress  |   |
|   +--------------------------+      +------------------------+   |
+------------------------------------------------------------------+
                                 |
                            (Delegates)
                                 v
+------------------------------------------------------------------+
|                       DATA / SERVICE LAYER                       |
|                                                                  |
|   +--------------------------+      +------------------------+   |
|   |      OpenTdbService      |      |   SharedPreferences    |   |
|   |  - REST API client       |      |  - Category, amount    |   |
|   |  - Error code handling   |      |  - Difficulty & type   |   |
|   +--------------------------+      +------------------------+   |
|                                 |                                |
|   +----------------------------------------------------------+   |
|   |                      Data Models                         |   |
|   |  - TriviaCategory (id, name)                             |   |
|   |  - TriviaQuestion (question, answers, HTML decoding)     |   |
+------------------------------------------------------------------+
```

### Key Architectural Strengths:
1. **Loose Coupling**: Screens never invoke `http.get` directly. All network interaction is mediated through `OpenTdbService` and exposed to the UI via `CategoryProvider` and `QuizProvider`.
2. **Testability**: `OpenTdbService` accepts an optional `http.Client`, enabling painless mocking and dependency injection during unit and widget testing.
3. **Resilience**: Network failures do not crash the app. The provider catches exceptions, sets dedicated error flags, and the UI presents inline retry banners.

---

## 4. File & Directory Structure

```
FlutterClassExam/
│
├── lib/
│   ├── main.dart                       # App entry point, MultiProvider registration
│   ├── app.dart                        # MaterialApp root, theme binding & initial route
│   │
│   ├── core/                           # Application core configurations
│   │   ├── quiz_constants.dart         # Constants (student name, timers, keys)
│   │   └── quiz_theme.dart             # Palette tokens, button styles, Google Fonts
│   │
│   ├── models/                         # Domain entity models
│   │   ├── trivia_category.dart        # Trivia category data class & JSON deserializer
│   │   └── trivia_question.dart        # Question entity with HTML entity decoding
│   │
│   ├── services/                       # External service clients
│   │   └── opentdb_service.dart        # Open Trivia Database API client & exceptions
│   │
│   ├── providers/                      # Business logic & reactive state
│   │   ├── category_provider.dart      # Category fetching & cache provider
│   │   └── quiz_provider.dart          # Quiz session, timer, and score provider
│   │
│   └── ui/                             # User interface layer
│       ├── screens/
│       │   ├── welcome_screen.dart             # Splash & welcome screen
│       │   ├── category_selection_screen.dart  # Grid view of all trivia categories
│       │   ├── quiz_config_screen.dart         # Sliders, dropdowns & quiz start
│       │   ├── quiz_screen.dart                # Main interactive question runner
│       │   └── results_screen.dart             # Score card & analytics screen
│       └── widgets/
│           └── quiz_widgets.dart               # Skeletons, loaders, and retry banners
│
├── pubspec.yaml                        # Project metadata, dependencies & assets
└── README.md                           # Comprehensive documentation
```

---

## 5. User Flow & Screen-by-Screen Breakdown

```
+------------------+         +----------------------------+
|  Welcome Screen  | ------> |  Category Selection Screen |
+------------------+         +----------------------------+
                                           |
                                           v
+------------------+         +----------------------------+
|  Results Screen  | <------ |     Active Quiz Screen     |
+------------------+         +----------------------------+
         |                                 ^
         |                                 |
         +------- (Play Again) ------------+
```

---

### 5.1 Welcome Screen

**File**: `lib/ui/screens/welcome_screen.dart`  
**Purpose**: Serves as the landing hub of the application, introducing the app identity and the author/student credentials.

```
+----------------------------------------------------+
|                                                    |
|                    [ ? ]                           |
|               (o)  ( O )  (?)                      |
|                  Welcome Art                       |
|                                                    |
|                    Quizzical                       |
|                   Imam Hosen                       |
|                                                    |
|                                                    |
|              [   START QUIZ   ]                    |
|                                                    |
+----------------------------------------------------+
```

- **Visual Art Component (`_WelcomeArt`)**: A layered composition using soft circular blobs, colorful accent icons, and an expressive avatar circle.
- **Branding**:
  - Title: **Quizzical** styled with `GoogleFonts.poppins` (font size 36–42, bold).
  - Subtitle: **Imam Hosen** (sourced dynamically from `kStudentName` in `quiz_constants.dart`).
- **Responsive Layout**: Uses `MediaQuery.sizeOf(context)` to switch padding and typography dynamically between compact mobile screens and wide tablet/desktop viewports.
- **Action**: A prominent full-width elevated button triggering navigation to the Category Selection Screen.

---

### 5.2 Category Selection Screen

**File**: `lib/ui/screens/category_selection_screen.dart`  
**Purpose**: Displays all available trivia topics fetched from the OpenTDB API in an interactive pastel grid.

```
+----------------------------------------------------+
|  Quizzical                                         |
|  choose a category to focus on:                    |
|----------------------------------------------------|
|  +--------------------+    +--------------------+  |
|  |     [Icon: Book]   |    |     [Icon: Film]   |  |
|  |  General Knowledge |    |   Film & Cinema    |  |
|  +--------------------+    +--------------------+  |
|  +--------------------+    +--------------------+  |
|  |   [Icon: Computer] |    |    [Icon: Sports]  |  |
|  |   Science & Tech   |    |       Sports       |  |
|  +--------------------+    +--------------------+  |
|  +--------------------+    +--------------------+  |
|  |    [Icon: History] |    |  [Icon: Mythology] |  |
|  |       History      |    |      Mythology     |  |
|  +--------------------+    +--------------------+  |
+----------------------------------------------------+
```

- **Automatic Fetching**: Dispatches `CategoryProvider.loadCategories()` in `initState` via `addPostFrameCallback`.
- **In-Memory Caching**: If categories were already loaded previously in the session, they are rendered immediately without triggering a new network request.
- **Dynamic Icons (`_iconFor`)**: Analyzes the category title string and assigns an intuitive icon:
  - Books / Literature $\rightarrow$ `Icons.menu_book`
  - Movies / Film $\rightarrow$ `Icons.movie`
  - Music $\rightarrow$ `Icons.music_note`
  - Television $\rightarrow$ `Icons.tv`
  - Video Games $\rightarrow$ `Icons.sports_esports`
  - Science & Nature $\rightarrow$ `Icons.science`
  - Computers $\rightarrow$ `Icons.computer`
  - Mathematics $\rightarrow$ `Icons.calculate`
  - Sports $\rightarrow$ `Icons.sports_soccer`
  - Geography $\rightarrow$ `Icons.public`
  - History $\rightarrow$ `Icons.history_edu`
  - Art $\rightarrow$ `Icons.palette`
- **Pastel Color Rotation**: Cards cycle through 12 harmonious pastel shades (`kCategoryPastels`).
- **Skeleton Shimmer**: When loading, renders `CategorySkeletonGrid` containing placeholder card containers.
- **Retry Mechanism**: If network failure occurs, renders a `RetryBanner` with a one-click retry button.

---

### 5.3 Quiz Configuration Screen

**File**: `lib/ui/screens/quiz_config_screen.dart`  
**Purpose**: Gives the user granular control over question count, difficulty, and question type for the chosen category.

```
+----------------------------------------------------+
|  <- Configuration                                  |
|----------------------------------------------------|
|                                                    |
|                    Quizzical                       |
|                  Configuration                     |
|               Science: Computers                   |
|                                                    |
|  Amount                                         10 |
|  [===========o-----------------------------------] |
|                                                    |
|  Difficulty                                        |
|  [ Any / Easy / Medium / Hard                    v]|
|                                                    |
|  Type                                              |
|  [ Multiple Choice / True or False               v]|
|                                                    |
|                                                    |
|              [      START     ]                    |
+----------------------------------------------------+
```

- **Category Header**: Displays the name of the category selected from the previous screen.
- **Amount Slider (`_AmountSlider`)**:
  - Range: `1` to `50` questions.
  - Granularity: Step intervals of 1.
  - Active tracker with real-time numeric counter.
- **Difficulty Dropdown (`_LabeledDropdown`)**:
  - Options: `Any` (all difficulties), `Easy`, `Medium`, `Hard`.
- **Question Format Dropdown**:
  - Options: `Multiple Choice` (4 answers) or `True / False` (Boolean).
- **Persistent Memory**: Any adjusted setting is automatically saved to device disk using `SharedPreferences`.
- **Validation & Loading**: Displays `QuizLoadingSkeleton` while the API request is dispatched to OpenTDB. If the API reports insufficient questions for that specific configuration, an informative error message is displayed.

---

### 5.4 Interactive Quiz Screen

**File**: `lib/ui/screens/quiz_screen.dart`  
**Purpose**: The central quiz engine displaying questions, countdown timers, randomized options, and immediate visual feedback.

```
+----------------------------------------------------+
|                    3 / 10               [ EXIT ]   |
|  [==================-----------------------------] |
|  Score: 2                                   24s    |
|----------------------------------------------------|
|  +-----------------------------------------------+ |
|  | What does "CPU" stand for in computing?       | |
|  +-----------------------------------------------+ |
|                                                    |
|  +-----------------------------------------------+ |
|  | Central Processing Unit             [ ( * ) ] | |
|  +-----------------------------------------------+ |
|  +-----------------------------------------------+ |
|  | Computer Personal Unit              [ (   ) ] | |
|  +-----------------------------------------------+ |
|  +-----------------------------------------------+ |
|  | Central Program Utility             [ (   ) ] | |
|  +-----------------------------------------------+ |
|  +-----------------------------------------------+ |
|  | Core Processor Unit                 [ (   ) ] | |
|  +-----------------------------------------------+ |
|                                                    |
|              [   NEXT QUESTION   ]                 |
+----------------------------------------------------+
```

- **Live Progress & Meta Header**:
  - Question Counter: Current index vs total count (e.g., `4/10`).
  - Progress Bar: `LinearProgressIndicator` tracking fractional progress (`(index + 1) / total`).
  - Live Score: Tracks cumulative points awarded.
  - Timer: Shows remaining seconds. If $\le 5$ seconds, transitions from brand teal to alerting red with an hourglass/timer icon.
- **Exit Protection (`_exit`)**:
  - Tapping "EXIT" prompts an `AlertDialog`: *"Your progress for this session will be lost."*
  - Confirming resets the quiz session and cleanly pops back to the category selection root.
- **Question Card**: Card container with subtle drop shadow, displaying the decoded UTF-8 question text.
- **Answer Selection Mechanics**:
  - Tapping an option halts the countdown timer immediately.
  - **Correct Answer**: Tile turns soft mint teal (`#B2DFDB`) with a green checkmark icon.
  - **Incorrect Answer**: Tile turns coral red (`#FFA1A1`) with an error cancel icon, and the true correct answer is simultaneously revealed in green.
  - Once answered, all option tiles lock to prevent multi-tapping.
  - A bottom button appears: `"Next"` (or `"See Results"` if on the final question).
- **Timeout Handling**:
  - If the timer hits zero before an option is tapped, the timeout handler locks input, marks `timedOut = true`, reveals the correct answer in green, and automatically transitions after an 800ms preview.

---

### 5.5 Results & Performance Screen

**File**: `lib/ui/screens/results_screen.dart`  
**Purpose**: Summarizes user achievements, accuracy metrics, time taken, and provides an immediate loop to restart.

```
+----------------------------------------------------+
|                                                    |
|                    [ * * * ]                       |
|               ( Celebration Icon )                 |
|                                                    |
|                  Congratulation                    |
|                                                    |
|                    +-------+                       |
|                    |  90%  |                       |
|                    +-------+                       |
|                                                    |
|               You scored 9/10!                     |
|              Total time: 1m 24s                    |
|                                                    |
|   You've got a great foundation. Ready to try a    |
|               different category?                  |
|                                                    |
|                                                    |
|              [   PLAY AGAIN   ]                    |
+----------------------------------------------------+
```

- **Accuracy Computation**: `accuracyPercent = (score / totalQuestions) * 100`.
- **Dynamic Conditional Feedback**:
  - **Score $\ge 70\%$ (Passing / High Score)**:
    - Celebration icon: `Icons.celebration` in warm pink.
    - Title: `"Congratulation"`.
    - Badge: Soft green container (`#C8E6C9`).
    - Body message: *"You've got a great foundation. Ready to try a different category?"*
  - **Score $< 70\%$ (Needs Improvement)**:
    - Encouragement icon: `Icons.fitness_center` in vibrant orange.
    - Title: `"Keep Trying!"`.
    - Badge: Deep energetic orange (`#FF7043`).
    - Body message: *"Don't give up! Practice makes perfect. Try again to improve your score."*
- **Elapsed Duration Tracking**:
  - Displays total minutes and seconds spent in the quiz session formatted via `_formatDuration` (e.g., `2m 14s` or `45s`).
- **Play Again Action**:
  - Calls `QuizProvider.resetSession()`.
  - Clears question lists, timer instances, and score tallies while keeping user configuration preferences intact.
  - Clears navigation history with `pushAndRemoveUntil` back to the Category Selection Screen.

---

## 6. State Management Architecture (Provider)

State is managed reactively via the **Provider** package (`provider: ^6.1.5+1`). Two core ChangeNotifier providers power the application:

```
MultiProvider
├── CategoryProvider (OpenTdbService)
└── QuizProvider (OpenTdbService)
```

---

### 6.1 Quiz Phase Lifecycle & State Machine

The active quiz execution follows a finite state machine defined by the `QuizPhase` enum:

```
           +----------+
           |   IDLE   |
           +----------+
                 |
             startQuiz()
                 |
                 v
           +----------+   (Network / Parameter Error)
           | LOADING  | -----------------------------> +----------+
           +----------+                                |  ERROR   |
                 |                                     +----------+
          (Questions Ready)                                  |
                 |                                      (Retry Start)
                 v                                           |
    +----->+----------+ <------------------------------------+
    |      | PLAYING  | <-------------+
    |      +----------+               |
    |            |                    |
    |      (Select Answer             |
    |        or Timeout)         nextQuestion()
    |            |                    |
    |            v                    |
    |      +----------+               |
    |      | ANSWERED | --------------+
    |      +----------+ (Not Last Question)
    |            |
    |       (Is Last Question)
    |            |
    |            v
    |      +----------+
    |      | FINISHED |
    |      +----------+
    |            |
    +---- resetSession()
```

#### Lifecycle State Descriptions:
1. **`QuizPhase.idle`**: Default quiescent state. No active quiz is in memory.
2. **`QuizPhase.loading`**: Questions are currently being retrieved and parsed from the OpenTDB API. A loading skeleton is rendered.
3. **`QuizPhase.playing`**: The question is active. The 30-second countdown timer ticks every 1000ms. Answer tiles are clickable.
4. **`QuizPhase.answered`**: The user selected an answer OR the 30-second timer reached zero. The timer is halted, the correct answer is revealed, and the `"Next"` button appears.
5. **`QuizPhase.finished`**: All questions have been answered. Total elapsed time is captured. The UI navigates to `ResultsScreen`.
6. **`QuizPhase.error`**: The API returned an error code or a network exception was caught. A retry banner is presented.

---

### 6.2 Category Load Lifecycle

`CategoryProvider` coordinates category discovery using `CategoryLoadState`:

```
+------------+      loadCategories()      +------------+
|  INITIAL   | -------------------------> |  LOADING   |
+------------+                            +------------+
                                                |
                               +----------------+---------------+
                               |                                |
                        (HTTP 200 & Valid)             (Exception / Socket)
                               |                                |
                               v                                v
                        +------------+                   +------------+
                        |   LOADED   |                   |   ERROR    |
                        +------------+                   +------------+
                               |                                |
                        (In-Memory Cache)                (force: true)
                               |                                |
                               +--------------------------------+
```

- When `loadCategories()` is invoked with `force = false`, it returns immediately if `_categories.isNotEmpty`, sparing unnecessary network round-trips.
- When `force = true` is passed (e.g., from the Retry button), it bypasses the cache and queries the API fresh.

---

## 7. API Integration (Open Trivia Database)

The application consumes endpoints hosted by **[Open Trivia Database](https://opentdb.com/)**.

### 7.1 Endpoints Specification

#### 1. Category Index Endpoint
- **URL**: `https://opentdb.com/api_category.php`
- **Method**: `GET`
- **Response Structure**:
```json
{
  "trivia_categories": [
    { "id": 9, "name": "General Knowledge" },
    { "id": 10, "name": "Entertainment: Books" },
    { "id": 11, "name": "Entertainment: Film" },
    { "id": 18, "name": "Science: Computers" }
  ]
}
```

#### 2. Question Generation Endpoint
- **URL**: `https://opentdb.com/api.php`
- **Method**: `GET`
- **Query Parameters**:
  - `amount` (required, integer): Number of questions (1–50).
  - `category` (required, integer): Category ID from the category list.
  - `difficulty` (optional, string): Filter by `easy`, `medium`, or `hard`. Omitted if `'any'`.
  - `type` (optional, string): Filter by `multiple` (Multiple Choice) or `boolean` (True/False). Omitted if `'any'`.

---

### 7.2 API Response Codes & Error Mapping

OpenTDB embeds a `response_code` integer in every JSON payload. The application handles each code explicitly:

| Response Code | OpenTDB Status | Application Handling & User Message |
|---|---|---|
| **0** | Success | Questions returned successfully; initializes quiz session. |
| **1** | No Results | *"Not enough questions for this config. Try fewer questions or different filters."* |
| **2** | Invalid Parameter | *"Invalid quiz parameters. Please adjust and try again."* |
| **3** | Token Not Found | Handled as general service exception prompting retry. |
| **4** | Token Empty | Handled as general service exception prompting retry. |
| **Other** | Unknown Error | *"Could not load questions (code X). Please retry."* |

---

### 7.3 Sample API Payloads

#### Sample Multiple Choice Question (Raw Response):
```json
{
  "response_code": 0,
  "results": [
    {
      "type": "multiple",
      "difficulty": "easy",
      "category": "Science: Computers",
      "question": "What does the &quot;MP&quot; stand for in MP3?",
      "correct_answer": "Moving Picture",
      "incorrect_answers": [
        "Music Player",
        "Multi Pass",
        "Micro Process"
      ]
    }
  ]
}
```

#### Sample Boolean Question:
```json
{
  "response_code": 0,
  "results": [
    {
      "type": "boolean",
      "difficulty": "medium",
      "category": "Science: Computers",
      "question": "The HTML5 standard was published in 2014.",
      "correct_answer": "True",
      "incorrect_answers": [
        "False"
      ]
    }
  ]
}
```

---

## 8. Data Models & HTML Entity Decoding

### HTML Entity Decoding Engine

Raw text from OpenTDB contains HTML encoded characters that distort UI readability if rendered unprocessed. The app implements a custom decoding algorithm in `lib/models/trivia_question.dart`:

```dart
String decodeHtmlEntities(String value) {
  return value
      .replaceAll('&quot;', '"')
      .replaceAll('&#039;', "'")
      .replaceAll('&apos;', "'")
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&nbsp;', ' ')
      .replaceAllMapped(RegExp(r'&#(\d+);'), (m) {
        return String.fromCharCode(int.parse(m.group(1)!));
      })
      .replaceAllMapped(RegExp(r'&#x([0-9a-fA-F]+);'), (m) {
        return String.fromCharCode(int.parse(m.group(1)!, radix: 16));
      });
}
```

#### Decoding Verification Examples:
- `&quot;Hello World&quot;` $\rightarrow$ `"Hello World"`
- `Don&#039;t Stop` $\rightarrow$ `Don't Stop`
- `Ben &amp; Jerry` $\rightarrow$ `Ben & Jerry`
- `&#65;&#66;&#67;` (Decimal) $\rightarrow$ `ABC`
- `&#x2665;` (Hexadecimal) $\rightarrow$ `♥`

---

## 9. Local Persistence (SharedPreferences)

User configurations are preserved between application restarts using the `shared_preferences` package.

### Storage Keys & Defaults

| Key Constant | Storage Key String | Data Type | Default Value | Description |
|---|---|---|---|---|
| `kPrefsAmount` | `'quiz_amount'` | `int` | `10` | Preferred question batch size (1–50) |
| `kPrefsDifficulty`| `'quiz_difficulty'` | `String` | `'any'` | Last selected difficulty |
| `kPrefsType` | `'quiz_type'` | `String` | `'multiple'` | Format preference (`multiple` vs `boolean`) |
| `kPrefsCategoryId` | `'quiz_category_id'`| `int` | `null` | Most recently played category ID |
| `kPrefsCategoryName`| `'quiz_category_name'`| `String`| `''` | Most recently played category name |

---

## 10. Design System, Colors & Typography

The visual identity of Quizzical adheres to **Material 3** guidelines, balancing accessibility, readability, and modern aesthetics.

### Color Tokens

```
Primary Teal:       #00695C  (AppBar, primary buttons, active slider)
Primary Teal Dark:  #004D40  (Next button, confirmed answers)
Canvas Background:  #F2F2F2  (Quiz screen background, input fill)
Charcoal Text:      #37474F  (Headers, bold copy, labels)
Correct Mint:       #B2DFDB  (Correct answer tile highlight)
Incorrect Coral:    #FFA1A1  (Wrong answer tile highlight)
Good Score Green:   #C8E6C9  (Badge highlight for >= 70%)
Warning Orange:     #FF7043  (Badge highlight for < 70%)
```

### Pastel Category Palette
Category tiles rotate across 12 hand-picked pastel hues:
1. Sky Blue (`#B3E5FC`)
2. Soft Mint (`#C8E6C9`)
3. Butter Yellow (`#FFF9C4`)
4. Lilac (`#E1BEE7`)
5. Blush Pink (`#F8BBD0`)
6. Warm Peach (`#FFE0B2`)
7. Cyan Tint (`#B2EBF2`)
8. Lime Frost (`#DCEDC8`)
9. Pale Orange (`#FFCCBC`)
10. Lavender (`#D1C4E9`)
11. Soft Amber (`#FFECB3`)
12. Blue Grey Tint (`#CFD8DC`)

### Typography
- **GoogleFonts.poppins**: Employed across titles, buttons, timer digits, questions, and option labels for geometric clarity.
- **GoogleFonts.lora**: Utilized for italic secondary headings (e.g., *"choose a category to focus on:"*).

---

## 11. Error Handling & Edge Cases

| Scenario | Possible Cause | Application Defense Mechanism |
|---|---|---|
| **No Internet Connection** | Airplane mode, socket disconnection | Catches `SocketException`/`http.ClientException`, enters `error` phase, displays `RetryBanner` with manual retry. |
| **API Rate Limiting** | Spamming requests to OpenTDB | Catches HTTP non-200 responses, surfaces clean error toast/banner without crashing. |
| **Zero Questions Available** | Strict filters (e.g., 50 Hard True/False questions in Art) | Translates OpenTDB code 1 into *"Not enough questions for this config. Try fewer questions or different filters."* |
| **Timer Runs Out** | User inactivity or difficult question | Automatically triggers `_onTimeout()`, marks `timedOut = true`, reveals the correct answer in green, and advances smoothly. |
| **Accidental Mid-Quiz Back Tap** | User taps back button or EXIT | Intercepted by confirmation dialog warning that session data will be cleared. |
| **Rapid Double Taps on Answers** | Fast tapping on multiple options | Input is locked the instant the first option is registered (`_phase != QuizPhase.playing`). |

---

## 12. Prerequisites & Development Environment

Before executing the project, ensure your workstation meets the following specifications:

- **Flutter SDK**: Version `3.11.1` or higher
- **Dart SDK**: Version `3.11.1` or higher
- **IDE**: Android Studio, VS Code, or Antigravity IDE with Flutter & Dart extensions
- **Target Platforms Supported**:
  - Android (API level 21+)
  - iOS (iOS 12.0+)
  - Web (Chrome, Edge, Safari, Firefox)
  - macOS (macOS 10.14+)
  - Linux Desktop
  - Windows Desktop

---

## 13. Installation & Build Instructions

### 1. Clone the Codebase
```bash
git clone https://github.com/Niaze-33/FlutterClassExam.git
cd FlutterClassExam
```

### 2. Fetch Packages
```bash
flutter pub get
```

### 3. Verify Environment Integrity
```bash
flutter doctor
```

### 4. Run Locally

#### Run on Connected Device / Default Emulator:
```bash
flutter run
```

#### Run on Web (Chrome):
```bash
flutter run -d chrome
```

#### Run on macOS Desktop:
```bash
flutter run -d macos
```

#### Run on iOS Simulator:
```bash
flutter run -d ios
```

#### Run on Android Emulator:
```bash
flutter run -d android
```

### 5. Build for Production

#### Build Android APK:
```bash
flutter build apk --release
```

#### Build Android App Bundle (AAB):
```bash
flutter build appbundle --release
```

#### Build Web Release:
```bash
flutter build web --release
```

#### Build macOS Application:
```bash
flutter build macos --release
```

---

## 14. Testing & Quality Assurance

The codebase includes automated test suites and helper mocks.

### Executing Tests
```bash
flutter test
```

### Static Analysis & Lint Checks
```bash
flutter analyze
```

Code formatting adheres to Flutter standard lints (`package:flutter_lints`).

---

## 15. Configuration & Customization Guide

All primary metadata, timers, and question thresholds can be configured in a single file: `lib/core/quiz_constants.dart`.

```dart
// Student / Author branding displayed on Welcome Screen
const String kStudentName = 'Imam Hosen';

// Default, minimum, and maximum question limits
const int kDefaultQuestionAmount = 10;
const int kMinQuestionAmount = 1;
const int kMaxQuestionAmount = 50;

// Countdown timer duration in seconds for each question
const int kQuestionTimerSeconds = 30;
```

### Customization Recipes:
1. **Change Author Name**: Update `kStudentName` to your own name; it will automatically reflect on the welcome screen.
2. **Speed Run Mode**: Set `kQuestionTimerSeconds = 15` for a fast-paced trivia challenge.
3. **Change Default Question Batch**: Modify `kDefaultQuestionAmount = 20` to default to 20 questions.

---

## 16. Dependencies Reference

The application relies on verified packages defined in `pubspec.yaml`:

| Dependency | Version Constraint | Architecture Purpose |
|---|---|---|
| `flutter` | SDK | Core Flutter framework |
| `provider` | `^6.1.5+1` | Reactive state management (`CategoryProvider`, `QuizProvider`) |
| `http` | `^1.6.0` | Asynchronous HTTP client for Open Trivia Database |
| `shared_preferences` | `^2.5.3` | Persistent key-value local storage |
| `google_fonts` | `^6.2.1` | Typography (`Poppins` and `Lora`) |
| `cached_network_image`| `^3.4.1` | High-performance image caching utilities |
| `iconsax` | `^0.0.8` | Curated icon library |
| `cupertino_icons` | `^1.0.8` | iOS Cupertino style icons |
| `intl` | `^0.20.3` | Number and date formatting tools |
| `flutter_lints` (dev) | `^5.0.0` | Recommended code style rules |

---

## 17. Project Metadata & Author Information

- **Project Title**: Quizzical — Flutter Trivia Application
- **Context**: Flutter Class Exam / Project Submission
- **Student Name**: Imam Hosen
- **Repository**: [https://github.com/Niaze-33/FlutterClassExam](https://github.com/Niaze-33/FlutterClassExam)
- **Data Provider**: [Open Trivia Database](https://opentdb.com/)
- **License**: MIT License

---

End of Documentation.

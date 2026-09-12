# Travel Planner Hub (CodeNection 2026 Preliminary Round Project)

A continuous, video-native group travel planning mobile application that bridges inspiration and execution by connecting vertical video discovery directly with contextual AI booking, group communication, and a secure document & expense ledger.

---

## 2. Ideation & Process

### 2.1 Ideas We Considered

| Idea | Why it was dropped / kept |
| :--- | :--- |
| **Travel FYP Discovery Feed (Chosen)** | **Kept.** Replaces static search bars with engaging vertical video discovery, allowing users to scroll and explore travel destinations naturally. |
| **Contextual AI Booking Assistant (Chosen)** | **Kept.** Solves discovery friction by instantly extracting travel time, arrival estimates, and booking options directly from social videos. |
| **Unified Document & Expense Ledger (Chosen)** | **Kept.** Eliminates security risks and group fights by integrating secure passport verification and automated bill splitting into one workflow. |
| **Group Chat (Chosen)** | **Kept.** Keeps group discussions directly tied to specific video booking cards with multiple features added such as trip ledger and voting polls to avoid the feature act like a standard social media application. |
| **Budget Sync (Chosen)** | **Kept.** Features a live budget header in the lobby displaying target budget, total nights, and remaining money with AI synthesis recommendations. |
| **Community Hub (Chosen)** | **Kept.** For user to discover and communicate with travelling community and gather knowledge and guidance. |
| **AI Ideation (Chosen)** | **Kept.** User can alter the algorithm to find travel place catered more to their likings. |

### 2.2 Ideation Boards

#### 2.2.1 Problem Tree Graphs
This tree breaks down the core causes of travel planning friction—such as unstructured social media content and fragmented communication—and traces their downstream impacts on trip abandonment and budget overruns.

<p align="center">
  <img src="assets/problem_tree_graph.svg" alt="2.2.1 Problem Tree Graphs" width="900" />
</p>

<details open>
<summary><b>Mermaid Diagram View</b></summary>

```mermaid
graph BT
    subgraph Problem ["Problem (Root Friction Drivers)"]
        direction TB
        P1["Social media doesn't properly<br/>display geo-data and pricing"]
        P2["Group plans stall due to<br/>tedious booking steps"]
        P3["Shared cost and budget limit<br/>needs to be tracked manually"]
        P4["Travel discussion without proper<br/>knowledge and well-crafted plan"]
    end

    subgraph Causes ["Causes (Core Bottleneck)"]
        C1["<b>Friction-Heavy Group Travel Planning</b>"]
    end

    subgraph Effects ["Effects (Downstream Impact)"]
        direction TB
        E1["Lose track of total spend<br/>without budget tracking"]
        E2["Passport / ID details and budget tracking<br/>are scattered across multiple apps"]
        E3["Manually sharing sensitive IDs<br/>across unsecure WhatsApp chats"]
    end

    P1 --> C1
    P2 --> C1
    P3 --> C1
    P4 --> C1

    C1 --> E1
    C1 --> E2
    C1 --> E3
```

</details>

#### 2.2.2 User Flow Diagram
This diagram maps the user's journey from vertical video discovery in the FYP lobby through AI contextual booking, secure document verification, and group management.

<p align="center">
  <img src="assets/user_flow_diagram.svg" alt="2.2.2 User Flow Diagram" width="850" />
</p>

<details open>
<summary><b>Mermaid Flowchart View</b></summary>

```mermaid
flowchart TD
    Start(["Start"]) --> Scroll["User scrolls feed"]
    Scroll --> RecPlaces["AI-recommendation places displayed"]
    RecPlaces --> TapContextual["User tap AI-Contextual View"]
    TapContextual --> DetailsDisp["Travel time, optimal visiting time,<br/>hotel recommendation displayed"]
    DetailsDisp --> Decision{"User wants<br/>to book?"}
    
    Decision -- No --> Scroll
    Decision -- Yes --> InputBooking["User input dates and amount of people"]
    
    InputBooking --> InputDocs["User proceeds and input necessary documentations"]
    InputDocs --> BookingConfirmed["Booking confirmed"]
    BookingConfirmed --> ViewDetails["User views bookings detail"]
    ViewDetails --> EndNode(["End"])
```

</details>

### 2.3 Mentor Consultation

| Date | Mentor | Feedback Received | What Was Changed |
| :--- | :--- | :--- | :--- |
| **8/9/2026** | **Faris Imran** | <ul><li>Make the app become more social friendly.</li><li>Nail down the scalability of the app.</li><li>Make sure the main focus of the app still align with the problem statement.</li></ul> | <ul><li>Multiple features added in group chats to aid user plan travels rather than just acts as a way for communication like voting system and split payment.</li><li>A community system was created as a way for people to create a travel plan together with an unfamiliar faces for the sake of travelling benefits.</li></ul> |

---

## 3. Creativity and Novelty

### 3.1 Originality
Individually, short-form video discovery, AI content parsing, and expense-splitting tools all exist. No mainstream product combines them into one continuous group-travel flow. Our app treats the FYP-style feed itself as the entry point to booking, rather than treating inspiration (TikTok/Instagram), search/booking (Skyscanner, Agoda), communication (WhatsApp), and expense tracking (spreadsheets or splitting apps) as four separate steps in four separate apps. The originality is in this synthesis: an agentic AI layer sits between passive video content and an actionable, bookable, financially-coordinated group plan, which is a genuinely new combination of existing ideas rather than an incremental feature added to an existing travel app.

### 3.2 Novel Features or Twists
The standout twist is the Contextual AI Booking Assistant: it extracts travel time, arrival estimates, hotel recommendations, and booking options directly from the unstructured video a user is already watching, so scrolling itself becomes the search step. This is reinforced by several other clever features working together:
- **Booking-card-anchored group chat**: Keeps discussion directly attached to the specific trip option being decided on, instead of scattered across a generic WhatsApp thread.
- **Unified document and expense ledger**: Replaces manually sharing passport photos over chat with secure, in-app document verification.
- **Live budget header in the lobby**: Displays target budget, total nights, and remaining money, with AI-generated spend recommendations rather than static totals.

Together these form a standout twist that defines the product: it is the first video-native app where watching, deciding, booking, verifying, and paying happen without leaving the feed.

### 3.3 Differentiation from Existing Solutions
TikTok and Instagram surface travel inspiration but stop there — the user must manually leave the app to search, price, and book. Skyscanner, Agoda, and Booking.com handle search and booking but assume the user already knows what they want and offer no discovery or group-coordination layer. WhatsApp plus a manual spreadsheet is the default group-planning stack today, but it is fragmented and insecure — passport and ID photos are routinely shared over unencrypted chat threads with no verification layer, and spend tracking depends on someone remembering to update a shared sheet. TripIt and similar itinerary organizers only take over after a booking is already made. Our app is different because it is the only one that spans the full chain — discovery, contextual booking, secure verification, and group finance — in a single continuous flow, removing both the "app-switching tax" of juggling four or five tools and the specific security exposure of sharing identity documents over consumer chat apps.

---

## 4. Impact

### 4.1 Understanding the Problem Context
Group travel planning is friction-heavy for identifiable, structural reasons rather than a single vague pain point. Social media, the channel where most trip inspiration now happens, does not surface geo-data or pricing, so inspiration and execution are disconnected. Group booking stalls because it requires tedious, repeated manual steps across members. Shared costs and budget limits have to be tracked manually with no dedicated tool. Travel discussions happen without a structured plan behind them. Left unaddressed, these causes produce real downstream harm: groups lose track of total spend, passport and ID details end up scattered across multiple apps or shared over unsecured WhatsApp chats (a genuine identity-fraud exposure, not just an inconvenience), and trips are abandoned or run over budget as a result. This is the specific chain our mentor consultation pushed us to sharpen — confirming the solution stays anchored to this problem statement rather than drifting into a generic travel app.

### 4.2 Target Group Alignment
The target group is not "everyone who travels" — it is groups of friends and young travelers who already discover destinations through short-form video feeds and plan trips collectively rather than through a travel agent or a single organizer. This group spends significant time on FYP-style feeds for inspiration but today has no direct path from "I saw this in a video" to "we booked it together, split the cost, and verified our documents." Every core feature speaks to a real behavior this group already has: scrolling for inspiration, coordinating in group chats, and splitting shared costs — rather than asking them to adopt an unfamiliar workflow.

### 4.3 Effectiveness of the Solution
- **Before**: A user watches a travel video, screenshots or notes it, leaves the app to search a separate booking engine, manually retypes the details into a group chat, individually shares passport scans over that same unsecured chat so members can book or apply for visas, and tracks who owes what by memory or a separate spreadsheet — a slow, five-to-six step process spread across four or five different apps, with a real security exposure along the way.
- **After**: The user watches the same video, taps the AI-contextual view, and instantly sees travel time, arrival estimates, and hotel recommendations; the group chat is already attached to that specific booking card; every member submits verification documents once through a secure ledger instead of over chat; and the live budget header updates automatically with remaining group funds and AI spend recommendations. Each step in the "before" chain maps directly onto a feature that removes it, so the improvement is not incremental convenience — it collapses a fragmented, insecure, multi-app process into one continuous, safer in-app flow.

### 4.4 Reach and Scalability
The initial cohort is group and student travelers, but the architecture scales in more than one direction. Mentor feedback specifically pushed us to nail down scalability, which led directly to adding a community layer where users can form travel plans with people outside their existing friend group — turning the product from a tool for trips already being planned into one that can generate new group trips on its own. The same AI-parsing layer that reads existing short-form travel video also means growth is a content and partnership problem, not a re-architecture problem: it extends naturally to solo travelers and families by adjusting the chat and ledger features, and to new regions and languages as creator content from those markets is already being produced elsewhere. Longer term, booking commissions and creator/affiliate partnerships give the discovery layer itself a monetizable, scalable growth path.

---

## Getting Started

This project is built using Flutter.

### Prerequisites
- Flutter SDK (3.x or later)
- Dart SDK
- Android Studio / Xcode / VS Code with Flutter extension

### Running the App
```bash
flutter pub get
flutter run
```

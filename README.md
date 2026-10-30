# SkillBytes – Practical Learning Platform

**Team-0510 | SLU MAD Team 8**

## 1. Project Overview

SkillBytes is a mobile application designed to help learners develop practical technology skills through short, structured learning sessions. The platform focuses on making technical education accessible, beginner-friendly, and easy to follow.

Learners can explore courses in areas such as coding, networking, and electronics, enroll in courses, complete short lessons, and track their learning progress.

## 2. Problem Statement

Many learners struggle to develop technical skills because courses can be lengthy, learning resources are scattered, and beginners often lack a clear learning path. SkillBytes aims to address these challenges through bite-sized lessons, organized course content, and visible progress tracking.

## 3. Project Objectives

- Provide clear learning paths for practical technology topics.
- Organize courses into tracks, modules, and short lessons.
- Enable learners to browse courses and enroll.
- Display learning progress and completed lessons.
- Provide administrators with a simple way to manage learning content.
- Develop a clean and user-friendly mobile application.

## 4. Target Users

**Learners:** Students, beginners, hobbyists, and working professionals who want to improve their technical skills.

**Administrators:** Instructors or content managers responsible for creating, organizing, and updating courses and modules.

## 5. Key Features

### Learner Features
- Login and registration screens
- Home dashboard
- Course listing and course details
- Course enrollment
- Short lessons and learning modules
- Learning progress tracking
- User profile

### Administrator Features
- Admin dashboard
- Add and edit courses
- Organize modules and lessons
- View course enrollment information

*These are planned features; implementation will take place in subsequent development phases.*

## 6. Technology Stack

- **Frontend:** Flutter
- **Programming Language:** Dart
- **Version Control:** Git and GitHub
- **Wireframing:** Figma or Whimsical
- **Initial Development:** Mock data
- **Possible Future Backend:** Firebase, subject to team agreement

## 7. Navigation Flow

### Learner
Login/Sign Up → Home → Course Listing → Course Details → Enroll → Lessons → Progress/Profile

### Administrator
Login → Admin Dashboard → Manage Courses → Add/Edit Course → Manage Modules and Lessons

## 8. Planned Wireframes

The initial low-fidelity wireframes will cover:

1. Login and Sign Up
2. Home Dashboard
3. Course Listing
4. Course Details

These wireframes will illustrate the basic layout, buttons, forms, and navigation before implementation begins.

## 9. Project Structure

```text
skillbytes_app/
├── android/
├── ios/
├── lib/
│   └── main.dart
├── test/
├── web/
├── windows/
├── linux/
├── macos/
├── docs/
├── wireframes/
├── README.md
├── pubspec.yaml
└── .gitignore
```

The `docs/` and `wireframes/` folders will contain the project proposal, user journeys, navigation documentation, and wireframe exports as they are added.

## 10. Team Members

- Philip Gbafa – Team Lead
- Saanchi Agarwal – Project Lead
- Rajkumar – Co Project Lead
- Thembinkosi Bhebe – Project Manager
- Sharnice Obeng – Project Scribe
- Muhammad Huzaifa Sajjad – Member
- Shafiya Anam – Member

## 11. Week 1 Deliverables

- App proposal document
- Learner and administrator user journeys
- Four low-fidelity wireframes
- GitHub repository with the initial Flutter project
- Project README and navigation flow

## 12. SkillBytes App - Week 2 Update🚀 What Changed This Week?
During Week 2, our team transitioned the app from initial wireframes to a fully functional, interactive 4-screen Flutter prototype with seamlessly integrated navigation.
1. Working UI Prototype
Core Screens: Built interactive Flutter UI layouts for four core screens—Login Screen, Home Screen, Program Listing Screen, and Program Details Screen.
Interactive Navigation: Implemented Navigator routing logic to enable smooth user movement across all four screens.
2. Branding & Theme Consistency
ThemeData Integration: Applied unified colors, typography, and styled widgets consistent with Excelerate’s brand guidelines.
3. Documentation & GitHub Repository
Project Documentation: Updated the README.md with a defined Project Vision and core objectives.
Visuals & Codebase: Documented repository progress with app walkthrough screenshots and structured commit history.
💻 Team Contributions
Philip Gbafa: Built the main Flutter app screens (Login, Home, Job Listing, Job Details) and implemented Navigator logic.
Muhammad Huzaifa Sajjad & Rajkumar A: Assisted with UI layout design, button styling, and unified ThemeData across all screens.
Saanchi Agarwal: Authored the Project Vision, Objectives, and updated the GitHub README.md documentation.
Shafiya Anam: Recorded the demo video walkthrough highlighting design choices and navigation flow.
Sharnice Obeng: Conducted end-to-end user flow testing and captured clean UI screenshots of all four screens.
Thembinkosi Bhebe: Created and managed the GitHub repository, formatted the README.md file, and handled final submission pushes.
🎯 Project Vision & ObjectivesProject Vision
SkillBytes is designed to bridge the gap between learning and professional growth by providing students with an intuitive, mobile-first gateway to explore programs, hone industry-relevant skills, and unlock career opportunities. By simplifying access to experiential learning opportunities, SkillBytes empowers learners to seamlessly navigate their professional journey with clarity and confidence.
Objectives
Seamless Navigation: Deliver a clean, structured, and user-friendly multi-screen interface to make discovering and reviewing programs effortless.
Consistent Visual Identity: Ensure dynamic design consistency across screens adhering to Excelerate’s brand identity and UI standards.
Interactive Prototype: Establish a robust Flutter code foundation prepared for real-time dynamic data integration and interactive features in upcoming iterations.

# 13. SkillBytes App - Week 3 Update

## 🚀 What Changed This Week?
During Week 3, our team transitioned the app from static hardcoded UI screens to a fully functional, interactive, and data-driven Flutter application.


### 1. API & JSON Data Integration
**Dynamic Content:** Program Listing and Program Details screens now fetch and display real data dynamically from a mock API / sample JSON data source instead of static text.
### 2. Forms & Validation
**Interactive Forms:** Implemented a working form (feedback/registration) allowing users to submit input.
**Input Validation:** Added validation rules ensuring fields cannot be left empty and email inputs adhere to proper formatting requirements.
### 3. Loading & Error Handling UX
**Loading States:** Integrated CircularProgressIndicator widgets to provide visual feedback during data fetching.
**Error Management:** Implemented try/catch error handling blocks with user-friendly error messages to ensure a smooth user experience.
---
## 💻 Team Contributions
**Philip Gbafa:** Fetched data from mock API/JSON and integrated Listing & Details screens.
**Rajkumar A:** Built the form UI (TextFormField) with robust input validation.
**Muhammad Huzaifa Sajjad:** Implemented reusable loading spinners, user-friendly
error states, retry actions, and empty-result handling for the data-driven
program listing and details screens.
**Saanchi Agarwal:** Updated the GitHub README.md documentation.
**Shafiya Anam & Sharnice Obeng:** Authored the comprehensive Changelog documenting connected data screens, form functionality, loading spinners, and error handling.
**Thembinkosi Bhebe:** Conducted final reviews and managed deliverables submission.

## 14. Repository

GitHub: https://github.com/RAJ322622/skillbytes_app

## 15. Future Enhancements

Potential future features include quizzes, certificates, offline lessons, reminder notifications, interactive electronics simulations, and community discussions.

## 16. Conclusion

SkillBytes aims to make practical technology learning easier to begin and maintain through short lessons, structured courses, and progress tracking. This repository provides the initial foundation for the team's collaborative development.

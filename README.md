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

# 12. SkillBytes App - Week 3 Update

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
**Muhammad H S:** Implemented loading spinners and error handling/states.
**Saanchi Agarwal:** Updated the GitHub README.md documentation.
**Shafiya Anam & Sharnice Obeng:** Authored the comprehensive Changelog documenting connected data screens, form functionality, loading spinners, and error handling.
**Thembinkosi Bhebe:** Conducted final reviews and managed deliverables submission.

## 13. Repository

GitHub: https://github.com/RAJ322622/skillbytes_app

## 14. Future Enhancements

Potential future features include quizzes, certificates, offline lessons, reminder notifications, interactive electronics simulations, and community discussions.

## 15. Conclusion

SkillBytes aims to make practical technology learning easier to begin and maintain through short lessons, structured courses, and progress tracking. This repository provides the initial foundation for the team's collaborative development.

# Task Instructions Template

Use this template to create task instruction files for parallel development.

## Overview
Brief description of the overall goal and context for this set of tasks.

**Example:**
```markdown
## Overview
Implement a comprehensive user profile management system with full CRUD operations, 
including frontend components, backend APIs, and database integration.
```

## Tasks

### Task 1: [Task Name]
- Specific deliverable 1
- Specific deliverable 2
- Specific deliverable 3

**Example:**
```markdown
### Task 1: User Profile Component
- Create UserProfile.tsx component with TypeScript interfaces
- Implement profile display with avatar, name, email, and bio
- Add edit mode with form validation
- Write unit tests for component functionality
```

### Task 2: [Task Name]
- Specific deliverable 1
- Specific deliverable 2
- Specific deliverable 3

### Task 3: [Task Name]
- Specific deliverable 1
- Specific deliverable 2
- Specific deliverable 3

## Guidelines for Creating Tasks

### 1. **Make Tasks Independent**
- Each task should be completable without waiting for others
- Avoid dependencies between tasks when possible
- If dependencies exist, note them clearly

### 2. **Be Specific**
- Include exact file names and locations
- Specify expected functionality
- Mention testing requirements
- Include any architectural decisions

### 3. **Balance Workload**
- Try to make tasks roughly equal in complexity
- Consider the skills required for each task
- Account for setup and testing time

### 4. **Include Context**
- Reference existing patterns in the codebase
- Mention related files or components
- Explain business logic if needed

## Task Complexity Examples

### Simple Task (1-2 hours)
```markdown
### Task 1: Add Loading Spinner
- Create LoadingSpinner.tsx component in common/
- Add three size variants: small, medium, large
- Export from common/index.ts
- Add Storybook story with all variants
```

### Medium Task (3-5 hours)
```markdown
### Task 2: User Authentication API
- Implement login/logout endpoints in authController.ts
- Add JWT token generation and validation
- Create middleware for protected routes
- Write integration tests for auth flow
- Update API documentation
```

### Complex Task (6+ hours)
```markdown
### Task 3: Dashboard Analytics System
- Design and implement analytics data models
- Create data aggregation service with caching
- Build interactive charts component with Chart.js
- Add real-time updates with WebSocket
- Implement role-based data filtering
- Create comprehensive test suite
```

## Example Complete Task File

```markdown
# Task Set: User Profile System

## Overview
Implement a complete user profile management system including profile display, 
editing capabilities, avatar upload, and activity history tracking.

## Tasks

### Task 1: Profile Display Component
- Create UserProfile.tsx in components/users/
- Implement ProfileAvatar component with image fallbacks
- Add ProfileInfo component with name, email, role display
- Create ProfileStats component showing user activity metrics
- Write unit tests for all components

### Task 2: Profile Editing System
- Create ProfileEditForm.tsx with form validation
- Implement avatar upload with image cropping
- Add ProfileSettings component for user preferences
- Create password change functionality
- Add success/error messaging system

### Task 3: Backend Profile API
- Implement profile CRUD endpoints in userController.ts
- Add image upload handling with file validation
- Create profile activity tracking service
- Add role-based permission checks
- Write API integration tests
```
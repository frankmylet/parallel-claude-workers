# Format Tasks Command

Converts unformatted task descriptions into properly structured parallel development task files.

## Usage

```bash
# Format unformatted task notes into structured task file
/format-tasks --input="raw-notes.txt" --output="formatted-tasks.md" --workers=4

# Interactive mode - input tasks directly
/format-tasks --interactive --workers=3

# Use with existing text file
/format-tasks --input="my-notes.md" --workers=4
```

## Arguments

- `--input=<file>` - Input file with unformatted task descriptions
- `--output=<file>` - Output formatted task file (default: parallel-tasks.md)
- `--workers=<number>` - Number of workers to optimize tasks for (default: 3)
- `--interactive` - Enter tasks interactively in Claude Code
- `--help` - Show detailed help

## Input Format

Your unformatted input can be:

**Simple list:**
```
- Create user login component
- Add user registration
- Build user dashboard
- Add password reset functionality
```

**Detailed notes:**
```
Need to implement user authentication system:
1. Login form with validation
2. Registration process with email verification  
3. Dashboard showing user info
4. Password reset via email
Also need to add:
- Input validation everywhere
- Error handling
- Loading states
- Tests for all components
```

**Mixed format:**
```
User Profile Features:
- Profile display component
- Edit profile form
- Avatar upload with cropping
- Activity history

API Requirements:
- CRUD endpoints for profile
- Image upload handling
- Activity tracking
- Validation and error responses
```

## Output Format

Creates a properly structured task file ready for parallel development:

```markdown
# Task Set: User Authentication System

## Overview
Implement comprehensive user authentication with login, registration, dashboard, and password reset functionality...

## Tasks

### Task 1: User Login Component
- Create LoginForm.tsx with validation
- Add error handling and loading states
- Implement secure authentication flow
- Write unit tests for login functionality

### Task 2: User Registration System
- Build RegistrationForm.tsx component
- Add email verification workflow
- Implement validation and error messaging
- Create registration API endpoints

### Task 3: User Dashboard
- Create Dashboard.tsx showing user info
- Add profile management features
- Implement activity history display
- Add responsive design and loading states
```

## Examples

```bash
# Quick format from notes file
/format-tasks --input="user-auth-notes.txt" --workers=3

# Interactive task entry
/format-tasks --interactive --workers=4

# Custom output file
/format-tasks --input="features.md" --output="auth-tasks.md" --workers=2
```

## Integration with Parallel Workflow

After formatting tasks, immediately launch parallel development:

```bash
# Format tasks then launch workers
/format-tasks --input="notes.txt" --output="tasks.md" --workers=4
/parallel-work --instructions=tasks.md --workers=4 --auto-launch
```

This streamlines the entire process from unformatted notes to running parallel workers!
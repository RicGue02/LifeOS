# Commit Policy for Repository

## 1. **Language**

- All commit messages must be in English.

## 2. **Commit Message Format**

- Use the following format:
    ```
    type: Brief description of the change
    ```
    
Where `type` can be:
- `feat`: A new feature
- `fix`: A bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, missing semi-colons, etc.)
- `refactor`: Code refactoring (neither fixes a bug nor adds a feature)
- `test`: Adding or updating tests
- `chore`: Routine tasks (build processes, dependencies updates, etc.)

## 3. **Commit Message Structure**

- **Line 1**: Type and brief description (max 50 characters).
- **Line 2**: Blank line.
- **Following lines**: Detailed description of the change if necessary (max 72 characters per line).

**Example:**

```
feat: Add user login functionality

Added the user login functionality including the frontend form and backend
authentication logic. Updated the user schema and added relevant tests.
```

## 4. **Commit Frequency and Grouping**

- Commits should be frequent, ideally after completing a specific functionality or page.
- Avoid making overly large commits; instead, break the work into manageable and logical parts.

## 5. **Detailed Commit Messages**

- The description should be clear and concise, indicating what was changed and why.
- Avoid generic commit messages like "fixed bugs" or "changed stuff".

## 6. **References to Tasks or Issues**

- Include references to task or issue numbers when relevant.
- Recommended format: `#1234` (where 1234 is the issue or task number).

**Example:**

```
fix: Correct login issue with expired tokens

The login issue was due to expired tokens not being handled properly. Updated
the token validation logic and added new tests to cover this case.

Refs: #5678
```
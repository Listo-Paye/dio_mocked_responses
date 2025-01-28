# Contributing to dio_mocked_responses

Thank you for considering contributing to `dio_mocked_responses`. This guide outlines the best practices and contribution process for the project.

## Guidelines
### Development Practices
1. **Test-Driven Development (TDD):**
    - TDD is a development practice where tests are written before the actual implementation of a feature or bug fix.
    - Steps to follow:
        1. Write a test that describes the desired behavior of the feature (it will initially fail since the feature is not yet implemented).
        2. Implement the minimal amount of code needed to make the test pass.
        3. Refactor the code for readability and maintainability, ensuring the test still passes.
    - Benefits:
        - Ensures code reliability and reduces bugs.
        - Encourages better design as developers think about the requirements before coding.

2. **Behavior-Driven Development (BDD):**
    - BDD extends TDD by focusing on the behavior of the system as described in natural language scenarios.
    - Scenarios are written in plain English and describe how a feature should behave under specific conditions.
    - Example BDD workflow:
        1. Define a scenario (e.g., "When a user logs in with valid credentials, they should see their dashboard").
        2. Translate the scenario into tests using tools or directly in your test files.
        3. Implement the feature to satisfy the scenario.
    - Benefits:
        - Improves collaboration between developers, testers, and stakeholders.
        - Makes requirements easier to understand and validate.

3. **SOLID Principles:**
    - SOLID is a set of five principles for writing clean and maintainable code:
        1. **Single Responsibility Principle (SRP):** A class should have one, and only one, reason to change. Each class should focus on a single responsibility.
        2. **Open/Closed Principle (OCP):** Classes should be open for extension but closed for modification. This allows adding new functionality without changing existing code.
        3. **Liskov Substitution Principle (LSP):** Subtypes should be substitutable for their base types without altering the program's behavior.
        4. **Interface Segregation Principle (ISP):** Interfaces should be specific to the needs of the client and not force unnecessary dependencies.
        5. **Dependency Inversion Principle (DIP):** High-level modules should not depend on low-level modules; both should depend on abstractions.
    - Benefits:
        - Encourages better design and separation of concerns.
        - Reduces coupling and improves code reusability.

### Commit Messages
- All commit messages must follow the [Angular commit message guidelines](https://gist.github.com/brianclements/841ea7bffdb01346392c):
    - **Format:** `<type>(<scope>): <description>`
    - **Types:**
        - `feat`: A new feature.
        - `fix`: A bug fix.
        - `docs`: Documentation changes.
        - `style`: Changes that do not affect code functionality (e.g., formatting).
        - `refactor`: Code changes that neither fix a bug nor add a feature.
        - `test`: Adding or modifying tests.
        - `chore`: Maintenance tasks or other changes that don't modify source files.

  Example:
  ```
  feat(mock-interceptor): add support for dynamic headers
  ```

### Code Style
- Follow the Dart and Flutter conventions for clean, consistent code.
- Use meaningful variable and method names.

## How to Contribute

### 1. Fork the Repository
- Clone your fork to your local machine.

### 2. Create a Branch
- Create a feature branch for your changes:
  ```bash
  git checkout -b feat/new-feature
  ```

### 3. Write Tests
- Add unit tests for your feature or bug fix in the appropriate test files.

### 4. Update the Example
- Modify the example in the `README` file to demonstrate the new functionality or behavior.

### 5. Follow Commit Guidelines
- Commit your changes with meaningful messages adhering to the Angular commit message format.

### 6. Open a Pull Request
- Push your changes to your fork and open a pull request (PR) to the `main` branch of the repository.
- Provide a clear description of the changes in the PR, including:
    - The problem the PR addresses.
    - The solution and how it works.
    - Any additional notes or considerations.

### 7. Review and Feedback
- Be open to feedback during the code review process. Address requested changes promptly.

## Code of Conduct
By contributing to this project, you agree to uphold the community standards and foster a welcoming and inclusive environment.

## Questions or Issues
If you have any questions or encounter any issues, feel free to open an issue on the repository. We value your contributions and feedback!

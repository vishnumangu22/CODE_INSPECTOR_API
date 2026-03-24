# 🚀 Code Inspector API

## 🧠 Overview

Code Inspector API is a **static code analysis system** built using Ruby on Rails.
It analyzes code changes between two Git branches and detects:

* Breaking changes (method removal, argument changes)
* Dependency issues across the repository
* Syntax errors using AST parsing
* Code optimization opportunities

The goal is to **identify risks before code is merged**, improving code quality and preventing production failures.

---

## 🔥 Key Features

* ✅ AST-based code analysis (using Parser & Ripper)
* ✅ Detects method addition, removal, rename, and argument changes
* ✅ Dependency impact analysis across entire repository
* ✅ Syntax error detection with detailed diagnostics
* ✅ Risk scoring system (low / medium / high)
* ✅ Optimization suggestions
* ✅ Handles dynamic method calls

---

## 🏗️ Architecture

```
Client Request
     ↓
CodeReviewsController
     ↓
CodeReviewService
     ↓
--------------------------------------------------
| GitRepositoryService (clone repo)              |
| StructuredDiffParserService (diff branches)   |
| AstParserService (extract methods)            |
| SyntaxAnalyzerService (syntax errors)         |
| DependencyImpactRule (cross-file analysis)    |
| AlternativeCodeService (optimization rules)   |
| ImpactAnalyzerService (risk scoring)          |
--------------------------------------------------
     ↓
Final JSON Response (Issues + Risk Level)
```

---

## ⚙️ How It Works

1. Accepts repository URL and branch names
2. Clones the repository locally
3. Compares base and feature branches
4. Extracts changed files and parses code using AST
5. Detects:

   * Method changes
   * Logic changes
   * Dependency issues
6. Runs syntax analysis
7. Suggests optimized code patterns
8. Calculates overall risk score

---

## 📡 API Usage

### 🔹 Endpoint

```
POST /api/v1/code_reviews
```

---

### 🔹 Request

```json
{
  "repo_url": "https://github.com/your-username/your-repo.git",
  "base_branch": "main",
  "compare_branch": "feature_branch"
}
```

---

### 🔹 Response

```json
{
  "status": "completed",
  "summary": {
    "risk_score": 10,
    "risk_level": "high"
  },
  "issues": {
    "impact": [
      {
        "type": "impact",
        "message": "Method removed",
        "file": "calculator.rb",
        "method": "calculate"
      }
    ],
    "dependency": [
      {
        "type": "dependency_impact",
        "message": "Method 'calculate' is removed but still used",
        "file": "order_service.rb"
      }
    ],
    "syntax": [],
    "suggestions": [
      {
        "type": "suggestion",
        "message": "Use find instead of select.first",
        "file": "user_service.rb",
        "original_code": "users.select { |u| u.active }.first",
        "suggested_code": "users.find { |u| u.active }"
      }
    ]
  }
}
```

---

## 🛠️ Tech Stack

* Ruby on Rails
* Parser Gem (AST parsing)
* Ripper (Ruby AST)
* Git CLI
* REST API

---

## 💡 Example Use Case

If a developer removes a method in one file but it is still used in another file:

```ruby
# Removed method
def calculate(price, discount)
end
```

```ruby
# Still used somewhere else
calc.calculate(100, 10)
```

➡️ The system detects this and flags it as a **high-risk dependency issue** before merge.

---

## ⚠️ Limitations

* Rule-based optimization may miss some pattern variations
* Limited handling of complex dynamic method calls
* Does not analyze runtime behavior (static analysis only)
* Currently supports Ruby only

---

## 🔮 Future Enhancements

* CI/CD integration (GitHub Actions)
* Multi-language support
* AI-based code analysis and suggestions
* Performance optimization using indexing
* GitHub PR comments integration

---

## 🎯 Why This Project?

In real-world development, breaking changes often go unnoticed until production.
This system helps developers:

* Catch errors early
* Prevent breaking changes
* Improve code quality automatically

---

## 🚀 Getting Started

```bash
# Clone the repository
git clone <your_repo_url>

# Install dependencies
bundle install

# Run server
rails server
```

---

## 👨‍💻 Author

**Vishnu**
Backend Developer | Ruby on Rails | Full Stack Developer

---

## ⭐ Contribution

Feel free to fork, improve, and raise pull requests!

---

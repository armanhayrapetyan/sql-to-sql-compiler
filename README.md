# SQL-to-SQL Compiler

A compiler that parses and transforms SQL queries (SELECT, FUNCTION, and TRIGGER forms) into modified or optimized SQL output. Built with **Flex** (lexer) and **Bison** (parser).

---

## 📌 Table of Contents
1. [Features](#-features)
2. [Prerequisites](#-prerequisites)
3. [Installation](#-installation)
4. [Usage](#-usage)
5. [Project Structure](#-project-structure)
6. [Makefile Details](#-makefile-details)
7. [Supported SQL Syntax](#-supported-sql-syntax)
8. [Examples](#-examples)
9. [Contributing](#-contributing)
10. [License](#-license)

---

## ✨ Features
- Lexical analysis using **Flex**.
- Syntax parsing using **Bison**.
- Supports three SQL forms: `SELECT`, `FUNCTION`, and `TRIGGER`.
- Clean separation of lexer/parser logic.
- Simple build system via Makefile.

---

## 🛠️ Prerequisites
Ensure you have these installed:
- **GCC** (`sudo apt install gcc` on Ubuntu)
- **Flex** (`sudo apt install flex`)
- **Bison** (`sudo apt install bison`)
- **Make** (usually pre-installed)

---

## 📥 Installation
1. Clone the repository:
   ```sh
   git clone https://github.com/your-username/sql-to-sql-compiler.git
   cd sql-to-sql-compiler

2. Build the project:
    make
    ./sql_parser  # Runs the compiler (input methods depend on your main.c)

3. Clean Build Artifacts
    make clean    # Removes generated files (lexers, parsers, binaries)

 Project Structure
        .
    ├── lexer/               # Flex lexer definitions (.l files)
    │   ├── select_form.l    # Lexer for SELECT queries
    │   ├── function_form.l  # Lexer for FUNCTION definitions
    │   └── trigger_form.l   # Lexer for TRIGGER definitions
    ├── parser/              # Bison parser definitions (.y files)
    │   ├── select_form.y    # Parser for SELECT
    │   ├── function_form.y  # Parser for FUNCTION
    │   └── trigger_form.y   # Parser for TRIGGER
    ├── main.c               # Driver code (entry point)
    ├── Makefile             # Build automation
    └── README.md            # This documentation
# Task manager

A task-management application demonstrating classes, structs, protocols, enums, computed properties, optional values, and explicit error handling.

## Repository

```text
task-manager/
├── README.md
├── .gitignore
├── no-ri.toml
├── source/
│   ├── main.no-ri
│   ├── models.no-ri
│   └── services.no-ri
└── tests/
    └── unit/
        └── task-test.no-ri
```

The repository follows the n-os source convention. Objects use CamelCase, methods use underscores, and compound filenames use dashes.

## Build and run

From the project root:

```sh
no-ri check
no-ri test
no-ri build
no-ri run source/main.no-ri
```

The manifest schema, test discovery, and assertion API are specifications in development.

[Application walkthrough](../../docs/examples/task-manager.md)
